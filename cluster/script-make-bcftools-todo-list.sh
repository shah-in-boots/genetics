#!/bin/bash
# Build a todo list of VCF files that still need hard filtering.
# Usage: bash script-make-bcftools-todo-list.sh <batch_dir>

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $(basename "$0") <batch_dir>" >&2
    exit 1
fi

BATCH_DIR="$1"

BASE_DIR="$HOME/cardio_darbar_chi_link/data/genetics/${BATCH_DIR}"
INPUT_DIR="${BASE_DIR}/raw"
STATUS_DIR="${BASE_DIR}/status"
TODO_FILE="${STATUS_DIR}/hard-filter-todo.txt"

mkdir -p "${STATUS_DIR}"
> "${TODO_FILE}"

TOTAL=0
TODO_COUNT=0

for pattern in "${INPUT_DIR}"/*.vcf "${INPUT_DIR}"/*.vcf.gz; do
    if [[ ! -e "${pattern}" ]]; then
        continue
    fi

    ((TOTAL++))
    filename=$(basename "${pattern}")

    case "${filename}" in
        *.vcf.gz) sample="${filename%.vcf.gz}" ;;
        *.vcf) sample="${filename%.vcf}" ;;
        *) sample="${filename}" ;;
    esac

    done_marker="${STATUS_DIR}/${sample}.hard-filter.done"

    if [[ -f "${done_marker}" ]]; then
        continue
    fi

    echo "${filename}" >> "${TODO_FILE}"
    ((TODO_COUNT++))
done

DONE_COUNT=$((TOTAL - TODO_COUNT))

echo "Batch directory   : ${BATCH_DIR}"
echo "Input directory   : ${INPUT_DIR}"
echo "Todo list written : ${TODO_FILE}"
echo ""
echo "Total VCF files   : ${TOTAL}"
echo "Already filtered  : ${DONE_COUNT}"
echo "Pending filtering : ${TODO_COUNT}"
