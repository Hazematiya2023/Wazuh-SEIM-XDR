########################################################################
#               ©Created by Hazem Mohamed                              #
#                 E-Mail:hmohamed200@gmail.com                         #
#                https://itsysadmins-eg.info                           #
#         This menu to install Wazuh SEIM Solutin on Ubunto Server     #
#                 recommended requirement spec. is 32 GB               #
#             don't forgot to chmod 755 for this script file           #
########################################################################


#!/bin/bash

# Function to read IP addresses
read_ip() {
    local prompt=$1
    local var_name=$2
    read -p "$prompt: " ip_address
    eval "$var_name='$ip_address'"
}

# Ask user to enter the  IP addresses , 1st one for indexer ,
# Manager IP and Dashboard IP Address , if you will host all of them on the same server please enter the same IP
read_ip "Enter the IP address for the indexer" INDEXER_IP
read_ip "Enter the IP address for the manager" MANAGER_IP
read_ip "Enter the IP address for the dashboard" DASHBOARD_IP

# Update system and install necessary packages
apt-get update
apt-get upgrade -y
apt-get install -y curl apt-transport-https

# Install Wazuh repository and key
curl -sO https://packages.wazuh.com/key/GPG-KEY-WAZUH
apt-key add GPG-KEY-WAZUH
echo "deb https://packages.wazuh.com/4.x/apt/ stable main" > /etc/apt/sources.list.d/wazuh.list

# Install Wazuh Manager
apt-get update
apt-get install -y wazuh-manager

# Install Wazuh Indexer (Elasticsearch)
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" > /etc/apt/sources.list.d/elastic-8.x.list
apt-get update
apt-get install -y elasticsearch

# Install Wazuh Dashboard (Kibana)
apt-get install -y kibana

# Configure Wazuh Manager
sed -i "s/{MANAGER_IP}/$MANAGER_IP/g" /var/ossec/etc/ossec.conf

# Configure Elasticsearch
sed -i "s/#network.host: 192.168.0.1/network.host: $INDEXER_IP/g" /etc/elasticsearch/elasticsearch.yml

# Configure Kibana
sed -i "s/#server.host: \"localhost\"/server.host: \"$DASHBOARD_IP\"/g" /etc/kibana/kibana.yml

# Restart services
systemctl restart wazuh-manager
systemctl restart elasticsearch
systemctl restart kibana

echo "Wazuh setup completed. Please verify the installation and configuration."

echo "Thanks for using this menu , Best Regards Hazem Mohamed ©"

