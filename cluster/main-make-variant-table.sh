#!/usr/bin/env bash

# SLURM modules to load
module load R/4.4.1-gfbf-2023b
module load apptainer/1.2.5

# First part of the script is to call the R script that gets a gene panel
# This writes out a file called "gene_panel_atrial_fibrillation.csv" 
# Contains which genes to filter for from the VCF annotations 
# Under column "gene_symbol"
Rscript create-gene-panel.R "atrial fibrillation"



