#!/bin/bash

#Q: What does the command who | wc -l do? Explain its usage in monitoring.

#A: It counts how many users are currently logged in.
# it help to know how many users are currently accessing the system, if more users are accessing the system it might cause performance issue
# it helps for monitoring
# helpful for maintenance

#Q: Use awk to calculate the total of a numeric field (e.g., salary) in a CSV file.

awk -F, 'NR>1 {sum+=$4} END {print sum}' employees.csv

#Q: Write a bash script to:
# Install multiple packages given as command-line arguments 
# Print status after each install (Success/Fail)

for ele in "$@"
do 
  sudo apt install -y "$ele"
  status=$?
    if "$status" -eq 0;then 
      echo "$ele -> Exit status is: $status, successful"
    else 
      echo "$ele -> Exit status is: $status, failed"
    fi
done
