import pandas as pd, numpy as np, matplotlib.pyplot as plt
#import sys

#Lib = sys.argv[1]

Lib="L1"
BED=f"illumina_bwa/mosdepth/Wheat_500_{Lib}.regions.bed.gz"

# 1
# Load mosdepth windowed coverage
df = pd.read_csv(
    BED,
    sep="\t", header=None,
    names=["chr", "start", "end", "depth"]
)

#df = df[df["chr"] == CHR].copy() # select chromosome

# -------------------------------------------
# Read chromosome accession-to-name mapping
chromosomes = pd.read_csv(
    "illumina_bwa/chromosomes.txt",
    sep=r"\s+", header=None,
    names=["chr", "type", "chr_name"]
)

chr_dict = dict(zip(chromosomes["chr"], chromosomes["chr_name"])) # Create dictionary
#---------------------------------------------

# 2
#!!!!!! final 1 Mb bin is shorter than 1 Mb, and some final windows is shorter then 500 bp (a length-weighted mean would be more accurate than a simple mean) !!!

# Assign each 500 bp window to a 1 Mb bin and Calculate mean coverage for each 1 Mb bin
df_1mb = (df.assign(bin=df["start"] // 1000000).groupby(["chr", "bin"], as_index=False)
      .agg(start=("start", "min"),end=("end", "max"),mean_depth=("depth", "mean")))

# Identify bins with mean coverage below 10x
low_cov = df_1mb[df_1mb["mean_depth"] < 10].copy()

# Sort by genomic position
low_cov = low_cov.sort_values(["chr", "start"])

# Identify where a new interval should begin (boolean values)
# (check if chromosome changed and the current window start exactly where the previous window ends)
# (shift() lets compare each row with the previous row: shift() moves the values in a column down by one row)
low_cov["new_interval"] = (
    (low_cov["chr"] != low_cov["chr"].shift()) |
    (low_cov["start"] != low_cov["end"].shift())
)

# Assign an interval ID (cumsum() adds 1 every time it encounters a new interval)
low_cov["interval_id"] = low_cov["new_interval"].cumsum()

# Merge adjacent low-coverage bins
low_cov_intervals = (low_cov.groupby(["chr", "interval_id"], as_index=False)
    .agg(start=("start", "min"),end=("end", "max"),min_depth=("mean_depth", "min"),mean_depth=("mean_depth", "mean")))

# Calculate interval length
low_cov_intervals["length"] = (low_cov_intervals["end"] - low_cov_intervals["start"])

# limit the number of decimal places
low_cov_intervals[["mean_depth", "min_depth"]] = (low_cov_intervals[["mean_depth", "min_depth"]].round(2))

# 3
# Add chromosome names to the coverage table
low_cov_intervals["chr_name"] = (low_cov_intervals["chr"].map(chr_dict))
# Arrange the columns
low_cov_intervals = low_cov_intervals[["chr", "chr_name", "start", "end", "length","mean_depth", "min_depth"]]

# Save results
low_cov_intervals.to_csv( f"illumina_bwa/mosdepth/Wheat_{Lib}_low_coverage_intervals.tsv", sep="\t", index=False)
