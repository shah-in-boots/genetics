#!/usr/bin/env Rscript

# This function loops through all the VEP files and combines them into a table
# Preferentially the VEP files have been filtered to be smaller in size
# Takes two arguments: 1) batch directory, 2) number of available CPUs

# Setup & libraries
library(tidyverse)
library(card)
library(fs)
library(future)
library(future.apply)

# Get command line arguments
args <- commandArgs(trailingOnly = TRUE)
batch_dir <- args[1]
number_cpus <- as.integer(args[2])

# Check if argument was provided
if (length(args) == 0) {
  stop("Usage: Rscript convert-vep-to-table.R <BATCH_DIR>")
}

# Batch directory 
# Used to identify correct working folder
working_folder <- fs::path(
  fs::path_expand("~/cardio_darbar_chi_link/data/genetics"),
  batch_dir,
  "vep_filtered"
)

message("Working folder: ", working_folder)

# List out files in working folder
vep_files <- fs::dir_ls(working_folder, glob = "*.vep.filtered")

# For each file, read in the VEP file and convert to table
# Each table should have the patient ID in a column to allow for analysis later
# Do this across multiple cores using future 
future::plan(multisession, workers = number_cpus)

message("Using multiple workers: ", number_cpus)

vep_table_list <- future_lapply(vep_files, function(file) {
  message("Processing file: ", file)
  # Take the file name up until the first dot as the patient ID
  sample_id <- stringr::str_extract(fs::path_file(file), "^[^.]+") 

  # Read in the VEP data using card package
  vep_data <- 
    card::read_vep_data(file) |>
    # Add sample ID column
    dplyr::mutate(sample_id = sample_id) |>
    # Move to front of table
    dplyr::relocate(sample_id)

  message("Done with sample: ", sample_id)
})

# Convert the table list into a single table
# Save a copy in same working folder to make sure the file wrote out
vep_table <- dplyr::bind_rows(vep_table_list)
saveRDS(vep_table, fs::path(working_folder, "vep_annotations.rds"))
message("Saved RDS file to working folder: ", fs::path(working_folder, "vep_annotations.rds"))


# Write out the combined table as a CSV file
output_file <- fs::path(working_folder, "vep_annotations.csv")
readr::write_csv(vep_table, output_file)
message("Write out table to: ", output_file)
