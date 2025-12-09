#!/bin/bash
#SBATCH --job-name=vep_table
#SBATCH --partition=batch
#SBATCH --cpus-per-task=4
#SBATCH --nodes=1
#SBATCH --mem=32GB
#SBATCH --time=04:00:00
#SBATCH --output=logs/vep_table_%J.out
#SBATCH --error=logs/vep_table_%J.err

# Script for submission 
# This has
# Used like this`sbatch submit-convert-vep-to-table.sh "${BATCH_DIR}"``

# Take arguments from command line
BATCH_DIR="$1"

# Make sure path for libraries is present
export R_LIBS_USER="~/tools/R/library"

# Load R module
module load R/4.4.1-gfbf-2023b

# Run script
# Takes following arguments:
# 1 = batch directory
# 2 = SLURM cpus per task
Rscript convert-vep-to-table.R "${BATCH_DIR}" "${SLURM_CPUS_PER_TASK}"
