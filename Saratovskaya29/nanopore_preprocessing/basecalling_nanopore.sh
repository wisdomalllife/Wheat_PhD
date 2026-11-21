#!/bin/bash -i
#SBATCH --job-name=dorado
#SBATCH --cpus-per-task=30
#SBATCH --mem=30G
#SBATCH --time=10:00:00
#SBATCH --partition=gpu_A100
#SBATCH --gres=gpu:2

conda activate nanopore

# old version - cause deprecated nanopore libs
Dorado=./Dorado/dorado-0.9.6-linux-x64/bin
DATA=./nanopore_data
OUTPUT=./nanopore_basecalled

# ls head -n -1 > flow_list.txt or sed -i '$d' flow_list.txt
FLOW_LIST=${DATA}/flow_list.txt # list of names

# convert to pod5
#Python 3.12.16
while IFS= read -r FLOW; do
    echo Processing "$FLOW"
    pod5 convert fast5 ${DATA}/$FLOW/*.fast5 --output ${DATA}/$FLOW.pod5 --threads 8
done < "$FLOW_LIST"

# basecalling
echo Start time is `date +%Y/%m/%d--%H:%M`
echo $CUDA_VISIBLE_DEVICES

${Dorado}/dorado basecaller hac@v3.3 $DATA/ --trim all --device cuda:all > ${OUTPUT}/wheat_basecalled.bam
echo Finish time is `date +%Y/%m/%d--%H:%M`

# samtools view -H wheat_basecalled.bam | grep -oE "\S*models?=\S*" # ckech the models

samtools fastq ${OUTPUT}/wheat_basecalled.bam > ${OUTPUT}/nanopore_basecalled.fastq # covert bam to fastq
NanoPlot --outdir ${OUTPUT}/nanoplotres --fastq ${OUTPUT}/nanopore_basecalled.fastq # quality check

# if alignment is needed:
#dorado aligner $REF <calls> --output-dir <output-dir> --mm2-opts "-x splice --junc-bed <annotations_file>"
#dorado basecaller ... | dorado aligner ... > calls.aligned.bam