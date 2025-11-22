#!/bin/bash

#SBATCH --job-name=filter_vep_by_gene
#SBATCH --partition=batch
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --output=logs/vep_%A_%a.out
#SBATCH --error=logs/vep_%A_%a.err
#SBATCH --array=0-10

# SETUP ====

# This script is submitted as part of the parent script
# Parent script is main-make-variant-table.sh
set -euo pipefail

# Load required modules
module load apptainer/1.2.5

# VARS ====

# Batch directory is given from command line as first argument
# Gene list is a comma-separated list of genes to filter for
BATCH_DIR="$1"
GENE_LIST="$2"

# Standard locations for the directory of interest
INPUT_DIR="$HOME/cardio_darbar_chi_link/data/genetics/${BATCH_DIR}/vep"
OUTPUT_DIR="$HOME/cardio_darbar_chi_link/data/genetics/${BATCH_DIR}/vep_filtered"

# FILES ====

# Create list of files to process
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

# BATCHING ====

# Get the VEP filename for this array task
# This is a batched file
VEP_FILE="${TODO_FILES[$SLURM_ARRAY_TASK_ID]}"

bash "${HOME}/projects/genetics/cluster/run-filter-vep-by-gene.sh" "${BATCH_DIR}" "${GENE_LIST}" "${VEP_FILE}"