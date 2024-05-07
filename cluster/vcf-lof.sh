#!/bin/bash

# Target directory
cd ~/data/genetics/vcf

for file in *.vcf; do
	base_name=$(basename "$file" .vcf)

	# Convert with LOFTEE annotations
	vep - i $file -o ${base_name}.txt --verbose --fork 2 --offline --no_stats --polyphen s --sift -s --symbol --show_ref_allele --plugin Lof,loftee_path:/shared/home/ashah282/tools/loftee/,human_ancestor_fa:false --dir_plugin /shared/home/ashah282/tools/loftee/

done
