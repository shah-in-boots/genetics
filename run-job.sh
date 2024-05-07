#!/bin/sh

#SBATCH --partition=cpu-t3
#SBATCH --job-name=loftee
#SBATCH --nodes=10
#SBATCH --tasks-per-node=1
#SBATCH --error=slurm-%J.err
#SBATCH --output=slurm-%J.out

module load R/4.2.1-foss-2022a
module load SAMtools/1.15.1-GCC-11.2.0
module load ensembl-vep/v111
sh cluster/vcf-lof.sh

