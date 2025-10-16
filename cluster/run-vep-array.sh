#!/bin/bash
#SBATCH --job-name=vep_batch
#SBATCH --partition=general            # TODO: update to your cluster's partition/queue
#SBATCH --cpus-per-task=4              # matches --fork value
#SBATCH --mem=16G
#SBATCH --time=12:00:00
#SBATCH --output=logs/vep_%A_%a.out
#SBATCH --error=logs/vep_%A_%a.err
# Submit with: sbatch --array=0-<N-1>%4 cluster/run-vep-array.sh

set -euo pipefail

module load apptainer >/dev/null 2>&1 || module load singularity >/dev/null 2>&1 || true

if command -v apptainer >/dev/null 2>&1; then
    CONTAINER_CMD=apptainer
elif command -v singularity >/dev/null 2>&1; then
    CONTAINER_CMD=singularity
else
    echo "Neither apptainer nor singularity is available on PATH" >&2
    exit 1
fi

SIF_PATH="${HOME}/vep.sif"
CACHE_DIR="${HOME}/.vep"
PLUGIN_DIR="${CACHE_DIR}/loftee"
INPUT_DIR="${HOME}/data/genetics/vcf"
OUTPUT_DIR="${HOME}/data/genetics/vep"

for path in "${SIF_PATH}" "${CACHE_DIR}" "${PLUGIN_DIR}" "${INPUT_DIR}"; do
    if [[ ! -e ${path} ]]; then
        echo "Required path ${path} does not exist. Update the variables near the top of the script." >&2
        exit 1
    fi
done

if [[ -z "${SLURM_ARRAY_TASK_ID:-}" ]]; then
    echo "This script is designed to be run as a SLURM array job." >&2
    echo "Submit with: sbatch --array=0-(N-1)%4 cluster/run-vep-array.sh" >&2
    exit 1
fi

mapfile -d '' -t VCF_FILES < <(find "${INPUT_DIR}" -maxdepth 1 -type f -name '*.vcf' -print0 | sort -z)
TOTAL=${#VCF_FILES[@]}

if (( TOTAL == 0 )); then
    echo "No VCF files found in ${INPUT_DIR}" >&2
    exit 1
fi

if (( SLURM_ARRAY_TASK_ID >= TOTAL )); then
    echo "Task ${SLURM_ARRAY_TASK_ID} exceeds number of VCFs (${TOTAL}); exiting." >&2
    exit 0
fi

VCF_FILE="${VCF_FILES[SLURM_ARRAY_TASK_ID]}"
SAMPLE_NAME="$(basename "${VCF_FILE}" .vcf)"

mkdir -p "${OUTPUT_DIR}" logs

srun "${CONTAINER_CMD}" exec \
    --bind "${CACHE_DIR}:/cache","${INPUT_DIR}:/input","${OUTPUT_DIR}:/output","${PLUGIN_DIR}:/plugins" \
    "${SIF_PATH}" vep \
        --input_file "/input/${SAMPLE_NAME}.vcf" \
        --output_file "/output/${SAMPLE_NAME}.vep.vcf" \
        --format vcf \
        --dir_cache /cache \
        --offline \
        --cache \
        --no_stats \
        --everything \
        --force_overwrite \
        --show_ref_allele \
        --plugin LoF,loftee_path:/plugins,human_ancestor_fa:false \
        --fork "${SLURM_CPUS_PER_TASK}"
