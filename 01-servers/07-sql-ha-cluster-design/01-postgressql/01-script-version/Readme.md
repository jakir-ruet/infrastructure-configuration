## Complete guideline of HA Postgre SQL server including Monitoring

![Infrastructure Architecture](/01-servers/07-sql-ha-cluster-design/01-postgressql/01-script-version/img/infra-design.png)

### 1. Hostname & IP setup

You first set hostnames and update `/etc/hosts` on all nodes.

✅ **Correct:** all nodes must resolve each other before starting Etcd/Patroni/PostgreSQL.

### 2. Vagrant alternative

You provided a Vagrant setup.

✅ **Optional but useful for dev/testing.**

### 3. Common tools

Installing `net-tools`, `curl`, `python3`, etc.

✅ **Correct:** required for Patroni, PostgreSQL, and exporters.

### 4. Etcd installation

`install_etcd.sh` → create `/etc/default/etcd` or `/etc/systemd/system/etcd.service`

✅ **Correct:** Etcd cluster must be up before Patroni (Patroni depends on Etcd).

### 5. PostgreSQL & Patroni installation

Install PostgreSQL, stop default service, install Patroni, configure WAL directories.

✅ **Correct:** Patroni should manage PostgreSQL service, so stopping default PostgreSQL is necessary.

### 6. Patroni configuration

Apply `/etc/patroni/config.yml`, set directories, ensure replication ports are open.

✅ **Correct:** this ensures the cluster forms correctly and replication works.

### 7. HAProxy setup

Install HAProxy, configure leader (writes) and replicas (reads), enable stats page.

✅ **Correct:** HAProxy sits in front of Patroni-managed PostgreSQL nodes.

### 8. PgBouncer setup

Configure pooling, TCP keepalive, idle timeout, start service.

✅ **Correct:** helps with connection management, prevents connection exhaustion.

### 9. Exporters for Prometheus

- Postgres exporter → all Postgres nodes
- HAProxy exporter → HAProxy node
- PgBouncer exporter → PgBouncer

✅ **Correct:** metrics collection order is fine; exporters should run after services exist.

### 10. Prometheus

Configure scrape targets (postgres, HAProxy, PgBouncer).

✅ **Correct:** Prometheus must scrape only after services and exporters are running.

### 11. Grafana

Add Prometheus as a data source, dashboards for HAProxy/Postgres/PgBouncer.

✅ **Correct:** Grafana queries depend on Prometheus; so this is last.

---

### ⚠️ Minor Adjustments / Recommendations

- **PgBouncer before HAProxy clients:**
  - Make sure HAProxy reads/writes are pointed to PgBouncer if you want to use pooling.
  - Otherwise, HAProxy talks directly to Patroni nodes.

- **Firewall / UFW rules:**
  - Ensure Prometheus server can access exporters (ports 9187, 9127, 7000).
  - Make Grafana access open to  workstation/browser.

- **SSL in HAProxy:**
   - HAProxy config uses SSL on write/read frontends. Ensure certificates exist before starting HAProxy.

- **Patroni health check ports:**
  - HAProxy health checks use port 8008 → ensure Patroni REST API is enabled and reachable.

---

### ✅ Conclusion

The install sequence is correct and follows proper dependency order:

`Hosts → Etcd → PostgreSQL/Patroni → HAProxy → PgBouncer → Exporters → Prometheus → Grafana`

> Only double-check  HAProxy frontends and PgBouncer integration carefully: the clients should point to PgBouncer if pooling is needed.
