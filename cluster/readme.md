# README

1. Make sure that the VCF files are appropriately filtered. Can apply hard-filtering rule to ensure appropriate file size and quality. Mimics role of DRAGEN vs. GATK pipeline. Does not need to be repeated if filtered files are available.

`main-script-gatk-hard-filter.sh`

1. Variant annotation using VEP.

`main-batch-vep.sh`

1. Create a table of relevant variants (based on genes of interest)

`main-variant-table.sh`