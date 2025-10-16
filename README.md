# genetics

Sandbox for evaluation of genetic files. No guarantees on quality/bugs unless wrapped released as package later on. 

Has essentially two major folders:

- *local* = A workspace intended for use on a local computer, with different paths to data and more of a sandbox approach
- *cluster* = A workspace intended for HPC environments (e.g. SLURM) with different data paths and ability for parallelization



## Abbreviations

| Acronym | Expanded |
| - | --- | 
| vcf | variant call format |

## Tools

These are contained as git submodules in this repository, however the cluster may also contain a similar set of tools.

### samtools, bcftools, htslib

https://www.htslib.org

These are general C-based NGS data analysis tools.

### vcftools

https://vcftools.github.io/index.html

## Ensembl VEP

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
