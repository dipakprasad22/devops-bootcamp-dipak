#!/bin/bash

#---------------[Example-1]---------------------------#
value=3

if [ $value -gt 5 ]; then
    echo "The value is greater than 5."
else
    echo "The value is 5 or less."
fi


#---------------[Example-2]---------------------------#
echo "Enter a number:"
read -r number

if [ $((number % 2)) -eq 0 ]; then
    echo "$number is even."
else
    echo "$number is odd."
fi


#---------------[Example-3]---------------------------#
echo "Enter a filename:"
read -r filename

if [ -e "$filename" ]; then
    echo "The file '$filename' exists."
else
    echo "The file '$filename' does not exist."
fi