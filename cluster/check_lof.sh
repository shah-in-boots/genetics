#!/bin/bash

# Output file
output="lof_check_results.txt"

# Clear/create output file
> "$output"

echo "Checking files for LoF annotations..." 
echo "Results will be saved to: $output"
echo ""

# Loop through all files in current directory (adjust pattern as needed)
for file in *.vcf *.txt *.tsv; do
	# Skip if file doesn't exist (handles case where pattern doesn't match)
	[ -e "$file" ] || continue

	# Count occurrences of "LoF" in the file
	lof_count=$(grep -o "LoF" "$file" | wc -l)

	# Check if count exceeds threshold (8)
	if [ "$lof_count" -gt 8 ]; then
		echo "$file: YES (found $lof_count occurrences)" >> "$output"
		echo "✓ $file: $lof_count LoF occurrences"
	else
		echo "$file: NO (found $lof_count occurrences)" >> "$output"
	fi
done

echo ""
echo "Analysis complete. Check $output for results."
