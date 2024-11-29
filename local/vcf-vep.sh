 #!/bin/bash

# Set up directory structure
VCF_DIR="./vcf"
VEP_DIR="./vep"
LOG_DIR="./logs"
LOG_FILE="${LOG_DIR}/vep_analysis.log"
PROCESSED_LIST="${LOG_DIR}/processed_files.txt"

# Create directories if they don't exist
mkdir -p "${VCF_DIR}" "${VEP_DIR}" "${LOG_DIR}"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "${LOG_FILE}"
    echo "$1"
}

# Function to check if file has been processed
is_processed() {
    grep -q "^$1$" "${PROCESSED_LIST}" 2>/dev/null
    return $?
}

# Create processed files list if it doesn't exist
touch "${PROCESSED_LIST}"

# Process each VCF file
for file in ${VCF_DIR}/*.vcf; do
    # Get basename of the file
    base_name=$(basename "$file" .vcf)
    
    # Check if file has already been processed
    if is_processed "${base_name}"; then
        log_message "Skipping ${base_name}.vcf - already processed"
        continue
    fi
    
    log_message "Starting processing of ${base_name}.vcf"
    
    # Run VEP with LOFTEE
    if vep -i "$file" \
        -o "${VEP_DIR}/${base_name}_vep.txt" \
        --verbose \
        --fork 4 \
        --offline \
        --no_stats \
        --polyphen s \
        --sift s \
        --symbol \
        --show_ref_allele \
        --plugin LoF,loftee_path:/Users/asshah4/tools/loftee/,human_ancestor_fa:false \
        --dir_plugin /Users/asshah4/tools/loftee/; then
        
        # Log success and add to processed list
        log_message "Successfully processed ${base_name}.vcf"
        echo "${base_name}" >> "${PROCESSED_LIST}"
    else
        # Log failure
        log_message "ERROR: Failed to process ${base_name}.vcf"
    fi
done

log_message "VEP analysis completed"
