#!/bin/bash -i
#SBATCH --job-name=bwa
#SBATCH --cpus-per-task=20
#SBATCH --mem=100G
#SBATCH --time=20:00:00
#SBATCH --partition=amd_256M
#SBATCH --array=1-8
#SBATCH --output=./%a.bwaL1.out
#SBATCH --error=./%a.bwaL1.err

conda activate quality

REF=./reference/bwa2/GCF_018294505.1_IWGSC_CS_RefSeq_v2.1_chr.fna
DATA=./illumina_fastp_trimmed/split
OUTPUT=./illumina_bwa

i=$SLURM_ARRAY_TASK_ID
Lib="L1"

# index the assembly for bwa
#bwa-mem2 index $REF

# split data
seqkit split2 -1 $DATA/Wheat.${Lib}.R1.trim.fq.gz -2 $DATA/Wheat.${Lib}.R2.trim.fq.gz -p 8 -O $DATA/split --threads 4

# aligning
echo Start time is `date +%Y/%m/%d--%H:%M`

bwa-mem2 mem -t 20 $REF \
        $DATA/Wheat.${Lib}.R1.trim.part_00${i}.fq.gz \
        $DATA/Wheat.${Lib}.R2.trim.part_00${i}.fq.gz \
        | samtools sort  -@ 10 -o $OUTPUT/Wheat.${Lib}.part_00${i}.sorted.bam # ~ 18 h for bwa1 and ~ 9 h for bwa2

samtools merge -@ 10 -o $OUTPUT/Wheat.${Lib}.merged.sorted.bam $OUTPUT/Wheat.${Lib}.*.sorted.bam # ~ 1 h
samtools index -c -@ 10 $OUTPUT/Wheat.${Lib}.merged.sorted.bam # ~ 7 min
rm $OUTPUT/Wheat.${Lib}.part_*.sorted.bam
echo Finish time is `date +%Y/%m/%d--%H:%M`

samtools view -b $OUTPUT/Wheat.${Lib}.merged.sorted.bam NC_057794.1 > chr1A_alignment.bam # to get a particular chr
# samtools view -H  $OUTPUT/Wheat.L1.merged.sorted.bam > header.txt
