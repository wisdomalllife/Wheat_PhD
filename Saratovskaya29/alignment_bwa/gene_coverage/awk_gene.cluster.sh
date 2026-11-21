distance=500000

awk -v max_distance="$distance" 'BEGIN {FS=OFS="\t"}
# NR == 1 means that this block runs only for the first line of the input file.
# next tells AWK to skip the remaining commands for this line and immediately read the next line.
NR == 1 {chr = $1; cluster_start = $2; cluster_end = $3; count = 1; prev_end = $3; next}
{
    distance = $2 - prev_end

    if ($1 == chr && distance < max_distance) {
        count++ # Increases the number of genes in the cluster by one
        if ($3 > cluster_end)
            cluster_end = $3
    }
    # Start a new cluster when the distance is too large or new chr
    else {
        print chr, cluster_start, cluster_end, count
        chr = $1; cluster_start = $2; cluster_end = $3; count = 1
    }
    # update the end coordinate of the previous gene
    prev_end = $3
}
# Print the last cluster; end executes after AWK has finished reading the entire file.
END {
    if (NR > 0) # ensures that the command only prints a cluster if the input file contains at least one record
        print chr, cluster_start, cluster_end, count
}' genes.bed > gene_clusters_${distance}.bed
