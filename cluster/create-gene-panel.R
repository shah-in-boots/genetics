#!/usr/bin/env Rscript

# Get command line arguments
args <- commandArgs(trailingOnly = TRUE)

# Check if argument was provided
if (length(args) == 0) {
  stop("Usage: Rscript create-gene-panel.R <phenotype_description>")
}

# Get the phenotype description argument
phenotype <- args[1]

# Your code here
print(paste("Creating gene panel for phenotype:", phenotype))

# Add your gene panel creation logic below
# Setup library first
library(tidyverse)
library(card)

dat <- card::query_genes_by_phenotype(
  phenotype,
  database = "clinvar",
  max_results = 500
)

# Write out to CSV
write_csv(dat, paste0("gene_panel_", gsub(" ", "_", phenotype), ".csv"))