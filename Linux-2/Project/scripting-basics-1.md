# Advanced Shell Concepts - Wildcards, String Manipulation, and More 🚀

This guide covers advanced shell scripting concepts including wildcards, pattern matching, string manipulation, command execution, and system utilities.

## Table of Contents
1. [Wildcards and Pattern Matching](#wildcards-and-pattern-matching)
2. [Advanced String Manipulation](#advanced-string-manipulation)
3. [Command Execution](#command-execution)
4. [Process Substitution](#process-substitution)
5. [Regular Expressions](#regular-expressions)
6. [Text Processing Tools](#text-processing-tools)
7. [File Descriptors and Redirection](#file-descriptors-and-redirection)
8. [Job Control](#job-control)
9. [Signal Handling](#signal-handling)
10. [Here Documents](#here-documents)
11. [Arithmetic Operations](#arithmetic-operations)
12. [Conditional Expressions](#conditional-expressions)
13. [Shell Parameter Expansion](#shell-parameter-expansion)
14. [Environment Variables](#environment-variables)

## Wildcards and Pattern Matching

### Basic Wildcards

```bash
#!/bin/bash

# * - Matches zero or more characters
ls *.txt              # All .txt files
ls test*              # Files starting with "test"
ls *test*             # Files containing "test"

# ? - Matches exactly one character
ls file?.txt          # file1.txt, fileA.txt, but not file10.txt
ls ???.sh             # All .sh files with 3-letter names

# [] - Character class, matches any single character in the brackets
ls file[123].txt      # file1.txt, file2.txt, file3.txt
ls file[a-z].txt      # filea.txt through filez.txt
ls file[A-Z].txt      # fileA.txt through fileZ.txt
ls file[0-9].txt      # file0.txt through file9.txt
ls file[!0-9].txt     # Files NOT ending with a digit

# {} - Brace expansion (not a wildcard, but similar usage)
echo {A,B,C}.txt      # A.txt B.txt C.txt
echo file{1..5}.txt   # file1.txt file2.txt file3.txt file4.txt file5.txt
echo {a..z}           # a b c ... z
mkdir dir{1,2,3}      # Creates dir1, dir2, dir3

# Combining wildcards
ls *.{jpg,png,gif}    # All image files
ls [A-Z]*.txt         # .txt files starting with uppercase letter
ls *[0-9].*           # Files with a digit before the extension
```

### Extended Globbing

```bash
#!/bin/bash

# Enable extended globbing
shopt -s extglob

# ?(pattern) - Matches zero or one occurrence
ls file?(s).txt       # file.txt or files.txt

# *(pattern) - Matches zero or more occurrences
ls file*(s).txt       # file.txt, files.txt, filess.txt, etc.

# +(pattern) - Matches one or more occurrences
ls file+(s).txt       # files.txt, filess.txt, but not file.txt

# @(pattern|pattern) - Matches exactly one pattern
ls file@(1|2|3).txt   # file1.txt, file2.txt, or file3.txt

# !(pattern) - Matches anything except the pattern
ls !(*.txt)           # All files except .txt files
ls !(file1|file2).txt # All .txt files except file1.txt and file2.txt

# Practical examples
# Remove all files except .log files
rm !(*.log)

# Copy all image files
cp *.@(jpg|jpeg|png|gif) /backup/images/

# List all script files
ls *.@(sh|bash|py|pl)
```

### Pattern Matching in Case Statements

```bash
#!/bin/bash

read -p "Enter filename: " filename

case "$filename" in
    *.txt)
        echo "Text file"
        ;;
    *.{jpg,jpeg,png,gif})
        echo "Image file"
        ;;
    *.{mp3,wav,flac})
        echo "Audio file"
        ;;
    *.{mp4,avi,mkv})
        echo "Video file"
        ;;
    [A-Z]*)
        echo "File starts with uppercase letter"
        ;;
    *[0-9]*)
        echo "File contains numbers"
        ;;
    *)
        echo "Unknown file type"
        ;;
esac
```

## Advanced String Manipulation

### String Operations

```bash
#!/bin/bash

# String variable
string="Hello World from Shell Scripting"
filename="/home/user/documents/report.txt"
email="user@example.com"

# Length
echo "Length: ${#string}"

# Substring extraction
echo "First 5 chars: ${string:0:5}"
echo "From position 6: ${string:6}"
echo "Last 10 chars: ${string: -10}"
echo "From 6, length 5: ${string:6:5}"

# Pattern removal (from beginning)
echo "Remove shortest match from start: ${filename#*/}"
echo "Remove longest match from start: ${filename##*/}"

# Pattern removal (from end)
echo "Remove shortest match from end: ${filename%/*}"
echo "Remove longest match from end: ${filename%%/*}"

# String replacement
echo "Replace first occurrence: ${string/World/Universe}"
echo "Replace all occurrences: ${string//l/L}"
echo "Replace if at start: ${string/#Hello/Hi}"
echo "Replace if at end: ${string/%ing/ed}"

# Case conversion (Bash 4+)
echo "Uppercase: ${string^^}"
echo "Lowercase: ${string,,}"
echo "Toggle first char: ${string^}"
echo "Toggle all: ${string~~}"

# Default values
unset var
echo "Default if unset: ${var:-default}"
echo "Default and assign: ${var:=default}"
echo "Error if unset: ${var:?Variable not set}"
echo "Alternate value if set: ${var:+alternate}"
```

### Advanced String Patterns

```bash
#!/bin/bash

# Extract parts of strings
url="https://www.example.com/path/to/file.html"
protocol="${url%%://*}"
domain="${url#*://}"
domain="${domain%%/*}"
path="${url#*://*/}"
file="${url##*/}"

echo "Protocol: $protocol"
echo "Domain: $domain"
echo "Path: $path"
echo "File: $file"

# Email parsing
email="john.doe@example.com"
username="${email%@*}"
domain="${email#*@}"

echo "Username: $username"
echo "Domain: $domain"

# Version string parsing
version="v2.5.3-beta"
major="${version#v}"
major="${major%%.*}"
minor="${version#*.}"
minor="${minor%%.*}"
patch="${version#*.*.}"
patch="${patch%%-*}"
tag="${version#*-}"

echo "Major: $major"
echo "Minor: $minor"
echo "Patch: $patch"
echo "Tag: $tag"
```

## Command Execution

### Command Substitution

```bash
#!/bin/bash

# Legacy syntax (backticks)
current_date=`date`
echo "Today is: $current_date"

# Modern syntax (recommended)
current_date=$(date)
echo "Today is: $current_date"

# Nested command substitution
files_count=$(ls $(pwd) | wc -l)
echo "Number of files: $files_count"

# Command substitution in loops
for user in $(cat /etc/passwd | cut -d: -f1); do
    echo "User: $user"
done

# Multiple commands
system_info=$(uname -a; date; whoami)
echo "System info: $system_info"

# Command substitution with pipes
largest_file=$(du -sh * | sort -rh | head -1)
echo "Largest file: $largest_file"
```

### exec Command

```bash
#!/bin/bash

# Replace current shell with command
# exec ls -l  # This would replace the shell

# Redirect file descriptors
exec 3>&1  # Save stdout
exec 1>output.log  # Redirect stdout to file
echo "This goes to the file"
exec 1>&3  # Restore stdout
exec 3>&-  # Close fd 3

# Open file for reading
exec 3<input.txt
while read -u 3 line; do
    echo "Line: $line"
done
exec 3<&-  # Close fd 3

# Logging script example
LOG_FILE="/tmp/script.log"
exec 1> >(tee -a "$LOG_FILE")
exec 2>&1
echo "This is logged to both screen and file"
```

### xargs Command

```bash
#!/bin/bash

# Basic xargs usage
find . -name "*.txt" | xargs wc -l

# With placeholder
find . -name "*.log" | xargs -I {} mv {} {}.old

# Parallel execution
find . -name "*.jpg" | xargs -P 4 -I {} convert {} -resize 50% small_{}

# Handle spaces in filenames
find . -name "*.txt" -print0 | xargs -0 grep "pattern"

# With confirmation
echo "file1 file2 file3" | xargs -p rm

# Limited arguments per command
echo {1..1000} | xargs -n 100 echo

# Build complex commands
cat urls.txt | xargs -I {} curl -O {}
```

## Process Substitution

### Basic Process Substitution

```bash
#!/bin/bash

# Process substitution for input
diff <(sort file1.txt) <(sort file2.txt)

# Process substitution for output
tee >(grep ERROR > errors.log) >(grep WARN > warnings.log)

# Compare command outputs
diff <(ls dir1) <(ls dir2)

# Multiple process substitutions
paste <(cut -d: -f1 /etc/passwd) <(cut -d: -f3 /etc/passwd)

# With while loop
while read user id; do
    echo "User $user has ID $id"
done < <(paste <(cut -d: -f1 /etc/passwd) <(cut -d: -f3 /etc/passwd))

# Log filtering
command 2> >(grep -v "harmless" >&2)
```

### Advanced Process Substitution

```bash
#!/bin/bash

# Compare sorted versions of files
comm <(sort file1.txt | uniq) <(sort file2.txt | uniq)

# Monitor multiple log files
tail -f /var/log/syslog > >(grep -i error) &
tail -f /var/log/auth.log > >(grep -i failed) &

# Process multiple inputs
join <(sort file1.txt) <(sort file2.txt)

# Complex pipeline with process substitution
cat data.txt | tee >(grep pattern1 > matches1.txt) \
                   >(grep pattern2 > matches2.txt) \
                   >(grep pattern3 > matches3.txt) > /dev/null
```

## Regular Expressions

### Basic Regular Expressions

```bash
#!/bin/bash

# grep with regular expressions
grep '^[A-Z]' file.txt              # Lines starting with uppercase
grep '[0-9]$' file.txt              # Lines ending with digit
grep '^[[:space:]]*$' file.txt      # Empty lines (only whitespace)
grep '\<word\>' file.txt            # Whole word match

# Extended regular expressions (grep -E or egrep)
grep -E '(cat|dog)' file.txt        # Match cat or dog
grep -E '[0-9]{3}-[0-9]{4}' phones.txt  # Phone numbers xxx-xxxx
grep -E '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' emails.txt

# sed with regular expressions
sed 's/[0-9]\+/NUMBER/g' file.txt   # Replace numbers
sed '/^#/d' config.txt              # Delete comment lines
sed 's/\([A-Z]\)\([A-Z]*\)/\1\L\2/g' file.txt  # Capitalize first letter only

# Using regex in bash
if [[ "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
    echo "Valid email"
fi

# Extract matched parts
if [[ "$string" =~ ([0-9]+)\.([0-9]+)\.([0-9]+) ]]; then
    major="${BASH_REMATCH[1]}"
    minor="${BASH_REMATCH[2]}"
    patch="${BASH_REMATCH[3]}"
fi
```

### Advanced Regular Expressions

```bash
#!/bin/bash

# Lookahead and lookbehind (with grep -P)
grep -P '(?<=@)\w+\.\w+' emails.txt     # Domain after @
grep -P '\d+(?=\s*dollars)' prices.txt  # Number before "dollars"

# Complex patterns
# IP address validation
ip_regex='^([0-9]{1,3}\.){3}[0-9]{1,3}$'
if [[ "$ip" =~ $ip_regex ]]; then
    echo "Valid IP"
fi

# URL extraction
url_regex='https?://[^[:space:]]+'
grep -oE "$url_regex" webpage.html

# Credit card masking
echo "1234-5678-9012-3456" | sed -E 's/([0-9]{4}-){2}[0-9]{4}/XXXX-XXXX-XXXX-\1/'

# Password validation
password_regex='^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[@#$%]).{8,}$'
if [[ "$password" =~ $password_regex ]]; then
    echo "Strong password"
fi
```

## Text Processing Tools

### awk

```bash
#!/bin/bash

# Basic awk usage
awk '{print $1, $3}' file.txt              # Print columns 1 and 3
awk -F: '{print $1, $7}' /etc/passwd       # Use : as delimiter
awk 'NR > 1' file.txt                      # Skip header line
awk 'length($0) > 80' file.txt             # Lines longer than 80 chars

# Pattern matching
awk '/pattern/ {print $2}' file.txt        # Print column 2 for matching lines
awk '$3 > 100' data.txt                    # Lines where column 3 > 100
awk '$1 ~ /^[A-Z]/' file.txt              # Column 1 starts with uppercase

# Variables and calculations
awk '{sum += $3} END {print sum}' data.txt # Sum column 3
awk '{sum += $3; count++} END {print sum/count}' data.txt  # Average

# Multiple patterns and actions
awk '
    BEGIN { print "Report Header" }
    /ERROR/ { errors++ }
    /WARNING/ { warnings++ }
    END { 
        print "Errors:", errors
        print "Warnings:", warnings
    }
' logfile.txt

# Field manipulation
awk '{ $3 = $3 * 1.1; print }' prices.txt  # Increase column 3 by 10%
awk '{ temp = $1; $1 = $2; $2 = temp; print }' file.txt  # Swap columns
```

### sed

```bash
#!/bin/bash

# Basic sed operations
sed 's/old/new/' file.txt                  # Replace first occurrence
sed 's/old/new/g' file.txt                 # Replace all occurrences
sed '3s/old/new/' file.txt                 # Replace only on line 3
sed '1,5s/old/new/' file.txt               # Replace on lines 1-5

# Delete operations
sed '/pattern/d' file.txt                  # Delete matching lines
sed '3d' file.txt                          # Delete line 3
sed '3,5d' file.txt                        # Delete lines 3-5
sed '$d' file.txt                          # Delete last line

# Insert and append
sed '3i\New line' file.txt                 # Insert before line 3
sed '3a\New line' file.txt                 # Append after line 3
sed '1i\#!/bin/bash' script.sh             # Add shebang

# Multiple operations
sed -e 's/old/new/g' -e '/pattern/d' file.txt
sed '
    s/old/new/g
    /pattern/d
    3i\New line
' file.txt

# In-place editing
sed -i.bak 's/old/new/g' file.txt          # Edit with backup
sed -i 's/old/new/g' file.txt              # Edit without backup

# Advanced sed
sed -n '10,20p' file.txt                   # Print lines 10-20
sed 's/\([A-Z]\)\([a-z]*\)/\2\1/g' file.txt  # Swap case pattern
sed '/start/,/end/d' file.txt              # Delete between patterns
```

### cut, sort, uniq

```bash
#!/bin/bash

# cut command
cut -d: -f1 /etc/passwd                    # First field with : delimiter
cut -d, -f1,3 data.csv                     # Fields 1 and 3
cut -c1-10 file.txt                        # Characters 1-10
cut -d' ' -f2- file.txt                    # From field 2 to end

# sort command
sort file.txt                              # Alphabetical sort
sort -n numbers.txt                        # Numerical sort
sort -r file.txt                           # Reverse sort
sort -k2,2 data.txt                        # Sort by column 2
sort -t: -k3n /etc/passwd                  # Sort by UID
sort -u file.txt                           # Sort and remove duplicates

# uniq command
uniq file.txt                              # Remove adjacent duplicates
uniq -c file.txt                           # Count occurrences
uniq -d file.txt                           # Show only duplicates
uniq -u file.txt                           # Show only unique lines

# Combining tools
cut -d: -f7 /etc/passwd | sort | uniq -c   # Count shells
ps aux | sort -nk3 | tail -5               # Top 5 CPU users
cat access.log | awk '{print $1}' | sort | uniq -c | sort -nr | head -10
```

## File Descriptors and Redirection

### Standard File Descriptors

```bash
#!/bin/bash

# Standard file descriptors
# 0 - stdin
# 1 - stdout
# 2 - stderr

# Basic redirection
command > output.txt      # Redirect stdout
command 2> errors.txt     # Redirect stderr
command &> all.txt        # Redirect both stdout and stderr
command >> append.txt     # Append to file

# Advanced redirection
command 2>&1              # Redirect stderr to stdout
command 1>&2              # Redirect stdout to stderr
command > output.txt 2>&1 # Both to same file

# Swapping stdout and stderr
command 3>&1 1>&2 2>&3 3>&-

# Suppress output
command > /dev/null 2>&1  # Discard all output
command 2> /dev/null      # Discard only errors
```

### Custom File Descriptors

```bash
#!/bin/bash

# Opening custom file descriptors
exec 3< input.txt         # Open fd 3 for reading
exec 4> output.txt        # Open fd 4 for writing
exec 5<> temp.txt         # Open fd 5 for read/write

# Using custom file descriptors
while read -u 3 line; do
    echo "Processing: $line" >&4
done

# Closing file descriptors
exec 3<&-                 # Close fd 3
exec 4>&-                 # Close fd 4
exec 5>&-                 # Close fd 5

# Advanced usage
{
    echo "Starting process..."
    command1
    command2
} > process.log 2>&1

# Here string with file descriptor
exec 3<<< "Hello World"
read -u 3 message
echo "Message: $message"
exec 3<&-
```

## Job Control

### Background and Foreground Jobs

```bash
#!/bin/bash

# Running jobs in background
long_command &
pid=$!
echo "Started background job with PID: $pid"

# Multiple background jobs
command1 & pid1=$!
command2 & pid2=$!
command3 & pid3=$!

# Wait for specific job
wait $pid1
echo "Command1 finished"

# Wait for all background jobs
wait
echo "All background jobs completed"

# Job control commands
jobs                      # List jobs
fg %1                     # Bring job 1 to foreground
bg %1                     # Send job 1 to background
kill %1                   # Kill job 1

# Disown jobs
long_command &
disown                    # Job continues after shell exit
disown -h %1              # Job ignores SIGHUP
```

### Process Management

```bash
#!/bin/bash

# Process monitoring
ps aux | grep process_name
pgrep -f "pattern"
pidof process_name

# Process tree
pstree -p $$

# Killing processes
kill $pid                 # Terminate process
kill -9 $pid             # Force kill
killall process_name      # Kill by name
pkill -f "pattern"        # Kill by pattern

# Nice values
nice -n 10 command        # Run with lower priority
renice -n 5 -p $pid      # Change priority

# Process limits
ulimit -n                 # File descriptor limit
ulimit -u                 # Process limit
ulimit -m                 # Memory limit

# Timeout command
timeout 10s command       # Kill after 10 seconds
timeout --preserve-status 10s command
```

## Signal Handling

### Basic Signal Handling

```bash
#!/bin/bash

# Trap signals
trap 'echo "Ctrl+C pressed"' SIGINT
trap 'echo "Script terminated"' SIGTERM
trap 'cleanup' EXIT

# Cleanup function
cleanup() {
    echo "Cleaning up..."
    rm -f /tmp/tempfile*
    kill $(jobs -p) 2>/dev/null
}

# Ignore signals
trap '' SIGINT            # Ignore Ctrl+C
trap '' SIGTERM          # Ignore termination

# Reset signal handling
trap - SIGINT            # Reset to default

# Multiple signals
trap 'handler' SIGINT SIGTERM SIGHUP

# Signal handler function
handler() {
    case $1 in
        SIGINT)
            echo "Interrupted"
            ;;
        SIGTERM)
            echo "Terminated"
            ;;
        SIGHUP)
            echo "Hangup"
            ;;
    esac
}
```

### Advanced Signal Handling

```bash
#!/bin/bash

# Graceful shutdown
running=true
trap 'running=false' SIGTERM SIGINT

while $running; do
    # Main loop
    sleep 1
done

echo "Shutting down gracefully..."

# Reload configuration
trap 'reload_config' SIGHUP

reload_config() {
    echo "Reloading configuration..."
    source /etc/myapp/config
}

# Child process management
children=()

start_child() {
    command &
    children+=($!)
}

cleanup_children() {
    for pid in "${children[@]}"; do
        kill "$pid" 2>/dev/null
    done
    wait
}

trap 'cleanup_children' EXIT

# Signal forwarding
forward_signal() {
    for pid in "${children[@]}"; do
        kill -$1 "$pid" 2>/dev/null
    done
}

trap 'forward_signal SIGTERM' SIGTERM
trap 'forward_signal SIGINT' SIGINT
```

## Here Documents

### Basic Here Documents

```bash
#!/bin/bash

# Simple here document
cat << EOF
This is a multi-line
text that will be
printed exactly as shown.
EOF

# Here document with variables
name="John"
cat << EOF
Hello, $name!
Welcome to the system.
Today is $(date)
EOF

# Here document with command
mysql -u user -p password << EOF
USE database;
SELECT * FROM users;
EXIT;
EOF

# Suppress leading tabs
cat <<- EOF
	This text has
	leading tabs that
	will be removed
EOF

# Here document to file
cat > config.txt << EOF
server=localhost
port=8080
debug=true
EOF
```

### Advanced Here Documents

```bash
#!/bin/bash

# Quoted here document (no expansion)
cat << 'EOF'
This $variable will not expand
Neither will $(this command)
EOF

# Here document in function
create_script() {
    cat > "$1" << 'EOF'
#!/bin/bash
echo "Generated script"
echo "Created on: $(date)"
EOF
    chmod +x "$1"
}

# Here document with indirection
exec 3<< EOF
First line
Second line
Third line
EOF

while read -u 3 line; do
    echo "Read: $line"
done
exec 3<&-

# Here string
while read -r line; do
    echo "Line: $line"
done <<< "Single line input"

# Multiple here documents
cat << EOF1; cat << EOF2
First document
EOF1
Second document
EOF2
```

## Arithmetic Operations

### Basic Arithmetic

```bash
#!/bin/bash

# Arithmetic expansion
result=$((5 + 3))
result=$((10 - 4))
result=$((6 * 7))
result=$((20 / 4))
result=$((17 % 5))         # Modulo
result=$((2 ** 8))         # Exponentiation

# Increment/decrement
((count++))
((count--))
((count += 5))
((count *= 2))

# let command
let result=5+3
let "result = 5 + 3"
let count++

# expr command (legacy)
result=$(expr 5 + 3)
result=$(expr 10 \* 2)     # Escape special chars

# Floating point with bc
result=$(echo "scale=2; 10 / 3" | bc)
result=$(echo "scale=4; 22 / 7" | bc)

# Complex calculations with bc
result=$(bc << EOF
scale=4
pi = 4 * a(1)
r = 5
area = pi * r^2
area
EOF
)
```

### Advanced Arithmetic

```bash
#!/bin/bash

# Bitwise operations
result=$((5 & 3))          # AND
result=$((5 | 3))          # OR
result=$((5 ^ 3))          # XOR
result=$((~5))             # NOT
result=$((5 << 2))         # Left shift
result=$((20 >> 2))        # Right shift

# Compound operations
((x = 5, y = 10, sum = x + y))
echo "Sum is $sum"

# Ternary operator
((result = (a > b) ? a : b))

# Random numbers
random=$((RANDOM % 100))   # 0-99
random=$((RANDOM % 100 + 1))  # 1-100

# Mathematical functions with awk
result=$(awk 'BEGIN {print sin(1)}')
result=$(awk 'BEGIN {print sqrt(16)}')
result=$(awk 'BEGIN {print log(10)}')

# Advanced bc calculations
calculate() {
    bc -l << EOF
define factorial(n) {
    if (n <= 1) return 1
    return n * factorial(n-1)
}

define fibonacci(n) {
    if (n <= 1) return n
    return fibonacci(n-1) + fibonacci(n-2)
}

factorial($1)
fibonacci($2)
EOF
}

result=$(calculate 5 10)
```

## Conditional Expressions

### File Test Operators

```bash
#!/bin/bash

# File existence and type
[[ -e file ]]              # Exists
[[ -f file ]]              # Regular file
[[ -d file ]]              # Directory
[[ -L file ]]              # Symbolic link
[[ -p file ]]              # Named pipe
[[ -S file ]]              # Socket
[[ -b file ]]              # Block device
[[ -c file ]]              # Character device

# File permissions
[[ -r file ]]              # Readable
[[ -w file ]]              # Writable
[[ -x file ]]              # Executable
[[ -u file ]]              # Setuid bit set
[[ -g file ]]              # Setgid bit set
[[ -k file ]]              # Sticky bit set

# File characteristics
[[ -s file ]]              # Size greater than zero
[[ -t fd ]]                # File descriptor is terminal
[[ -O file ]]              # You own the file
[[ -G file ]]              # Group ID matches yours

# File comparison
[[ file1 -nt file2 ]]      # file1 newer than file2
[[ file1 -ot file2 ]]      # file1 older than file2
[[ file1 -ef file2 ]]      # Same file (hard link)
```

### String and Numeric Comparisons

```bash
#!/bin/bash

# String comparisons
[[ "$str1" == "$str2" ]]   # Equal
[[ "$str1" != "$str2" ]]   # Not equal
[[ "$str1" < "$str2" ]]    # Less than (alphabetically)
[[ "$str1" > "$str2" ]]    # Greater than
[[ -z "$str" ]]            # Empty string
[[ -n "$str" ]]            # Non-empty string

# Pattern matching
[[ "$str" == pattern* ]]   # Glob pattern
[[ "$str" =~ regex ]]      # Regular expression

# Numeric comparisons
[[ $num1 -eq $num2 ]]      # Equal
[[ $num1 -ne $num2 ]]      # Not equal
[[ $num1 -lt $num2 ]]      # Less than
[[ $num1 -le $num2 ]]      # Less than or equal
[[ $num1 -gt $num2 ]]      # Greater than
[[ $num1 -ge $num2 ]]      # Greater than or equal

# Compound conditions
[[ condition1 && condition2 ]]  # AND
[[ condition1 || condition2 ]]  # OR
[[ ! condition ]]              # NOT

# Arithmetic conditions
(( num1 < num2 ))
(( num1 == num2 ))
(( num1 > 0 && num1 < 100 ))
```

## Shell Parameter Expansion

### Advanced Parameter Expansion

```bash
#!/bin/bash

# Indirect expansion
var="USER"
echo ${!var}               # Expands to value of $USER

# Name prefix matching
echo ${!BASH*}             # All variables starting with BASH

# Array operations
array=(one two three four five)
echo ${array[@]}           # All elements
echo ${#array[@]}          # Number of elements
echo ${array[@]:2:2}       # Slice: elements 2-3
echo ${array[@]#t*}        # Remove prefix from each
echo ${array[@]%e}         # Remove suffix from each

# Case modification
name="john doe"
echo ${name^}              # First char uppercase
echo ${name^^}             # All uppercase
echo ${name,}              # First char lowercase
echo ${name,,}             # All lowercase
echo ${name~}              # Toggle first char
echo ${name~~}             # Toggle all chars

# Parameter transformation
echo ${parameter@Q}        # Quote for reuse as input
echo ${parameter@E}        # Expand escape sequences
echo ${parameter@P}        # Expand prompt strings
echo ${parameter@A}        # Assignment format
echo ${parameter@a}        # Attributes

# Pattern replacement
text="foo bar foo baz"
echo ${text/foo/FOO}       # Replace first
echo ${text//foo/FOO}      # Replace all
echo ${text/#foo/FOO}      # Replace if at start
echo ${text/%baz/BAZ}      # Replace if at end

# Length operations
echo ${#text}              # Length of string
echo ${#array[@]}          # Number of array elements
echo ${#array[2]}          # Length of element 2
```

### Complex Expansions

```bash
#!/bin/bash

# Nested parameter expansion
default="default_value"
value=${var:-${default}}

# Conditional assignment
: ${var:=default}          # Assign if unset
: ${var?Error message}     # Error if unset

# Array manipulation
unset array[2]             # Remove element
array+=(new1 new2)         # Append elements
array=("${array[@]}" new)  # Another way to append

# Associative arrays
declare -A hash
hash[key1]="value1"
hash[key2]="value2"
echo ${hash[key1]}
echo ${!hash[@]}           # All keys
echo ${hash[@]}            # All values

# Complex transformations
path="/home/user/documents/file.txt"
dir=${path%/*}
file=${path##*/}
name=${file%.*}
ext=${file##*.}

# Multiple operations
result=${var^^}            # Uppercase
result=${result// /_}      # Replace spaces
result=${result#_}         # Remove leading underscore
```

## Environment Variables

### Managing Environment Variables

```bash
#!/bin/bash

# Export variables
export VAR="value"
export -f function_name    # Export function

# Unset variables
unset VAR
unset -f function_name     # Unset function

# List environment
env                        # All environment variables
export                     # All exported variables
declare -x                 # Another way to list exports

# Common environment variables
echo $HOME                 # Home directory
echo $USER                 # Current user
echo $PATH                 # Executable search path
echo $PWD                  # Current directory
echo $OLDPWD              # Previous directory
echo $SHELL               # Current shell
echo $TERM                # Terminal type
echo $LANG                # Language/locale

# Modifying PATH
PATH="/new/path:$PATH"     # Prepend
PATH="$PATH:/new/path"     # Append
PATH=${PATH//:old:/:new:}  # Replace component

# Temporary environment
VAR=value command          # Set for single command
env VAR=value command      # Another way
```

### Advanced Environment Usage

```bash
#!/bin/bash

# Save and restore environment
save_env() {
    declare -p > /tmp/env_backup.sh
}

restore_env() {
    source /tmp/env_backup.sh
}

# Environment for subprocess
(
    export SPECIAL_VAR="value"
    ./subprocess.sh
)
# SPECIAL_VAR not visible here

# Reading environment files
if [ -f .env ]; then
    export $(cat .env | xargs)
fi

# Setting multiple variables
read -r VAR1 VAR2 VAR3 <<< "value1 value2 value3"

# Environment variable defaults
: ${DEBUG:=false}
: ${LOG_LEVEL:=info}
: ${MAX_RETRIES:=3}

# Checking required variables
required_vars=(API_KEY DB_HOST DB_USER)
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: $var is not set"
        exit 1
    fi
done

# Dynamic variable names
for i in {1..5}; do
    var="VAR_$i"
    export $var="value_$i"
    echo "${!var}"
done
```

## Best Practices and Tips

### Performance Optimization

```bash
#!/bin/bash

# Use built-in commands instead of external
# Good:
var=${string#prefix}
# Bad:
var=$(echo "$string" | sed 's/^prefix//')

# Avoid useless cat
# Good:
grep pattern file.txt
# Bad:
cat file.txt | grep pattern

# Use process substitution instead of temp files
# Good:
diff <(sort file1) <(sort file2)
# Bad:
sort file1 > temp1; sort file2 > temp2; diff temp1 temp2

# Batch operations
# Good:
find . -name "*.txt" -exec grep -l pattern {} +
# Bad:
find . -name "*.txt" -exec grep -l pattern {} \;

# Read files efficiently
# Good:
while IFS= read -r line; do
    process "$line"
done < file.txt
# Bad:
for line in $(cat file.txt); do
    process "$line"
done
```

### Security Considerations

```bash
#!/bin/bash

# Quote all variables
file="my file.txt"
rm "$file"                 # Safe
rm $file                   # Unsafe - word splitting

# Validate input
user_input="$1"
if [[ ! "$user_input" =~ ^[a-zA-Z0-9_]+$ ]]; then
    echo "Invalid input"
    exit 1
fi

# Use -- to signal end of options
grep -- "$pattern" file.txt

# Avoid eval
# Bad:
eval "$user_command"
# Good:
case "$user_command" in
    "safe_command") safe_command ;;
    *) echo "Unknown command" ;;
esac

# Secure temporary files
temp_file=$(mktemp) || exit 1
trap 'rm -f "$temp_file"' EXIT

# Set safe defaults
set -euo pipefail
IFS=\n\t'
```

### Common Patterns

```bash
#!/bin/bash

# Default values pattern
arg="${1:-default}"
config_file="${CONFIG_FILE:-/etc/myapp.conf}"

# Die function
die() {
    echo "Error: $1" >&2
    exit "${2:-1}"
}

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$1] $2" | tee -a "$LOG_FILE"
}

# Retry pattern
retry() {
    local max_attempts=$1
    local delay=$2
    shift 2
    local count=0
    
    until "$@"; do
        ((count++))
        if ((count >= max_attempts)); then
            return 1
        fi
        sleep "$delay"
    done
    return 0
}

# Lock file pattern
lock_file="/var/run/myapp.lock"
exec 200>"$lock_file"
flock -n 200 || die "Another instance is running"

# Configuration loading
load_config() {
    local config_file="$1"
    if [[ -f "$config_file" ]]; then
        # shellcheck source=/dev/null
        source "$config_file"
    else
        die "Config file not found: $config_file"
    fi
}

# Argument parsing pattern
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -f|--file)
                FILE="$2"
                shift 2
                ;;
            -*)
                die "Unknown option: $1"
                ;;
            *)
                ARGS+=("$1")
                shift
                ;;
        esac
    done
}
```

## Advanced Script Template

```bash
#!/usr/bin/env bash
#
# Script: advanced_template.sh
# Description: Advanced shell script template with all best practices
# Author: Your Name
# Version: 1.0.0
#

set -euo pipefail
IFS=\n\t'

# Global variables
readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
readonly VERSION="1.0.0"

# Configuration
declare -A CONFIG=(
    [debug]="false"
    [verbose]="false"
    [log_file]="/tmp/${SCRIPT_NAME%.*}.log"
    [timeout]="30"
)

# Colors for output
declare -A COLORS=(
    [red]=\e[31m'
    [green]=\e[32m'
    [yellow]=\e[33m'
    [blue]=\e[34m'
    [reset]=\e[0m'
)

# Logging functions
log() {
    local level="$1"
    shift
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $*" | tee -a "${CONFIG[log_file]}"
}

debug() { [[ "${CONFIG[debug]}" == "true" ]] && log "DEBUG" "$@"; }
info() { log "INFO" "$@"; }
warn() { log "WARN" "${COLORS[yellow]}$*${COLORS[reset]}"; }
error() { log "ERROR" "${COLORS[red]}$*${COLORS[reset]}" >&2; }
die() { error "$@"; exit 1; }

# Signal handling
cleanup() {
    local exit_code=$?
    debug "Cleaning up... (exit code: $exit_code)"
    # Add cleanup tasks here
    exit $exit_code
}

trap cleanup EXIT
trap 'die "Script interrupted"' INT TERM

# Help function
usage() {
    cat << EOF
${COLORS[blue]}${SCRIPT_NAME} v${VERSION}${COLORS[reset]}

USAGE:
    ${SCRIPT_NAME} [OPTIONS] <arguments>

OPTIONS:
    -h, --help              Show this help
    -v, --verbose           Verbose output
    -d, --debug             Debug mode
    -c, --config FILE       Configuration file
    -t, --timeout SECONDS   Operation timeout

EXAMPLES:
    ${SCRIPT_NAME} -v process file.txt
    ${SCRIPT_NAME} --config custom.conf --debug

EOF
}

# Argument parsing
parse_arguments() {
    local args=()
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--verbose)
                CONFIG[verbose]="true"
                shift
                ;;
            -d|--debug)
                CONFIG[debug]="true"
                set -x
                shift
                ;;
            -c|--config)
                [[ -f "$2" ]] || die "Config file not found: $2"
                # shellcheck source=/dev/null
                source "$2"
                shift 2
                ;;
            -t|--timeout)
                [[ "$2" =~ ^[0-9]+$ ]] || die "Invalid timeout: $2"
                CONFIG[timeout]="$2"
                shift 2
                ;;
            --)
                shift
                args+=("$@")
                break
                ;;
            -*)
                die "Unknown option: $1"
                ;;
            *)
                args+=("$1")
                shift
                ;;
        esac
    done
    
    # Validate required arguments
    [[ ${#args[@]} -ge 1 ]] || die "Missing required arguments"
    
    # Set global variables
    COMMAND="${args[0]}"
    ARGS=("${args[@]:1}")
}

# Main function
main() {
    parse_arguments "$@"
    
    info "Starting ${SCRIPT_NAME} v${VERSION}"
    debug "Configuration: $(declare -p CONFIG)"
    debug "Command: $COMMAND"
    debug "Arguments: ${ARGS[*]}"
    
    # Main logic
    case "$COMMAND" in
        process)
            process_files "${ARGS[@]}"
            ;;
        analyze)
            analyze_data "${ARGS[@]}"
            ;;
        *)
            die "Unknown command: $COMMAND"
            ;;
    esac
    
    info "Completed successfully"
}

# Command functions
process_files() {
    local files=("$@")
    
    for file in "${files[@]}"; do
        [[ -f "$file" ]] || { warn "File not found: $file"; continue; }
        
        info "Processing: $file"
        # Add processing logic here
    done
}

analyze_data() {
    local data_file="$1"
    
    [[ -f "$data_file" ]] || die "Data file not found: $data_file"
    
    info "Analyzing: $data_file"
    # Add analysis logic here
}

# Execute main function
main "$@"
```

## Conclusion

This guide covers advanced shell scripting concepts including:

1. **Wildcards and Pattern Matching** - File globbing and extended patterns
2. **Advanced String Manipulation** - Complex string operations and transformations
3. **Command Execution** - Command substitution, exec, and xargs
4. **Process Substitution** - Advanced input/output redirection
5. **Regular Expressions** - Pattern matching with grep, sed, and bash
6. **Text Processing Tools** - awk, sed, cut, sort, and uniq
7. **File Descriptors** - Advanced I/O redirection
8. **Job Control** - Background processes and signal management
9. **Signal Handling** - Trapping and managing signals
10. **Here Documents** - Multi-line input and templates
11. **Arithmetic Operations** - Math in shell scripts
12. **Conditional Expressions** - Advanced test conditions
13. **Parameter Expansion** - Advanced variable manipulation
14. **Environment Variables** - Managing the shell environment

These advanced concepts will help you write more powerful, efficient, and maintainable shell scripts. Remember to always test your scripts thoroughly and follow security best practices when handling user input or sensitive data.