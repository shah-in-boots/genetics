#!/bin/bash
#SBATCH --job-name=gatk_hard_filter
#SBATCH --partition=batch
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=02:00:00
#SBATCH --output=logs/gatk_hard_filter_%A_%a.out
#SBATCH --error=logs/gatk_hard_filter_%A_%a.err
#SBATCH --array=1-100

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $(basename "$0") <batch_dir>" >&2
    exit 1
fi

BATCH_DIR="$1"

BASE_DIR="$HOME/cardio_darbar_chi_link/data/genetics/${BATCH_DIR}"
STATUS_DIR="${BASE_DIR}/status"
TODO_FILE="${STATUS_DIR}/hard-filter-todo.txt"

if [[ ! -f "${TODO_FILE}" ]]; then
    echo "Todo list ${TODO_FILE} not found. Run script-make-bcftools-todo-list.sh first." >&2
    exit 1
fi

if declare -F module >/dev/null 2>&1; then
    module load bcftools >/dev/null 2>&1 || true
fi

VCF_FILE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "${TODO_FILE}" || true)

if [[ -z "${VCF_FILE}" ]]; then
    echo "No entry for array index ${SLURM_ARRAY_TASK_ID}; exiting."
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "${SCRIPT_DIR}/run-gatk-hard-filter.sh" "${BATCH_DIR}" "${VCF_FILE}"
