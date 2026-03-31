## Welcome to nginx server in details

### What is a Proxy Server?
A proxy server acts as an intermediary between a client (user) and a destination server. It forwards requests from the client to the destination server and returns the server’s response to the client.

### What is a Reverse Proxy Server?
A reverse proxy acts as an intermediary between the client and one or more backend servers. It forwards client requests to the appropriate backend server and then sends the backend server's response to the client.

### What is Load Balancing?
Load balancing is the process of distributing incoming network traffic across multiple servers to ensure no single server becomes overwhelmed with requests. NGINX can distribute the load using various algorithms, including Round Robin, Least Connections, and IP Hash.

### Install NGINX

```bash
sudo apt update
sudo apt install nginx
```

### Configure NGINX as a Proxy Server

```bash
sudo nano /etc/nginx/sites-available/default
```

```json
server {
    listen 80;

    location / {
        proxy_pass http://your_upstream_server_address;  # Forward requests to upstream server
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
sudo systemctl reload nginx
```

### NGINX as a Reverse Proxy Server

```json
server {
    listen 80;

    location / {
        proxy_pass http://backend1.com;   # Forward traffic to a backend server
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Add Multiple Backend Servers (If Need)

```json
upstream backend {
    server backend1.com;
    server backend2.com;
}

server {
    listen 80;

    location / {
        proxy_pass http://backend;  # Use the upstream defined earlier
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Configure Load Balancing in NGINX - Round Robin (Default)

```json
upstream backend {
    server backend1.com;
    server backend2.com;
    server backend3.com;
}

server {
    listen 80;

    location / {
        proxy_pass http://backend;  # Distribute traffic equally across backend servers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Configure Load Balancing in NGINX - Least Connections

```json
upstream backend {
    least_conn;  # Use Least Connections method
    server backend1.com;
    server backend2.com;
    server backend3.com;
}

server {
    listen 80;

    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### IP Hash Load Balancing

```json
upstream backend {
    ip_hash;  # Use IP Hash method
    server backend1.com;
    server backend2.com;
    server backend3.com;
}

server {
    listen 80;

    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Advanced Load Balancing - Server Weighting

```json
upstream backend {
    server backend1.com weight=3;  # This server will get 3 times more traffic
    server backend2.com weight=1;
}
```

### NGINX as a SSL/TLS Termination Proxy

```json
server {
    listen 443 ssl;
    server_name yourdomain.com;

    ssl_certificate /etc/nginx/ssl/yourdomain.crt;
    ssl_certificate_key /etc/nginx/ssl/yourdomain.key;

    location / {
        proxy_pass http://backend;  # Send decrypted requests to backend
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Enable HTTP/2 (Optional but Recommended)

```json
server {
    listen 443 ssl http2;
    server_name yourdomain.com;

    ssl_certificate /etc/nginx/ssl/yourdomain.crt;
    ssl_certificate_key /etc/nginx/ssl/yourdomain.key;

    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Monitoring and Logging

You can also monitor NGINX performance using tools like `Grafana`, `Prometheus`, and `nginx-module-vts`.

```json
http {
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log;
}
```

### Connection Limits

```json
location / {
    proxy_cache my_cache;
    proxy_cache_valid 200 1h;
    proxy_cache_valid 404 1m;
}
```

### Give ownership and test manually

```bash
sudo chown -R jakir:jakir /home/jakir/express-app
node app.js
```

### Create systemd Service File

```bash
sudo vi /etc/systemd/system/express-app.service
```

```bash
[Unit]
Description=Node.js App run by jakir
After=network.target

[Service]
Environment=PORT=3000
Type=simple
User=jakir
Group=jakir
WorkingDirectory=/home/jakir/express-app
ExecStart=/usr/bin/node /home/jakir/express-app/app.js
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

### Enable and Start the Service

```bash
sudo systemctl daemon-reload
sudo systemctl enable express-app
sudo systemctl start express-app
```

### Check status and logs

```bash
sudo systemctl status express-app
sudo journalctl -u express-app -f
```

### Setup Nginx Reverse Proxy (Optional)

```bash
sudo vi /etc/nginx/sites-available/express-app
```

```json
server {
    listen 80;
    server_name your_server_ip_or_domain;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### Enable site and reload Nginx

```bash
sudo ln -s /etc/nginx/sites-available/express-app /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

