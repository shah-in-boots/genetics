#!/bin/bash

# Error catching
set -euo pipefail

# Define directories
VCF_DIR="vcf"
VEP_DIR="ep"
LOG_DIR="logs"

# Create necessary directories if they don't exist
mkdir -p "${VCF_DIR}"
mkdir -p "${VEP_DIR}"
mkdir -p "${LOG_DIR}"

# Timestamp for logging
timestamp=$(date '+%Y%m%d_%H%M%S')
log_file="${LOG_DIR}/vep_annotation_${timestamp}.log"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "${log_file}"
}

# Function to check if VEP output exists and is complete
is_vep_complete() {
    local vcf_file="$1"
    local vep_file="${VEP_DIR}/$(basename "${vcf_file}" .vcf.gz).vep.vcf.gz"
    
    if [[ -f "${vep_file}" && -f "${vep_file}.tbi" ]]; then
        # Check if the file is not truncated/corrupted
        if zgrep -q "^#EOF" "${vep_file}"; then
            return 0
        fi
    fi
    return 1
}

