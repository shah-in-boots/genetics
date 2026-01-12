# README

# INSTRUCTIONS

1. Make sure that the VCF files are appropriately filtered. Can apply hard-filtering rule to ensure appropriate file size and quality. Mimics role of DRAGEN vs. GATK pipeline. Does not need to be repeated if filtered files are available.

`main-script-gatk-hard-filter.sh`

1. Variant annotation using VEP. The HPC limits are about 100 at a time, which means multiple runs are required to complete the annotation. The main script, below, can be adjusted. It targets a single directory at a time and passes it to an Dockerized Ensembl-VEP command (`vep`). The specific SLURM options are contained in the `submit-*` scripts. 

`main-batch-vep.sh`

1. Create a table of relevant variants (based on genes of interest)

`main-variant-table.sh`
