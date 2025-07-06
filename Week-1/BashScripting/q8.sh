#!/bin/bash

read -p "Enter password" pass

if [[ ${#pass} -ge 8 && "$pass" =~ [0-9] && "$pass" =~ [^a-zA-Z0-9] ]]; then
  echo "Strong password"
else 
  echo "Weak password"
fi

