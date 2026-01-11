#!/bin/bash

# docker-vep.sh
# Wrapper script for running VEP with LOFTEE using a Docker container
#
# The input file is the VCF file to be annotated. The I/O directories are set
# within the script itself. It will output the annotation file with the
# extension changed from *.vcf to *.vep. Additional options for the VEP system
# can be adjusted below.
# 
# Arguments:
#   $1 = input VCF file (*.vcf)
#
# Example:
#
#   vep-docker.sh <input.vcf> 
#
# Script needs to be executable and should be placed on path before calling
#   chmod +x docker-vep.sh

set -exuo pipefail

# Path Configuration -----------------------------------------------------------

# VEP paths
VEP_CACHE_DIR="$HOME/.vep"
LOFTEE_DIR="$HOME/.vep/loftee"
ASSEMBLY="GRCh38"

# File directories
INPUT_DIR="$HOME/projects/genetics/data/uic_first_batch/vcf/"
OUTPUT_DIR="$HOME/projects/genetics/data/uic_first_batch/vep/"

# Inputs -----------------------------------------------------------------------

# Make sure there is an input argument
if [ $# -ne 1 ]; then
	echo "Usage: $(basename $0) <input.vcf>"
	exit 1
fi

INPUT_FILE="$1"
INPUT_PATH="${INPUT_DIR}/${INPUT_FILE}"

# Make sure the input file exists in the input directory
if [ ! -f "$INPUT_PATH" ]; then
	echo "Input file not found: $INPUT_PATH"
	exit 1
fi

# Make sure hte output file is appropriately named
# Needs to be renamed from *.vcf to *.vep
OUTPUT_FILE="${INPUT_FILE%.vcf}.vep"


# Run VEP ----------------------------------------------------------------------

# Check things like the forks, and what data is wanted here. 
docker run --rm \
	-v "${VEP_CACHE_DIR}:/opt/vep/.vep" \
	-v "${INPUT_DIR}:/input" \
	-v "${OUTPUT_DIR}:/output" \
	-v "${LOFTEE_DIR}:/plugins/loftee" \
	ensemblorg/ensembl-vep vep \
	--input_file /input/$INPUT_FILE \
	--output_file /output/$OUTPUT_FILE \
	--format vcf \
	--assembly $ASSEMBLY --species homo_sapiens \
	--offline --cache \
	--dir_cache /opt/vep/.vep \
	--fork 4 \
	--no_stats \
	--everything \
	--show_ref_allele \
	--force_overwrite \
	--dir_plugins /plugins/loftee \
	--plugin "LoF,loftee_path:/plugins/loftee,human_ancestor_fa:false,conservation_file:/plugins/loftee/loftee.sql,gerp_bigwig:/plugins/loftee/gerp_conservation_scores.homo_sapiens.GRCh38.bw"