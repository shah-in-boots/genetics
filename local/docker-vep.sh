#!/bin/bash

docker run \
	-v $HOME/.vep:/data \
	-v $HOME/data/genetics/uic_second_batch/raw:/input \
	-v $HOME/data/genetics/uic_second_batch/vep:/output \
	ensemblorg/ensembl-vep vep \
	-i /input/SM-OJT8K.hard-filtered.vcf \
	-o /output/tmp_vep.txt \
	--cache --offline --verbose \
	--polyphen s --sift s --symbol --show_ref_allele \
	--plugin LoF,loftee_path:$HOME/tools/loftee,human_ancestor_fa:false \
	--dir_plugin $HOME/tools/loftee/


