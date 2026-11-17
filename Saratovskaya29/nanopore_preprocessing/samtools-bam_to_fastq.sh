#!/bin/bash -i
#SBATCH --job-name=samtools
#SBATCH --cpus-per-task=10
#SBATCH --mem=30G
#SBATCH --time=10:00:00
#SBATCH --partition=amd_256M

conda activate quality

OUTPUT=./nanopore_basecalled

echo Start time is `date +%Y/%m/%d--%H:%M`
samtools fastq ${OUTPUT}/wheat_basecalled.bam > ${OUTPUT}/nanopore_basecalled.fastq
echo Finish time is `date +%Y/%m/%d--%H:%M`
