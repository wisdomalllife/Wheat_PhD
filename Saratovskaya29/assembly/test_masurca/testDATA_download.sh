#!/bin/bash -i
#SBATCH --job-name=sratool
#SBATCH --cpus-per-task=10
#SBATCH --mem=50G
#SBATCH --time=24:00:00
#SBATCH --partition=amd_256M

conda activate ncbi

fastq-dump --split-files --origfmt SRR8107695
fastq-dump --split-files --origfmt SRR8107697
fastq-dump --split-files --origfmt SRR8107696
fastq-dump --split-files --origfmt SRR8107698
