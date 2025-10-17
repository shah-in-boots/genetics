#!/bin/bash
# This script takes one argument, which is the BATCH processing directory
# It calls the `script-make-todo-list.sh` to create the todo list of files that are yet to be processed
# It then calls a SLURM command to submit the job with the `submit-vep-array-batch.sh` file, which in turn requires an argument for hte batch directory
# Submission file then identifies the names of VCF files and passes it to the `run-vep-single-vcf.sh` file wiht two arguments, the first being the batch directory and the second being the VCF file name (this is internal)

# This line sets the script to exit immediately if a command exits with a non-zero status, treat unset variables as an error, and fail on any command in a pipeline that fails.
set -euo pipefail

BATCH_DIR="$1"

# STEP ONE - make list of files that still need to be analyzed
sh script-make-vep-todo-list.sh "${BATCH_DIR}"

# STEP TWO - run VEP in batch mode
# the script itself contains the space for controlling the array count
sbatch submit-vep-array-batch.sh "${BATCH_DIR}"
