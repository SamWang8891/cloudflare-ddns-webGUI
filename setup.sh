#!/bin/bash


# Create the file to store log
LOG_FILE=./app/script/.env
touch "$LOG_FILE"
echo 'record="sub.domain.tld"' >> "$LOG_FILE"
echo 'zone_id=""' >> "$LOG_FILE"
echo 'token=""' >> "$LOG_FILE"
echo 'email=""' >> "$LOG_FILE"
echo 'proxy="true"' >> "$LOG_FILE"
echo 'ttl="60"' >> "$LOG_FILE"

# Set permission to the app folder
chmod -R 777 ./app 

docker compose up -d
