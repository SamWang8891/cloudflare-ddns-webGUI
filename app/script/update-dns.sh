#!/bin/bash

#Create a file to store log
LOG_FILE="/app/script/update-dns.log"
if ! [ -f $LOG_FILE ]; then
    touch $LOG_FILE
fi

#Clear the log and write the current time to the log file
> $LOG_FILE
echo "$(date "+%z %Y-%m-%d %H:%M:%S")" >>$LOG_FILE

#Validate if config file exists
CONFIG_FILE="/app/script/.env"
if ! [ -f $CONFIG_FILE ]; then
    echo "Config file not found" >>$LOG_FILE
    echo "Config file not found"
    exit 0
fi

#Validate if every parameter is set
source $CONFIG_FILE
if [ -z "${record}" ]; then
    echo "Record not set in config file" >>$LOG_FILE
    echo "Record not set in config file"
    exit 0
fi
if [ -z "${zone_id}" ]; then
    echo "Zone ID (zone_id) not set in config file" >>$LOG_FILE
    echo "Zone ID (zone_id) not set in config file"
    exit 0
fi
if [ -z "${token}" ]; then
    echo "Token not set in config file" >>$LOG_FILE
    echo "Token not set in config file"
    exit 0
fi
if [ -z "${email}" ]; then
    echo "Email not set in config file" >>$LOG_FILE
    echo "Email not set in config file"
    exit 0
fi
if [ "${proxy}" != "true" ] && [ "${proxy}" != "false" ]; then
    echo "Record not set in config file" >>$LOG_FILE
    echo "Record not set in config file"
    exit 0
fi
if [ -z "${ttl}" ]; then
    echo "Ttl not set in config file" >>$LOG_FILE
    echo "Ttl not set in config file"
    exit 0
fi


# List of alternative services to get the external IP address
# If failed or incorrect, you can try to replace the service with another one
# "https://api.ipify.org"
# "https://ipinfo.io/ip"
# "https://ifconfig.me"
# "https://icanhazip.com"

#Get the external IPv4 address
ip=$(curl -4 -s -X GET https://api.ipify.org --max-time 10)
if [ -z "$ip" ]; then
    echo "Error! Can't get external ip from https://api.ipify.org. Either there's no network connection or the site is down" >>$LOG_FILE
    echo "Error! Can't get external ip from https://api.ipify.org. Either there's no network connection or the site is down"
    exit 0
fi


#Get record_info
record_info=$(
    curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records?type=A&name=$record" \
        -H "X-Auth-Email: $email" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json"
)
if [[ $(echo $record_info | jq -r '.success') == "false" ]]; then
    echo ${record_info} >>$LOG_FILE
    echo ${record_info}
    exit 1
fi

#Get record_id
record_id=$(echo $record_info | jq -r '.result[0].id')


#Push dns record to Cloudflare
data="\"name\": \"$record\", \"proxied\": $proxy, \"ttl\": $ttl, \"content\": \"$ip\", \"type\": \"A\""
update_dns_record=$(
    curl -s --request PATCH \
        --url "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$record_id" \
        -H "X-Auth-Email: $email" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json" \
        --data "{$data}"
)
if [[ $(echo $update_dns_record | jq -r '.success') == "false" ]]; then
    echo ${update_dns_record} >>$LOG_FILE
    echo ${update_dns_record}
    exit 1
fi
echo "DNS record updated successfully!"
echo "$record DNS Record updated to $ip, ttl: $ttl, proxied: $proxy"
echo "$record DNS Record updated to $ip, ttl: $ttl, proxied: $proxy" >>$LOG_FILE