#conda activate plotpy

list=./illumina_bwa/chromosomes.txt #list of names
Lib="L1"
#CHR=$(sed "${i}q;d" $list | cut -d' ' -f1)
#Chr_name=$(sed "${i}q;d" $list | cut -d' ' -f3)

echo Start time is `date +%Y/%m/%d--%H:%M` # ~ 4 min
while read -r CHR col2 Chr_name; do

    # Skip empty lines ([[ ... ]] - Bash conditional test, -z - Tests whether a string has zero length, continue - Skip the remaining commands in the current loop)
    [[ -z "$CHR" ]] && continue

    echo ""
    echo "----------------------------------------"
    echo "Processing chromosome: $Chr_name"
    echo "Accession: $CHR"
    echo "----------------------------------------"

    python coverage_plot.py "$Lib" "$CHR" "$Chr_name"

    # $? - Exit status of the most recently executed command, -ne - Not equal, 0 - indicates successful execution
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed for chromosome $Chr_name"
    fi

done < "$list"
echo Finish time is `date +%Y/%m/%d--%H:%M`

