#!/bin/bash

# Q: Q1: What’s the use of read in Bash? Show a sample script that takes name and age from user input.
# A: read is used to take input from the user
echo "Enter name: "
read name
echo "Enter age: "
read age

#Q: Use awk to print all usernames from /etc/passwd with UID less than 1000.
#A:
file="/etc/passwd"
names=$(awk -F: '$3<1000 {print $1}' "$file")
echo "$names"
# -F sets the field separator to :
# $3 refers to the UID field
# $1 is the username field

# Q: Write a script to: 
# Monitor /var disk usage If usage > 80%, 
# log a warning Use df, awk, and conditional logic

# A:

usage=$(df /var | awk 'NR > 1 {gsub("%",""); print $5}')
echo "Usage is $usage%"
if [ "$usage" -gt 80 ]
then
  echo "Warning storage 80% full!"
else
  echo "Everything is OK"
fi 

