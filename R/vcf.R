library(tidyverse)
library(VariantAnnotation)
library(TxDb.Hsapiens.UCSC.hg38.knownGene)
library(GenomicFeatures)
library(AnnotationHub)

# VCF that has been processed by VEP
vcf <- readVcf(here::here('data/sample-vep.vcf'))

