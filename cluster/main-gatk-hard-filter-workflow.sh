#!/bin/bash
# Run the hard-filter todo builder and submit the matching SLURM array.
# Usage: bash main-gatk-hard-filter-workflow.sh <batch_dir>

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $(basename "$0") <batch_dir>" >&2
    exit 1
fi

BATCH_DIR="$1"

SCRIPT_DIR="$HOME/projects/genetics/cluster"
bash "${SCRIPT_DIR}/script-make-bcftools-todo-list.sh" "${BATCH_DIR}"

BASE_DIR="$HOME/cardio_darbar_chi_link/data/genetics/${BATCH_DIR}"
TODO_FILE="${BASE_DIR}/status/hard-filter-todo.txt"

TODO_COUNT=$(grep -c . "${TODO_FILE}" 2>/dev/null || true)

if [[ -z "${TODO_COUNT}" || "${TODO_COUNT}" -eq 0 ]]; then
    echo "No VCF files require filtering. Nothing to submit."
    exit 0
fi

echo "Submitting ${TODO_COUNT} hard-filter task(s)..."
sbatch --array=1-"${TODO_COUNT}" "${SCRIPT_DIR}/submit-gatk-hard-filter-array.sh" "${BATCH_DIR}"
