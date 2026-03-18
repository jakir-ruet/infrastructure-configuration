#!/bin/bash

echo "Checking Patroni cluster..."
patronictl -c /etc/patroni.yml list

echo ""
echo "Checking PostgreSQL replication..."
psql -U postgres -c "SELECT client_addr,state FROM pg_stat_replication;"

echo ""
echo "Checking HAProxy..."
systemctl is-active haproxy

echo ""
echo "Checking PgBouncer..."
systemctl is-active pgbouncer
