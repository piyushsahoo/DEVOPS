#!/bin/bash

file="/var/log/auth.log"

if [ ! -f "$file" ]
then
  echo "Log file doesn't exist"
fi 

grep ssh /var/log/auth.log

grep "session opened for user" "$file" | awk '!seen[$4]++ {print $4, "Time:" $1,$2,$3}' $file
