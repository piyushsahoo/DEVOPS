#!/bin/bash

#Q1: What is the purpose of test -f file.txt and test -s file.txt?

# A: 
# test -f file.txt	Returns true if file.txt exists and is a regular file
# test -s file.txt	Returns true if file.txt exists and is not empty (size > 0)

# Q: Extract only digits from a string like TestT100String using grep or awk.

ans=$(echo "TestT100String" | grep -o "[0-9]\+")
echo "$ans"
# -o is used to print only matching string

#Q: Write a script to:
# Accept a username Print last login info.List files in /home owned by that user (Hint: Use last, ls -l, and grep.)

username="$1"

lastLogin=$(last root | head -1)
echo "$lastLogin"


list=$(ls -l /home | grep "$username")
echo "$list"


