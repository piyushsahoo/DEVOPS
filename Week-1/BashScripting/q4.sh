#!/bin/bash

file="/etc/passwd"

while read line
do 
  username=$(echo "$line" | cut -d: -f1)
  homedir=$(echo "$line" | cut -d: -f6)

  if [ -d "$homedir" ]
  then
    echo "$username : Home directory exists -> $homedir"
  else 
    echo "$username : Home directory doesn't exist"
  fi
done < "$file"  
