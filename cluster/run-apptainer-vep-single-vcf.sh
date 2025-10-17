#!/bin/bash
# Script to process a single VCF file with status tracking
# Usage: ./process-single-vcf.sh <sample_id.vcf>

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "ERROR: Usage: $0 <sample_id.vcf>" >&2
    exit 1
fi

SAMPLE_ID="$1"

# Define directories
VEP_DIR="$HOME/.vep" 
INPUT_DIR="$HOME/projects/genetics/data/uic_second_batch/vcf"
OUTPUT_DIR="$HOME/projects/genetics/data/uic_second_batch/vep"
LOFTEE_DIR="$HOME/.vep/loftee"
VEP_SIF="$HOME/vep.sif"
STATUS_DIR="$HOME/projects/genetics/data/status"

# Create status directory if it doesn't exist
mkdir -p "${STATUS_DIR}"
mkdir -p "${OUTPUT_DIR}"

# Define status files
SUCCESS_FILE="${STATUS_DIR}/${SAMPLE_ID}.success"
FAILED_FILE="${STATUS_DIR}/${SAMPLE_ID}.failed"
IN_PROGRESS_FILE="${STATUS_DIR}/${SAMPLE_ID}.inprogress"

# Check if already successfully processed
if [[ -f "${SUCCESS_FILE}" ]]; then
    echo "Sample ${SAMPLE_ID} already successfully processed - skipping"
    exit 0
fi

# Remove old failed/in-progress markers if retrying
rm -f "${FAILED_FILE}" "${IN_PROGRESS_FILE}"

# Mark as in progress
touch "${IN_PROGRESS_FILE}"

# Validate input file exists
if [[ ! -f "${INPUT_DIR}/${SAMPLE_ID}" ]]; then
    echo "ERROR: Input file does not exist: ${INPUT_DIR}/${SAMPLE_ID}" >&2
    touch "${FAILED_FILE}"
    rm -f "${IN_PROGRESS_FILE}"
    exit 1
fi

echo "Processing ${SAMPLE_ID}..."

# Run VEP annotation
apptainer exec \
    --bind ${VEP_DIR}:/data \
    --bind ${INPUT_DIR}:/input \
    --bind ${OUTPUT_DIR}:/output \
    --bind ${LOFTEE_DIR}:/plugins \
    ${VEP_SIF} vep \
    --input_file /input/${SAMPLE_ID} \
    --output_file /output/${SAMPLE_ID}.vep \
    --format vcf \
    --cache \
    --force_overwrite \
    --show_ref_allele \
    --everything \
    --plugin LoF,loftee_path:/plugins,human_ancestor_fa:false

# Check if VEP completed successfully
if [[ $? -eq 0 ]]; then
    # Verify output file was created and is not empty
    if [[ -f "${OUTPUT_DIR}/${SAMPLE_ID}.vep" ]] && [[ -s "${OUTPUT_DIR}/${SAMPLE_ID}.vep" ]]; then
        touch "${SUCCESS_FILE}"
        rm -f "${IN_PROGRESS_FILE}"
        echo "✓ Successfully completed: ${SAMPLE_ID}"
        exit 0
    else
        echo "ERROR: Output file missing or empty for ${SAMPLE_ID}" >&2
        touch "${FAILED_FILE}"
        rm -f "${IN_PROGRESS_FILE}"
        exit 1
    fi
else
    touch "${FAILED_FILE}"
    rm -f "${IN_PROGRESS_FILE}"
    echo "ERROR: VEP failed for ${SAMPLE_ID}" >&2
    exit 1
fi