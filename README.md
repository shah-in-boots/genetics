# genetics

Sandbox for evaluation of genetic files. No guarantees on quality/bugs unless wrapped released as package later on. 

Has essentially two major folders:

- *local* = A workspace intended for use on a local computer, with different paths to data and more of a sandbox approach
- *cluster* = A workspace intended for HPC environments (e.g. SLURM) with different data paths and ability for parallelization



## Data

### Batch Comparison

The `data/` directory contains two batches of sequencing data processed with different variant callers:

| Aspect | First Batch | Second Batch |
|--------|-------------|--------------|
| **Variant Caller** | GATK (HaplotypeCaller) | DRAGEN |
| **Processing** | Traditional GATK pipeline | Illumina DRAGEN unified workflow |
| **Reference Build** | GRCh38 | GRCh38dh (decoy-aware) |
| **Output Format** | VCF with GATK-specific annotations | VCF with DRAGEN-specific annotations |
| **Quality Filters** | GATK standard filters (QD, FS, MQ, SOR) | DRAGEN hard filters (DRAGENHardQUAL, LowDepth) |
| **Hard Filtering Thresholds** | Various GATK recommendations | QUAL < 5.0, DP ≤ 1 |

**Key Differences:**
- DRAGEN uses a proprietary variant calling algorithm optimized for speed and accuracy
- DRAGEN includes target-specific filtering (Twist Alliance Clinical Research Exome)
- Quality scores and metrics are not directly comparable between callers
- Variant counts and genotype concordance may differ
- DRAGEN output includes both BAM (CRAM) and VCF with joint variant detection capability

**File Organization:**
- `data/uic_first_batch/vcf/` - GATK-processed VCF files
- `data/uic_second_batch/vcf/` - DRAGEN-processed VCF files
- `data/uic_second_batch/vep/` - VEP annotation outputs for second batch

## Abbreviations

| Acronym | Expanded |
| - | --- | 
| vcf | variant call format |
| GATK | Genome Analysis Toolkit |
| DRAGEN | Dynamic Read Analysis for GENomics |
| VEP | Variant Effect Predictor |

## Tools

These are contained as git submodules in this repository, however the cluster may also contain a similar set of tools.

### samtools, bcftools, htslib

https://www.htslib.org

These are general C-based NGS data analysis tools.

### vcftools

https://vcftools.github.io/index.html

## Ensembl VEP

The preferred way to do this is using VEP from a docker file. 

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

## Cluster Workflows

The [cluster/](cluster/) directory contains SLURM-based scripts for high-performance computing environments to process variant data at scale.

### Directory Structure

Scripts assume the following data organization for each batch:
- `data/genetics/{batch_name}/vcf/` - Input VCF files
- `data/genetics/{batch_name}/vep/` - VEP annotation outputs
- `data/genetics/{batch_name}/status/` - Processing status tracking (`.done` markers, `todo.txt` list)

### Workflows

#### 1. GATK Hard Filtering

**Script:** [main-script-gatk-hard-filter.sh](cluster/main-script-gatk-hard-filter.sh)

Single SLURM job that applies hard quality filters to GATK-called variants:
- **Filters:** QUAL ≥ 5, FORMAT/DP > 1, removes non-PASS variants
- **Tool:** BCFtools view with parallel processing (4 threads)
- **Resources:** 4 CPUs, 16GB RAM, 4-hour time limit
- **Input:** `uic_first_batch/raw/*.vcf*`
- **Output:** `uic_first_batch/vcf/*.hard-filtered.vcf` (indexed)

```bash
sbatch cluster/main-script-gatk-hard-filter.sh
```

#### 2. VEP Annotation Batch Processing

**Main script:** [main-vep-batch-workflow.sh](cluster/main-vep-batch-workflow.sh)

Three-tier workflow for parallelized VEP annotation using SLURM array jobs:

**Tier 1: Workflow Orchestration**
- **Purpose:** Coordinates the complete VEP batch annotation workflow
- **Usage:** `bash main-vep-batch-workflow.sh <batch_dir>`
- **Steps:**
  1. Calls [script-make-vep-todo-list.sh](cluster/script-make-vep-todo-list.sh:1) to identify unprocessed files
  2. Submits [submit-vep-array-batch.sh](cluster/submit-vep-array-batch.sh:1) as SLURM array job

**Tier 2: Array Job Submission**
- **Script:** [submit-vep-array-batch.sh](cluster/submit-vep-array-batch.sh:1)
- **Job Parameters:**
  - Array size: 0-99 (up to 100 parallel jobs)
  - Resources: 2 CPUs, 16GB RAM per task
  - Time limit: 4 hours per task
- **Functionality:**
  - Loads Apptainer module
  - Reads VCF filename from `todo.txt` based on array index
  - Calls [run-vep-single-vcf.sh](cluster/run-vep-single-vcf.sh:1) for each file

**Tier 3: Single VCF Processing**
- **Script:** [run-vep-single-vcf.sh](cluster/run-vep-single-vcf.sh:1)
- **Container:** Apptainer/Singularity VEP image (`vep.sif`)
- **VEP Configuration:**
  - `--cache`: Uses local VEP cache (`~/.vep`)
  - `--everything`: All variant consequence annotations
  - `--show_ref_allele`: Include reference allele
  - `--plugin LoF`: Loss-of-function annotations via LOFTEE plugin
- **Tracking:** Creates `.done` marker in status directory upon completion

**Supporting Script:**
- [script-make-vep-todo-list.sh](cluster/script-make-vep-todo-list.sh:1): Scans for VCF files without `.done` markers and creates `todo.txt`

**Example Usage:**
```bash
# Process all unfinished VCFs in uic_second_batch
bash cluster/main-vep-batch-workflow.sh uic_second_batch

# Check processing status
bash cluster/script-make-vep-todo-list.sh uic_second_batch
```

**Resumability:** The workflow automatically skips completed files (tracked via `.done` markers), allowing safe re-runs after failures.

### Testing Scripts

- [test-run-apptainer-vep-single-vcf.sh](cluster/test-run-apptainer-vep-single-vcf.sh:1) - Test VEP processing on a single VCF
- [test-submit-apptainer-vep.sh](cluster/test-submit-apptainer-vep.sh:1) - Test SLURM submission configuration

# CLUSTER
