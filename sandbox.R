# Trim appropraite AFL patients rom the data set

library(tidyverse)
library(vcfR)

clinical <-
  tar_read(flutter_data_tidy, store = "../aflubber/_targets/") |>
  select(study_id, family_history) |>
  filter(family_history == 1)

afl_ids <-
  tar_read(flutter_ids, store = "../aflubber/_targets/") |>
  filter(!is.na(dna_id)) |>
  filter(str_detect(dna_id, pattern = "UIC"))

# Find flutter history ids
ids <-
  inner_join(afl_ids, clinical, by = "study_id") |>
  pluck("dna_id")

gen_ids <- colnames(vcf_data@gt)

common_ids <- ids[which(ids %in% gen_ids)]

fp <- file.path(data_loc, "aflubber", "genetics", "afl.vcf.gz")

write.vcf(vcf_data[, c("FORMAT", common_ids)], file = fp)

# Variants ----

library(VariantAnnotation)
vcf <- readVcf('data/Broad-AF-UIC-Cases-UIC0002.vcf')

header(vcf)
geno(header(vcf))
geno(vcf)
geno(header(vcf))['GT', ]
GT <- geno(vcf)$GT

# New WES data ----

x <- vroom::vroom("~/Downloads/sample.tsv")
