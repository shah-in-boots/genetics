#!/bin/bash

#SBATCH --partition=batch
#SBATCH --job-name=bcftools_filter
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --error=logs/filter-%J.err
#SBATCH --output=logs/filter-%J.out

module load BCFtools/1.17-GCC-12.2.0

INPUT_DIR="$HOME/cardio_darbar_chi_link/data/genetics/uic_first_batch/raw"
OUTPUT_DIR="$HOME/cardio_darbar_chi_link/data/genetics/uic_first_batch/vcf"

mkdir -p "${OUTPUT_DIR}"

for vcf in "${INPUT_DIR}"/*.vcf*; do
		base=$(basename "$vcf" | sed 's/\.vcf.*//')
		out="${OUTPUT_DIR}/${base}.hard-filtered.vcf"
					    
		bcftools view --include 'QUAL>=5 && FORMAT/DP>1 && FILTER!="PASS"' -Oz -o "$out" --threads 4 "$vcf"
		bcftools index -t "$out"
done
