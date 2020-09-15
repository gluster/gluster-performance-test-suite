#!/bin/bash

if [ $# -ne 1  ]
then
  echo; echo "Usage: $0 <result to be analyzed> "
  echo; echo "eg:"
  echo; echo "    # $0 fuse-mount-large-file-result.txt "
  exit
fi

declare -A Operations

Operations=( ["seq-write"]="initial writers" ["seq-read"]="24 readers" ["random-read"]="random readers"  ["random-write"]="random writers" )

for key in ${!Operations[@]}
do
    if [ "$key"  = "seq-read" ]
    then
        grep -i "${Operations[$key]}" $1 | awk  -v ops="$key" -M -v PREC=100 -v CONVFMT=%.17g  'BEGIN{ sum = 0} {sum+=sprintf("%f",$8)} END{print ops " : " sum/NR}' >> /tmp/$$-lr
    else
        grep -i "${Operations[$key]}" $1 | awk  -v ops="$key" -M -v PREC=100 -v CONVFMT=%.17g  'BEGIN{ sum = 0} {sum+=sprintf("%f",$9)} END{print ops " : " sum/NR}'  >> /tmp/$$-lr
    fi
done


sort -r /tmp/$$-lr
