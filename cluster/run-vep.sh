#!/bin/bash

# run-vep.sh
# Wrapper script for running VEP with LOFTEE using a Apptainer (on cluster)
#
# The input file is the VCF file to be annotated. The I/O directories are set
# within the script itself. It will output the annotation file with the
# extension changed from *.vcf to *.vep. Additional options for the VEP system
# can be adjusted below.
# 
# Arguments:
#   $1 = batch directory folder
#   $2 = input VCF file (*.vcf)
#
# Example:
#
#   run-vep.sh <barch_dir> <input.vcf> 
#
# Script needs to be executable and should be placed on path before calling
#   chmod +x run-vep.sh

set -exuo pipefail

# Path Configuration -----------------------------------------------------------

# VEP paths
VEP_SIF="$HOME/vep.sif"
VEP_DIR="$HOME/.vep"
LOFTEE_DIR="$HOME/.vep/loftee"
ASSEMBLY="GRCh38"

# File directories
BATCH_DIR=$1
INPUT_DIR="$HOME/cardio_darbar_chi_link/data/genetics/${BATCH_DIR}/vcf"
OUTPUT_DIR="$HOME/cardio_darbar_chi_link/data/genetics/${BATCH_DIR}/vep"

# Make sure output exists
mkdir -p "${OUTPUT_DIR}"

# Arguments --------------------------------------------------------------------

# This is the VCF file, the 2nd argument
INPUT_FILE="$2"

# Make sure there is an input argument
if [ $# -ne 2 ]; then
	echo "Usage: $(basename $0) <batch_dir> <input.vcf>"
	exit 1
fi

INPUT_PATH="${INPUT_DIR}/${INPUT_FILE}"

# Make sure the input file exists in the input directory
if [ ! -f "$INPUT_PATH" ]; then
	echo "Input file not found: $INPUT_PATH"
	exit 1
fi

# Make sure the output file is appropriately named
# Needs to be renamed from *.vcf to *.vep
OUTPUT_FILE="${INPUT_FILE%.vcf}.vep"

# Run VEP ----------------------------------------------------------------------

# Apptainer/singularity run of VEP through SIF file
# Need to adjust options 
apptainer exec \
	--bind "${VEP_DIR}:/opt/vep/.vep" \
	--bind "${INPUT_DIR}:/input" \
	--bind "${OUTPUT_DIR}:/output" \
	--bind "${LOFTEE_DIR}:/plugins/loftee" \
  ${VEP_SIF} vep \
	--input_file /input/$INPUT_FILE \
	--output_file /output/$OUTPUT_FILE \
	--format vcf \
  --species homo_sapiens --assembly $ASSEMBLY \
	--offline --cache \
	--dir_cache /opt/vep/.vep \
  --fork 4 \
	--no_stats \
	--everything \
	--show_ref_allele \
	--force_overwrite \
	--dir_plugins /plugins/loftee \
	--plugin "LoF,loftee_path:/plugins/loftee,human_ancestor_fa:/plugins/loftee/human_ancestor.fa,conservation_file:/plugins/loftee/loftee.sql,gerp_bigwig:/plugins/loftee/gerp_conservation_scores.homo_sapiens.GRCh38.bw"
