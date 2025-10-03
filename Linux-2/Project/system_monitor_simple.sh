#!/bin/bash
# Simple system monitor with email alerts (max 50 lines)

# Thresholds
CPU_LIMIT=5
MEM_LIMIT=15
EMAIL="admin@example.com"

# Function to get CPU usage
get_cpu_usage() {
    top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}' | sed 's/%us,//' | sed 's/%sy,//'
}

# Function to get memory usage
get_memory_usage() {
    free | awk '/Mem:/ { printf "%.0f", $3/$2 * 100.0 }'
}

# Function to send email alert
send_email_alert() {
    local subject="$1"
    local message="$2"
    echo "EMAIL ALERT:"
    echo "To: $EMAIL"
    echo "Subject: $subject"
    echo "Message: $message"
    echo "Timestamp: $(date)"
    echo "---"
}

# Function to check thresholds and alert
check_and_alert() {
    local cpu_usage
    cpu_usage=$(get_cpu_usage)
    local mem_usage
    mem_usage=$(get_memory_usage)
    
    echo "$(date +"%H:%M:%S") - CPU: ${cpu_usage}% | Memory: ${mem_usage}%"
    
    # Check CPU threshold
    if (( $(echo "$cpu_usage > $CPU_LIMIT" | bc -l) )); then
        send_email_alert "HIGH CPU ALERT" "CPU usage is ${cpu_usage}% (limit: ${CPU_LIMIT}%)"
    fi
    
    # Check memory threshold
    if (( $(echo "$mem_usage > $MEM_LIMIT" | bc -l) )); then
        send_email_alert "HIGH MEMORY ALERT" "Memory usage is ${mem_usage}% (limit: ${MEM_LIMIT}%)"
    fi
}

# Main monitoring loop
echo "Starting system monitoring..."
echo "CPU Limit: ${CPU_LIMIT}% | Memory Limit: ${MEM_LIMIT}%"
echo "Alert Email: $EMAIL"
echo "---"

for i in {1..10}; do
    echo "Iteration: $i"
    check_and_alert
    sleep 15
done

echo "Monitoring complete."