# On Prometheus server or HAProxy node
wget https://github.com/prometheus/haproxy_exporter/releases/download/v0.14.0/haproxy_exporter-0.14.0.linux-amd64.tar.gz
tar xvf haproxy_exporter-0.14.0.linux-amd64.tar.gz
sudo mv haproxy_exporter-0.14.0.linux-amd64/haproxy_exporter /usr/local/bin/

sudo tee /etc/systemd/system/haproxy_exporter.service <<EOF
[Unit]
Description=Prometheus HAProxy Exporter
After=network.target

[Service]
User=haproxy
ExecStart=/usr/local/bin/haproxy_exporter -haproxy.scrape-uri="http://localhost:7000/stats;csv"
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now haproxy_exporter
