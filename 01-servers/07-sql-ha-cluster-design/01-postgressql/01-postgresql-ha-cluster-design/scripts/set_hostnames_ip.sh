#!/bin/bash

# User for SSH
USER="jakir"

# List of servers with their IPs and desired hostnames
declare -A SERVERS=(
    ["192.168.1.111"]="etcd1-server"
    ["192.168.1.112"]="etcd2-server"
    ["192.168.1.113"]="etcd3-server"
    ["192.168.1.114"]="postgres1-server"
    ["192.168.1.115"]="postgres2-server"
    ["192.168.1.116"]="postgres3-server"
    ["192.168.1.117"]="haproxy-server"
    ["192.168.1.118"]="prometheus-server"
    ["192.168.1.119"]="grafana-server"
)

# Loop through all servers
for IP in "${!SERVERS[@]}"; do
    HOSTNAME=${SERVERS[$IP]}
    echo "Setting hostname $HOSTNAME on $IP..."

    ssh $USER@$IP "sudo hostnamectl set-hostname $HOSTNAME && echo '$IP $HOSTNAME' | sudo tee -a /etc/hosts"

    # Optional: verify
    ssh $USER@$IP "hostnamectl status | grep 'Static hostname'"
done

echo "All hostnames updated!"
