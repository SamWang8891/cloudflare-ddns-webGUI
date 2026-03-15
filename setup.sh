#!/bin/bash


# Check if cloudflare-ddns is already installed on docker
if [ "$(docker ps -aq -f name=cloudflare-ddns)" ]; then
    read -p "There is an existing one, do you want to reinstall and reconfigure it? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        echo "Exiting..."
        echo ""
        exit 1
    fi
    read -p "WARNING!!! Backup configuration before proceed! Type "sure" to proceed.: " confirm
    if [ "$confirm" == "sure" ]; then
        docker compose down
    else
        echo "Exiting..."
        echo ""
        exit 1
    fi
fi


# Create the file to store config
CONF_FILE=./app/cloudflare-ddns-script/config.txt
echo "Thank you for choosing cloudflare-ddns-webGUI!"
echo "The config file is stored in $CONF_FILE"
if [ -f "$CONF_FILE" ]; then
    rm "$CONF_FILE"
    echo "Old file found, deleting it..."
fi
touch "$CONF_FILE"
echo "Creating the config file and add empty config to it..."

# Ask user for network interface
echo ""
echo "Network interface selection for getting public IP:"
echo "  Press Enter to use default (let curl decide)"
echo "  Or enter a specific interface name (e.g. eth0, wlan0)"
read -p "Interface [default]: " selected_interface
if [ -z "$selected_interface" ]; then
    selected_interface="default"
fi
echo "Using interface: $selected_interface"
echo ""

echo "network_interface=\"$selected_interface\"" >> "$CONF_FILE"
echo 'record="sub.domain.tld"' >> "$CONF_FILE"
echo 'zone_id=""' >> "$CONF_FILE"
echo 'token=""' >> "$CONF_FILE"
echo 'email=""' >> "$CONF_FILE"
echo 'proxy="true"' >> "$CONF_FILE"
echo 'ttl="60"' >> "$CONF_FILE"

# Set permission to the app folder
echo "Setting permission to the app folder"
chmod -R 777 ./app 

echo "Now docker compose up, with detach parameter (-d)."
docker compose up -d
