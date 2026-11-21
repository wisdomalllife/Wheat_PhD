import pandas as pd, numpy as np, matplotlib.pyplot as plt
import sys

Lib = sys.argv[1]
CHR = sys.argv[2]
Chr_name = sys.argv[3]

# for testing
#Lib="L2"
#CHR="NC_057794.1"
#Chr_name="1A"
# -----------

BED=f"illumina_bwa/mosdepth/Wheat_500_{Lib}.regions.bed.gz"

# Load mosdepth windowed coverage
df = pd.read_csv(
    BED,
    sep="\t", header=None,
    names=["chrom", "start", "end", "depth"]
)
df = df[df["chrom"] == CHR].copy() # select chromosome

# Aggregate 500 bp windows into 1 mb display bins

# 1 new column called plot_bin: all 500 bp windows belonging to the same 1 Mb interval receive the same plot_bin value
#( // divides and rounds down to the nearest whole number)
# 2 groupby: groups all rows with the same plot_bin value
# 3 agg: calculates three values for each group: for exp. end=("end", "max") keeps the largest ending position in the group.
df_plot = (df.assign(plot_bin=df["start"] // 1000000).groupby("plot_bin", as_index=False)
      .agg(start=("start", "min"),end=("end", "max"),depth=("depth", "mean")))

df_plot["pos_mb"] = ((df_plot["start"] + df_plot["end"]) / 2 / 1e6) # middle position of each 1 Mb bin
# df["pos_mb"] = (df["start"] + df["end"]) / 2 / 1e6   # midpoint in Mb (1e6=1000000)

# summarise windowed coverage
mean_depth = df["depth"].mean()
pct_ge20   = (df["depth"] >= 20).mean() * 100
pct_ge30   = (df["depth"] >= 30).mean() * 100

#		plot

fig, ax = plt.subplots(figsize=(15, 4)) # Creates a figure measuring 15 inches wide and 4 inches high

ax.fill_between(df_plot["pos_mb"], df_plot["depth"], alpha=0.7, color="#2E86C1", label="Mean depth (1 mb display bins)") # blue filled coverage plot.
#ax.fill_between(df["pos_mb"], df["depth"], alpha=0.7, color="#2E86C1", label="Depth (500 bp windows)") # blue filled coverage plot.
ax.axhline(mean_depth, color="#1A3C5E", ls="-",  lw=1.5, label=f"Mean: {mean_depth:.1f}×") # average sequencing depth.
ax.axhline(30,         color="#0E7C5B", ls="--", lw=1.2, label="30× target")
ax.axhline(10,         color="#D97706", ls=":",  lw=1.0, label="10× floor")
ax.set_xlabel(f"Chromosome {Chr_name} position (Mb)")
ax.set_ylabel("Coverage depth (×)")
ax.set_title(
    f"chr {Chr_name} Coverage — Mean: {mean_depth:.1f}×  |  "
    f"Bases ≥20×: {pct_ge20:.1f}%  |  Bases ≥30×: {pct_ge30:.1f}%"
)
ax.legend(fontsize=9, loc="upper right")
ax.set_xlim(0, df_plot["pos_mb"].max()) # Sets the X-axis from 0 to the largest genomic position in the dataset.
ax.set_ylim(0, min(df_plot["depth"].max() * 1.1, 80))

plt.tight_layout()
plt.savefig(f"illumina_bwa/mosdepth/Wheat_500_{Lib}_{Chr_name}_coverage.png", dpi=150, bbox_inches="tight")
print(f"Coverage plot saved. Mean: {mean_depth:.1f}× | ≥20×: {pct_ge20:.1f}% | ≥30×: {pct_ge30:.1f}%")
