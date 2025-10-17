#!/bin/bash
# Apply a simple GATK-style hard filter to a single VCF using bcftools.
# Usage: bash run-gatk-hard-filter.sh <batch_dir> <vcf_filename>

set -euo pipefail

if [[ $# -ne 2 ]]; then
    echo "Usage: $(basename "$0") <batch_dir> <vcf_filename>" >&2
    exit 1
fi

BATCH_DIR="$1"
VCF_FILE="$2"

BASE_DIR="$HOME/cardio_darbar_chi_link/data/genetics/${BATCH_DIR}"
INPUT_DIR="${BASE_DIR}/raw"
OUTPUT_DIR="${BASE_DIR}/vcf"
STATUS_DIR="${BASE_DIR}/status"

INPUT_PATH="${INPUT_DIR}/${VCF_FILE}"

if [[ ! -f "${INPUT_PATH}" ]]; then
    echo "Error: ${INPUT_PATH} not found" >&2
    exit 1
fi

mkdir -p "${OUTPUT_DIR}"
mkdir -p "${STATUS_DIR}"

case "${VCF_FILE}" in
    *.vcf.gz) SAMPLE_NAME="${VCF_FILE%.vcf.gz}" ;;
    *.vcf) SAMPLE_NAME="${VCF_FILE%.vcf}" ;;
    *) SAMPLE_NAME="${VCF_FILE}" ;;
esac

OUTPUT_PATH="${OUTPUT_DIR}/${SAMPLE_NAME}.hard-filtered.vcf"
DONE_MARKER="${STATUS_DIR}/${SAMPLE_NAME}.hard-filter.done"

if declare -F module >/dev/null 2>&1; then
    module load bcftools >/dev/null 2>&1 || true
fi

bcftools view "${INPUT_PATH}" \
    | bcftools filter -i 'QUAL>5 && INFO/DP>1' \
    > "${OUTPUT_PATH}"

touch "${DONE_MARKER}"

echo "Filtered VCF written to ${OUTPUT_PATH}"
echo "Completion flag written to ${DONE_MARKER}"
