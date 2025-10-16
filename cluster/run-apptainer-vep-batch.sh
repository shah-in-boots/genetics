#!/bin/bash
#SBATCH --job-name=docker_vep
#SBATCH --partition=batch
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=48:00:00
#SBATCH --output=logs/docker_vep_%j.out
#SBATCH --error=logs/docker_vep_%j.err
#SBATCH --array=0-241%4

# The number of array files total is above, determined by the number of VCF files in the folder of interest

set -euo pipefail

# Load required modules
module load apptainer/1.2.5

# Call the VEP script
bash "${HOME}/projects/genetics/cluster/test-apptainer-vep.sh"

# Configuration for bathc files
INPUT_DIR="$HOME/projects/genetics/data/uic_second_batch/vcf"
SCRIPT_DIR="$HOME/projects/genetics/cluster"

# Get list of VCF files
mapfile -d '' -t VCF_FILES < <(find "${INPUT_DIR}" -maxdepth 1 -type f -name '*.vcf' -print0 | sort -z)
TOTAL=${#VCF_FILES[@]}

if (( TOTAL == 0 )); then
    echo "ERROR: No VCF files found in ${INPUT_DIR}" >&2
    exit 1
fi

# q: What does this section do?
# a: This section checks if the SLURM_ARRAY_TASK_ID is valid (i.e., within the range of available VCF files). If not, it exits gracefully.
if (( SLURM_ARRAY_TASK_ID >= TOTAL )); then
    echo "Task ${SLURM_ARRAY_TASK_ID} exceeds number of VCFs (${TOTAL}); exiting" >&2
    exit 0
fi

# Get the VCF file for this task
VCF_FILE="${VCF_FILES[SLURM_ARRAY_TASK_ID]}"
SAMPLE_NAME="$(basename "${VCF_FILE}")"

# Create logs directory
mkdir -p logs

echo "Processing sample ${SLURM_ARRAY_TASK_ID}/${TOTAL}: ${SAMPLE_NAME}"

# Call the worker script with the sample name
bash "${SCRIPT_DIR}/apptainer-vep-batch.sh" "${SAMPLE_NAME}"
