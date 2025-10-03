#!/bin/bash
# Analyze directory structure and find large files
declare -A dir_sizes
total_large_files=0

# Outer loop: iterate through directories
for dir in /home /var /tmp
do
    if [ -d "$dir" ]; then
        echo "=== Analyzing $dir ==="
        dir_total=0
        
        # Inner loop: find large files in each directory
        while IFS= read -r -d '' file
        do
            size=$(stat -c%s "$file" 2>/dev/null)
            if [ "$size" -gt 100000000 ]; then  # Files > 100MB
                size_mb=$((size / 1024 / 1024))
                echo "  Large file: $file (${size_mb}MB)"
                dir_total=$((dir_total + size_mb))
                total_large_files=$((total_large_files + 1))
            fi
        done < <(find "$dir" -type f -size +100M -print0 2>/dev/null)
        
        dir_sizes["$dir"]=$dir_total
        echo "  Total large files in $dir: ${dir_total}MB"
        echo ""
    fi
done

# Summary report
echo "=== SUMMARY ==="
for dir in "${!dir_sizes[@]}"
do
    echo "$dir: ${dir_sizes[$dir]}MB in large files"
done
echo "Total large files found: $total_large_files"