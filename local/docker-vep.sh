#!/bin/bash

# This generally works for LoF, assuming that Loftee is in the correct place
# Dockerized version works well as long as files are mounted appropriately
docker run \
	-v $HOME/.vep:/data \
	-v $HOME/data/genetics/uic_first_batch/vcf:/input \
	-v $HOME/data/genetics/uic_first_batch/tmp:/output \
	-v $HOME/.vep/loftee:/plugins \
	ensemblorg/ensembl-vep vep \
	--input_file /input/CCDG_Broad_CVD_AF_Darbar_UIC_Cases-UIC0330.vcf \
	--output_file /output/tmp_vep.txt \
	--format vcf \
	--cache \
	--force_overwrite \
	--plugin LoF,loftee_path:/plugins,human_ancestor_fa:false 


