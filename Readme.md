## Welcome Infrastructure Configuration Project

### DevOps Infrastructure & HA Cluster Design

This repository contains a complete hands-on collection of **server setups, load balancing, and high-availability database architectures**. It is designed for learning and implementing real-world **DevOps and production-ready infrastructure**.

### Project Structure Overview

#### 01-servers

Covers multiple web servers, application deployments, and reverse proxy configurations.

##### Web Servers

- **Apache** → Flask application deployment
- **Nginx** → Node.js (Express) application
- **Tomcat** → Java-based application server
- **LiteSpeed & Caddy** → Modern web servers

##### Proxy & Load Balancer

- **HAProxy**
  - Layer 4 & Layer 7 load balancing
  - Reverse proxy setup
  - Includes diagrams and documentation

### 07-sql-ha-cluster-design

Design and implementation of **High Availability Database Clusters**.

#### PostgreSQL Cluster (`01-postgresql`)

- Patroni-based HA cluster (3 nodes)
- Streaming replication
- Automatic failover

##### Versions

- **Manual Setup**
  - Patroni configuration
  - HAProxy integration
- **Ansible Automation**
  - Full cluster deployment using playbooks
  - Includes roles for:
    - ETCD
    - PostgreSQL
    - HAProxy
    - Monitoring (Prometheus, Grafana)
    - PgBouncer

##### Features

- Backup & health check scripts
- Cluster monitoring
- Failover testing

##### MySQL Cluster (`02-mysql`)

- MySQL Group Replication
- Multi-node HA architecture

##### Versions

- **Manual Setup**
- **Ansible Automation**

### 02-jenkins

- CI/CD pipeline setup and automation

### 03-docker

- Containerization concepts and Docker setups

### 04-ansible

- Infrastructure automation using Ansible
- Includes:
  - Inventory management
  - Playbooks
  - Roles (e.g., Docker installation)

### 05-kubernetes

- Kubernetes fundamentals and deployment practices

#### Key Highlights

- ✅ High Availability (HA) database design
- ✅ Load balancing with HAProxy
- ✅ Infrastructure as Code (Ansible)
- ✅ Monitoring with Prometheus & Grafana
- ✅ Real-world production-like setups

#### Use Cases

- DevOps learning & practice
- Production-ready infrastructure design
- Database clustering & failover testing
- Automation with Ansible
