#!/bin/bash

# Main script for pooling together annotated files into a table
# Simply calls the correct submission script

# First set up all the relevant paths/variables
BATCH_DIR="uic_second_batch"

sbatch submit-vep-to-table.sh "${BATCH_DIR}"
