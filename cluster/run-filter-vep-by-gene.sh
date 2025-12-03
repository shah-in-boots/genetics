#!/bin/bash

# Filter a VEP-annotated VCF for a list of genes using filter_vep.
# The input variables are:
#  1) BATCH_DIR = batch directory so knows where to create output
#  2) GENE_LIST = bash variable with list of genes, comma separated
#  3) VEP_FILE = input file that is a VEP to be filtered down
#
# This file is called in the `submit-filter-vep-array.sh` script`

set -euo pipefail

# VARS ====

# Variables of interest
BATCH_DIR="$1"
GENE_LIST="$2"
VEP_FILE="$3"

# Standard locations of important paths
VEP_DIR="$HOME/.vep" 
INPUT_DIR="$HOME/cardio_darbar_chi_link/data/genetics/${BATCH_DIR}/vep"
OUTPUT_DIR="$HOME/cardio_darbar_chi_link/data/genetics/${BATCH_DIR}/vep_filtered"
VEP_SIF="$HOME/vep.sif"

# FILTER_VEP ====

apptainer exec \
    --bind ${VEP_DIR}:/data \
    --bind ${INPUT_DIR}:/input \
    --bind ${OUTPUT_DIR}:/output \
    ${VEP_SIF} filter_vep \
    --input_file /input/${VEP_FILE} \
    --output_file /output/${VEP_FILE}.filtered \
    --filter "SYMBOL in {${GENE_LIST}}" \
    --force_overwrite \
		--only_matched
