#!/bin/bash

# User for SSH
USER="jakir"

# List of servers with their IPs and desired hostnames
declare -A SERVERS=(
    ["192.168.1.111"]="etcd1-server"
    ["192.168.1.112"]="etcd2-server"
    ["192.168.1.113"]="etcd3-server"
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
