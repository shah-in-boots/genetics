#!/bin/bash
# gatk-hard-filter.sh
# ------------------------------------------------------------------------------
# Purpose: apply a simple hard filter (QUAL > 5, INFO/DP > 1) to a single VCF
#          so it roughly matches the DRAGEN pipeline output.
# Usage:   bash run-gatk-hard-filter.sh [batch_dir] <vcf_filename>
# Inputs:  the VCF must exist under the batch-specific raw folder defined below.
# Outputs: a new VCF named "<sample>.hard-filtered.vcf" saved in the batch vcf folder
#          and a completion marker in the batch status folder.
# ------------------------------------------------------------------------------

# -e : stop immediately if any command exits with a non-zero status
# -u : treat unset variables as an error
# -o pipefail : if a pipeline fails, the whole script fails
set -euo pipefail


# Arguments past to script
BATCH_DIR="$1"
VCF_FILE="$2"

# Input and output folders in the shared cluster storage.
# Adjust these paths if you copy the script to a different batch.
BASE_DIR="$HOME/cardio_darbar_chi_link/data/genetics/${BATCH_DIR}"
INPUT_DIR="${BASE_DIR}/raw"
OUTPUT_DIR="${BASE_DIR}/vcf"
STATUS_DIR="${BASE_DIR}/status"
mkdir -p "$OUTPUT_DIR"
mkdir -p "$STATUS_DIR"

INPUT_PATH="${INPUT_DIR}/${VCF_FILE}"

if [[ ! -f "${INPUT_PATH}" ]]; then
    echo "Error: ${INPUT_PATH} not found" >&2
    exit 1
fi

# q: what does this code do?
# a: It determines the sample name from the VCF file name by removing the file extension.
case "${VCF_FILE}" in
    *.vcf.gz) SAMPLE_NAME="${VCF_FILE%.vcf.gz}" ;;
    *.vcf) SAMPLE_NAME="${VCF_FILE%.vcf}" ;;
    *) SAMPLE_NAME="${VCF_FILE}" ;;
esac

OUTPUT_PATH="${OUTPUT_DIR}/${SAMPLE_NAME}.hard-filtered.vcf"
DONE_MARKER="${STATUS_DIR}/${SAMPLE_NAME}.hard-filter.done"

# BCFtools pipeline:
#   1. view: stream the VCF so we can read gzip and plain text with one command.
#   2. filter: keep only variants meeting both thresholds.
#      - QUAL > 5 ensures confident variant calls.
#      - INFO/DP > 1 requires at least 2 reads supporting the call.
bcftools view "${INPUT_PATH}" \
    | bcftools filter -i 'QUAL>5 && INFO/DP>1 && FILTER!="PASS"' \
    > "${OUTPUT_PATH}"

# Mark completion so the todo list generator can skip this sample next time.
touch "${DONE_MARKER}"

echo "Filtered VCF written to ${OUTPUT_PATH}"
