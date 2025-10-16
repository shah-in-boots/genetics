# genetics

Sandbox for evaluation of genetic files. No guarantees on quality/bugs unless wrapped released as package later on. 

Has essentially two major folders:

- *local* = A workspace intended for use on a local computer, with different paths to data and more of a sandbox approach
- *cluster* = A workspace intended for HPC environments (e.g. SLURM) with different data paths and ability for parallelization



## Data

### Batch Comparison

The `data/` directory contains two batches of sequencing data processed with different variant callers:

| Aspect | First Batch | Second Batch |
|--------|-------------|--------------|
| **Variant Caller** | GATK (HaplotypeCaller) | DRAGEN |
| **Processing** | Traditional GATK pipeline | Illumina DRAGEN unified workflow |
| **Reference Build** | GRCh38 | GRCh38dh (decoy-aware) |
| **Output Format** | VCF with GATK-specific annotations | VCF with DRAGEN-specific annotations |
| **Quality Filters** | GATK standard filters (QD, FS, MQ, SOR) | DRAGEN hard filters (DRAGENHardQUAL, LowDepth) |
| **Hard Filtering Thresholds** | Various GATK recommendations | QUAL < 5.0, DP ≤ 1 |

**Key Differences:**
- DRAGEN uses a proprietary variant calling algorithm optimized for speed and accuracy
- DRAGEN includes target-specific filtering (Twist Alliance Clinical Research Exome)
- Quality scores and metrics are not directly comparable between callers
- Variant counts and genotype concordance may differ
- DRAGEN output includes both BAM (CRAM) and VCF with joint variant detection capability

**File Organization:**
- `data/uic_first_batch/vcf/` - GATK-processed VCF files
- `data/uic_second_batch/vcf/` - DRAGEN-processed VCF files
- `data/uic_second_batch/vep/` - VEP annotation outputs for second batch

## Abbreviations

| Acronym | Expanded |
| - | --- | 
| vcf | variant call format |
| GATK | Genome Analysis Toolkit |
| DRAGEN | Dynamic Read Analysis for GENomics |
| VEP | Variant Effect Predictor |

## Tools

These are contained as git submodules in this repository, however the cluster may also contain a similar set of tools.

### samtools, bcftools, htslib

https://www.htslib.org

These are general C-based NGS data analysis tools.

### vcftools

https://vcftools.github.io/index.html

## Ensembl VEP

The preferred way to do this is using VEP from a docker file. 

This annotation software can be loaded through a Python Anaconda environment

1. Load Anaconda
1. Create a virtual environment
1. Activate a virtual environment
1. Install Ensembl
1. Load it prior to usage

```
[smohr@ip-172-25-17-35 ~]$ module load Anaconda3/2022.05
[smohr@ip-172-25-17-35 ~]$ conda create -n ensembl
[smohr@ip-172-25-17-35 ~]$ source activate  ensembl
(ensembl) [smohr@ip-172-25-17-35 ~]$ conda install bioconda::ensembl-vep
```

# CLUSTER
