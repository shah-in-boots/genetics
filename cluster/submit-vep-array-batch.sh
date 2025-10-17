#!/bin/bash
#SBATCH --job-name=vep_array
#SBATCH --partition=batch
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --output=logs/vep_%A_%a.out
#SBATCH --error=logs/vep_%A_%a.err
#SBATCH --array=1-5

set -euo pipefail

INPUT_DIR="$HOME/cardio_darbar_chi_link/data/genetics/uic_first_batch/vcf"
OUTPUT_DIR="$HOME/cardio_darbar_chi_link/data/genetics/uic_first_batch/vep"
STATUS_DIR="$HOME/cardio_darbar_chi_link/data/genetics/uic_first_batch/status"
FILE_LIST="${STATUS_DIR}/todo.txt"

# Load required modules
module load apptainer/1.2.5

# Get the VCF filename for this array task
VCF_FILE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "${FILE_LIST}")

# Run VEP on this file
bash "${HOME}/projects/genetics/cluster/run-vep-single-vcf.sh" "${VCF_FILE}"