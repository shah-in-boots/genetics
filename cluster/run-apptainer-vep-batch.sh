#!/bin/bash
#SBATCH --job-name=docker_vep
#SBATCH --partition=batch
#SBATCH --nodes=4
#SBATCH --cpus-per-task=2
#SBATCH --mem=2G
#SBATCH --time=08:00:00
#SBATCH --output=logs/docker_vep_%j.out
#SBATCH --error=logs/docker_vep_%j.err
#SBATCH --array=0-19%4

set -euo pipefail

# Load required modules
module load apptainer/1.2.5

INPUT_DIR="$HOME/projects/genetics/data/uic_second_batch/vcf"
SCRIPT_DIR="$HOME/projects/genetics/cluster"
STATUS_DIR="$HOME/cardio_darbar_chi_link/data/genetics/status"

# Get BATCH_NUMBER from environment (set when submitting job)
BATCH_NUMBER=${BATCH_NUMBER:-0}
BATCH_SIZE=20

# Get all VCF files that haven't been successfully processed
mapfile -d '' -t ALL_FILES < <(find "${INPUT_DIR}" -maxdepth 1 -type f -name '*.vcf' -print0 | sort -z)

# Filter out already processed files
VCF_FILES=()
for vcf in "${ALL_FILES[@]}"; do
    filename=$(basename "$vcf")
    if [[ ! -f "${STATUS_DIR}/${filename}.success" ]]; then
        VCF_FILES+=("$vcf")
    fi
done

TOTAL_UNPROCESSED=${#VCF_FILES[@]}

# Calculate which file this array task should process
FILE_INDEX=$((BATCH_NUMBER * BATCH_SIZE + SLURM_ARRAY_TASK_ID))

if (( FILE_INDEX >= TOTAL_UNPROCESSED )); then
    echo "Task ${SLURM_ARRAY_TASK_ID} (file index ${FILE_INDEX}) exceeds remaining files (${TOTAL_UNPROCESSED}); exiting"
    exit 0
fi

VCF_FILE="${VCF_FILES[FILE_INDEX]}"
SAMPLE_NAME="$(basename "${VCF_FILE}")"

mkdir -p logs

echo "Batch ${BATCH_NUMBER}, Task ${SLURM_ARRAY_TASK_ID}: Processing ${SAMPLE_NAME} (${FILE_INDEX}/${TOTAL_UNPROCESSED})"

bash "${SCRIPT_DIR}/apptainer-vep-batch.sh" "${SAMPLE_NAME}"
