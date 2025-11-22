#!/bin/bash
#SBATCH --job-name=vep_array
#SBATCH --partition=batch
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --output=logs/vep_%A_%a.out
#SBATCH --error=logs/vep_%A_%a.err
#SBATCH --array=0-99

# This script is submitted as part of the parent script
# `main-vep-batch-workflow.sh` gives it the batch directory argument

set -euo pipefail

# Batch directory is given from command line as first argument
BATCH_DIR="$1"

# Standard locations
INPUT_DIR="$HOME/cardio_darbar_chi_link/data/genetics/${BATCH_DIR}/vcf"
OUTPUT_DIR="$HOME/cardio_darbar_chi_link/data/genetics/${BATCH_DIR}/vep"
STATUS_DIR="$HOME/cardio_darbar_chi_link/data/genetics/${BATCH_DIR}/status"
FILE_LIST="${STATUS_DIR}/todo.txt"

# Load required modules
module load apptainer/1.2.5

# Get the VCF filename for this array task
VCF_FILE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "${FILE_LIST}")

# Run VEP on this file
bash "${HOME}/projects/genetics/cluster/run-vep-single-vcf.sh" "${BATCH_DIR}" "${VCF_FILE}"
