#!/bin/bash

# Script: install_etcd.sh
# Purpose: Install Etcd server and client on Ubuntu/Debian

echo "=== Updating system ==="
sudo apt update -y
sudo apt upgrade -y

echo "=== Installing prerequisites ==="
sudo apt install -y curl wget tar

echo "=== Installing Etcd server ==="
sudo apt install -y etcd-server etcd-client

echo "=== Verifying Etcd installation ==="
echo "Etcd version:"
etcd --version

echo "Etcdctl version:"
etcdctl version

echo "=== Etcd installation completed on $(hostname) [$HOSTNAME] ==="
