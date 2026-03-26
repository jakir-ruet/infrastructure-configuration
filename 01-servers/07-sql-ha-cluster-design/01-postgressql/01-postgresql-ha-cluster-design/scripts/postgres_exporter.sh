# On postgres1/2/3
sudo useradd -rs /bin/false postgres_exporter

# Download latest release
wget https://github.com/prometheus-community/postgres_exporter/releases/download/v0.11.0/postgres_exporter-0.11.0.linux-amd64.tar.gz
tar xvfz postgres_exporter-0.11.0.linux-amd64.tar.gz
sudo mv postgres_exporter-0.11.0.linux-amd64/postgres_exporter /usr/local/bin/

# Setup environment variables
cat <<EOF | sudo tee /etc/systemd/system/postgres_exporter.service
[Unit]
Description=Prometheus PostgreSQL Exporter
After=network.target

[Service]
User=postgres_exporter
Environment=DATA_SOURCE_NAME="postgresql://replicator:admin@localhost:5432/postgres?sslmode=disable"
ExecStart=/usr/local/bin/postgres_exporter

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now postgres_exporter
