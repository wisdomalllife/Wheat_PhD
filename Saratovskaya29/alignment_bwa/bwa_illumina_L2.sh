#!/bin/bash -i
#SBATCH --job-name=bwa
#SBATCH --cpus-per-task=20
#SBATCH --mem=100G
#SBATCH --time=20:00:00
#SBATCH --partition=amd_256M
#SBATCH --array=1-8
#SBATCH --output=./%a.bwaL2.out
#SBATCH --error=./%a.bwaL2.err
#SBATCH --dependency afterok:1623262

conda activate quality

REF=./reference/bwa2/GCF_018294505.1_IWGSC_CS_RefSeq_v2.1_chr.fna
DATA=./illumina_fastp_trimmed/split
OUTPUT=./illumina_bwa

i=$SLURM_ARRAY_TASK_ID
Lib="L2"

# index the assembly for bwa ~ 2h
#bwa-mem2 index $REF

seqkit split2 -1 $DATA/Wheat.${Lib}.R1.trim.fq.gz -2 $DATA/Wheat.${Lib}.R2.trim.fq.gz -p 8 -O $DATA/split --threads 4


# aligning
echo Start time is `date +%Y/%m/%d--%H:%M`

bwa-mem2 mem -t 20 $REF \
        $DATA/Wheat.${Lib}.R1.trim.part_00${i}.fq.gz \
        $DATA/Wheat.${Lib}.R2.trim.part_00${i}.fq.gz \
        | samtools sort  -@ 10 -o $OUTPUT/Wheat.${Lib}.part_00${i}.sorted.bam # ~ 9 h

samtools merge -@ 10 -o $OUTPUT/Wheat.${Lib}.merged.sorted.bam  $OUTPUT/Wheat.${Lib}.*.sorted.bam
samtools index -c -@ 10 $OUTPUT/Wheat.${Lib}.merged.sorted.bam
rm $OUTPUT/Wheat.${Lib}.part_*.sorted.bam
echo Finish time is `date +%Y/%m/%d--%H:%M`
samtools stats -@ 10 $OUTPUT/Wheat.${Lib}.merged.sorted.bam > samstats.${Lib}.txt
# bamtools stats -in $OUTPUT/Wheat.${Lib}.merged.sorted.bam
