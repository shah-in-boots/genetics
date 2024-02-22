#!/bin/bash
# The working directory must be where the VCF files are kept
# Iterate over all the files in the VCF folder
# and process each file using the VEP command
# Then, filter based on TTN variants
# and rename the output files based on their original names

for file in *.vcf; do
		# Basename of the file
    base_name=$(basename "$file" .vcf)

    # Convert with LOFTEE annotations
    vep -i $file -o ${base_name}.txt --verbose --fork 4 --offline --no_stats --polyphen s --sift s --symbol --show_ref_allele --plugin LoF,loftee_path:/Users/asshah4/tools/loftee/,human_ancestor_fa:false --dir_plugin /Users/asshah4/tools/loftee/

    # Filter to reduce filesize
    filter_vep -i ${base_name}.txt -o ${base_name}-filter.txt -filter "SYMBOL is TTN and (LoF is HC or LoF is LC)"

    # Remove previous filtered file
    rm ${base_name}.txt

done
