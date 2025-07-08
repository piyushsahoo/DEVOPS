#!/bin/bash

#Q: Differentiate between $HOME, ~, and ~-. Give command examples.
#A: $HOME:- stores path to home directory
#   ~ :- Shell shortcut that expands to the current user's home directory.
#   ~- :-  Expands to the previous working directory — same as $OLDPWD.

#Q: Use awk to extract names, ages, and departments from a file where names start with S and end with a.

res=$(awk 'NR > 1 && $1 ~ "^S.*a$" {print $1, $2, $3}' emp.txt)

echo "$res"

#Q: Write a script to print:
#   Current date Uptime of the system 
#   Number of logged-in users 
#   (Use command substitution.)

date=$(date)
echo "Date is:- $date"
uptime=$(uptime -p)
echo "uptime of system is:- $uptime"
loggedInUsers=$(who | wc -l)
echo "No. of logged in users:- $loggedInUsers"