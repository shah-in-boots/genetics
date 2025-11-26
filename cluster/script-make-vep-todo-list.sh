#!/bin/bash
# Create list of VCF files that need processing
# Run by `bash script-make-todo-list.sh <batch_directory>`

# Batch directory is given from command line as first argument
BATCH_DIR="$1"

# Standard locations
INPUT_DIR="$HOME/cardio_darbar_chi_link/data/genetics/${BATCH_DIR}/vcf"
OUTPUT_DIR="$HOME/cardio_darbar_chi_link/data/genetics/${BATCH_DIR}/lof"
STATUS_DIR="$HOME/cardio_darbar_chi_link/data/genetics/${BATCH_DIR}/status"
TODO_FILE="${STATUS_DIR}/todo.txt"

mkdir -p "${STATUS_DIR}"
> "${TODO_FILE}"

# Find VCF files that don't have a .done marker
for vcf in "${INPUT_DIR}"/*.vcf; do
    filename=$(basename "${vcf}")
    if [ ! -f "${STATUS_DIR}/${filename}.done" ]; then
        echo "${filename}" >> "${TODO_FILE}"
    fi
done

# Show results
TOTAL=$(ls "${INPUT_DIR}"/*.vcf 2>/dev/null | wc -l)
TODO=$(cat "${TODO_FILE}" | wc -l)
DONE=$((TOTAL - TODO))

echo "Total VCF files: ${TOTAL}"
echo "Already done: ${DONE}"
echo "Need processing: ${TODO}"
echo ""
echo "List saved to: ${TODO_FILE}"
