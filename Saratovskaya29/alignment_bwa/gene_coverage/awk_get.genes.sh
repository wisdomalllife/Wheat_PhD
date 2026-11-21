awk 'BEGIN {FS=OFS="\t"} $3 == "gene" && $1 ~ /^NC_05/ {
    if (match($9, /gene=[^;]+/))
       print $1, $4-1, $5, substr($9, RSTART+5, RLENGTH-5)
}' GCF_018294505.1_IWGSC_CS_RefSeq_v2.1_genomic.gff | sort -k1,1 -k2,2n > genes.bed
