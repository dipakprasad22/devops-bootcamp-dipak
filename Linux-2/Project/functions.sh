#!/bin/bash
# Example functions in bash scripting
my_basic_function() {
    echo "Hello from my_basic_function!"
}

print_time_cpu_mem() {
    local time_now cpu_usage mem_usage
    time_now=$(date +"%H:%M:%S")
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    mem_usage=$(free -m | awk '/Mem:/ { printf "%.2f", $3/$2 * 100.0 }')
    echo "time:$time_now:CPU:$cpu_usage:MEM:$mem_usage"
}
# Script: monitor_resources.sh
# Description: Monitors system resources every 2 seconds for 10 iterations.

monitor_resources() {
    echo "Starting resource monitoring..."
    for i in {1..10}; do
        echo "Iteration: $i"
        print_time_cpu_mem
        sleep 2
    done
    echo "Resource monitoring complete."
}

monitor_resources
