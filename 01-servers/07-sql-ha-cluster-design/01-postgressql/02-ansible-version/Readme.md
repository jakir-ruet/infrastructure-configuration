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

### Project Folder Structure (Enterprise)

```bash
postgress-ha-cluster/
├── Readme.md
├── ansible.cfg
├── group_vars
│   └── all.yml
├── inventory
│   └── hosts.ini
├── playbooks
│   └── site.yml
├── roles
│   ├── common
│   │   └── tasks
│   │       └── main.yml
│   ├── etcd
│   │   └── tasks
│   │       └── main.yml
│   ├── grafana
│   │   └── tasks
│   │       └── main.yml
│   ├── haproxy
│   │   └── tasks
│   │       └── main.yml
│   ├── patroni
│   │   ├── handlers
│   │   │   └── main.yml
│   │   └── tasks
│   │       └── main.yml
│   ├── postgres
│   │   └── tasks
│   │       └── main.yml
│   └── prometheus
│       └── tasks
│           └── main.yml
└── templates
    ├── etcd.conf.j2
    ├── haproxy.cfg.j2
    └── patroni.yml.j2
```

### Set Hostname

```bash
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

### Entries into `/ete/hosts`

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

```bash
ssh-copy-id jakir@192.168.1.111
ssh-copy-id jakir@192.168.1.112
ssh-copy-id jakir@192.168.1.113
ssh-copy-id jakir@192.168.1.114
ssh-copy-id jakir@192.168.1.115
ssh-copy-id jakir@192.168.1.116
ssh-copy-id jakir@192.168.1.117
ssh-copy-id jakir@192.168.1.118
ssh-copy-id jakir@192.168.1.119
```

```bash
ansible-playbook -i inventory/hosts.yml playbooks/install-common.yml --ask-become-pass
ansible-playbook playbooks/site.yml -K
ansible-playbook -i inventory/hosts.ini playbooks/site.yml -K
```
