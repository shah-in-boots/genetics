#!/bin/bash

# Step 1: Create directory structure from gene lists

# Create parent filtered directory
echo "Creating parent filtered directory..."
mkdir -p filtered

echo "Creating directory structure..."
for category_file in gene_lists/*.txt; do
    # Get category name without .txt extension
    category=$(basename "$category_file" .txt)
    echo "Processing category: $category"
    
    # Create category directory
    mkdir -p "filtered/$category"
    
    # Create subdirectories for each gene
    while IFS= read -r gene; do
        if [[ ! -z "$gene" ]]; then  # Check for non-empty lines
            mkdir -p "filtered/$category/$gene"
            echo "Created directory: filtered/$category/$gene"
        fi
    done < "$category_file"
done

# Step 2: Process VEP files for each gene in each category
echo "Processing VEP files..."
for category_file in gene_lists/*.txt; do
    category=$(basename "$category_file" .txt)
    echo "Processing category: $category"
    
    # Read each gene from the category file
    while IFS= read -r gene; do
        if [[ -z "$gene" ]]; then continue; fi  # Skip empty lines
        
        echo "Processing gene: $gene"
        
        # Create temporary directory
        mkdir -p "temp_${category}_${gene}"
        
        # Process each VEP file
        for vep_file in vep/*.txt; do
            base_name=$(basename "$vep_file" .txt)
            output_file="temp_${category}_${gene}/${base_name}_lof.txt"
            
            # Run filter_vep to find high-confidence LoF variants
            filter_vep \
                -i "$vep_file" \
                -o "$output_file" \
                --filter "SYMBOL = $gene and LoF = 'HC'" \
                --force_overwrite
            
            # Check if filtered file has variants (excluding headers)
            if [ -f "$output_file" ] && [ $(grep -v "^#" "$output_file" | wc -l) -gt 0 ]; then
                # Move non-empty files to appropriate directory
                mv "$output_file" "$category/$gene/"
                echo "Found LoF variants in $base_name for $gene"
            else
                # Remove empty files
                rm -f "$output_file"
            fi
        done
        
        # Clean up temporary directory
        rm -rf "temp_${category}_${gene}"
        
        # Check if gene directory is empty
        if [ -z "$(ls -A $category/$gene)" ]; then
            echo "No LoF variants found for $gene"
        fi
        
    done < "$category_file"
done

# Final cleanup
rm -rf temp_*
echo "Processing complete!"
