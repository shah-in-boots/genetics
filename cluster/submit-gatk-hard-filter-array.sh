#!/bin/bash
#SBATCH --job-name=gatk_hard_filter
#SBATCH --partition=batch
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=02:00:00
#SBATCH --output=logs/gatk_hard_filter_%A_%a.out
#SBATCH --error=logs/gatk_hard_filter_%A_%a.err
#SBATCH --array=0-99

set -euo pipefail

# Argument given to script
BATCH_DIR="$1"

BASE_DIR="$HOME/cardio_darbar_chi_link/data/genetics/${BATCH_DIR}"
STATUS_DIR="${BASE_DIR}/status"
FILE_LIST="${STATUS_DIR}/hard-filter-todo.txt"

if [[ ! -f "${FILE_LIST}" ]]; then
    echo "Todo file ${FILE_LIST} not found. Run script-make-bcftools-todo-list.sh first." >&2
    exit 1
fi

module load bcftools

TASK_LINE=$((SLURM_ARRAY_TASK_ID + 1))
VCF_FILE=$(sed -n "${TASK_LINE}p" "${FILE_LIST}" || true)

if [[ -z "${VCF_FILE}" ]]; then
    echo "No VCF entry for array index ${SLURM_ARRAY_TASK_ID}; skipping."
    exit 0
fi

bash "${HOME}/projects/genetics/cluster/run-gatk-hard-filter.sh" "${BATCH_DIR}" "${VCF_FILE}"
