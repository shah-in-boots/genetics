#!/bin/bash
#SBATCH --job-name=vep_array
#SBATCH --partition=batch
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --output=logs/vep_%A_%a.out
#SBATCH --error=logs/vep_%A_%a.err
#SBATCH --array=0-99

# This script is submitted as part of the parent script
# `main-batch-vep.sh` gives it the batch directory argument

set -euo pipefail

# Load required modules
module load apptainer/1.2.5

# Batch directory is given from command line as first argument
# Second argument is the list of todo files as an array
BATCH_DIR="$1"
TODO_FILES=("${@:2}")

# Standard locations
INPUT_DIR="$HOME/cardio_darbar_chi_link/data/genetics/${BATCH_DIR}/vcf"
OUTPUT_DIR="$HOME/cardio_darbar_chi_link/data/genetics/${BATCH_DIR}/vep"

# Get the VCF filename for this array task
VCF_FILE="${TODO_FILES[$SLURM_ARRAY_TASK_ID]}"

# Run VEP on this file
bash run-vep.sh "${BATCH_DIR}" "${VCF_FILE}"
