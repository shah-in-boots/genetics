#!/bin/bash
# Build todo list for GATK hard-filtering via BCFtools
# Usage: bash script-make-bcftools-todo-list.sh [batch_dir]

set -euo pipefail

# Batch directory of VCF files that need filtering
BATCH_DIR="$1"

BASE_DIR="$HOME/cardio_darbar_chi_link/data/genetics/${BATCH_DIR}"
INPUT_DIR="${BASE_DIR}/raw"
STATUS_DIR="${BASE_DIR}/status"
TODO_FILE="${STATUS_DIR}/hard-filter-todo.txt"

mkdir -p "${STATUS_DIR}"
> "${TODO_FILE}"

shopt -s nullglob
mapfile -t VCF_FILES < <(find "${INPUT_DIR}" -maxdepth 1 -type f \( -name '*.vcf' -o -name '*.vcf.gz' \) | sort)
shopt -u nullglob

TOTAL=0
TODO_COUNT=0
DONE_COUNT=0

for vcf_path in "${VCF_FILES[@]}"; do
    ((TOTAL++))
    filename=$(basename "${vcf_path}")

    case "${filename}" in
        *.vcf.gz) sample="${filename%.vcf.gz}" ;;
        *.vcf) sample="${filename%.vcf}" ;;
        *) sample="${filename}" ;;
    esac

    done_marker="${STATUS_DIR}/${sample}.hard-filter.done"

    if [[ -f "${done_marker}" ]]; then
        ((DONE_COUNT++))
        continue
    fi

    echo "${filename}" >> "${TODO_FILE}"
    ((TODO_COUNT++))
done

echo "Batch directory   : ${BATCH_DIR}"
echo "Input directory   : ${INPUT_DIR}"
echo "Todo list written : ${TODO_FILE}"
echo ""
echo "Total VCF files   : ${TOTAL}"
echo "Already filtered  : ${DONE_COUNT}"
echo "Pending filtering : ${TODO_COUNT}"
