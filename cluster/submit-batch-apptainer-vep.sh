#!/bin/bash
#SBATCH --job-name=vep_array
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=04:00:00
#SBATCH --output=logs/vep_%A_%a.out
#SBATCH --error=logs/vep_%A_%a.err
#SBATCH --array=0-99%10

set -euo pipefail

# Load required module
module load apptainer/1.2.5

# Define directories
INPUT_DIR="$HOME/projects/genetics/data/uic_second_batch/vcf"
STATUS_DIR="$HOME/projects/genetics/data/status"
SCRIPT_DIR="$HOME/projects/genetics/cluster"

# Create necessary directories
mkdir -p logs "${SCRIPT_DIR}"

# Get list of unprocessed VCF files
mapfile -t VCF_FILES < <(
    for vcf in "${INPUT_DIR}"/*.vcf; do
        filename=$(basename "$vcf")
        if [[ ! -f "${STATUS_DIR}/${filename}.success" ]]; then
            echo "$filename"
        fi
    done | sort
)

TOTAL_UNPROCESSED=${#VCF_FILES[@]}

echo "Found ${TOTAL_UNPROCESSED} unprocessed VCF files"

if (( TOTAL_UNPROCESSED == 0 )); then
    echo "No unprocessed files found. Exiting."
    exit 0
fi

# Exit if this array task exceeds available files
if (( SLURM_ARRAY_TASK_ID >= TOTAL_UNPROCESSED )); then
    echo "Array task ${SLURM_ARRAY_TASK_ID} exceeds unprocessed files (${TOTAL_UNPROCESSED})"
    exit 0
fi

# Get the file for this task
SAMPLE_NAME="${VCF_FILES[$SLURM_ARRAY_TASK_ID]}"

echo "Array task ${SLURM_ARRAY_TASK_ID}: Processing ${SAMPLE_NAME}"

# Process the file using the single-VCF script
bash "${SCRIPT_DIR}/run-apptainer-vep-single-vcf.sh" "${SAMPLE_NAME}"