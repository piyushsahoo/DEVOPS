#!/bin/bash

folder="$1"

#Q : What is the function of set -- $myvar? Show its use in splitting a string.
#A : Replaces the positional parameters with word splitting

myvar="Hi i am piyush"
set -- $myvar
echo "First: $1"
echo "Second: $2"
echo "Third: $3"
echo "Fourth: $4"

#Q: Use sed to replace all instances of 'll' with 'l' in a text file.

replaced=$(sed 's/ll/l/g' llWithl.txt)
echo "$replaced"

#Q: Write a bash script to:
#   Accept a folder path as an argument Find the latest modified file Copy it to a backup folder and print its name



recentModified=$(ls -t "$folder" | head -1)
echo "Recently modified file is $recentModified"

cp "$folder/$recentModified" ./backups
