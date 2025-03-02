#!/bin/bash

# This is a file to help download VCF data from terra
# Uses the gcloud SDK

TSV_FILE="terra_uic_second_batch.tsv"
OUTPUT_DIR="."
LOG_FILE="terra_log_$(date +%Y%m%d_%H%M%S).log"
VCF_COLUMN=39

# Script header
# Display script header
echo "====================================================="
echo "Terra VCF Downloader Script"
echo "Started at $(date)"
echo "====================================================="
echo ""

# Check if TSV file exists
if [ ! -f "$TSV_FILE" ]; then
	echo "Error: TSV file '$TSV_FILE' not found."
	echo "Please edit the script to set the correct TSV_FILE variable."
	exit 1
fi

# Create output directory if isn't alrady present
mkdir -p "$OUTPUT_DIR"

# Log file and put terminal output into log file
# Okay to duplicate the output
exec > >(tee -a "$LOG_FILE") 2>&1

# Check if gcloud is authenticated
echo "Authetication with below Google Cloud account"
gcloud auth list

# Read the VCF path one by one
echo "Extracting VCF paths from $TSV_FILE in (column $VCF_COLUMN)..."

# Place it in a temporary file if needed
TMP_PATHS=$(mktemp)

# Get VCF paths, awk to handle the TSV file
# Select the column number that contains the VCF path above
awk -F '\t' -v col="$VCF_COLUMN" 'NR>1 && $col!="" {gsub(/^"|"$/, "", $col); print $col}' "$TSV_FILE" > "$TMP_PATHS"

# Count total files that will be downloading
TOTAL_FILES=$(wc -l < "$TMP_PATHS")
echo "Found $TOTOAL_FILES VCF paths."

# Show sample of files to be downloaded
echo "Sample of VCF paths to be downloaded:"
head -5 "$TMP_PATHS"
echo "..."

# Create a summary file with original paths
echo "Creating summary file with all paths..."
cp "$TMP_PATHS" "${OUTPUT_DIR}/vcf_path_summary.txt"

# Ask for confirmation
read -p "Do you want to proceed with downloading $TOTAL_FILES VCF files? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
	    echo "Download canceled by user."
			    rm "$TMP_PATHS"
					    exit 0
fi


# Download each VCF file with progress
echo "Starting downloads at $(date)..."
echo "Progress will be logged to $LOG_FILE"

COUNTER=0
while read -r path; do
	if [[ ! -z "$path" ]]; then
		COUNTER=$((COUNTER+1))
		filename=$(basename "$path")
		echo "[${COUNTER}/${TOTAL_FILES}] Downloading: $filename"

		# Download the file
		gcloud storage cp "$path" "${OUTPUT_DIR}/${filename}"

		# Check download success
		if [ $? -eq 0 ]; then
			echo "✓ Successfully downloaded: $filename"
			echo "${path},${filename},SUCCESS,$(date)" >> "${OUTPUT_DIR}/download_results.csv"
		else
			echo "✗ Failed to download: $filename"
			echo "${path},${filename},FAILED,$(date)" >> "${OUTPUT_DIR}/download_results.csv"
		fi
	fi
done < "$TMP_PATHS"

# Clean up
rm "$TMP_PATHS"

# Verify downloaded files
echo "Verifying downloaded files..."
EXPECTED_FILES=$TOTAL_FILES
ACTUAL_FILES=$(find "$OUTPUT_DIR" -type f -not -name "*.txt" -not -name "*.csv" | wc -l)

echo "====================================================="
echo "Download Summary"
echo "====================================================="
echo "Expected files: $EXPECTED_FILES"
echo "Actually downloaded: $ACTUAL_FILES"
echo "See ${OUTPUT_DIR}/download_results.csv for detailed results"
echo "Complete log available in $LOG_FILE"
echo "Finished at $(date)"
echo "====================================================="

exit 0
