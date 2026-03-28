## Lab Architecture - Recommended

## Pre-Requisite

[Etcd](https://etcd.io/)

## Node Plan

| SL  | Name  | Hostname     | IP            | Role | RAM | Disk     |
| --- | ----- | ------------ | ------------- | ---- | --- | -------- |
| 1   | Etcd1 | etcd1-server | 192.168.1.111 | etcd | 2GB | 10–20 GB |
| 2   | Etcd2 | etcd2-server | 192.168.1.112 | etcd | 2GB | 10–20 GB |
| 3   | Etcd3 | etcd3-server | 192.168.1.113 | etcd | 2GB | 10–20 GB |

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

## Put these IP & Hostname to `/etc/hosts` - `All Node`

```bash
# Keep these each other in all Node
# 192.168.1.110 ansible-controller # If use Ansible
192.168.1.111 etcd1-server
192.168.1.112 etcd2-server
192.168.1.113 etcd3-server
```

## Put these IP & Hostname to `/etc/hosts` - `Ansible Controller`

```bash
# Keep these only Ansible Controller
192.168.1.110 ansible-controller
192.168.1.111 etcd1-server
192.168.1.112 etcd2-server
192.168.1.113 etcd3-server
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

## Generate Keygen - `Local/Ansible Controller` Machine

```bash
ssh-keygen -t ed25519 -C "jakir.ruet.bd@gmail.com"  # Or
ssh-keygen
```

```bash
ssh-copy-id user@192.168.1.111
ssh-copy-id user@192.168.1.112
ssh-copy-id user@192.168.1.113
```

```bash
ssh jakir@192.168.1.111 # Password ask first time
ssh jakir@192.168.1.112 # Password ask first time
ssh jakir@192.168.1.113 # Password ask first time
```

## Install dependencies

```bash
sudo apt update
sudo apt install -y curl wget net-tools
```

## Install etcd (All Nodes)

### For Etcd Machine

```bash
# For amd64 machine
ETCD_VERSION="v3.5.9"
wget https://github.com/etcd-io/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz
```

```bash
# For arm64 machine
ETCD_VERSION="v3.5.9"
wget https://github.com/etcd-io/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-arm64.tar.gz
```

```bash
tar -xvf etcd-v3.5.9-linux-arm64.tar.gz
cd etcd-v3.5.9-linux-arm6
sudo mv etcd etcdctl /usr/local/bin/
```

```bash
tar -xvf etcd-${ETCD_VERSION}-linux-amd64.tar.gz
cd etcd-${ETCD_VERSION}-linux-amd64
sudo mv etcd etcdctl /usr/local/bin/
```

```bash
etcd --version
etcdctl version
```

```bash
# Create Data Directory
sudo mkdir -p /var/lib/etcd
```

## Create systemd Service

```bash
sudo vi /etc/systemd/system/etcd.service
```

### For local host

```bash
[Unit]
Description=etcd key-value store
After=network.target

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd \
  --name default \
  --data-dir /var/lib/etcd \
  --listen-client-urls http://0.0.0.0:2379 \
  --advertise-client-urls http://0.0.0.0:2379

Restart=always
RestartSec=5
LimitNOFILE=40000

[Install]
WantedBy=multi-user.target
```

### For etcd1-server

```ini
[Unit]
Description=etcd
After=network.target

[Service]
ExecStart=/usr/local/bin/etcd \
  --name etcd1-server \
  --data-dir /var/lib/etcd \
  --initial-advertise-peer-urls http://192.168.1.111:2380 \
  --listen-peer-urls http://192.168.1.111:2380 \
  --listen-client-urls http://192.168.1.111:2379,http://127.0.0.1:2379 \
  --advertise-client-urls http://192.168.1.111:2379 \
  --initial-cluster etcd1-server=http://192.168.1.111:2380,etcd2-server=http://192.168.1.112:2380,etcd3-server=http://192.168.1.113:2380 \
  --initial-cluster-token my-etcd-cluster \
  --initial-cluster-state new

Restart=always
LimitNOFILE=40000

[Install]
WantedBy=multi-user.target
```

### For etcd2-server

```ini
[Unit]
Description=etcd
After=network.target

[Service]
ExecStart=/usr/local/bin/etcd \
  --name etcd2-server \
  --data-dir /var/lib/etcd \
  --initial-advertise-peer-urls http://192.168.1.112:2380 \
  --listen-peer-urls http://192.168.1.112:2380 \
  --listen-client-urls http://192.168.1.112:2379,http://127.0.0.1:2379 \
  --advertise-client-urls http://192.168.1.112:2379 \
  --initial-cluster etcd1-server=http://192.168.1.111:2380,etcd2-server=http://192.168.1.112:2380,etcd3-server=http://192.168.1.113:2380 \
  --initial-cluster-token my-etcd-cluster \
  --initial-cluster-state new

Restart=always
LimitNOFILE=40000

[Install]
WantedBy=multi-user.target
```

### For etcd3-server

```ini
[Unit]
Description=etcd
After=network.target

[Service]
ExecStart=/usr/local/bin/etcd \
  --name etcd3-server \
  --data-dir /var/lib/etcd \
  --initial-advertise-peer-urls http://192.168.1.113:2380 \
  --listen-peer-urls http://192.168.1.113:2380 \
  --listen-client-urls http://192.168.1.113:2379,http://127.0.0.1:2379 \
  --advertise-client-urls http://192.168.1.113:2379 \
  --initial-cluster etcd1-server=http://192.168.1.111:2380,etcd2-server=http://192.168.1.112:2380,etcd3-server=http://192.168.1.113:2380 \
  --initial-cluster-token my-etcd-cluster \
  --initial-cluster-state new

Restart=always
LimitNOFILE=40000

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd
sudo systemctl status etcd
```

## Test etcd

```bash
etcdctl put test "hello"
etcdctl get test
```

## Testing etcd Cluster - `Set environment variable`

```bash
# Run in each Node
export ETCDCTL_API=3
```

## Check cluster health

```bash
# Run in each Node
etcdctl \
  --endpoints=http://192.168.1.111:2379,http://192.168.1.112:2379,http://192.168.1.113:2379 \
  endpoint health
```

## Check member list

```bash
etcdctl --endpoints=http://192.168.1.111:2379 member list
```

## Check leader

```bash
etcdctl \
--endpoints=http://192.168.1.111:2379,http://192.168.1.112:2379,http://192.168.1.113:2379 \
endpoint status --write-out=table
```

## Key-Value Testing (REAL TEST)

```bash
etcdctl put db_name "ha_postgres_cluster"
# Should see
# OK
```

## Get data each Node

```bash
ssh jakir@192.168.1.111
etcdctl get db_name
```

## Failure Test (Enterprise Level)

```bash
sudo systemctl stop etcd
etcdctl endpoint status --write-out=table
```

> Firewall (If enabled)

```bash
sudo ufw allow 2379
sudo ufw allow 2380
```
