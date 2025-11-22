#!/usr/bin/env bash

# STEP 1
# First part of the script is to call the R script that gets a gene panel
# This writes out a file called "gene_panel_atrial_fibrillation.csv" 
# Contains which genes to filter for from the VCF annotations 
# Under column "gene_symbol"
# The file output is "gene_panel_${PHENOTYPE}.tsv" (with spaces changed to underscore)
# Only need to do this once per phenotype of interest
PHENOTYPE="atrial fibrillation"
bash submit-gene-panel.sh "${PHENOTYPE}"

# STEP 2
# Second part is to filter VEP files for the genes in the gene panel
# Will need the `gene_symbol` to identify which gene to filter for
# Batch this over the number of files available in the VEP folders

# Gene panel file (subbing underscores for spaces)
# Save list of genes for filtering by `filter_vep` (comma separated)
PANEL_TSV="$HOME/projects/genetics/data/gene_panel_${PHENOTYPE// /_}.tsv"
GENE_LIST=$(awk 'NR > 1 { print $1 }' "$PANEL_TSV" | paste -sd ',' -)

# SLURM submission
# Needs to know the following arguments:
# 1 = batch directory
# 2 = Gene list variable (bash array)

sbatch submit-filter-vep-arrah.sh "${BATCH_DIRECTORY}"
