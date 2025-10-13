#!/bin/bash
# Start Flask dashboard in background
python3 /app/dashboard.py &

# Start monitor script in foreground
exec /bin/bash /app/monitor_container.sh live