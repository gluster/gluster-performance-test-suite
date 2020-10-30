#!/bin/bash

if [ $# -ne 1  ]
then
  echo; echo "Usage: $0 <result to be analyzed> "
  echo; echo "eg:"
  echo; echo "    # $0 fuse-mount-small-file-result.txt "
  exit
fi

Operations=( "create" "ls-l" "chmod" "stat" "read" "append" ": rename" "delete-renamed" "mkdir" "rmdir" "cleanup" )

for (( i = 0; i < ${#Operations[@]} ; i++ ))
do
    if [ "${Operations[$i]}"  = "read" -o "${Operations[$i]}"  = "delete-renamed" -o "${Operations[$i]}" = "mkdir" -o "${Operations[$i]}" = "rmdir" ]
    then
        egrep -i "operation|^files/sec" $1 | grep -A 1 -i "${Operations[$i]}" | grep -i files | awk  -v ops=$(echo "${Operations[$i]}" | tr -d ' :')  -v PREC=100 -v CONVFMT=%.17g  'BEGIN{ sum = 0} {sum+=sprintf("%f",$3)} END{print ops ": " sum/NR}'
    else
        egrep -i "operation|^files/sec" $1 | grep -A 1 -i "${Operations[$i]}" | grep -i files | tail -n +2 | awk  -v ops=$(echo "${Operations[$i]}" | tr -d ' :')  -v PREC=100 -v CONVFMT=%.17g  'BEGIN{ sum = 0} {sum+=sprintf("%f",$3)} END{print ops ": " sum/NR}'
    fi
done


