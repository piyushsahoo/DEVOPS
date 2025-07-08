#!/bin/bash

#Q1: What does ${var:0:3} and ${var::-1} do? Show with examples.
#  ${var:0:3} :- Extracts a substring starting from position 0, with length 3.
# ${var::-1}:- Extracts the entire string except the last 1 character.

var="HelloWorld"
echo "${var:0:3}"

var="HelloWorld"
echo "${var::-1}"

#Q: Use grep to match all URLs starting with http or https in a file.

grep -Eo 'http|https' http.txt 

#Q: Write a script to:
# Accept a service name (like nginx, mysql, etc.) as input 
# Check if the service is actively running using systemctl
# If the service is inactive or failed, restart it and log the timestamp of the restart to service.log

read -p "Enter a service name(nginx, mysql, etc.))" service

# systemctl status "$service"

status=$(systemctl is-active "$service")
echo "$status"

if [ "$status" == "inactive" ] || [ "$status" == "failed" ]; then
  sudo systemctl restart "$service"
  echo "$(date) -> Restarted $service" >> service.log
fi
