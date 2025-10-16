#!/bin/bash

# Target directory (or test directory)
cd /shared/home/ashah282/data/genetics/test

for file in *.vcf; do
	base_name=$(basename "$file" .vcf)

	# Convert with LOFTEE annotations
	apptainer exec /shared/software/EasyBuild/modules/all/ensembl-vep/ensembl-vep_latest.sif vep -i $file -o ${base_name}.txt --verbose --fork 2 --offline --no_stats --polyphen s --sift s --symbol --show_ref_allele --plugin Lof,loftee_path:/shared/home/ashah282/tools/loftee/,human_ancestor_fa:false --dir_plugin /shared/home/ashah282/tools/loftee/

	# Convert without LOFTEE
	#apptainer exec /shared/software/EasyBuild/modules/all/ensembl-vep/ensembl-vep_latest.sif vep -i $file -o ${base_name}.txt --verbose --fork 2 --offline --no_stats --polyphen s --sift s --symbol --show_ref_allele

done
