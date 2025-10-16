#!/bin/bash

# Sample to test
SAMPLE_ID="SM-OJRMH.hard-filtered.vcf"
VEP_DIR="$HOME/.vep" 
INPUT_DIR="$HOME/projects/genetics/data/uic_second_batch/vcf"
OUTPUT_DIR="$HOME/projects/genetics/data/uic_second_batch/vep"
LOFTEE_DIR="$HOME/.vep/loftee"

# This generally works for LoF, assuming that Loftee is in the correct place
# Dockerized version works well as long as files are mounted appropriately
docker run \
	-v ${VEP_DIR}:/data \
	-v ${INPUT_DIR}:/input \
	-v ${OUTPUT_DIR}:/output \
	-v ${LOFTEE_DIR}:/plugins \
	ensemblorg/ensembl-vep vep \
	--input_file /input/${SAMPLE_ID} \
	--output_file /output/${SAMPLE_ID}.vep \
	--format vcf \
	--cache \
	--force_overwrite \
	--show_ref_allele \
	--everything \
	--plugin LoF,loftee_path:/plugins,human_ancestor_fa:false 


