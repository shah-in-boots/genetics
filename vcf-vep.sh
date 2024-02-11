#!/bin/bash
# Iterate over all the files in the VCF folder
# and process each file using the VEP command
# Then, filter based on TTN variants
# and rename the output files based on their original names

for file in *.vcf; do
    base_name=$(basename "$file" .vcf)
    vep --verbose --fork 4 --offline -i $file  --no_stats --polyphen s --sift s --symbol --show_ref_allele -o ${base_name}.txt
done
