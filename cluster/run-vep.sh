#!/bin/bash
# Process single VCF file through VEP
# Usage: bash run-vep.sh <batch_dir> <vcf_filename>

set -euo pipefail

# Arguments
BATCH_DIR="$1"
VCF_FILE="$2"

# Standard locations
VEP_DIR="$HOME/.vep" 
INPUT_DIR="$HOME/cardio_darbar_chi_link/data/genetics/${BATCH_DIR}/vcf"
OUTPUT_DIR="$HOME/cardio_darbar_chi_link/data/genetics/${BATCH_DIR}/lof"
STATUS_DIR="$HOME/cardio_darbar_chi_link/data/genetics/${BATCH_DIR}/status"
LOFTEE_DIR="$HOME/.vep/loftee"
VEP_SIF="$HOME/vep.sif"

mkdir -p "${OUTPUT_DIR}"
mkdir -p "${STATUS_DIR}"

apptainer exec \
    --bind ${VEP_DIR}:/data \
    --bind ${INPUT_DIR}:/input \
    --bind ${OUTPUT_DIR}:/output \
    --bind ${LOFTEE_DIR}:/plugins \
    ${VEP_SIF} vep \
    --input_file /input/${VCF_FILE} \
    --output_file /output/${VCF_FILE}.vep \
    --format vcf \
    --cache \
    --force_overwrite \
    --show_ref_allele \
    --plugin LoF,loftee_path:/plugins,human_ancestor_fa:false \
		--everything

# Mark as complete
touch "${STATUS_DIR}/${VCF_FILE}.done"
