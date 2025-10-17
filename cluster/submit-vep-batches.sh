#!/bin/bash

INPUT_DIR="$HOME/projects/genetics/data/uic_second_batch/vcf"
STATUS_DIR="$HOME/cardio_darbar_chi_link/data/genetics/status"
BATCH_SIZE=20

mkdir -p "${STATUS_DIR}"

# Count unprocessed files
mapfile -d '' -t ALL_FILES < <(find "${INPUT_DIR}" -maxdepth 1 -type f -name '*.vcf' -print0 | sort -z)
UNPROCESSED=0
for vcf in "${ALL_FILES[@]}"; do
    filename=$(basename "$vcf")
    if [[ ! -f "${STATUS_DIR}/${filename}.success" ]]; then
        ((UNPROCESSED++))
    fi
done

echo "Total VCF files: ${#ALL_FILES[@]}"
echo "Unprocessed files: ${UNPROCESSED}"

# Calculate number of batches needed
NUM_BATCHES=$(( (UNPROCESSED + BATCH_SIZE - 1) / BATCH_SIZE ))

echo "Submitting ${NUM_BATCHES} batch(es) of up to ${BATCH_SIZE} files each"

# Submit each batch
for ((batch=0; batch<NUM_BATCHES; batch++)); do
    echo "Submitting batch ${batch}..."
    sbatch --export=BATCH_NUMBER=${batch} run-apptainer-vep-batch.sh
done