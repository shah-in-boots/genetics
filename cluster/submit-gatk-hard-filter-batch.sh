#!/bin/bash
#SBATCH --job-name=gatk_hard_filter
#SBATCH --partition=batch
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --output=logs/gatk_hard_filter_%A_%a.out
#SBATCH --error=logs/gatk_hard_filter_%A_%a.err
#SBATCH --array=0-50

# Relevant module
module load BCFtools/1.17-GCC-12.2.0