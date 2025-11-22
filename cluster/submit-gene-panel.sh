#!/bin/bash
#SBATCH --job-name=gene_panel
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --output=logs/gene_panel_%A_%a.out
#SBATCH --error=logs/gene_panel_%A_%a.err

# Load R module
#module load R/4.4.1-gfbf-2023b
module load R

# Variables
PHENOTYPE="$1"

# R script to create a gene panel based on the provided phenotype
# Will write out to the 'data' folder in the 'genetics' repository
Rscript $HOME/projects/genetics/cluster/create-gene-panel.R "${PHENOTYPE}"