#!/bin/bash -i
#SBATCH --job-name=fastqc
#SBATCH --cpus-per-task=4
#SBATCH --mem=30G
#SBATCH --time=03:00:00
#SBATCH --array=1-4
#SBATCH --partition=amd_256M

conda activate quality

## data
OUTPUT=./illumina_fastp_trimmed

i=$SLURM_ARRAY_TASK_ID
list=(L1.R1 L1.R2 L2.R1 L2.R2) #list of input's names
Lib="${list[$i-1]}"

# (Wheat.L1.R1.fq.gz  Wheat.L1.R2.fq.gz   Wheat.L2.R1.fq.gz   Wheat.L2.R2.fq.gz)

echo Start time is `date +%Y/%m/%d--%H:%M`
fastqc -t 4 --outdir fastqc/ illumina_data/Wheat.${Lib}.fq.gz # check before trimming
#fastqc -t 4 --outdir $OUTPUT/fastqc/ $OUTPUT/Wheat.${Lib}.trim.fq.gz # check after trimming
echo Finish time is `date +%Y/%m/%d--%H:%M`

