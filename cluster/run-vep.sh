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
OUTPUT_DIR="$HOME/cardio_darbar_chi_link/data/genetics/${BATCH_DIR}/vep"
LOFTEE_DIR="$HOME/.vep/loftee"
VEP_SIF="$HOME/vep.sif"

# Make sure output exists
mkdir -p "${OUTPUT_DIR}"

apptainer exec \
    --bind ${VEP_DIR}:/data \
    --bind ${INPUT_DIR}:/input \
    --bind ${OUTPUT_DIR}:/output \
    --bind ${LOFTEE_DIR}:/plugins \
    ${VEP_SIF} vep \
    --input_file /input/${VCF_FILE} \
    --format vcf \
    --output_file /output/${VCF_FILE}.vep \
    --vcf \
    --cache \
    --force_overwrite \
    --show_ref_allele \
    --plugin LoF,loftee_path:/plugins,human_ancestor_fa:false \
		--everything

