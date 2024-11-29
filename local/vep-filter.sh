#!/bin/bash

###########################################
# SECTION 1: SETUP AND DIRECTORY STRUCTURE
###########################################

# Define all directory paths we'll use
VEP_DIR="./vep"          # Where your VEP annotated files are
OUTPUT_BASE="./filtered" # Where filtered results will go
LOG_DIR="./logs"         # Where logs will be stored
GENE_LIST_DIR="./gene_lists" # Where your gene category files are stored
CATEGORIES_LOG="${LOG_DIR}/variant_categories.json" # Main log file in JSON format

# Create all necessary directories
# -p flag creates parent directories if they don't exist
mkdir -p "${OUTPUT_BASE}" "${LOG_DIR}"

###########################################
# SECTION 2: INITIALIZE LOG FILE
###########################################

# Create an empty JSON object ({}) if log file doesn't exist
# -f tests if file exists
if [ ! -f "${CATEGORIES_LOG}" ]; then
    echo "{}" > "${CATEGORIES_LOG}"
fi

###########################################
# SECTION 3: LOGGING FUNCTION
###########################################

# Function to log findings to our JSON file
# Takes 4 parameters: sample name, category, gene, and variant
log_finding() {
    # Store function parameters in named variables for clarity
    local sample=$1
    local category=$2
    local gene=$3
    local variant=$4
    
    # Create temporary file for JSON manipulation
    # mktemp creates a temporary file with a unique name
    local temp_log=$(mktemp)
    
    # Use jq to update our JSON log file
    # jq is a tool for manipulating JSON
    # --arg defines variables we can use in the jq command
    # The command adds/updates an entry for this sample with category, gene, and variant info
    jq --arg sample "$sample" \
       --arg category "$category" \
       --arg gene "$gene" \
       --arg variant "$variant" \
    '.[$sample] += {"category": $category, "gene": $gene, "variant": $variant}' \
    "${CATEGORIES_LOG}" > "$temp_log"
    
    # Move temporary file to replace our log file
    mv "$temp_log" "${CATEGORIES_LOG}"
}

###########################################
# SECTION 4: MAIN PROCESSING LOOP
###########################################

# Loop through each category file (e.g., structural.txt, ion_channel.txt)
for category_file in ${GENE_LIST_DIR}/*.txt; do
    # Get category name by removing .txt from filename
    category=$(basename "$category_file" .txt)
    echo "Processing category: $category"
    
    # Create directory for this category's results
    category_dir="${OUTPUT_BASE}/${category}"
    mkdir -p "$category_dir"
    
    # Convert list of genes from file into comma-separated list
    # tr replaces newlines with commas
    # sed removes the trailing comma
    genes=$(tr '\n' ',' < "$category_file" | sed 's/,$//')
    
    # Process each VEP annotated file
    for vep_file in ${VEP_DIR}/*_vep.txt; do
        # Get sample name by removing _vep.txt from filename
        sample=$(basename "$vep_file" _vep.txt)
        # Define output file path for this sample and category
        output_file="${category_dir}/${sample}_${category}_lof.txt"
        
        echo "Analyzing $sample for $category genes..."
        
        # Run filter_vep command
        # && means only execute what follows if filter_vep succeeds
        filter_vep \
            -i "$vep_file" \
            -o "$output_file" \
            -filter "SYMBOL in ($genes) and (LoF is HC or LoF is LC)" \
            --force_overwrite \
            && {
                # Check if output file has content (found variants)
                # -s tests if file exists and has size greater than zero
                if [ -s "$output_file" ]; then
                    # Process each line of the output file
                    # Skip header line with tail -n +2
                    while IFS=$'\t' read -r line; do
                        # Extract gene and variant info from the line
                        # cut -f4 gets the 4th tab-separated field
                        gene=$(echo "$line" | cut -f4)  # Adjust field number as needed
                        variant=$(echo "$line" | cut -f1)  # Adjust field number as needed
                        
                        # Log this finding
                        log_finding "$sample" "$category" "$gene" "$variant"
                    done < <(tail -n +2 "$output_file")
                    
                    echo "Found LOF variants in $sample for $category"
                else
                    # Remove empty output files to keep things clean
                    rm "$output_file"
                fi
            }
    done
done

###########################################
# SECTION 5: GENERATE SUMMARY REPORT
###########################################

echo "Creating summary report..."
summary_file="${LOG_DIR}/variant_summary.txt"

# Create header for summary report
echo "Variant Summary Report" > "$summary_file"
echo "Generated on: $(date)" >> "$summary_file"
echo "-------------------" >> "$summary_file"

# Use jq to create human-readable summary from our JSON log
# to_entries converts JSON object to array of key-value pairs
# Format each entry nicely with sample, category, gene, and variant info
jq -r 'to_entries | .[] | "Sample: \(.key)\nCategory: \(.value.category)\nGene: \(.value.gene)\nVariant: \(.value.variant)\n---"' \
    "${CATEGORIES_LOG}" >> "$summary_file"

echo "Analysis complete. See ${LOG_DIR} for logs and summary."
