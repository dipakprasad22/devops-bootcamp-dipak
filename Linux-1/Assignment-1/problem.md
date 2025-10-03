## Shell Scripting Assignment: File Permission Checker

### Problem:
Create a script called `check_permissions.sh` that checks if a given file or directory has the correct permissions and ownership. The script should help system administrators quickly verify if files have secure permissions.

### Task Description:
Write a script that:
1. Takes a file/directory path as a command-line argument
2. Takes expected permission (like 644, 755) as second argument
3. Checks if the file exists
4. Verifies the current permissions match expected permissions
5. Checks if file is owned by current user
6. Reports any security issues (world-writable files, etc.)
7. Uses appropriate exit codes for different scenarios

### Expected Usage:
```bash
./check_permissions.sh /etc/passwd 644
./check_permissions.sh /home/user/script.sh 755
./check_permissions.sh /var/log 755
```

### Expected Output Examples:
```bash
# Good case:
✅ /etc/passwd has correct permissions (644)
✅ File ownership is secure
Exit code: 0

# Bad case:
❌ /tmp/test.txt has permissions 777 (expected 644)
⚠️  WARNING: File is world-writable!
❌ File owned by different user
Exit code: 1
```

### Considerations:
- What if no arguments are provided?
- What if file doesn't exist?
- How to handle directories vs files differently?
- What permissions are considered dangerous?
- How to extract current permissions from `ls -l` or `stat`?
- What if user provides invalid permission format?

### Hints:
- Use `$1` and `$2` for command-line arguments
- Use `[ $# -eq 2 ]` to check argument count
- Use `stat -c %a filename` to get octal permissions
- Use `stat -c %U filename` to get file owner
- Use `whoami` to get current user
- Use `find` with `-perm` to check for dangerous permissions
- Use `awk` to parse `ls -l` output for additional details
- Exit codes: 0=success, 1=permission mismatch, 2=file not found, 3=invalid arguments

### Skills Practiced:
- Command-line argument handling (`$1`, `$2`, `$#`)
- File existence testing (`-f`, `-d`)
- String comparison and variables
- If-else conditional logic
- Exit codes and script termination
- Using `find` with permission checks
- Using `awk` for text processing
- Command substitution with `stat`
- Security-focused scripting

This is a practical script that system administrators actually use!