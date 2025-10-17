#!/bin/bash
# Orchestrate todo generation and SLURM submission for GATK hard filter
# Usage: bash main-gatk-hard-filter-workflow.sh [batch_dir]

set -euo pipefail

DEFAULT_BATCH_DIR="uic_first_batch"

if [[ $# -gt 1 ]]; then
    echo "Usage: $(basename "$0") [batch_dir]" >&2
    exit 1
fi

if [[ $# -eq 1 ]]; then
    BATCH_DIR="$1"
else
    BATCH_DIR="${DEFAULT_BATCH_DIR}"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Generating todo list for batch ${BATCH_DIR}..."
bash "${SCRIPT_DIR}/script-make-bcftools-todo-list.sh" "${BATCH_DIR}"

BASE_DIR="$HOME/cardio_darbar_chi_link/data/genetics/${BATCH_DIR}"
STATUS_DIR="${BASE_DIR}/status"
TODO_FILE="${STATUS_DIR}/hard-filter-todo.txt"

if [[ ! -f "${TODO_FILE}" ]]; then
    echo "Expected todo list ${TODO_FILE} not found; aborting." >&2
    exit 1
fi

TODO_COUNT=$(wc -l < "${TODO_FILE}")

if [[ "${TODO_COUNT}" -eq 0 ]]; then
    echo "No VCF files require filtering. Nothing to submit."
    exit 0
fi

ARRAY_MAX=$((TODO_COUNT - 1))

echo "Submitting SLURM array job with ${TODO_COUNT} task(s)..."
sbatch --array=0-"${ARRAY_MAX}" "${SCRIPT_DIR}/submit-gatk-hard-filter-array.sh" "${BATCH_DIR}"
