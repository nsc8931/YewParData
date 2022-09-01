#!/bin/bash

dirToParse=$1
appName=$2

echo "hosts threads instance probability runtime totalspawns"
for f in ${dirToParse}/*; do
    awk '
    BEGIN{ hosts=threads=instance=probability=runtime="nan"; totalspawns=0 }
    /HOSTS:/ { hosts=$2 }
    /PROBABILITY:/ { probability=$2 }
    /cpu =/ { runtime=$3 }
    /spawns/ {
    split($0, info, ",")
    totalspawns += info[5]
    }
    /CMD:/ {
    # Get instance
    inst = $6
    # Get last element in path
    numDirs = split(inst, paths, "/")
    inst = paths[numDirs]

    # Remove extension
    dots = split(inst, ext, ".")

    # We have a dot in the filename (like some cliques).
    if (dots == 3) {
        instance = ext[1]"."ext[2]
    } else {
        instance = ext[1]
    }

    # Number of threads
    match($0, /--hpx:threads ([0-9]+)/, marr);
    threads = marr[1];
    }
    END { if (totalspawns == 0) { totalspawns = "nan" }
    print hosts,threads,instance,probability,runtime,totalspawns }
    ' ${f}
done

