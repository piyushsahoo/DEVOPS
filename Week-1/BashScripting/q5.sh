#!/bin/bash
file="file.log"
grep -n "ERROR" "$file" | awk -F: '{print "Line: " $1,": " $4}'