## Infrastructure Architecture

![Infrastructure Architecture](/01-servers/07-sql-ha-cluster-design/01-postgressql/01-script-version/img/infra-design.png)

### Pre-Requisite

1. [Etcd](https://etcd.io/)
2. [Patroni](https://www.enterprisedb.com/docs/supported-open-source/patroni/)
3. [PostgreSQL](https://www.postgresql.org/)
4. [HAProxy](https://www.haproxy.org/)
5. [Prometheus](https://prometheus.io/)
6. [Grafana](https://grafana.com/)

## Instance Plan

| SL  | Name       | Hostname          | IP            | Role                               | RAM | Disk |
| --- | ---------- | ----------------- | ------------- | ---------------------------------- | --- | ---- |
| 1   | Etcd1      | etcd1-server      | 192.168.1.111 | etcd                               | 2GB | 2GB  |
| 2   | Etcd2      | etcd2-server      | 192.168.1.112 | etcd                               | 2GB | 2GB  |
| 3   | Etcd3      | etcd3-server      | 192.168.1.113 | etcd                               | 2GB | 2GB  |
| 4   | Postgres1  | postgres1-server  | 192.168.1.114 | PostgreSQL & Patroni               | 2GB | 2GB  |
| 5   | Postgres2  | postgres2-server  | 192.168.1.115 | PostgreSQL & Patroni               | 2GB | 2GB  |
| 6   | Postgres3  | postgres3-server  | 192.168.1.116 | PostgreSQL & Patroni               | 2GB | 2GB  |
| 7   | HAProxy    | haproxy-server    | 192.168.1.117 | Load Balancer for PostgreSQL       | 2GB | 2GB  |
| 8   | Prometheus | prometheus-server | 192.168.1.118 | Monitoring (Collects Metrics)      | 2GB | 2GB  |
| 9   | Grafana    | grafana-server    | 192.168.1.119 | Visualization (Queries Prometheus) | 2GB | 2GB  |

### Recommended - Production

| Component  | Disk     |
| ---------- | -------- |
| etcd       | 10–20 GB |
| PostgreSQL | 50+ GB   |
| Monitoring | 20+ GB   |

## Set hostname, IPs and append the entry to `/etc/hosts`

```bash
chmod +x scripts/set_hostnames_ip.sh
./scripts/set_hostnames_ip.sh
```

## Or

## SSH and set hostname

```bash
ssh jakir@192.168.1.111
sudo hostnamectl set-hostname etcd1-server
exit
hostnamectl status

ssh jakir@192.168.1.112
sudo hostnamectl set-hostname etcd2-server
exit
hostnamectl status

ssh jakir@192.168.1.113
sudo hostnamectl set-hostname etcd3-server
exit
hostnamectl status
```

```bash
ssh jakir@192.168.1.114
sudo hostnamectl set-hostname postgres1-server
exit
hostnamectl status

ssh jakir@192.168.1.115
sudo hostnamectl set-hostname postgres2-server
exit
hostnamectl status

ssh jakir@192.168.1.116
sudo hostnamectl set-hostname postgres3-server
exit
hostnamectl status
```

```bash
ssh jakir@192.168.1.117
sudo hostnamectl set-hostname haproxy-server
exit
hostnamectl status

ssh jakir@192.168.1.118
sudo hostnamectl set-hostname prometheus-server
exit
hostnamectl status

ssh jakir@192.168.1.119
sudo hostnamectl set-hostname grafana-server
exit
hostnamectl status
```

## On each node, add all IPs and hostnames to `/etc/hosts`

```bash
# 192.168.1.110 ansible-controller # If user ansible
192.168.1.111 etcd1-server
192.168.1.112 etcd2-server
192.168.1.113 etcd3-server
192.168.1.114 postgres1-server
192.168.1.115 postgres2-server
192.168.1.116 postgres3-server
192.168.1.117 haproxy-server
192.168.1.118 prometheus-server
192.168.1.119 grafana-server
```

## Or

## Use Vagrantfile

```bash
cd vagrant
vagrant up
vagrant status
vagrant ssh etcd1-server
vagrant destroy -f
```

## Install common packages

```bash
chmod +x scripts/install_common_tools.sh
./scripts/install_common_tools.sh
```

## Install Etcd on Etcd servers

```bash
chmod +x scripts/install_etcd.sh
./scripts/install_etcd.sh
```

## Configure etcd - Two ways

1. Create the main configuration file `/etc/default/etcd` - `Recommended`
2. Create a `systemd service` `/etc/systemd/system/etcd.service`

## Create the main configuration file `/etc/default/etcd`

```bash
sudo vi /etc/default/etcd
```

```bash
ETCD_NAME="etcd1"
ETCD_DATA_DIR="/var/lib/etcd"

# Peer URLs for cluster communication
ETCD_LISTEN_PEER_URLS="http://192.168.1.111:2380"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.1.111:2380"

# Client URLs for API access
ETCD_LISTEN_CLIENT_URLS="http://192.168.1.111:2379,http://127.0.0.1:2379"
ETCD_ADVERTISE_CLIENT_URLS="http://192.168.1.111:2379"

# Cluster configuration
ETCD_INITIAL_CLUSTER="etcd1=http://192.168.1.111:2380,etcd2=http://192.168.1.112:2380,etcd3=http://192.168.1.113:2380"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"

# Enable v2 API if needed
ETCD_ENABLE_V2="true"
```

```bash
sudo systemctl daemon-reload
sudo systemctl restart etcd
sudo systemctl enable etcd
sudo systemctl status etcd
```

> From anywhere access to any IPs

```bash
# Open Etcd client and peer ports
sudo ufw allow 2379/tcp
sudo ufw allow 2380/tcp
sudo ufw reload
```

> Restrict access to specific IPs

```bash
# Optional: restrict access to cluster instance only
sudo ufw allow from 192.168.1.111 to any port 2379
sudo ufw allow from 192.168.1.112 to any port 2379
sudo ufw allow from 192.168.1.113 to any port 2379

sudo ufw allow from 192.168.1.111 to any port 2380
sudo ufw allow from 192.168.1.112 to any port 2380
sudo ufw allow from 192.168.1.113 to any port 2380

sudo ufw reload
```

```bash
etcdctl member list
```

```bash
curl http://192.168.1.111:2380/members
curl http://192.168.1.111:2380/members
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl restart etcd
sudo systemctl status etcd
```

## [OR] Create a `systemd service` `/etc/systemd/system/etcd.service` on each `etcd` server

```bash
sudo vi /etc/systemd/system/etcd.service
```

```bash
[Unit]
Description=etcd key-value store
Documentation=https://etcd.io
After=network.target

[Service]
User=etcd
Type=notify
ExecStart=/usr/local/bin/etcd --config-file /etc/etcd/etcd.conf.yml
Restart=always
RestartSec=5s
LimitNOFILE=40000

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl restart etcd
sudo systemctl enable etcd
sudo systemctl status etcd
```

## Install PostgreSQL and Patroni on Postgres servers

```bash
sudo apt update
sudo apt install -y curl ca-certificates gnupg lsb-release
```

```bash
sudo apt install -y postgresql-common
sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
```

> Press Enter to continue, or Ctrl-C to abort.
> Press `Enter`

```bash
sudo apt update
sudo apt upgrade -y
```

```bash
sudo apt install -y net-tools
```

```bash
sudo apt install -y postgresql-18 postgresql-client-18 postgresql-contrib-18
```

```bash
psql --version
```

> Stop PostgreSQL (For Patroni setup later)

```bash
sudo systemctl stop postgresql
```

```bash
sudo ln -s /usr/lib/postgresql/18/bin/* /usr/sbin/
```

> Install Python (needed for Patroni)

```bash
sudo apt install -y python3 python3-
sudo apt install -y python3-testresources
sudo apt install -y --only-upgrade python3-setuptools
sudo apt install -y python3-psycopg2
```

```bash
sudo apt install -y patroni
sudo apt install -y etcd-client
```

```bash
patroni --version
```

```bash
# Must be applied all instance
sudo cp /etc/patroni/config.yml.in /etc/patroni/config.yml
sudo vi /etc/patroni/config.yml
```

```bash
# Must be applied all instance
sudo mkdir -p /data/patroni
sudo chown postgres:postgres /data/patroni
sudo chmod 700 /data/patroni
```

```bash
# Ensure WAL archive directory exists on all instance
sudo mkdir -p /backup/wal
sudo chown postgres:postgres /backup/wal
sudo chmod 700 /backup/wal
```

```bash
# Leader (postgres1-server, 192.168.1.114)
# All PostgreSQL instance should trust each other on port 5432
sudo ufw allow from 192.168.1.115/32 to any port 5432
sudo ufw allow from 192.168.1.116/32 to any port 5432
```

> This allows replicas (postgres2 & postgres3) to connect to the leader for streaming replication.

```bash
# Replica1 (postgres2-server, 192.168.1.115)
# All PostgreSQL instance should trust each other on port 5432
sudo ufw allow from 192.168.1.114/32 to any port 5432
sudo ufw allow from 192.168.1.116/32 to any port 5432
```

> Allows the leader and other replica to connect if needed (e.g., cascading replication, failover, or pg_basebackup).

```bash
# Replica2 (postgres3-server, 192.168.1.116)
# All PostgreSQL instance should trust each other on port 5432
sudo ufw allow from 192.168.1.114/32 to any port 5432
sudo ufw allow from 192.168.1.115/32 to any port 5432
```

> Same logic: allows leader and other replica to connect for replication and failover.

```bash
# Must be applied all replica instance
sudo vi /etc/systemd/system/patroni.service
```

```bash
# Must be applied all replica instance
[Unit]
Description=High availability PostgreSQL Cluster
After=network.target

[Service]
Type=simple
User=postgres
Group=postgres

# Start Patroni with your config file
ExecStart=/usr/bin/patroni /etc/patroni/config.yml

# Restart automatically if it fails
Restart=always
RestartSec=5

# Timeout before killing service
TimeoutSec=30

# Kill only main process
KillMode=process

[Install]
WantedBy=multi-user.target
```

```bash
# Must be applied all replica instance
sudo systemctl daemon-reload
sudo systemctl start patroni
sudo systemctl enable patroni
sudo systemctl status patroni
```

```bash
# Check patroni cluster status
patronictl -c /etc/patroni/config.yml list
```

```bash
# Should see
+ Cluster: postgres (7618246142072547256) --------+----+-------------+-----+------------+-----+
| Member    | Host          | Role    | State     | TL | Receive LSN | Lag | Replay LSN | Lag |
+-----------+---------------+---------+-----------+----+-------------+-----+------------+-----+
| postgres1 | 192.168.1.114 | Leader  | running   |  2 |             |     |            |     |
| postgres2 | 192.168.1.115 | Replica | streaming |  2 |   0/50300C0 |   0 |  0/50300C0 |   0 |
| postgres3 | 192.168.1.116 | Replica | streaming |  2 |   0/50300C0 |   0 |  0/50300C0 |   0 |
+-----------+---------------+---------+-----------+----+-------------+-----+------------+-----+
```

```bash
# Check leader
curl http://192.168.1.114:8008/primary

# Check replica
curl http://192.168.1.115:8008/replica
curl http://192.168.1.116:8008/replica
```

## HAProxy Server Configuration

```bash
sudo apt update
sudo apt upgrade -y
```

```bash
sudo apt install net-tools
sudo apt install -y haproxy
```

```bash
sudo vi /etc/haproxy/haproxy.cfg
```

```bash
# Validity check
sudo haproxy -c -f /etc/haproxy/haproxy.cfg
# Should see Configuration file is valid
```

```bash
sudo systemctl enable haproxy
sudo systemctl restart haproxy
sudo systemctl status haproxy
```

```bash
# On postgres1/2/3
sudo ufw allow from 192.168.1.117 to any port 8008   # Allow HAProxy only
```

```bash
# On HAProxy server (192.168.1.115)
sudo ufw allow 5000/tcp   # writes → leader
sudo ufw allow 5001/tcp   # reads → replicas
sudo ufw status
sudo ufw allow from 192.168.1.117 to any port 8008
```

```bash
sudo systemctl restart haproxy
sudo systemctl status haproxy
```

```bash
# Stats page
curl http://<haproxy_ip>:7000/stats
curl http://192.168.1.117:7000/stats
```

```bash
psql -h 192.168.1.114 -p 5000 postgres -W
psql -h 192.168.1.114 -U postgres -d postgres
# password is admin@123
```

```bash
CREATE TABLE Students(
  ID SERIAL PRIMARY KEY,
  Name VARCHAR(100) NOT NULL,
  Age INT NOT NULL
);
```

```bash
INSERT INTO Students(Name, Age) VALUES
('Alice', 20),
('Bob', 22),
('Charlie', 21);
```

```bash
select * from students;
```

```bash
# Check patroni cluster status
patronictl -c /etc/patroni/config.yml list
```

```bash
sudo systemctl status haproxy
```

```bash
# Test Failover
sudo systemctl stop patroni # leader node
```

```bash
# Check patroni cluster status
patronictl -c /etc/patroni/config.yml list
```

```bash
# PgBouncer Exporter Service
chmod +x scripts/pgbouncer_exporter.sh
./scripts/pgbouncer_exporter.sh
```

```bash
http://<POSTGRES_SERVER_IP>:9127/metrics
```

## Install `postgres_exporter` on all Postgres instance

```bash
chmod +x scripts/postgres_exporter.sh
./scripts/postgres_exporter.sh
```

```bash
sudo systemctl status prometheus
```

```bash
http://<PROMETHEUS_SERVER_IP>:9090
http://192.168.1.118:9090
```

## Install HAProxy exporter

```bash
chmod +x scripts/haproxy_exporter.sh
./scripts/haproxy_exporter.sh
```

```bash
sudo systemctl status grafana-server
```

```bash
http://<GRAFANA_SERVER_IP>:3000
http://192.168.1.118:3000 # admin/admin
```

> Add Prometheus as a data source

- Go to `Settings` → `Data Sources` → `Add data source` → `Prometheus`
- URL: `http://<PROMETHEUS_SERVER_IP>:9090`
- Save & Test
