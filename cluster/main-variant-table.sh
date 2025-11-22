#!/usr/bin/env bash

# STEP 1
# First part of the script is to call the R script that gets a gene panel
# This writes out a file called "gene_panel_atrial_fibrillation.csv"
# Contains which genes to filter for from the VCF annotations
# Under column "gene_symbol"
# The file output is "gene_panel_${PHENOTYPE}.tsv" (with spaces changed to underscore)
# Placed in the 'data' folder of the 'genetics' repository
# Only need to do this once per phenotype of interest
PHENOTYPE="atrial fibrillation"
PANEL_TSV="$HOME/projects/genetics/data/gene_panel_${PHENOTYPE// /_}.tsv"

if [[ -f "$PANEL_TSV" ]]; then
    echo "Gene panel already exists: $PANEL_TSV"
else
    echo "Creating gene panel for: $PHENOTYPE"
    sbatch submit-gene-panel.sh "${PHENOTYPE}"
fi

# STEP 2
# Second part is to filter VEP files for the genes in the gene panel
# Will need the `gene_symbol` to identify which gene to filter for
# Batch this over the number of files available in the VEP folders

# Gene panel file (already defined above)
# Save list of genes for filtering by `filter_vep` (comma separated)
GENE_LIST=$(awk 'NR > 1 { print $1 }' "$PANEL_TSV" | paste -sd ',' -)

# Standard I/O directories
# The local directory folders
# THe individual scripts places this in the DARBAR/data/genetics path 
BATCH_DIR="uic_first_batch"
INPUT_DIR="$HOME/cardio_darbar_chi_link/data/genetics/${BATCH_DIR}/vep"
OUTPUT_DIR="$HOME/cardio_darbar_chi_link/data/genetics/${BATCH_DIR}/vep_filtered"

# Create list of files to process
# This list is an array that will be accessed by the Array No.
TODO_FILES=() # list of files to process
INPUT_FILES=("$INPUT_DIR"/*.vep)

for f in "${INPUT_FILES[@]}"; do
    basename=$(basename "$f")
    # Check if corresponding output file doesn't exist
    # FYI double brackets so variables don't get split
    if [[ ! -f "$OUTPUT_DIR/$basename" ]]; then
        TODO_FILES+=("$f")
    fi
done

# SLURM submission
# Needs to know the following arguments:
# 1 = batch directory
# 2 = Gene list variable (bash array)
# 3 = VEP file array (bash array)

sbatch submit-array-filter-vep.sh "${BATCH_DIR}" "${GENE_LIST}" "${TODO_FILES[@]}"
