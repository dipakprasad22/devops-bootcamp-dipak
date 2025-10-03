#!/bin/bash
# Examples of various for loops in bash scripting

#----Simple numeric iteration----#
for i in 1 2 3 4 5
do
echo $i
done


#----Simple list iteration----#
for fruit in apple banana orange grape
do
    echo "I like $fruit"
done

#----Count from 1 to 10 ----#
for ((i=1; i<=10; i++))
do
    echo "Number: $i"
    # Calculate square
    square=$((i * i))
    echo "Square of $i is $square"
done


# vi hosts
# for i in `cat hosts`
# do
# scp nginx.conf ec2-user@$i:/home/ec2-user
# done                                                                                                        100%   22     9.2KB/s   00:00    


#----Process all .txt files in current directory----#
for file in *.txt
do
    if [ -f "$file" ]; then
        echo "Processing: $file"
        lines=$(wc -l < "$file")
        echo "  Lines: $lines"
        words=$(wc -w < "$file")
        echo "  Words: $words"
        echo "---"
    fi
done


#----Find running processes and analyze memory usage----#
high_memory_processes=()

for pid in $(ps -eo pid --no-headers)
do
    # Get memory usage for each process
    mem=$(ps -p $pid -o rss= 2>/dev/null)
    
    if [ -n "$mem" ] && [ "$mem" -gt 50000 ]; then  # > 50MB
        process_name=$(ps -p $pid -o comm= 2>/dev/null)
        high_memory_processes+=("$process_name:$mem")
        echo "High memory process: $process_name (PID: $pid, Memory: ${mem}KB)"
    fi
done

echo "Found ${#high_memory_processes[@]} high memory processes"


while true; do
  echo "Press [CTRL+C] to stop.."
  sleep 1
done

a=3
while [ "$a" -lt 10 ]; do
echo "$a"
a=$(expr "$a" + 1)
done