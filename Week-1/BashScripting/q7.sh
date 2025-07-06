#!/bin/bash

file="example.csv"

cat "$file" | sed 's/[;\t]/,/g' | sed 's/ *, */,/g' | sed 's/^*//; s/ *$//' | sed 's/,,*/,/g' | awk ' NR > 1 {print $1, $2, $3}' > one.csv
