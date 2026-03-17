## Welcome to High Avalability PostGreSQL Server

This repository contains the configuration files and scripts to set up a high availability PostgreSQL server using Patroni. The setup includes three nodes: one primary and two replicas, ensuring data redundancy and failover capabilities.

### Pre-Requisite

1. [Etcd](https://etcd.io/)
2. [Patroni](https://www.enterprisedb.com/docs/supported-open-source/patroni/)
3. [PostgreSQL](https://www.postgresql.org/)
4. [HAProxy](https://www.haproxy.org/)

### Node layout

| SL  | Name      | Hostname         | IP            | Role                 | RAM | Disk |
| --- | --------- | ---------------- | ------------- | -------------------- | --- | ---- |
| 1   | Etcd      | etcd-server      | 192.168.1.111 | etcd                 | 2GM | 2GB  |
| 2   | Postgres1 | postgres1-server | 192.168.1.112 | PostgreSQL & Patroni | 2GB | 2GB  |
| 3   | Postgres2 | postgres2-server | 192.168.1.113 | PostgreSQL & Patroni | 2GB | 2GB  |
| 4   | Postgres3 | postgres3-server | 192.168.1.114 | PostgreSQL & Patroni | 2GB | 2GB  |
| 5   | HAProxy   | haproxy-server   | 192.168.1.115 | HAProxy              | 2GB | 2GB  |

### Set Hostname

```bash
ssh jakir@192.168.1.111
sudo hostnamectl set-hostname etcd-server
```

```bash
ssh jakir@192.168.1.112
sudo hostnamectl set-hostname postgres1-server
```

```bash
ssh jakir@192.168.1.113
sudo hostnamectl set-hostname postgres2-server
```

```bash
ssh jakir@192.168.1.114
sudo hostnamectl set-hostname postgres3-server
```

```bash
ssh jakir@192.168.1.115
sudo hostnamectl set-hostname haproxy-server
```

### `Hosts` Setup in `/etc/hosts`

```bash
192.168.1.111 etcd-server
192.168.1.112 postgres1-server
192.168.1.113 postgres2-server
192.168.1.114 postgres3-server
192.168.1.115 haproxy-server
```

### Update & Upgade each Instance

```bash
sudo apt update
sudo apt upgrade
```

### Etcd Server Configuration

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget tar
```

```bash
sudo apt install etcd-server -y
sudo apt install etcd-client
```

```bash
etcd --version
etcdctl version
```

#### Configure etcd - Two ways

1. Create the main configuration file `/etc/default/etcd`
2. Create a `systemd service` `/etc/systemd/system/etcd.service`

#### Create the main configuration file `/etc/default/etcd`

```bash
sudo vi /etc/default/etcd
```

```bash
ETCD_NAME="etcd-server"
ETCD_DATA_DIR="/var/lib/etcd"
ETCD_LISTEN_PEER_URLS="http://192.168.1.111:2380"
ETCD_LISTEN_CLIENT_URLS="http://192.168.1.111:2379,http://127.0.0.1:2379"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.1.111:2380"
ETCD_ADVERTISE_CLIENT_URLS="http://192.168.1.111:2379"
ETCD_INITIAL_CLUSTER="etcd-server=http://192.168.1.111:2380"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_ENABLE_V2="true"
```

> For `multi-node clusters`, replace IPs accordingly and list all nodes in initial-cluster.

```bash
sudo systemctl restart etcd
sudo systemctl enable etcd
sudo systemctl status etcd
```

> From anywhere access to any IPs

```bash
sudo ufw allow 2379/tcp
sudo ufw allow 2380/tcp
sudo ufw reload
```

> Restrict access to specific IPs

```bash
# Only allow 192.168.1.112 and 192.168.1.113
sudo ufw allow from 192.168.1.112 to any port 2379
sudo ufw allow from 192.168.1.113 to any port 2379
sudo ufw allow from 192.168.1.112 to any port 2380
sudo ufw allow from 192.168.1.113 to any port 2380
sudo ufw reload
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

#### [OR] Create a `systemd service` `/etc/systemd/system/etcd.service`

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

### PostgreSQL & Patroni Server Configuration

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
# Must be applied all replica instance
sudo cp /etc/patroni/config.yml.in /etc/patroni/config.yml
sudo vi /etc/patroni/config.yml
```

```bash
# Must be applied all replica instance
sudo mkdir -p /data/patroni
sudo chown postgres:postgres /data/patroni
sudo chmod 700 /data/patroni
```

```bash
# Leader (postgres1-server, 192.168.1.112)
sudo ufw allow from 192.168.1.113/32 to any port 5432
sudo ufw allow from 192.168.1.114/32 to any port 5432
```

> This allows replicas (postgres2 & postgres3) to connect to the leader for streaming replication.

```bash
# Replica1 (postgres2-server, 192.168.1.113)
sudo ufw allow from 192.168.1.112/32 to any port 5432
sudo ufw allow from 192.168.1.114/32 to any port 5432
```

> Allows the leader and other replica to connect if needed (e.g., cascading replication, failover, or pg_basebackup).

```bash
# Replica2 (postgres3-server, 192.168.1.114)
sudo ufw allow from 192.168.1.112/32 to any port 5432
sudo ufw allow from 192.168.1.113/32 to any port 5432
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
| postgres1 | 192.168.1.112 | Replica | streaming |  2 |   0/50300C0 |   0 |  0/50300C0 |   0 |
| postgres2 | 192.168.1.113 | Leader  | running   |  2 |             |     |            |     |
| postgres3 | 192.168.1.114 | Replica | streaming |  2 |   0/50300C0 |   0 |  0/50300C0 |   0 |
+-----------+---------------+---------+-----------+----+-------------+-----+------------+-----+
```

```bash
# Check leader
curl http://192.168.1.112:8008/primary

# Check replica
curl http://192.168.1.113:8008/replica
curl http://192.168.1.114:8008/replica
```

### HAProxy Server Configuration

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
sudo ufw allow from 192.168.1.115 to any port 8008   # HAProxy IP
```

```bash
# On HAProxy server (192.168.1.115)
sudo ufw allow 5000/tcp   # writes → leader
sudo ufw allow 5001/tcp   # reads → replicas
sudo ufw status
sudo ufw allow from 192.168.1.115 to any port 8008
```

```bash
sudo systemctl restart haproxy
sudo systemctl status haproxy
```

```bash
# Stats page
curl http://<haproxy_ip>:7000/stats
curl http://192.168.1.115:7000/stats
```

```bash
psql -h 192.168.1.115 -p 5000 postgres -W
psql -h 192.168.1.112 -U postgres -d postgres
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
