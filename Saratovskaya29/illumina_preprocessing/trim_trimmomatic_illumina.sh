#!/bin/bash -i
#SBATCH --job-name=trim
#SBATCH --cpus-per-task=15
#SBATCH --mem=30G
#SBATCH --time=64:00:00
#SBATCH --array=1-2
#SBATCH --partition=amd_256M
#SBATCH --output=./%a.trim.out
#SBATCH --error=./%a.trim.err

conda activate quality

## data
DATA=./illumina_data
OUTPUT=./illumina_trimmed

i=$SLURM_ARRAY_TASK_ID
list=(L1 L2) #list of input's names
Lib="${list[$i-1]}" # grab number i

#fastqc -t 4 --outdir fastqc/ illumina_data/Wheat.L1.R1.fq.gz
#(Wheat.L1.R1.fq.gz  Wheat.L1.R2.fq.gz   Wheat.L2.R1.fq.gz   Wheat.L2.R2.fq.gz)

# trimmomatic - too slow for wheat
echo Start time is `date +%Y/%m/%d--%H:%M`
trimmomatic PE -phred33 $DATA/Wheat.${Lib}.R1.fq.gz $DATA/Wheat.${Lib}.R2.fq.gz\
        $OUTPUT/Wheat.${Lib}.R1.paired.fq.gz $OUTPUT/Wheat.${Lib}.R1.unpaired.fq.gz\
        $OUTPUT/Wheat.${Lib}.R2.paired.fq.gz $OUTPUT/Wheat.${Lib}.R2.unpaired.fq.gz\
        ILLUMINACLIP:NexteraPE-PE.fa:2:30:10:2:True LEADING:3 TRAILING:3 MINLEN:80
echo Finish time is `date +%Y/%m/%d--%H:%M`
