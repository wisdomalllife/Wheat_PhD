#!/bin/bash -i
#SBATCH --job-name=bwa
#SBATCH --cpus-per-task=30
#SBATCH --mem=60G
#SBATCH --array=1-2
#SBATCH --time=120:00:00
#SBATCH --partition=amd_256M
#SBATCH --output=./%a.bwa.out
#SBATCH --error=./%a.bwa.err

conda activate quality

REF=./reference/GCF_018294505.1_IWGSC_CS_RefSeq_v2.1_genomic.fna # check chromosome only
DATA=./illumina_fastp_trimmed
OUTPUT=./illumina_bwa

i=$SLURM_ARRAY_TASK_ID
list=(L1 L2) #list of input's names
Lib="${list[$i-1]}"

# index the assembly for bwa
#bwa index $REF

# aligning - without splitting it's too slow
echo Start time is `date +%Y/%m/%d--%H:%M`

bwa mem -t 30 $REF \
        $DATA/Wheat.${Lib}.R1.trim.fq.gz \
        $DATA/Wheat.${Lib}.R2.trim.fq.gz \
        | samtools sort  -@ 10 -o $OUTPUT/Wheat.${Lib}.sorted.bam

samtools index -c -@ 10 $OUTPUT/Wheat.${Lib}.sorted.bam
echo Finish time is `date +%Y/%m/%d--%H:%M`

