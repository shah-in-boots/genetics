#!/bin/bash

# This generally works for LoF, assuming that Loftee is in the correct place
# Dockerized version works well as long as files are mounted appropriately
docker run \
	-v $HOME/.vep:/data \
	-v $HOME/data/genetics/uic_second_batch/vcf:/input \
	-v $HOME/data/genetics/uic_second_batch/vep:/output \
	-v $HOME/.vep/loftee:/plugins \
	ensemblorg/ensembl-vep vep \
	--input_file /input/SM-OJT8K.hard-filtered.vcf \
	--output_file /output/tmp_vep.txt \
	--format vcf \
	--cache \
	--force_overwrite \
	--show_ref_allele \
	--everything \
	--plugin LoF,loftee_path:/plugins,human_ancestor_fa:false 


