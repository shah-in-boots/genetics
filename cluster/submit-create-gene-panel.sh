#!/bin/bash
#SBATCH --job-name=gene_panel
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --output=logs/gene_panel_%J.out
#SBATCH --error=logs/gene_panel_%J.err

# Make sure path for libraries is present
export R_LIBS_USER="~/tools/R/library"

# Load R module
module load R/4.4.2-gfbf-2024a

# Variables
PHENOTYPE="$1"

# R script to create a gene panel based on the provided phenotype
# Will write out to the 'data' folder in the 'genetics' repository
Rscript create-gene-panel.R "${PHENOTYPE}"
