# Cluster workflows

## Parallel VEP annotation

Use `run-vep-array.sh` to annotate every VCF in the cluster input directory with Ensembl VEP running inside the `vep.sif` container.

### Preparation
1. Confirm the following resources live in your home directory (update the script if not):
   - `~/vep.sif`
   - `~/.vep` cache directory
   - `~/.vep/loftee` plugin directory
   - `~/data/genetics/vcf` input directory containing `.vcf` files
2. Create an output directory if it does not exist:
   ```bash
   mkdir -p ~/data/genetics/vep
   ```
3. Optional: review the resource requests at the top of the script (`partition`, `mem`, `time`).

### Submit the array job
Count the number of VCF files and submit the array, limiting concurrency to four tasks (roughly "four nodes"):
```bash
NUM=$(find ~/data/genetics/vcf -maxdepth 1 -type f -name '*.vcf' | wc -l)
sbatch --array=0-$((NUM-1))%4 cluster/run-vep-array.sh
```
Each task binds the cache, input, output, and LoFTEE plugin into the container and runs VEP with `--offline`, `--no_stats`, and the LoFTEE plugin enabled.

Logs for each task are written to the `logs/` directory alongside the submission.
