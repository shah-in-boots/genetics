#!/bin/bash
# Process single VCF file through VEP
# Usage: bash run-vep-single.sh <vcf_filename>

set -euo pipefail

VCF_FILE="$1"
VEP_DIR="$HOME/.vep" 
INPUT_DIR="$HOME/cardio_darbar_chi_link/data/genetics/uic_first_batch/vcf"
OUTPUT_DIR="$HOME/cardio_darbar_chi_link/data/genetics/uic_first_batch/vep"
STATUS_DIR="$HOME/cardio_darbar_chi_link/data/genetics/uic_first_batch/status"
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
	--everything \
	--plugin LoF,loftee_path:/plugins,human_ancestor_fa:false

# Mark as complete
touch "${STATUS_DIR}/${VCF_FILE}.done"