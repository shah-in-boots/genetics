#!/bin/bash
#SBATCH --job-name=docker_vep_test
#SBATCH --partition=batch
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=02:00:00
#SBATCH --output=logs/docker_vep_%j.out
#SBATCH --error=logs/docker_vep_%j.err

set -euo pipefail

# Load required modules
module load apptainer/1.2.5


# Call the VEP script
bash "${HOME}/projects/genetics/cluster/test-apptainer-vep.sh"
