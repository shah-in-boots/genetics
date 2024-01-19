# Using ensemblVEP package
library(ensemblVEP)
isTRUE(grepl('vep', (Sys.which("vep"))))
param <- VEPFlags()
flags(param)

# Set host to be at the ensembl database
param <- VEPFlags(flags = list(host = "useastdb.ensembl.org"))

# Sample human VCF file from genetics data from UIC
vcf_path <- fs::path("~/data/genetics/vcf/CCDG_Broad_CVD_AF_Darbar_UIC_Cases-UIC0002.vcf")

# GRanges can be returned as the default
gr <- ensemblVEP(vcf_path, param = param)

# VCF files can be return if added to the flags
param <- VEPFlags(flags = list(vcf = TRUE, host = "useastdb.ensembl.org"))
