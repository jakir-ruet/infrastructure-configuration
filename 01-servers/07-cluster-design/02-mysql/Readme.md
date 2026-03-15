## What You Will Build

By the end of this guide, you will have:

- A `primary` PostgreSQL server handling writes
- One or more `replica servers` using streaming replication
- `Replication slots` to protect `WAL` segments
- `Monitoring queries` to check replication health
- A base for `automatic failover` with `Patroni` or `repmgr`.

## Architecture

![Architecture](/01-servers/07-cluster-design/01-postgresql/img/psql-cluster-architecture.png)

### Prerequisites

Before starting, ensure you have:

- `Two or more servers` running Ubuntu 22.04 or Ubuntu 24.04 (VMs or bare metal)
- `Root or sudo access` on all servers
- `Network connectivity` between servers on port 5432
- At least `2 GB RAM` per server for testing (more for production)
- `Configured hostnames` or known `IP addresses` for all nodes.

### Cluster Node Details

| Role      | Hostname    | RAM | Disk | IP Address    |
| --------- | ----------- | --- | ---- | ------------- |
| Primary   | primary-db  | 2GB | 2GB  | 192.168.1.117 |
| Replica 1 | replica-db1 | 2GB | 2GB  | 192.168.1.118 |
| Replica 2 | replica-db2 | 2GB | 2GB  | 192.168.1.119 |

### Verify the installation by checking the service status

```bash
sudo chmod +x /01-servers/07-cluster-design/01-postgresql/scripts/postgre-install-all.sh
sudo ./01-servers/07-cluster-design/01-postgresql/scripts/postgre-install-all.sh
```

```bash
sudo systemctl status postgresql
sudo -u postgres psql -c "SELECT version();" # Verify the version
```

### Configure the Primary Server

```bash
sudo cp /etc/postgresql/16/main/postgresql.conf /etc/postgresql/16/main/postgresql.conf.bak
sudo vi /etc/postgresql/16/main/postgresql.conf
```

### Configure Client Authentication

```bash
sudo cp /etc/postgresql/16/main/pg_hba.conf /etc/postgresql/16/main/pg_hba.conf.bak
# Open the host-based authentication file
sudo vi /etc/postgresql/16/main/pg_hba.conf
```

### Create the Archive Directory

```bash
sudo mkdir -p /var/lib/postgresql/16/archive
sudo chown postgres:postgres /var/lib/postgresql/16/archive
sudo chmod 700 /var/lib/postgresql/16/archive
```

### Create the Replication User

```bash
sudo -u postgres psql
```

```bash
-- 1. Create a dedicated replication user
-- Use a strong password in production; adjust username as needed
CREATE ROLE replicator WITH REPLICATION LOGIN ENCRYPTED PASSWORD 'Sql@054003';

-- 2. Create a publication for logical replication (optional for table-level replication)
-- Use this if you want to replicate all tables
CREATE PUBLICATION my_publication FOR ALL TABLES;

-- 3. Create physical replication slots for each standby
-- Prevents WAL segments from being removed until replicas have received them
SELECT * FROM pg_create_physical_replication_slot('replica1_slot');
SELECT * FROM pg_create_physical_replication_slot('replica2_slot');

-- 4. Verify the replication slots exist and see their status
SELECT slot_name, slot_type, active, database FROM pg_replication_slots;

-- 5. Exit psql
\q
```

```bash
sudo systemctl restart postgresql
sudo systemctl status postgresql
sudo tail -50 /var/log/postgresql/postgresql-16-main.log
```

### Configure `Replica` Servers

```bash
sudo systemctl stop postgresql

# Remove the default data directory
# WARNING: This deletes all data in this cluster
sudo rm -rf /var/lib/postgresql/16/main/*
```

### Take a Base Backup from the Primary

```bash
# Take a base backup from the primary (192.168.1.117)
# -h: primary hostname/IP
# -U: replication user
# -D: destination directory on standby
# -P: show progress
# -R: create standby.signal for automatic recovery
# -S: use the replication slot created for this standby
sudo -u postgres pg_basebackup \
    -h 192.168.1.117 \
    -U replicator \
    -D /var/lib/postgresql/16/main \
    -P \
    -R \
    -S replica1_slot
```

```bash
sudo -u postgres pg_basebackup \
    -h 192.168.1.117 \
    -U replicator \
    -D /var/lib/postgresql/16/main \
    -P \
    -R \
    -S replica2_slot
```

### Verify the Standby Configuration

```bash
# Verify standby.signal file exists (indicates this is a standby)
ls -la /var/lib/postgresql/16/main/standby.signal

# Check the auto-generated recovery configuration
sudo cat /var/lib/postgresql/16/main/postgresql.auto.conf
```

### The postgresql.auto.conf should contain something like

```bash
primary_conninfo = 'host=192.168.1.117 port=5432 user=replicator password=Sql@054003 sslmode=prefer'
primary_slot_name = 'replica1_slot'

primary_conninfo = 'host=192.168.1.117 port=5432 user=replicator password=Sql@054003 sslmode=prefer'
primary_slot_name = 'replica2_slot'
```

```bash
sudo systemctl restart postgresql
sudo systemctl status postgresql
```
