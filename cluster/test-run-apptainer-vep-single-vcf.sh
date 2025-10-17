#!/bin/bash

# Sample to test
SAMPLE_ID="SM-OJRMH.hard-filtered.vcf"
VEP_DIR="$HOME/.vep" 
INPUT_DIR="$HOME/projects/genetics/data/uic_second_batch/vcf"
OUTPUT_DIR="$HOME/projects/genetics/data/uic_second_batch/vep"
LOFTEE_DIR="$HOME/.vep/loftee"
VEP_SIF="$HOME/vep.sif"

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


