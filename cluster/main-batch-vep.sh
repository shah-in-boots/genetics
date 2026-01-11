#!/bin/bash
# Main script to run VEP command in batch mode
# Uses a SLURM submission script to set up array
# Array then analyzes one VCF file at a time
# To know which files to analyze, checks to see which files have not yet been processed

# This line sets the script to exit immediately if a command exits with a non-zero status, treat unset variables as an error, and fail on any command in a pipeline that fails.
set -euo pipefail

# VARIABLES ----

# First set up all the relevant paths/variables
BATCH_DIR="uic_first_batch"

# Standard I/O directories
INPUT_DIR="$HOME/cardio_darbar_chi_link/data/genetics/${BATCH_DIR}/vcf"
OUTPUT_DIR="$HOME/cardio_darbar_chi_link/data/genetics/${BATCH_DIR}/vep"

#  STEP ONE ----

# Create list of files to process
# This list is an array that will be accessed by the Array No.
TODO_FILES=() # list of files to process
INPUT_FILES=("$INPUT_DIR"/*.vcf)

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

# STEP TWO ----
# SLURM submission script
# SLURM needs to know the directory of interest and which files need to be run
sbatch submit-array-run-vep.sh "${BATCH_DIR}" "${TODO_FILES[@]}"
