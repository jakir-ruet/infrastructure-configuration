## Welcome Apache server install and configuration

### Prerequisites – enable required modules

```bash
sudo a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests proxy_hcheck headers ssl
sudo systemctl restart apache2
```

### Create a minimal backend app to test - See in `flask-app`

### Apache config: reverse proxy requests to backend

```bash
<VirtualHost *:80>
  ServerName example.com
  ProxyRequests Off
  ProxyPreserveHost On

  ProxyPass "/" "http://127.0.0.1:5000/"
  ProxyPassReverse "/" "http://127.0.0.1:5000/"

  # Optional security headers
  Header always set X-Frame-Options DENY
  Header always set X-Content-Type-Options nosniff
</VirtualHost>
```

```bash
sudo a2ensite reverse.conf
sudo systemctl reload apache2
```

```bash
http://example.com:5000/
```

### Use HTTPS at front-end & pass X‑Forwarded‑Proto header

```bash
<VirtualHost *:443>
  ServerName example.com
  SSLEngine On
  SSLCertificateFile /path/to/fullchain.pem
  SSLCertificateKeyFile /path/to/privkey.pem

  SSLProxyEngine On
  ProxyRequests Off
  ProxyPreserveHost On
  RequestHeader set X-Forwarded-Proto "https"

  ProxyPass "/" "http://127.0.0.1:5000/"
  ProxyPassReverse "/" "http://127.0.0.1:5000/"
</VirtualHost>
```

### Secure with SSL (Optional)

```bash
sudo apt install certbot python3-certbot-apache
sudo certbot --apache
```

```bash
VirtualHost *:443>
  ServerName example.com

  SSLEngine On
  SSLCertificateFile /etc/letsencrypt/live/example.com/fullchain.pem
  SSLCertificateKeyFile /etc/letsencrypt/live/example.com/privkey.pem

  SSLProxyEngine On
  ProxyPreserveHost On
  RequestHeader set X-Forwarded-Proto "https"

  ProxyPass "/" "balancer://mycluster/"
  ProxyPassReverse "/" "balancer://mycluster/"
</VirtualHost>
```

### Load‑balancing across multiple backend servers (Add a second backend instance)

```bash
<Proxy "balancer://mycluster">
  BalancerMember "http://127.0.0.1:5000" route=backend1 loadfactor=1
  BalancerMember "http://127.0.0.1:5001" route=backend2 loadfactor=1
  ProxySet lbmethod=byrequests stickysession=JSESSIONID
</Proxy>

<VirtualHost *:80>
  ServerName example.com
  ProxyPreserveHost On

  ProxyPass "/" "balancer://mycluster/"
  ProxyPassReverse "/" "balancer://mycluster/"
</VirtualHost>
```

### Health checks & failover (using mod_proxy_hcheck)

```bash
<Proxy "balancer://hc">
  BalancerMember "http://127.0.0.1:5000" hcmethod=GET hcuri="/health" hcinterval=10 hcthreshold=3
  BalancerMember "http://127.0.0.1:5001" hcmethod=GET hcuri="/health" hcinterval=10 hcthreshold=3
  ProxySet lbmethod=byrequests
</Proxy>
```

### Monitoring & managing the balancer

```bash
<Location "/balancer-manager">
  SetHandler balancer-manager
  Require host localhost
</Location>
```

```bash
http://example.com/balancer-manager
```
