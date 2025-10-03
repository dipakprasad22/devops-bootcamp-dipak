#!/bin/bash
# Script: check_permissions.sh
# Purpose: Verify file/directory permissions and ownership

# Exit codes:
# 0 = success
# 1 = permission mismatch or ownership issue
# 2 = file not found
# 3 = invalid arguments

# --- Argument Validation ---
if [ $# -ne 2 ]; then # Not exactly 2 arguments
    echo "Usage: $0 <file_or_directory> <expected_permission>" # e.g., 644, 755
    exit 3 # Invalid arguments
fi

TARGET="$1"         # File or directory to check
EXPECTED_PERM="$2"  # Expected permission in octal (e.g., 644, 755)

# Validate that expected permission is numeric (e.g., 644, 755)
if ! [[ "$EXPECTED_PERM" =~ ^[0-7]{3,4}$ ]]; then # Regex for octal permission
    echo "❌ Invalid permission format: $EXPECTED_PERM (expected octal like 644, 755)" 
    exit 3
fi

# --- File Existence Check ---
if [ ! -e "$TARGET" ]; then # Check if file/directory exists
    echo "❌ File or directory does not exist: $TARGET"
    exit 2
fi

# --- Get Current File Info ---
CURRENT_PERM=$(stat -c %a "$TARGET")    # Get current permissions in octal
CURRENT_OWNER=$(stat -c %U "$TARGET")   # Get current owner
CURRENT_USER=$(whoami)                  # Get current user

EXIT_CODE=0 # Initialize exit code

# --- Check Permissions ---
if [ "$CURRENT_PERM" -eq "$EXPECTED_PERM" ]; then # Permissions match
    echo "✅ $TARGET has correct permissions ($CURRENT_PERM)" # Permissions match
else
    echo "❌ $TARGET has permissions $CURRENT_PERM (expected $EXPECTED_PERM)"
    EXIT_CODE=1
fi

# --- Check Ownership ---
if [ "$CURRENT_OWNER" = "$CURRENT_USER" ]; then
    echo "✅ File ownership is secure (owned by $CURRENT_OWNER)"
else
    echo "❌ File owned by $CURRENT_OWNER (expected $CURRENT_USER)"
    EXIT_CODE=1
fi

# --- Security Checks ---
# World-writable files (dangerous: 777, 666, etc.)
if [ -w "$TARGET" ] && [ "$(stat -c %a "$TARGET")" -ge 666 ]; then
    echo "⚠️  WARNING: $TARGET is world-writable!"
    EXIT_CODE=1
fi

# If directory, check if it’s world-executable
if [ -d "$TARGET" ]; then
    if [ "$(stat -c %a "$TARGET")" -ge 757 ]; then
        echo "⚠️  WARNING: Directory $TARGET is world-executable!"
        EXIT_CODE=1
    fi
fi

exit $EXIT_CODE
