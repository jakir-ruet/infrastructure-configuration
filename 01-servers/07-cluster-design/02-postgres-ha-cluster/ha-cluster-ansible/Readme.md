## PostgreSQL HA cluster Design

Using these

- Database: PostgreSQL
- Cluster Manager: Patroni
- Distributed Consensus: etcd
- Load Balancer: HAProxy
- Automation: Ansible
- Connection Pooling: PgBouncer
- Monitoring: Prometheus
- Visualization: Grafana

### Project Folder Structure (Enterprise)

```bash
postgres-ha-cluster/
│
├── ansible.cfg
├── inventory/
│   └── hosts.yml
├── group_vars/
│   ├── etcd.yml
│   └── postgres.yml
├── roles/
│   ├── common/
│   ├── etcd/
│   ├── patroni/
│   ├── haproxy/
│   ├── pgbouncer/
│   ├── prometheus/
│   └── grafana/
├── playbooks/
│   ├── setup.yml
│   ├── etcd.yml
│   ├── postgres.yml
│   ├── haproxy.yml
│   └── monitoring.yml
└── README.md
```

### Enterprise Architecture

```bash
                        +----------------+
                        |   Applications |
                        +--------+-------+
                                 |
                          +------v------+
                          |  HAProxy LB |
                          +------+------+
                                 |
                     +-----------+-----------+
                     |                       |
               +-----v-----+           +-----v-----+
               | PgBouncer |           | PgBouncer |
               +-----+-----+           +-----+-----+
                     |                       |
          +----------+-----------------------+----------+
          |                     |                       |
   +------v------+       +------v------+       +--------v------+
   | PostgreSQL  |       | PostgreSQL  |       | PostgreSQL    |
   |  Primary    |<----->|  Replica    |<----->|  Replica      |
   | (Patroni)   |       | (Patroni)   |       | (Patroni)     |
   +------+------+
          |
          |
    +-----v------+
    |   etcd     |
    | cluster    |
    +------------+

Monitoring
----------
Prometheus ---> PostgreSQL Exporter
Prometheus ---> Patroni metrics
Grafana ------> Dashboards
```

### Node Layout (Recommended)

| Instance Name | Node IP       | Role                 | RAM | Disk | Notes                           |
| ------------- | ------------- | -------------------- | --- | ---- | ------------------------------- |
| etcd1         | 192.168.1.117 | etcd                 | 2GB | 2GB  | Cluster member 1                |
| etcd2         | 192.168.1.118 | etcd                 | 2GB | 2GB  | Cluster member 2                |
| etcd3         | 192.168.1.119 | etcd                 | 2GB | 2GB  | Cluster member 3                |
| pg1           | 192.168.1.120 | PostgreSQL + Patroni | 2GB | 2GB  | Primary/Replica 1               |
| pg2           | 192.168.1.121 | PostgreSQL + Patroni | 2GB | 2GB  | Replica 2                       |
| pg3           | 192.168.1.122 | PostgreSQL + Patroni | 2GB | 2GB  | Replica 3                       |
| lb1           | 192.168.1.123 | HAProxy + PgBouncer  | 2GB | 2GB  | Load balancer & connection pool |
| monitoring1   | 192.168.1.124 | Prometheus           | 2GB | 2GB  | Metrics collection              |
| monitoring2   | 192.168.1.125 | Grafana              | 2GB | 2GB  | Visualization                   |

### Entries into `/ete/hosts`

```bash
192.168.1.100 ansible-controller
192.168.1.111 etcd1-server
192.168.1.112 etcd2-server
192.168.1.113 pg1-server
192.168.1.114 pg2-server
192.168.1.115 lb1-server
192.168.1.116 prometheus-server
192.168.1.117 grafana-server
```

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "ansible@mac"
```

```bash
ssh-copy-id jakir@192.168.1.111
ssh-copy-id jakir@192.168.1.112
ssh-copy-id jakir@192.168.1.113
ssh-copy-id jakir@192.168.1.114
ssh-copy-id jakir@192.168.1.115
ssh-copy-id jakir@192.168.1.116
ssh-copy-id jakir@192.168.1.117
```

```bash
ansible all -i inventory/hosts.yml -m ping --ask-become-pass
```

### Deployment Phases

| Phase | Component          | Tools                | Outcome               |
| ----- | ------------------ | -------------------- | --------------------- |
| 1     | Infra Prep         | Ansible              | Servers ready         |
| 2     | Distributed Store  | etcd                 | Cluster state         |
| 3     | PostgreSQL Setup   | PostgreSQL + Patroni | DB nodes managed      |
| 4     | Replication        | PostgreSQL           | Streaming replication |
| 5     | Load Balancing     | HAProxy              | HA DB endpoint        |
| 6     | Connection Pooling | PgBouncer            | Efficient connections |
| 7     | Monitoring         | Prometheus           | Metrics collection    |
| 8     | Visualization      | Grafana              | Real-time dashboards  |

#### Run Playbook Without Prompt - `For all Instance`

```bash
sudo visudo
jakir ALL=(ALL) NOPASSWD:ALL
```

```bash
ansible-playbook -i inventory/hosts.yml playbooks/setup.yml --ask-become-pass
# It will ask once for jakir’s sudo password.
```

#### `OR` Run Playbook With Prompt - `For all Instance`

```bash
ansible-playbook -i inventory/hosts.yml playbooks/setup.yml --ask-become-pass
# It will ask once for jakir’s sudo password.
```

### Access Dashboards

| Component  | Verification                                | Notes                         |
| ---------- | ------------------------------------------- | ----------------------------- |
| Patroni    | `curl http://<pg-node-ip>:8008`             | Check cluster status & leader |
| HAProxy    | `psql -h 192.168.1.123 -U postgres`         | DB via load balancer          |
| PgBouncer  | `psql -h 192.168.1.123 -p 6432 -U postgres` | Connection pool               |
| Prometheus | `http://192.168.1.124:9090`                 | Metrics UI                    |
| Grafana    | `http://192.168.1.125:3000`                 | Dashboards                    |
