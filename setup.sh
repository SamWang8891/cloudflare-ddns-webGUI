#!/bin/bash


# Create the file to store log
CONF_FILE=./app/script/.env
echo "Thank you for choosing cloudflare-ddns-webGUI!"
echo "The conig file is stored in ./app/script/.eng"
if [ -f "$CONF_FILE" ]; then
    rm "$CONF_FILE"
    echo "Old file found, deleting it..."
fi
touch "$CONF_FILE"
echo "Creating the config file and add empty config to it..."
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
