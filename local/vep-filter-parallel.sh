#!/bin/bash

# Parallel VEP filtering script
# # Examples below:
# # Use default settings (75% of cores)
# ./process_lof_parallel.sh
#
# # Specify number of cores
# ./process_lof_parallel.sh -p 16
#
# # Clean up old logs and use specific number of cores
# ./process_lof_parallel.sh -c -p 8

# Default to 75% of cores
num_cores=$(nproc)
cores_to_use=$(( num_cores * 3 / 4 ))

# Add command line options
while getopts "c:p:" opt; do
    case $opt in
        c)  # Cleanup option
            cleanup_old_logs=true
            ;;
        p)  # Number of cores to use
            if [[ $OPTARG =~ ^[0-9]+$ ]]; then
                if [ $OPTARG -gt 0 ] && [ $OPTARG -le $num_cores ]; then
                    cores_to_use=$OPTARG
                else
                    echo "Error: Number of cores must be between 1 and $num_cores"
                    exit 1
                fi
            else
                echo "Error: -p requires a number"
                exit 1
            fi
            ;;
        \?)
            echo "Usage: $0 [-c] [-p cores]"
            echo "  -c: cleanup old logs"
            echo "  -p: number of cores to use (default: 75% of available cores)"
            exit 1
            ;;
    esac
done

# Check if GNU Parallel is installed
if ! command -v parallel &> /dev/null; then
    echo "GNU Parallel is not installed. Please install it first."
    exit 1
fi

# Create necessary directories
mkdir -p filtered logs

# Cleanup old logs if requested
if [ "$cleanup_old_logs" = true ]; then
    echo "Cleaning up old logs..."
    find logs -type f -name "*.log" -mtime +30 -exec rm {} \;
    echo "Removed logs older than 30 days"
fi

# Function to process a single gene
process_gene() {
    local category=$1
    local gene=$2
    local log_file="logs/${category}_${gene}.log"
    local processed_files_log="logs/processed_files_${category}_${gene}.txt"
    
    echo "Processing gene: $gene in category: $category"
    
    # Start logging
    {
        echo "=== Processing Start ==="
        echo "Date: $(date)"
        echo "Category: $category"
        echo "Gene: $gene"
        echo "======================="
    } > "$log_file"
    
    # Create temporary directory and ensure processed files log exists
    mkdir -p "temp_${category}_${gene}"
    touch "$processed_files_log"
    
    # Track if we found any variants
    found_variants=false
    start_time=$(date +%s)
    
    # Process each VEP file
    for vep_file in vep/*.txt; do
        base_name=$(basename "$vep_file")
        
        # Check if this specific file has been processed for this gene
        if grep -q "^${base_name}$" "$processed_files_log"; then
            echo "Already processed $base_name for $gene - skipping" | tee -a "$log_file"
            continue
        fi
        
        output_file="temp_${category}_${gene}/${base_name%.*}_lof.txt"
        
        echo "Processing $vep_file at $(date)" >> "$log_file"
        
        filter_vep \
            -i "$vep_file" \
            -o "$output_file" \
						--filter "SYMBOL is $gene and (LoF is HC or LoF is LC)" \
            --force_overwrite 2>> "$log_file"
        
        # Check if filtered file has variants
        if [ -f "$output_file" ] && [ $(grep -v "^#" "$output_file" | wc -l) -gt 0 ]; then
            mv "$output_file" "filtered/$category/$gene/"
            echo "Found LoF variants in $base_name" >> "$log_file"
            found_variants=true
        else
            rm -f "$output_file"
        fi
        
        # Log that this file has been processed
        echo "$base_name" >> "$processed_files_log"
    done
    
    # Calculate processing time
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    
    # Cleanup and final logging
    rm -rf "temp_${category}_${gene}"
    
    {
        echo "=== Processing Complete ==="
        echo "Date: $(date)"
        echo "Processing time: $duration seconds"
        if [ "$found_variants" = true ]; then
            echo "Status: Found LoF variants"
        else
            echo "Status: No LoF variants found"
        fi
        echo "COMPLETED"
        echo "========================="
    } >> "$log_file"
}
export -f process_gene

# Step 1: Create directory structure from gene lists
echo "Creating directory structure..."
for category_file in gene_lists/*.txt; do
    category=$(basename "$category_file" .txt)
    echo "Processing category: $category"
    mkdir -p "filtered/$category"
    
    while IFS= read -r gene; do
        if [[ ! -z "$gene" ]]; then
            mkdir -p "filtered/$category/$gene"
        fi
    done < "$category_file"
done

# Step 2: Generate job list
job_list_file="job_list.txt"
> "$job_list_file"

for category_file in gene_lists/*.txt; do
    category=$(basename "$category_file" .txt)
    while IFS= read -r gene; do
        if [[ ! -z "$gene" ]]; then
            echo "$category $gene" >> "$job_list_file"
        fi
    done < "$category_file"
done

# Step 3: Run parallel processing
echo "Starting parallel processing using $cores_to_use cores..."
echo "Using $cores_to_use out of $num_cores available cores"

parallel --jobs $cores_to_use \
    --colsep ' ' \
    --joblog logs/parallel_joblog.txt \
    process_gene {1} {2} :::: "$job_list_file"

# Generate summary report
summary_file="logs/summary_$(date +%Y%m%d_%H%M%S).txt"
{
    echo "Processing Summary"
    echo "================="
    echo "Date: $(date)"
    echo "Total genes processed: $(find logs -type f -name "*.log" -not -name "parallel_joblog.txt" | wc -l)"
    echo
    echo "Details by gene:"
    echo "---------------"
    find logs -type f -name "*.log" -not -name "parallel_joblog.txt" | while read log_file; do
        gene_name=$(basename "$log_file" .log)
        variants=$(grep "Found LoF variants" "$log_file" | wc -l)
        proc_time=$(grep "Processing time:" "$log_file" | cut -d: -f2-)
        echo "$gene_name: $variants LoF variants found (Processing time:$proc_time)"
    done
} > "$summary_file"

# Cleanup
rm -f "$job_list_file"
rm -rf temp_*

echo "Processing complete! Summary available in $summary_file"
