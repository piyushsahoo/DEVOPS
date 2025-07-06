#!/bin/bash
read -p "Enter process name" pname
ps aux | grep "$pname" | awk -v name="$pname" '{print "Process Id :" $2, "Memory Usage: "$4, "Name: " name}'

#-v in awk to declare variable eg: name="$pname"