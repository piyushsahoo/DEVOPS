#!/bin/bash

# Q: What does id -u return? How to check if script is running as root?
# A:
# id -u returns the numeric UID (User ID) of the current user.
# Root user always has UID = 0.

# Q:  Use grep to find lines in config.txt that:
# Start with port
# End with a number

# A: 
grep '^port.*[0-9]$' config.txt

#Q: Script that reads a .env file and exports all variables defined inside it using a loop.

# A: 

i=1
for file in *.env
do 
  echo "file $i -> $file"
  cat "$file" | awk -F= '{print $1}'
  ((i++))
done
