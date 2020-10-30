#!/bin/bash


if [ $# -lt 1  ]
then
  echo; echo "Usage: $0 <result file in tar format> ..."
  echo; echo "eg:"
  echo; echo "    # $0 fuse-fio-result.tar"
  exit
fi


TarFile=$1
ExtractedFolder="/tmp/fuse-fio-result"

rm -rf "${ExtractedFolder}"
tar -xf "${TarFile}" -C /tmp/ || { echo "Error: unable to extract ${TarFile}" ; exit 1 ; }
cd ${ExtractedFolder} || { echo "Error: unable to change directory to ${ExtractedFolder}"  ; exit 1 ; }

declare -A TestCase
TestCase=( ["sequential-write"]=0 ["sequential-read"]=0 ["random-write"]=0 ["random-read"]=0)

for Test in "${!TestCase[@]}"
do
    for((Run=0; Run<=4; Run++))
    do
       Val=$(grep -A 1 "All clients:" ${Test}.${Run}.txt | tail -1  | awk '{ print $4 }' | cut -f 1 -d')' | tr -d  "bw=KiB/sM(" )
       TestCase[${Test}]=`echo ${TestCase[${Test}]} + $Val | bc`
    done
    TestCase[${Test}]=`echo ${TestCase[${Test}]} / $Run | bc -l`
done

for Test in "${!TestCase[@]}"
do
  printf '%s : %0.2f\n' "$Test" "${TestCase[$Test]}"
done

