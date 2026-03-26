sudo tee /etc/systemd/system/pgbouncer_exporter.service <<EOF
[Unit]
Description=PgBouncer Exporter for Prometheus
After=network.target

[Service]
User=postgres
Group=postgres
ExecStart=/usr/local/bin/pgbouncer_exporter \
    --pgbouncer.connection-string "postgres://admin:password@127.0.0.1:6432/pgbouncer" \
    --web.listen-address ":9127"
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable pgbouncer_exporter
sudo systemctl start pgbouncer_exporter
sudo systemctl status pgbouncer_exporter
