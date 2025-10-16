#!/bin/bash
#SBATCH --job-name=docker_vep_test
#SBATCH --partition=general
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=02:00:00
#SBATCH --output=logs/docker_vep_%j.out
#SBATCH --error=logs/docker_vep_%j.err

set -euo pipefail

# Load required modules
module load apptainer >/dev/null 2>&1 || module load singularity >/dev/null 2>&1 || true

# Verify container runtime is available
if ! command -v apptainer >/dev/null 2>&1 && ! command -v singularity >/dev/null 2>&1; then
    echo "ERROR: Neither apptainer nor singularity is available" >&2
    exit 1
fi

# Call the VEP script
bash "${HOME}/projects/genetics/local/test-apptainer-vep.sh"
