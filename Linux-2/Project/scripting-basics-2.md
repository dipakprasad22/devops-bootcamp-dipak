# Shell Scripting Fundamentals

This guide covers the essential concepts of shell scripting with practical examples. Each section builds upon the previous one, taking you from basics to advanced topics.

## Table of Contents
1. [Introduction](#introduction)
2. [Getting Started](#getting-started)
3. [Variables](#variables)
4. [User Input](#user-input)
5. [Control Structures](#control-structures)
6. [Loops](#loops)
7. [Functions](#functions)
8. [Arrays](#arrays)
9. [String Manipulation](#string-manipulation)
10. [File Operations](#file-operations)
11. [Command Line Arguments](#command-line-arguments)
12. [Exit Status and Error Handling](#exit-status-and-error-handling)
13. [Debugging](#debugging)
14. [Best Practices](#best-practices)

## Introduction

Shell scripting is a powerful way to automate tasks in Unix/Linux systems. Scripts are text files containing a series of commands that the shell can execute.

## Getting Started

### Creating Your First Script

```bash
#!/bin/bash
# This is a comment
echo "Hello, World!"
```

**Key Points:**
- `#!/bin/bash` - Shebang line that specifies the interpreter
- Comments start with `#`
- Save the file with `.sh` extension
- Make it executable: `chmod +x script.sh`
- Run it: `./script.sh`

## Variables

### Declaring and Using Variables

```bash
#!/bin/bash

# Variable declaration
name="John"
age=25

# Using variables
echo "My name is $name"
echo "I am $age years old"

# Variable concatenation
greeting="Hello, $name!"
echo $greeting

# Command substitution
current_date=$(date)
echo "Today is: $current_date"
```

### Variable Scope

```bash
#!/bin/bash

global_var="I'm global"

function show_scope() {
    local local_var="I'm local"
    echo $global_var  # Accessible
    echo $local_var   # Accessible
}

show_scope
echo $global_var  # Accessible
echo $local_var   # Not accessible (empty)
```

## User Input

### Reading User Input

```bash
#!/bin/bash

# Simple input
echo "What's your name?"
read user_name
echo "Hello, $user_name!"

# Input with prompt
read -p "Enter your age: " user_age
echo "You are $user_age years old"

# Silent input (for passwords)
read -s -p "Enter password: " password
echo -e "\nPassword entered successfully"

# Input with timeout
read -t 5 -p "Quick! Enter something (5 seconds): " quick_input
if [ -z "$quick_input" ]; then
    echo "Too slow!"
else
    echo "You entered: $quick_input"
fi
```

## Control Structures

### If Statements

```bash
#!/bin/bash

# Basic if statement
age=18
if [ $age -ge 18 ]; then
    echo "You are an adult"
fi

# If-else statement
score=75
if [ $score -ge 60 ]; then
    echo "You passed!"
else
    echo "You failed."
fi

# If-elif-else statement
grade=85
if [ $grade -ge 90 ]; then
    echo "Grade: A"
elif [ $grade -ge 80 ]; then
    echo "Grade: B"
elif [ $grade -ge 70 ]; then
    echo "Grade: C"
else
    echo "Grade: F"
fi
```

### Case Statements

```bash
#!/bin/bash

echo "Select an option:"
echo "1) Start"
echo "2) Stop"
echo "3) Restart"
read choice

case $choice in
    1)
        echo "Starting the service..."
        ;;
    2)
        echo "Stopping the service..."
        ;;
    3)
        echo "Restarting the service..."
        ;;
    *)
        echo "Invalid option"
        ;;
esac
```

## Loops

### For Loops

```bash
#!/bin/bash

# Basic for loop
for i in 1 2 3 4 5; do
    echo "Number: $i"
done

# C-style for loop
for ((i=0; i<5; i++)); do
    echo "Count: $i"
done

# Looping through files
for file in *.txt; do
    echo "Processing $file"
done

# Looping through command output
for user in $(cat users.txt); do
    echo "User: $user"
done
```

### While Loops

```bash
#!/bin/bash

# Basic while loop
counter=1
while [ $counter -le 5 ]; do
    echo "Count: $counter"
    ((counter++))
done

# Reading file line by line
while IFS= read -r line; do
    echo "Line: $line"
done < input.txt

# Infinite loop with break
while true; do
    read -p "Enter 'quit' to exit: " input
    if [ "$input" = "quit" ]; then
        break
    fi
    echo "You entered: $input"
done
```

### Until Loops

```bash
#!/bin/bash

# Until loop (opposite of while)
counter=5
until [ $counter -lt 1 ]; do
    echo "Countdown: $counter"
    ((counter--))
done
echo "Blast off!"
```

## Functions

### Basic Functions

```bash
#!/bin/bash

# Simple function
greet() {
    echo "Hello, World!"
}

# Function with parameters
greet_user() {
    echo "Hello, $1!"
}

# Function with return value
add_numbers() {
    local sum=$(( $1 + $2 ))
    return $sum
}

# Function with echo as return
get_sum() {
    local sum=$(( $1 + $2 ))
    echo $sum
}

# Using functions
greet
greet_user "Alice"

add_numbers 5 3
echo "Sum: $?"

result=$(get_sum 10 20)
echo "Sum: $result"
```

### Advanced Functions

```bash
#!/bin/bash

# Function with default parameters
greet_with_default() {
    local name=${1:-"Guest"}
    echo "Hello, $name!"
}

# Function with variable number of arguments
sum_all() {
    local total=0
    for num in "$@"; do
        ((total += num))
    done
    echo $total
}

# Recursive function
factorial() {
    if [ $1 -le 1 ]; then
        echo 1
    else
        local prev=$(factorial $(( $1 - 1 )))
        echo $(( $1 * prev ))
    fi
}

# Using advanced functions
greet_with_default
greet_with_default "Bob"

echo "Sum: $(sum_all 1 2 3 4 5)"
echo "Factorial of 5: $(factorial 5)"
```

## Arrays

### Basic Arrays

```bash
#!/bin/bash

# Declaring arrays
fruits=("apple" "banana" "orange" "grape")
numbers=(1 2 3 4 5)

# Accessing elements
echo "First fruit: ${fruits[0]}"
echo "Third number: ${numbers[2]}"

# Array length
echo "Number of fruits: ${#fruits[@]}"

# Adding elements
fruits+=("pear")
echo "Added pear: ${fruits[@]}"

# Looping through arrays
echo "All fruits:"
for fruit in "${fruits[@]}"; do
    echo "- $fruit"
done

# Array indices
echo "Fruit indices:"
for i in "${!fruits[@]}"; do
    echo "$i: ${fruits[$i]}"
done
```

### Associative Arrays

```bash
#!/bin/bash

# Declaring associative arrays (requires bash 4+)
declare -A person
person[name]="John Doe"
person[age]=30
person[city]="New York"

# Accessing values
echo "Name: ${person[name]}"
echo "Age: ${person[age]}"

# Looping through associative arrays
echo "Person details:"
for key in "${!person[@]}"; do
    echo "$key: ${person[$key]}"
done
```

## String Manipulation

### String Operations

```bash
#!/bin/bash

# String length
text="Hello, World!"
echo "Length: ${#text}"

# Substring extraction
echo "First 5 chars: ${text:0:5}"
echo "From position 7: ${text:7}"

# String replacement
filename="document.txt"
echo "Replace txt with pdf: ${filename/txt/pdf}"

# Remove prefix/suffix
path="/home/user/file.txt"
echo "Filename: ${path##*/}"
echo "Directory: ${path%/*}"

# Case conversion (bash 4+)
name="John Doe"
echo "Uppercase: ${name^^}"
echo "Lowercase: ${name,,}"

# String comparison
str1="apple"
str2="Apple"
if [ "$str1" = "$str2" ]; then
    echo "Strings are equal"
else
    echo "Strings are different"
fi

# Pattern matching
if [[ "$filename" == *.txt ]]; then
    echo "It's a text file"
fi
```

## File Operations

### File Testing and Operations

```bash
#!/bin/bash

# File existence
if [ -f "myfile.txt" ]; then
    echo "File exists"
fi

# Directory existence
if [ -d "mydir" ]; then
    echo "Directory exists"
fi

# File permissions
if [ -r "myfile.txt" ]; then
    echo "File is readable"
fi

if [ -w "myfile.txt" ]; then
    echo "File is writable"
fi

if [ -x "myscript.sh" ]; then
    echo "File is executable"
fi

# File size check
if [ -s "myfile.txt" ]; then
    echo "File is not empty"
fi

# Reading files
while IFS= read -r line; do
    echo "Line: $line"
done < input.txt

# Writing to files
echo "Hello, World!" > output.txt
echo "Appending text" >> output.txt

# Creating temporary files
temp_file=$(mktemp)
echo "Temporary data" > "$temp_file"
echo "Temp file: $temp_file"
rm "$temp_file"
```

## Command Line Arguments

### Handling Arguments

```bash
#!/bin/bash

# Basic arguments
echo "Script name: $0"
echo "First argument: $1"
echo "Second argument: $2"
echo "All arguments: $@"
echo "Number of arguments: $#"

# Shift arguments
echo "Original first argument: $1"
shift
echo "After shift, first argument: $1"

# Processing all arguments
echo "Processing all arguments:"
for arg in "$@"; do
    echo "Argument: $arg"
done

# Argument validation
if [ $# -lt 2 ]; then
    echo "Usage: $0 <input> <output>"
    exit 1
fi

# Parsing options
while getopts "hv:f:" opt; do
    case $opt in
        h)
            echo "Help message"
            ;;
        v)
            echo "Verbose mode: $OPTARG"
            ;;
        f)
            echo "File: $OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            exit 1
            ;;
    esac
done
```

## Exit Status and Error Handling

### Exit Status

```bash
#!/bin/bash

# Exit status
command_that_might_fail
if [ $? -eq 0 ]; then
    echo "Command succeeded"
else
    echo "Command failed"
fi

# Using && and ||
mkdir newdir && echo "Directory created" || echo "Failed to create directory"

# Custom exit status
check_file() {
    if [ -f "$1" ]; then
        return 0
    else
        return 1
    fi
}

check_file "myfile.txt"
if [ $? -eq 0 ]; then
    echo "File exists"
else
    echo "File not found"
fi
```

### Error Handling

```bash
#!/bin/bash

# Set error mode
set -e  # Exit on error
set -u  # Exit on undefined variable

# Trap errors
error_handler() {
    echo "Error occurred on line $1"
    exit 1
}

trap 'error_handler $LINENO' ERR

# Try-catch simulation
{
    # Commands that might fail
    risky_command
} || {
    # Error handling
    echo "Command failed, handling error..."
}

# Cleanup on exit
cleanup() {
    echo "Cleaning up..."
    rm -f /tmp/tempfile*
}

trap cleanup EXIT

# Error logging
log_error() {
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') $1" >> error.log
}

command || log_error "Command failed"
```

## Debugging

### Debugging Techniques

```bash
#!/bin/bash

# Enable debug mode
set -x  # Print commands as they execute

# Debug specific sections
set +x  # Disable debug mode
echo "Normal execution"
set -x  # Enable debug mode
problematic_code
set +x  # Disable debug mode

# Debug output
debug() {
    [ "$DEBUG" = "true" ] && echo "[DEBUG] $1" >&2
}

DEBUG=true
debug "This is a debug message"

# Verbose mode
VERBOSE=${VERBOSE:-false}
verbose() {
    [ "$VERBOSE" = "true" ] && echo "[INFO] $1"
}

verbose "This is a verbose message"

# Using bash debug options
# bash -x script.sh    # Debug entire script
# bash -v script.sh    # Verbose mode
# bash -n script.sh    # Syntax check only
```

## Best Practices

### Script Template

```bash
#!/bin/bash
#
# Script: myscript.sh
# Description: Brief description of what the script does
# Author: Your Name
# Date: 2024-01-01
#

# Exit on any error
set -e

# Global variables
readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Default values
DEBUG=${DEBUG:-false}
VERBOSE=${VERBOSE:-false}

# Functions
usage() {
    cat << EOF
Usage: $SCRIPT_NAME [options] <arguments>

Options:
    -h, --help      Show this help message
    -v, --verbose   Enable verbose output
    -d, --debug     Enable debug mode

Examples:
    $SCRIPT_NAME -v file.txt
    $SCRIPT_NAME --debug --verbose input.txt output.txt
EOF
}

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

error() {
    echo "[ERROR] $1" >&2
}

debug() {
    [ "$DEBUG" = "true" ] && echo "[DEBUG] $1" >&2
}

verbose() {
    [ "$VERBOSE" = "true" ] && echo "[INFO] $1"
}

cleanup() {
    # Cleanup code here
    verbose "Cleaning up..."
}

# Main function
main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -d|--debug)
                DEBUG=true
                set -x
                shift
                ;;
            -*)
                error "Unknown option: $1"
                usage
                exit 1
                ;;
            *)
                break
                ;;
        esac
    done

    # Validate arguments
    if [ $# -lt 1 ]; then
        error "Missing required arguments"
        usage
        exit 1
    fi

    # Main logic here
    log "Starting $SCRIPT_NAME"
    verbose "Processing with verbose output"
    debug "Debug information"
    
    # Your script logic goes here
    
    log "Completed successfully"
}

# Trap signals
trap cleanup EXIT
trap 'error "Script interrupted"; exit 1' INT TERM

# Run main function
main "$@"
```

### Additional Best Practices

1. **Always quote variables**: `"$variable"` instead of `$variable`
2. **Use `[[ ]]` for conditionals**: More powerful than `[ ]`
3. **Check command existence**: `command -v cmd >/dev/null 2>&1`
4. **Use local variables in functions**: `local var="value"`
5. **Validate input**: Always validate user input and file existence
6. **Use meaningful variable names**: `user_input` instead of `ui`
7. **Add error checking**: Check return values of commands
8. **Use shellcheck**: Lint your scripts with `shellcheck script.sh`
9. **Document your code**: Add comments explaining complex logic
10. **Follow consistent style**: Use consistent indentation and naming

## Conclusion

This guide covers the fundamental concepts of shell scripting. Practice these examples and experiment with your own scripts. Remember that shell scripting is powerful but can be dangerous if not used carefully. Always test your scripts in a safe environment before running them on production systems.
