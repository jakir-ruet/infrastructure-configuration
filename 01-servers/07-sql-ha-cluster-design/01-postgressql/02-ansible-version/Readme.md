## Welcome to High Avalability postgresSQL Server - `Ansible Version`

This section provides an automated setup of a high availability postgresSQL cluster using Ansible. It includes Ansible playbooks and roles to streamline the deployment process, making it easier to set up and manage the postgresSQL HA cluster with minimal manual intervention.

### Pre-Requisite

1. Database: [postgresSQL](https://www.postgressql.org/)
2. Cluster Manager: [Patroni](https://www.enterprisedb.com/docs/supported-open-source/patroni/)
3. Distributed Consensus: [Etcd](https://etcd.io/)
4. Load Balancer: [HAProxy](https://www.haproxy.org/)
5. Automation: [Ansible](https://docs.ansible.com/)
6. Connection Pooling: [PgBouncer](https://www.pgbouncer.org/)
7. Monitoring: [Prometheus](https://prometheus.io/)
8. Visualization: [Grafana](https://grafana.com/)

### Project Folder Structure (Enterprise)

```bash
postgress-ha-cluster/
│
├── ansible.cfg
├── inventory/
│   └── hosts.yml
├── group_vars/
│   ├── etcd.yml
│   └── postgress.yml
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
│   ├── postgress.yml
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
   | postgresSQL  |       | postgresSQL  |       | postgresSQL    |
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
Prometheus ---> postgresSQL Exporter
Prometheus ---> Patroni metrics
Grafana ------> Dashboards
```

### Cluster Infrastructure Plan

The following table represents the planned infrastructure for the **postgresSQL High Availability Cluster with Monitoring and Automation**:

|  SL   | Instance Name     | Node IP       | Role                  | RAM | Disk | Notes                           |
| :---: | ----------------- | ------------- | --------------------- | --- | ---- | ------------------------------- |
|   1   | ansible-server    | 192.168.1.110 | ansible-controller    | 2GB | 2GB  | Ansible control node (Local)    |
|   2   | etcd1-server      | 192.168.1.111 | etcd                  | 2GB | 2GB  | ETCD cluster leader             |
|   3   | etcd2-server      | 192.168.1.112 | etcd                  | 2GB | 2GB  | ETCD cluster member1            |
|   4   | etcd3-server      | 192.168.1.113 | etcd                  | 2GB | 2GB  | ETCD cluster member2            |
|   5   | postgres1-server  | 192.168.1.114 | postgresSQL + Patroni | 2GB | 2GB  | Primary node                    |
|   6   | postgres2-server  | 192.168.1.115 | postgresSQL + Patroni | 2GB | 2GB  | Replica node1                   |
|   7   | postgres3-server  | 192.168.1.116 | postgresSQL + Patroni | 2GB | 2GB  | Replica node2                   |
|   8   | lb-server         | 192.168.1.117 | HAProxy + PgBouncer   | 2GB | 2GB  | Load balancer & connection pool |
|   9   | prometheus-server | 192.168.1.118 | Prometheus            | 2GB | 2GB  | Metrics collection              |
|  10   | grafana-server    | 192.168.1.119 | Grafana               | 2GB | 2GB  | Monitoring dashboard            |

---

#### Architecture Overview

|  SL   | Title                             | About                                                             |
| :---: | --------------------------------- | ----------------------------------------------------------------- |
|   1   | **Ansible Server:**               | Automates deployment and configuration                            |
|   2   | **ETCD Cluster (3 nodes)**        | A distributed key-value store used by Patroni for leader election |
|   3   | **postgresSQL Cluster (3 nodes)** | Primary + Replicas with streaming replication                     |
|   4   | **HAProxy + PgBouncer**           | Load balancing and connection pooling                             |
|   5   | **Monitoring Stack**              | Prometheus + Grafana for metrics and visualization                |

---

> **Key Features**

- High Availability (HA) with automatic failover
- Read/Write traffic separation
- Centralized configuration management (ETCD)
- Connection pooling for performance optimization
- Real-time monitoring and alerting

### Set Hostname

```bash
ssh jakir@192.168.1.110
sudo hostnamectl set-hostname ansible-controller
```

```bash
ssh jakir@192.168.1.111
sudo hostnamectl set-hostname etcd1-server
```

```bash
ssh jakir@192.168.1.112
sudo hostnamectl set-hostname etcd2-server
```

```bash
ssh jakir@192.168.1.113
sudo hostnamectl set-hostname etcd3-server
```

```bash
ssh jakir@192.168.1.114
sudo hostnamectl set-hostname postgress1-server
```

```bash
ssh jakir@192.168.1.115
sudo hostnamectl set-hostname postgress2-server
```

```bash
ssh jakir@192.168.1.116
sudo hostnamectl set-hostname postgress3-server
```

```bash
ssh jakir@192.168.1.117
sudo hostnamectl set-hostname lb-server
```

```bash
ssh jakir@192.168.1.118
sudo hostnamectl set-hostname prometheus-server
```

```bash
ssh jakir@192.168.1.119
sudo hostnamectl set-hostname grafana-server
```

### Entries into `/ete/hosts`

```bash
192.168.1.110 ansible-controller
192.168.1.111 etcd1-server
192.168.1.112 etcd2-server
192.168.1.113 etcd3-server
192.168.1.114 postgress1-server
192.168.1.115 postgress2-server
192.168.1.116 postgress3-server
192.168.1.117 lb-server
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
```
