#!/bin/bash
#Q1 : What does echo $? display after executing a command? How is it used in scripts?
#A : It is used to display the exit status of a command, where 0 means success, other value means error/failure

#Q2 : Use grep to extract all lines from a file that begin with a capital J and end with n.

lines=$(grep -iE "^J.*n$" JandN.txt)

echo "$lines"

#Q3. Write a bash script that accepts one or more arguments and prints:
#Total number of arguments 
#Length of each argument

echo "Total no. of argument $#"
i=1
for ele in "$@"
do 
  len="${#ele}"
  echo "$i word -> length = $len"
  ((i++))
done
