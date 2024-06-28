#!/usr/bin/env bash

api_result=$(curl -s "http://worldtimeapi.org/api/ip.txt")

while read -r line; do
    if [[ $line =~ ^timezone:(.*)$ ]]; then
        target_timezone=$(echo ${BASH_REMATCH[1]} | xargs)
        echo "Setting timezone to $target_timezone by network"

        timedatectl set-timezone $target_timezone
    fi
done <<< "$api_result"


