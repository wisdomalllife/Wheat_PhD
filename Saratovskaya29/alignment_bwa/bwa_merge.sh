#!/bin/bash -i
#SBATCH --job-name=merge
#SBATCH --cpus-per-task=10
#SBATCH --mem=60G
#SBATCH --time=04:00:00
#SBATCH --partition=amd_256M
#SBATCH --dependency afterok:1625102_[3-8]

conda activate quality

OUTPUT=./illumina_bwa

Lib="L1"

echo Start time is `date +%Y/%m/%d--%H:%M`
samtools merge -@ 10 -o $OUTPUT/Wheat.${Lib}.merged.sorted.bam  $OUTPUT/Wheat.${Lib}.*.sorted.bam
samtools index -c -@ 10 $OUTPUT/Wheat.${Lib}.merged.sorted.bam
echo Finish time is `date +%Y/%m/%d--%H:%M`
