#!/bin/bash -i
#SBATCH --job-name=filter
#SBATCH --cpus-per-task=10
#SBATCH --mem=30G
#SBATCH --time=10:00:00
#SBATCH --partition=amd_256M

conda activate nanopore

DATA=./nanopore_basecalled

echo Start time is `date +%Y/%m/%d--%H:%M`
fastplong -i ${DATA}/nanopore_basecalled.fastq -o ${DATA}/nanopore_filt.fastq --length_required 500 -q 8 --disable_adapter_trimming
echo Finish time is `date +%Y/%m/%d--%H:%M`

NanoPlot --outdir ${DATA}/nanoplotresfilt --fastq ${DATA}/nanopore_filt.fastq



