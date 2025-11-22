#!/usr/bin/env Rscript

# Get command line arguments
args <- commandArgs(trailingOnly = TRUE)

# Check if argument was provided
if (length(args) == 0) {
  stop("Usage: Rscript create-gene-panel.R <phenotype_description>")
}

# Get the phenotype description argument
phenotype <- args[1]

# Output is the phenotype being filtered for
print(paste("Creating gene panel for phenotype:", phenotype))

# Setup library first
# Add your gene panel creation logic below
# For atrial fibrillation, about 11k seems correct
library(tidyverse)
library(card)

dat <- card::query_genes_by_phenotype(
  phenotype,
  database = "clinvar",
  max_results = 1000
)

# Write out to file
# Use tab file to maintain rank and file
# Make sure path is at home directory in genetics folder
gene_file_path <- fs::path_home(
  "projects",
  "genetics",
  "data",
  paste0("gene_panel_", gsub(" ", "_", phenotype), ".tsv")
)
write_tsv(dat, gene_file_path)
