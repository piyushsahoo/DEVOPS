#!/bin/bash
#Q1
awk -F, 'NR > 1 && $1 ~ /^s.*a$/{print $1, $2, $3}' datafile.csv > output.txt
#Q2
awk -F, 'NR > 1 && $1 ~ /n$/{print $1, $2, $3}' datafile.csv > output.txt
#Q3
awk -F, 'NR > 1 && $1 ~ /^j.*n$/{print $1, $2, $3}' datafile.csv > output.txt
#Q4
ifconfig | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}'
#Q5
sed 's/ll/l/g' ll.txt > output.txt
#Q6
sed 's/\bH[^ ]*/HAHA/g' replace.txt > output.txt
#Q7
text="Test100String"
echo "$text" | sed 's/[^0-9]//g'  > output.txt
