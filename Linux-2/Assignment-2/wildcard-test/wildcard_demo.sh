#!/bin/bash

# Wildcard Pattern Demo Script
# This script demonstrates wildcard patterns (*, ?) in various file operations

echo "=== WILDCARD PATTERN DEMONSTRATION ==="
echo "Creating sample files for demonstration..."

# Remove the testing directory if it is present.
rm -rf wildcard_test &>/dev/null

# Create a testing directory and sample files
mkdir -p wildcard_test
cd wildcard_test || return

# Create various sample files
touch file.txt file1.txt file2.txt fileAB.txt
touch test.log test1.log test22.log testAB.log
touch data.csv data_2023.csv data_backup.csv
touch config.conf config_prod.conf config_dev.conf
touch script.py script_main.py backup_script.py
touch readme.md README.MD help.txt HELP.TXT

echo "Sample files created!"
echo

# Demo 1: Using * wildcard
echo "1. Using * (asterisk) wildcard:"
echo "   Pattern: *.txt (all files ending with .txt)"
echo "   Matches:"
ls ./*.txt 2>/dev/null || echo "   No matches found"
echo

echo "   Pattern: test* (all files starting with 'test')"
echo "   Matches:"
ls test* 2>/dev/null || echo "   No matches found"
echo

echo "   Pattern: *data* (all files containing 'data')"
echo "   Matches:"
ls ./*data* 2>/dev/null || echo "   No matches found"
echo

# Demo 2: Using ? wildcard
echo "2. Using ? (question mark) wildcard:"
echo "   Pattern: file?.txt (file + exactly 1 char + .txt)"
echo "   Matches:"
ls file?.txt 2>/dev/null || echo "   No matches found"
echo

echo "   Pattern: test??.log (test + exactly 2 chars + .log)"
echo "   Matches:"
ls test??.log 2>/dev/null || echo "   No matches found"
echo

echo "   Pattern: *.?? (files with exactly 2-char extensions)"
echo "   Matches:"
ls ./*.?? 2>/dev/null || echo "   No matches found"
echo

# Demo 3: Combining wildcards
echo "3. Combining wildcards:"
echo "   Pattern: *script*.?? (files containing 'script' with 2-char extension)"
echo "   Matches:"
ls ./*script*.?? 2>/dev/null || echo "   No matches found"
echo

# Demo 4: File operations with wildcards
echo "4. File operations with wildcards:"
echo "   Copying all .txt files to backup directory:"
mkdir -p backup
cp ./*.txt backup/ 2>/dev/null && echo "   ✓ Copied successfully" || echo "   ✗ No files to copy"
echo "   Files in backup:"
ls backup/ 2>/dev/null || echo "   No files"
echo

echo "   Counting files with different patterns:"
echo "   *.txt files: $(find ./*.txt 2>/dev/null | wc -l)"
echo "   test* files: $(find test* 2>/dev/null | wc -l)"
echo "   *conf files: $(find ./*.conf 2>/dev/null | wc -l)"
echo

# Demo 5: Case sensitivity
echo "5. Case sensitivity in wildcards:"
echo "   Pattern: *.md (lowercase)"
echo "   Matches:"
ls ./*.md 2>/dev/null || echo "   No matches found"
echo

echo "   Pattern: *.MD (uppercase)"
echo "   Matches:"
ls ./*.MD 2>/dev/null || echo "   No matches found"
echo

# Demo 6: Practical examples
echo "6. Practical wildcard examples:"
echo "   Find all configuration files:"
echo "   config* pattern matches:"
ls config* 2>/dev/null || echo "   No matches found"
echo

echo "   Find all Python files:"
echo "   *.py pattern matches:"
ls ./*.py 2>/dev/null || echo "   No matches found"
echo

echo "   Find files with single character names:"
echo "   ?.* pattern matches:"
ls /.* 2>/dev/null || echo "   No matches found"
echo

# Demo Completed
echo "=== Demo completed! ==="
echo "Test files were created in: $(pwd)"