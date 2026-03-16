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

| Node  | Node IP       | Role                 | RAM |Disk|
| ----- | ------------- | -------------------- |-----|----|
| node1 | 192.168.1.117 | etcd                 | 2GB |2GB |
| node2 | 192.168.1.118 | etcd                 | 2GB |2GB |
| node3 | 192.168.1.119 | etcd                 | 2GB |2GB |
| node4 | 192.168.1.120 | PostgreSQL + Patroni | 2GB |2GB |
| node5 | 192.168.1.121 | PostgreSQL + Patroni | 2GB |2GB |
| node6 | 192.168.1.122 | PostgreSQL + Patroni | 2GB |2GB |
| node7 | 192.168.1.123 | HAProxy + PgBouncer  | 2GB |2GB |
| node8 | 192.168.1.124 | Prometheus           | 2GB |2GB |
| node9 | 192.168.1.125 | Grafana              | 2GB |2GB |

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

```bash
ansible-playbook -i inventory/hosts.yml playbooks/setup.yml -K
```

### Access Dashboards

| Component  | Verification                                | Notes                         |
| ---------- | ------------------------------------------- | ----------------------------- |
| Patroni    | `curl http://<pg-node-ip>:8008`             | Check cluster status & leader |
| HAProxy    | `psql -h 192.168.1.123 -U postgres`         | DB via load balancer          |
| PgBouncer  | `psql -h 192.168.1.123 -p 6432 -U postgres` | Connection pool               |
| Prometheus | `http://192.168.1.124:9090`                 | Metrics UI                    |
| Grafana    | `http://192.168.1.125:3000`                 | Dashboards                    |
