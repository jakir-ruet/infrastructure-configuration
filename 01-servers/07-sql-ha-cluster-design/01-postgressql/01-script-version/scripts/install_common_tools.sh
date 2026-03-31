#!/bin/bash

# Script: install_common_tools.sh
# Purpose: Install net-tools, wget, curl, zip, tar on all servers

# Update package list
echo "Updating package list..."
sudo apt update -y

# Install packages
echo "Installing net-tools, wget, curl, zip, tar..."
sudo apt install -y net-tools wget curl zip tar

# Verify installation
echo "Verifying installed tools..."
for tool in ifconfig wget curl zip tar; do
    if command -v $tool &> /dev/null; then
        echo "$tool ✅ installed"
    else
        echo "$tool ❌ NOT installed"
    fi
done

echo "Installation completed on $(hostname) [$HOSTNAME]"
