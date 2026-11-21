#!/bin/bash -i
#SBATCH --job-name=depth
#SBATCH --cpus-per-task=8
#SBATCH --mem=40G
#SBATCH --time=04:00:00
#SBATCH --partition=amd_256M
#--dependency afterok:1628690

conda activate quality

Lib="L1"
BAM=./illumina_bwa/Wheat.${Lib}.merged.sorted.bam
PREFIX=./illumina_bwa/mosdepth/Wheat_500_${Lib}

echo Start time is `date +%Y/%m/%d--%H:%M`
mosdepth --threads 8 --by 500 --mapq 20 --no-per-base \
  --thresholds 1,5,10,20,30\
  --quantize 0:5:10:20:30:50:100: ${PREFIX} ${BAM} # ~ 30 min

# 500 bp windowed coverage for uniformity visualisation
# exclude MAPQ <20 reads (multi-mappers, repetitive regions)
# skip per-base depth BED file
# the number of bases in each region that are covered at or above each threshold
# splitting coverage into bins and merging adjacent regions that fall into the same bin even if they have different exact coverage values.
echo Finish time is `date +%Y/%m/%d--%H:%M`

