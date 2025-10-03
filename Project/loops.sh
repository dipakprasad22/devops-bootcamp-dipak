#!/bin/bash

#---------------[Example-1]---------------------------#
# for fruit in apple banana cherry
# do
#     echo "I like $fruit"
# done

#---------------[Example-2]---------------------------#
# for i in {1..5}
# do
#     echo "Iteration $i"
# done

#---------------[Example-3]---------------------------#
# count=1
# while [ $count -le 5 ]
# do
#     echo "Count is $count"
#     ((count++))
# done

#---------------[Example-4]---------------------------#
# echo "Enter a number:"
# read -r number
# sum=0
# for (( i=1; i<=number; i++ ))
# do
#     sum=$((sum + i))
# done
# echo "The sum of numbers from 1 to $number is $sum"

#---------------[Example-5]---------------------------#
# echo "Enter a number:"
# read -r number
# factorial=1
# for (( i=1; i<=number; i++ ))
# do
#     factorial=$((factorial * i))
# done
# echo "The factorial of $number is $factorial"

#---------------[Example-6]---------------------------#
# for file in *
# do
#     if [ -f "$file" ]; then
#         echo "File: $file"
#     elif [ -d "$file" ]; then
#         echo "Directory: $file"
#     fi
# done

#---------------[Example-7]---------------------------#
# for (( i=1; i<=10; i++ ))
# do
#     if [ $((i % 2)) -eq 0 ]; then
#         echo "$i is even"
#     else
#         echo "$i is odd"
#     fi
# done

#---------------[Example-8]---------------------------#
# for i in {1..5}
# do
#     if [ "$i" -eq 3 ]; then
#         echo "Skipping number 3"
#         continue
#     fi
#     echo "Number: $i"
# done
# echo "Loop finished."

#---------------[Example-9]---------------------------#
# count=1
# while [ $count -le 10 ]
# do
#     if [ $count -eq 6 ]; then
#         echo "Breaking the loop at count 6"
#         break
#     fi
#     echo "Count is $count"
#     ((count++))
# done
# echo "Loop ended."

#---------------[Example-10]--------------------------#
for i in {1..5}
do
    echo "Outer loop iteration $i"
    for j in {1..3}
    do
        echo "  Inner loop iteration $j"
    done
done
echo "All loops completed."






