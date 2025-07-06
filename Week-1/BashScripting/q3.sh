#!/bin/bash

df -h / | awk 'NR>1 {
  gsub("%","", $5)
  if ($5 > 80)
    print "Alert 80% full"
  else
    print "OK"
}'



