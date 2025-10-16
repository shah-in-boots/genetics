#!/bin/bash
# Script to run VEP on a single VCF file using apptainer
# Usage: ./test-apptainer-vep.sh <sample_id.vcf>

set -euo pipefail

# Accept sample ID as argument
if [[ $# -ne 1 ]]; then
    echo "ERROR: Usage: $0 <sample_id.vcf>" >&2
    exit 1
fi

# Sample ID is the argument given to the file when running it
# THis argument is given in the SBATCH running script, e.g. run-apptainer-vep.sh
SAMPLE_ID="$1"

VEP_DIR="$HOME/.vep" 
INPUT_DIR="$HOME/cardio_darbar_chi_link/data/genetics/uic_second_batch/vcf"
OUTPUT_DIR="$HOME/cardio_darbar_chi_link/data/genetics/uic_second_batch/vep"
LOFTEE_DIR="$HOME/.vep/loftee"
VEP_SIF="$HOME/vep.sif"

# Validate paths exist
for path in "${VEP_SIF}" "${VEP_DIR}" "${LOFTEE_DIR}" "${INPUT_DIR}/${SAMPLE_ID}"; do
    if [[ ! -e ${path} ]]; then
        echo "ERROR: Required path does not exist: ${path}" >&2
        exit 1
    fi
done

# Create output directory if needed
mkdir -p "${OUTPUT_DIR}"

# This generally works for LoF, assuming that Loftee is in the correct place
# Dockerized version works well as long as files are mounted appropriately
# Need the apptainer to be mounted before hand
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

echo "Completed VEP annotation for ${SAMPLE_ID}"