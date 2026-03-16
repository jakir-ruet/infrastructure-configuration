#!/bin/bash

echo "Stopping leader..."

LEADER=$(patronictl list | grep Leader | awk '{print $2}')

ssh $LEADER "systemctl stop patroni"

sleep 10

patronictl list
