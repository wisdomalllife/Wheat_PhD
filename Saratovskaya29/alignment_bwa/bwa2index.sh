#!/bin/bash -i
#SBATCH --job-name=indexbwa
#SBATCH --cpus-per-task=10
#SBATCH --mem=400G
#SBATCH --time=14:00:00
#SBATCH --partition=amd_1Tb

conda activate quality

REF=./reference/bwa2/GCF_018294505.1_IWGSC_CS_RefSeq_v2.1_chr.fna

# index the assembly for bwa
bwa-mem2 index $REF # ~ 2 h

