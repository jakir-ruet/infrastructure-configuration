## Architecture

![Architecture](/08-ha-proxy-server/img/haproxy-architecture.png)

## Network & IPs

| Host              | Component             | IP Address    |
| ----------------- | --------------------- | ------------- |
| haproxy-server    | HAProxy Load Balancer | 192.168.1.116 |
| web1-server       | Web Server 1          | 192.168.1.117 |
| web2-server       | Web Server 2          | 192.168.1.118 |
| web3-server       | Web Server 3          | 192.168.1.119 |
| prometheus-server | Prometheus            | 192.168.1.120 |
| grafana-server    | Grafana               | 192.168.1.121 |

> **Client's:** Any IP in LAN

```bash
ha-cluster/
├── haproxy/
│   ├── conf/                 # HAProxy configuration
│   │   └── haproxy.cfg
│   ├── certs/                # SSL certificates for HTTPS
│   │   └── haproxy.pem
│   ├── logs/                 # HAProxy logs
│   └── scripts/              # Optional: reload or backup scripts
│
├── webservers/
│   ├── web1/
│   │   ├── html/             # Static website files
│   │   │   └── index.html
│   │   └── logs/             # Optional logs if using simple HTTP server
│   │       └── access.log
│   │
│   ├── web2/
│   │   ├── html/
│   │   │   └── index.html
│   │   └── logs/
│   │       └── access.log
│   │
│   └── web3/
│       ├── html/
│       │   └── index.html
│       └── logs/
│           └── access.log
│
├── monitoring/
│   ├── prometheus/
│   │   ├── conf/             # prometheus.yml
│   │   ├── data/             # TSDB storage
│   │   └── logs/
│   │
│   └── grafana/
│       ├── conf/             # grafana.ini
│       ├── data/             # dashboards, DB, plugins
│       └── logs/
```

## SSH and set hostname

```bash
ssh jakir@192.168.1.116
sudo hostnamectl set-hostname haproxy-server
exit
hostnamectl status
```

```bash
ssh jakir@192.168.1.117
sudo hostnamectl set-hostname web1-server
exit
hostnamectl status

ssh jakir@192.168.1.118
sudo hostnamectl set-hostname web2-server
exit
hostnamectl status

ssh jakir@192.168.1.119
sudo hostnamectl set-hostname web3-server
exit
hostnamectl status
```

```bash
ssh jakir@192.168.1.120
sudo hostnamectl set-hostname prometheus-server
exit
hostnamectl status
```

```bash
ssh jakir@192.168.1.121
sudo hostnamectl set-hostname grafana-server
exit
hostnamectl status
```

## Put these into `/etc/hosts`

```bash
# Keep these each other in all Node
# 192.168.1.110 ansible-controller # If use Ansible
192.168.1.116 haproxy-server
192.168.1.117 web1-server
192.168.1.118 web2-server
192.168.1.119 web3-server
192.168.1.120 prometheus-server
192.168.1.121 grafana-server
```

## Common Install

```bash
# On all Node
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget vim git ufw net-tools software-properties-common
```

## Enable firewall (optional but recommended)

```bash
# On web1, web2 & web3 Node
sudo ufw allow OpenSSH
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable
sudo ufw status
```

## Install Web Servers

```bash
# On web1, web2 & web3 Node
sudo apt install -y nginx
sudo systemctl enable nginx --now
sudo ufw allow 'Nginx Full'
```

```bash
ssh jakir@192.168.1.117
echo "<h1>Welcome to Web1</h1>" | sudo tee /var/www/html/index.html
curl http://localhost
```

```bash
ssh jakir@192.168.1.118
echo "<h1>Welcome to Web2</h1>" | sudo tee /var/www/html/index.html
curl http://localhost
```

```bash
ssh jakir@192.168.1.119
echo "<h1>Welcome to Web3</h1>" | sudo tee /var/www/html/index.html
curl http://localhost
```

## Install HAProxy Load Balancer

```bash
# On HAProxy server (192.168.1.116)
sudo apt install -y haproxy
sudo systemctl enable haproxy --now
```

### Edit `/etc/haproxy/haproxy.cfg`

```bash
global
    log /dev/log local0
    log /dev/log local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

defaults
    log     global
    mode    http
    option  httplog
    option  dontlognull
    timeout connect 5000
    timeout client  50000
    timeout server  50000
    errorfile 400 /etc/haproxy/errors/400.http
    errorfile 403 /etc/haproxy/errors/403.http
    errorfile 408 /etc/haproxy/errors/408.http
    errorfile 500 /etc/haproxy/errors/500.http
    errorfile 502 /etc/haproxy/errors/502.http
    errorfile 503 /etc/haproxy/errors/503.http
    errorfile 504 /etc/haproxy/errors/504.http

frontend http_front
    bind *:80
    default_backend web_servers

frontend https_front
    bind *:443 ssl crt /etc/ssl/certs/haproxy.pem
    default_backend web_servers

backend web_servers
    balance roundrobin
    server web1-server 192.168.1.117:80 check
    server web2-server 192.168.1.118:80 check
    server web3-server 192.168.1.119:80 check
```

> **HTTPS Certificate:** Combine `cert.pem` + `key.pem` into `/etc/ssl/certs/haproxy.pem`

### Test and restart HAProxy

```bash
sudo haproxy -f /etc/haproxy/haproxy.cfg -c  # check config
sudo systemctl restart haproxy
```

### Test from client

```bash
curl http://192.168.1.116
curl -k https://192.168.1.116
```

### Enable HAProxy Metrics Exporter - `Optional`

```bash
# Install haproxy_exporter on HAProxy server
wget https://github.com/prometheus/haproxy_exporter/releases/download/v0.16.0/haproxy_exporter-0.16.0.linux-amd64.tar.gz
tar xvf haproxy_exporter-0.16.0.linux-amd64.tar.gz
sudo mv haproxy_exporter /usr/local/bin/
```

### Run as systemd service

```bash
[Unit]
Description=HAProxy Exporter
After=network.target

[Service]
ExecStart=/usr/local/bin/haproxy_exporter --haproxy.scrape-uri="http://localhost:8404/;csv"
Restart=always

[Install]
WantedBy=multi-user.target
```

### Add target to Prometheus

```bash
  - job_name: 'haproxy_exporter'
    static_configs:
      - targets: ['192.168.1.116:9101']
```

## Install Prometheus Monitoring

```bash
# On Prometheus server (192.168.1.120)
sudo useradd --no-create-home --shell /bin/false prometheus
sudo mkdir /etc/prometheus /var/lib/prometheus
sudo chown prometheus:prometheus /etc/prometheus /var/lib/prometheus
```

```bash
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v2.52.0/prometheus-2.52.0.linux-amd64.tar.gz
tar xvf prometheus-2.52.0.linux-amd64.tar.gz
sudo cp prometheus-2.52.0.linux-amd64/prometheus /usr/local/bin/
sudo cp prometheus-2.52.0.linux-amd64/promtool /usr/local/bin/
sudo cp -r prometheus-2.52.0.linux-amd64/consoles /etc/prometheus/
sudo cp -r prometheus-2.52.0.linux-amd64/console_libraries /etc/prometheus/
```

### Create Prometheus config `/etc/prometheus/prometheus.yml`

```bash
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'web_servers'
    static_configs:
      - targets: ['192.168.1.117:80','192.168.1.118:80','192.168.1.119:80']

  - job_name: 'haproxy'
    metrics_path: /haproxy?stats;format=prometheus
    static_configs:
      - targets: ['192.168.1.116:8404']
```

### Create systemd service

```bash
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
  --config.file /etc/prometheus/prometheus.yml \
  --storage.tsdb.path /var/lib/prometheus/

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now prometheus
```

> **Access Prometheus:** <http://192.168.1.120:9090>

## Install Grafana

```bash
# On Grafana server (192.168.1.121)
sudo apt install -y apt-transport-https software-properties-common wget
wget -q -O - https://packages.grafana.com/gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/grafana.gpg
echo "deb [signed-by=/usr/share/keyrings/grafana.gpg] https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
sudo apt update
sudo apt install -y grafana
sudo systemctl enable grafana-server --now
```

> **Access Grafana:** `http://192.168.1.121:3000` default `admin`/`admin`
