#!/bin/bash -i
#SBATCH --job-name=fastp
#SBATCH --cpus-per-task=15
#SBATCH --mem=30G
#SBATCH --time=04:00:00
#SBATCH --array=1-2
#SBATCH --partition=amd_256M
#SBATCH --output=./%a.fastp.out
#SBATCH --error=./%a.fastp.err

conda activate quality

## data
DATA=./illumina_data
OUTPUT=./illumina_fastp_trimmed

i=$SLURM_ARRAY_TASK_ID
list=(L1 L2) #list of input's names
Lib="${list[$i-1]}" # grab number i

#fastqc -t 4 --outdir fastqc/ illumina_data/Wheat.L1.R1.fq.gz
#Wheat.L1.R1.fq.gz  Wheat.L1.R2.fq.gz   Wheat.L2.R1.fq.gz   Wheat.L2.R2.fq.gz

echo Start time is `date +%Y/%m/%d--%H:%M`
fastp -i $DATA/Wheat.${Lib}.R1.fq.gz -I $DATA/Wheat.${Lib}.R2.fq.gz\
	-o $OUTPUT/Wheat.${Lib}.R1.trim.fq.gz -O $OUTPUT/Wheat.${Lib}.R2.trim.fq.gz\
  	--detect_adapter_for_pe --correction --trim_poly_g\
  	-l 50 --cut_front --cut_tail\
  	--thread 15 -h $OUTPUT/${Lib}_trim.html

echo Finish time is `date +%Y/%m/%d--%H:%M`

fastqc -t 4 -o $OUTPUT/fastqc $OUTPUT/Wheat.${Lib}.R1.trim.fq.gz
fastqc -t 4 -o $OUTPUT/fastqc $OUTPUT/Wheat.${Lib}.R2.trim.fq.gz

#multiqc fastqc
