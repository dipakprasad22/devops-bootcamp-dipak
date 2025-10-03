#!/bin/bash

# Regular Expression Demo Script
# This script demonstrates regex patterns with grep, sed, and awk

echo "=== REGULAR EXPRESSION DEMONSTRATION ==="
echo "Creating sample data for demonstration..."

# Remove the testing directory if it is present.
rm -rf regex_test &>/dev/null

# Create a testing directory and sample data files
mkdir -p regex_test
cd regex_test || return

# Create sample text files with various content
cat > sample_data.txt << 'EOF'
John Doe - Phone: 123-456-7890 - Email: john@email.com
Jane Smith - Phone: 987-654-3210 - Email: jane.smith@company.org
Bob Johnson - Phone: 555-123-4567 - Email: bob123@test.net
Alice Brown - Phone: 444-555-6666 - Email: alice@domain.co.uk
Mike Davis - Phone: 777-888-9999 - Email: mike_davis@example.com
Color: red, blue, green, colour
File: test.txt, data.csv, script.py, README.md
Numbers: 42, 100, 3.14, -25, 0.001
Dates: 2023-12-25, 01/15/2024, March 3rd, 2024
URLs: https://example.com, http://test.org, ftp://files.net
EOF

cat > log_file.txt << 'EOF'
2024-01-15 10:30:15 INFO Server started successfully
2024-01-15 10:30:16 DEBUG Loading configuration files
2024-01-15 10:30:17 ERROR Failed to connect to database
2024-01-15 10:30:18 WARN Connection timeout after 30 seconds
2024-01-15 10:30:19 INFO Retrying connection attempt 1
2024-01-15 10:30:20 INFO Connection established
2024-01-15 10:30:21 DEBUG Processing user request
2024-01-15 10:30:22 ERROR Invalid user credentials
2024-01-15 10:30:23 INFO User authentication successful
EOF

cat > mixed_content.txt << 'EOF'
IPv4 addresses: 192.168.1.1, 10.0.0.1, 172.16.0.100
Invalid IPs: 999.999.999.999, 192.168.1.256
Credit cards: 4532-1234-5678-9012, 5555-4444-3333-2222
SSNs: 123-45-6789, 987-65-4321
Words: cat, cats, dog, dogs, bird, birds
Test: file, files, test, testing, tests
Versions: v1.0, v2.15, v10.2.3, version-1.0
EOF

echo "Sample files created!"
echo

# GREP DEMONSTRATIONS
echo "=== GREP (Global Regular Expression Print) ==="
echo

echo "1. Basic pattern matching with grep:"
echo "   Finding lines containing 'Email':"
grep "Email" sample_data.txt
echo

echo "2. Using ? in regex (0 or 1 of preceding character):"
echo "   Pattern: 'colou?r' (matches 'color' or 'colour'):"
grep -iE "colou?r" sample_data.txt
echo

echo "3. Using * in regex (0 or more of preceding character):"
echo "   Pattern: 'test.*' (test followed by anything):"
grep "test.*" mixed_content.txt
echo

echo "4. Using . (dot) - matches any single character:"
echo "   Pattern: 'v...' (v followed by any 3 characters):"
grep "v..." mixed_content.txt
echo

echo "5. Using [] character classes:"
echo "   Pattern: '[0-9]' (any digit) (3times):"
grep -E "[0-9]{3}" sample_data.txt | head -3
echo

echo "   Pattern: '[A-Z][a-z]*' (word starting with capital):"
grep -o "[A-Z][a-z]*" sample_data.txt | head -5
echo

echo "6. Using ^ and $ anchors:"
echo "   Pattern: '^2024' (lines starting with 2024):"
grep "^2024" log_file.txt | head -3
echo

echo "   Pattern: 'INFO$' (lines ending with INFO - none in our case):"
grep "INFO$" log_file.txt || echo "   No matches found"
echo

# SED DEMONSTRATIONS
echo "=== SED (Stream Editor) ==="
echo

echo "7. Basic substitution with sed:"
echo "   Original line:"
echo "   John Doe - Phone: 123-456-7890"
echo "   Replacing 'Phone' with 'Tel':"
echo "   John Doe - Phone: 123-456-7890" | sed 's/Phone/Tel/'
echo

echo "8. Using regex patterns in sed substitution:"
echo "   Replacing all digits with 'X':"
echo "   Phone: 123-456-7890" | sed 's/[0-9]/X/g'
echo

echo "9. Using groups and backreferences:"
echo "   Swapping first and last names:"
echo "   John Doe" | sed 's/\([A-Z][a-z]*\) \([A-Z][a-z]*\)/\2, \1/'
echo

echo "10. Removing lines matching pattern:"
echo "   Removing ERROR lines from log:"
sed '/ERROR/d' log_file.txt | head -3
echo

echo "11. Adding text with sed:"
echo "   Adding 'ALERT: ' before ERROR lines:"
sed 's/^.*ERROR.*/ALERT: &/' log_file.txt | grep ALERT
echo

# AWK DEMONSTRATIONS
echo "=== AWK (Pattern Scanning and Processing) ==="
echo

echo "12. Basic awk pattern matching:"
echo "   Lines containing 'INFO':"
awk '/INFO/ {print}' log_file.txt | head -3
echo

echo "13. Using regex patterns in awk:"
echo "   Lines matching email pattern:"
awk '/[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+/ {print}' sample_data.txt | head -3
echo

echo "14. Field processing with awk:"
echo "   Extracting phone numbers (field after 'Phone:'):"
awk -F'Phone: ' '/Phone:/ {print $2}' sample_data.txt | awk '{print $1}'
echo

echo "=== COMPARISON: Wildcards vs Regex ==="
echo "Remember the key differences:"
echo "• Wildcards (shell): ? = exactly 1 char, * = any chars"
echo "• Regex (grep/sed/awk): ? = 0 or 1 of preceding, * = 0+ of preceding, . = any single char"
echo
echo "Examples:"
echo "• Shell: file?.txt matches file1.txt (? = exactly one char)"
echo "• Regex: files? matches 'file' or 'files' (s is optional)"
echo

echo "=== Demo completed! ==="
echo "All sample files are in: $(pwd)"