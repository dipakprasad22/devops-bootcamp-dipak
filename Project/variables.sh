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

#---------------[Example-4]---------------------------#
echo "Enter your age:"
read -r age
if [ "$age" -lt 18 ]; then

    echo "You are a minor."
elif [ "$age" -ge 18 ] && [ "$age" -lt 65 ]; then
    echo "You are an adult."
else
    echo "You are a senior citizen."
fi  

#---------------[Example-5]---------------------------#
echo "Enter a character:"
read -r char
if [[ "$char" =~ [a-zA-Z] ]]; then
    echo "'$char' is an alphabet."
elif [[ "$char" =~ [0-9] ]]; then
    echo "'$char' is a digit."      
else
    echo "'$char' is a special character."
fi

#---------------[Example-6]---------------------------#
echo "Enter a year:"
read -r year
if (( (year % 4 == 0 && year % 100 != 0)
        || (year % 400 == 0) )); then
        echo "$year is a leap year."
    else
        echo "$year is not a leap year."
fi

#---------------[Example-7]---------------------------#
echo "Enter three numbers:"
read -r a b c
if [ "$a" -ge "$b" ] && [ "$a" -ge "$c" ]; then
    echo "$a is the largest number."
elif [ "$b" -ge "$a" ] && [ "$b" -ge "$c" ]; then
    echo "$b is the largest number."
else
    echo "$c is the largest number."
fi

#---------------[Example-8]---------------------------#
echo "Enter a number:"
read -r num
if [ "$num" -lt 0 ]; then
    echo "$num is negative."
elif [ "$num" -eq 0 ]; then
    echo "$num is zero."
else
    echo "$num is positive."
fi


