#!/bin/bash

echo "Hostname is :- "
$HOSTNAME
echo "IP Address :- "
ifconfig | grep inet | grep -v 127.0.0.1 | awk '{print $2}'| head -n 1
echo "CPU INFO:- "
grep "model name" /proc/cpuinfo | head -n 1
echo "Total memory :- "
free | grep Mem | awk '{print $2}'
echo "Disk Usage:- "
df -h