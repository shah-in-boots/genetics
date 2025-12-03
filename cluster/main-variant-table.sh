#!/bin/bash

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
    sbatch submit-create-gene-panel.sh "${PHENOTYPE}"

    # Wait for gene panel file to be created
    echo "Waiting for gene panel creation to complete..."
    MAX_WAIT=1800  # 1/2 hours (adjust based on typical job time)
    WAIT_INTERVAL=30  # Check every 30 seconds
    ELAPSED=0

    while [[ ! -f "$PANEL_TSV" ]] && [[ $ELAPSED -lt $MAX_WAIT ]]; do
        sleep $WAIT_INTERVAL
        ELAPSED=$((ELAPSED + WAIT_INTERVAL))
        echo "  Still waiting... (${ELAPSED}s elapsed)"
    done

    # Check if file was created
    if [[ ! -f "$PANEL_TSV" ]]; then
        echo "ERROR: Gene panel file not created after ${MAX_WAIT}s"
        echo "Check SLURM logs in logs/gene_panel_*.out"
        exit 1
    fi

    # Validate file is non-empty and has expected format
    if [[ ! -s "$PANEL_TSV" ]]; then
        echo "ERROR: Gene panel file is empty: $PANEL_TSV"
        exit 1
    fi

    echo "Gene panel created successfully: $PANEL_TSV (${LINES} lines)"
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
    # Extract patient ID (everything before first ".")
    patient_id="${basename%%.*}"
    # Check if any output file with this patient ID exists
    # Essentially if no output file exists, add it to the todo list
    if ! ls "$OUTPUT_DIR/${patient_id}."* > /dev/null 2>&1; then
        TODO_FILES+=("$basename")
    fi
done

# SLURM submission
# This needs to be run several times because of the space limit
# Array limited to about 100 runs at a time
# After files have been filtered will not need to re-run jobs from this
#
# Needs to know the following arguments:
# 1 = batch directory
# 2 = Gene list variable (bash array)
# 3 = VEP file array (bash array)

sbatch submit-array-filter-vep.sh "${BATCH_DIR}" "${GENE_LIST}" "${TODO_FILES[@]}"

# STEP 3
# Third part is to combine all filtered VEP files into a CSV file
# This can later be merged with other folders for a study if needed
# Save this data in the './data' folder of the `genetics` repository
# This will be done with an R script that is `sbatch` submitted
sbatch submit-convert-vep-to-table.sh "${BATCH_DIR}"
