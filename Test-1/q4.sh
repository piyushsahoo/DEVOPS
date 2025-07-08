#!/bin/bash

#Q: What does $(command) mean in Bash, and how is it different from backticks `command`?

#A: $(command) it is used for command substitution and it produces an output of the command
# `command` serves the same purpose but it is older version

# Q: Use grep to print all records from a file that do not contain any digit.

res=$(grep -v '[0-9]' records.txt)
echo "$res"

# Q: Script that reads all .txt files in a directory and converts them to .bak files using a for loop.

for file in *.txt
do 
  cp "$file" "${file}.bak"
done

