#!/bin/bash

list=("ssh" "cron" "apache2" "mysql" "nginx")

for service in "${list[@]}"
do
  if systemctl is-active --quiet "$service"; then
    echo "$service is active"
  else 
    echo "$service is inactive"
  fi 
done
