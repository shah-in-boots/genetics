# Reading VEP data in R

# Load necessary libraries
library(tidyverse)
library(card)
library(fs)

# Key path
data_dir <- fs::path_expand("~/projects/genetics/data/uic_second_batch")

# Read in data
hea <- card:;read_vep_header(fs::path(data_dir, "vep", "tmp_vep.txt"))
dat <- card::read_vep_data(fs::path(data_dir, "vep", "tmp_vep.txt"))
