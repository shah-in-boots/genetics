#!/bin/bash
# gatk-hard-filter.sh
# ------------------------------------------------------------------------------
# Purpose: apply a simple hard filter (QUAL > 5, INFO/DP > 1) to a single VCF
#          so it roughly matches the DRAGEN pipeline output.
# Usage:   bash script-gatk-hard-filter.sh UIC001.vcf
# Inputs:  the VCF must exist under the raw folder defined below.
# Outputs: a new VCF named "<sample>.hard-filtered.vcf" saved in the vcf folder.
# ------------------------------------------------------------------------------

set -euo pipefail
# -e : stop immediately if any command exits with a non-zero status
# -u : treat unset variables as an error
# -o pipefail : if a pipeline fails, the whole script fails

# BCFtools executable or binary from path
# Creates a variable to be used later
BCFTOOLS_BIN="${BCFTOOLS_BIN:-bcftools}"

if ! command -v "${BCFTOOLS_BIN}" >/dev/null 2>&1; then
    echo "Error: ${BCFTOOLS_BIN} not found in PATH" >&2
    exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "Usage: $(basename "$0") <vcf_filename>" >&2
    exit 1
fi

VCF_FILE="$1"

# Input and output folders in the shared cluster storage.
# Adjust these paths if you copy the script to a different batch.
INPUT_DIR="$HOME/cardio_darbar_chi_link/data/genetics/uic_first_batch/raw"
OUTPUT_DIR="$HOME/cardio_darbar_chi_link/data/genetics/uic_first_batch/vcf"
mkdir -p "$OUTPUT_DIR"

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

# BCFtools pipeline:
#   1. view: stream the VCF so we can read gzip and plain text with one command.
#   2. filter: keep only variants meeting both thresholds.
#      - QUAL > 5 ensures confident variant calls.
#      - INFO/DP > 1 requires at least 2 reads supporting the call.
"${BCFTOOLS_BIN}" view "${INPUT_PATH}" \
    | "${BCFTOOLS_BIN}" filter -i 'QUAL>5 && INFO/DP>1 && FILTER!="PASS" && FILTER!="."' \
    > "${OUTPUT_PATH}"

echo "Filtered VCF written to ${OUTPUT_PATH}"
