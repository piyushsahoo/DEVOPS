#!/bin/bash

# Q: Explain expr $a + $b and why we use \* for multiplication in Bash
# A: expr is used for evaluating expressions.
# expr $a + $b adds the values of variables a and b.

# * is a shell wildcard (glob) used for matching filenames.
# So, you must escape it using a backslash (\*) or quote it to prevent shell expansion.

# Q2 Use sed to remove all blank lines from a file

# A:

sed '/^[[:space:]]*$/d' blankFile.txt

# Q: Write a script to:
# Read all .html files in a folder 
# Create .php copies using basename and cp

# A:

for file in *.html
do 
  base=$(basename "$file".html)
  cp "$file" "$base.php"
done

echo "Copying done"
