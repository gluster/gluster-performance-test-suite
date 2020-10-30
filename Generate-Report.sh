#!/bin/bash

if [ $# -ne 5  ]
then
    echo; echo "Usage: $0 <script-to-extracts-the-result> <Baseline result> <Baseline log file> <Current results> <Current log file>"
    echo; echo "eg:"
    echo; echo "    # $0 ./extract-smallfile-results.sh ~/config-for-cluster1/BaseLine-fuse-smallfile-result.txt ~/config-for-cluster1/BaselinePerfTest.log ./results/fuse-smallfile-result.txt ./results/PerfTest.log"
    exit
fi

Extractor="$1"
BaselineResult="$2"
BaselineLog="$3"
CurrentResult="$4"
CurrentLog="$5"
CurrentExtractedResult="/tmp/$$-current.txt"
BaselineExtractedResult="/tmp/$$-Baseline.txt"
Table="/tmp/$$-Report.txt"
TableWithoutHeadersForAnalysisOfStatus="/tmp/$$-Report-without-header.txt"

# Extract the results of the current test and Baseline test
$Extractor $BaselineResult > $BaselineExtractedResult
$Extractor $CurrentResult > $CurrentExtractedResult

# Get the New and the Old gluster version from the PerfTest.log file
CurrentGlusterVersion=$(grep 'glusterfs-server-' $CurrentLog | sed 's/server-//g' | awk 'BEGIN { FS="."; }  { print $1 }')
BaselineGlusterVersion=$(grep 'glusterfs-server-' $BaselineLog | sed 's/server-//g' | awk 'BEGIN { FS="."; }  { print $1 }')

# Create a table
echo "=============================================================================================================
FOPs                $BaselineGlusterVersion                $CurrentGlusterVersion               $CurrentGlusterVersion
                                                                                                      vs
                                                                                       $BaselineGlusterVersion
============================================================================================================="  > $Table
join -t: -1 1 -2 1 $BaselineExtractedResult  $CurrentExtractedResult | awk 'BEGIN { FS=":";  } { printf  "%-20s\t\t %-20d \t\t%-20d  \t\t%3d\n", $1,$2,$3,  (($3-$2)/$2)*100 }' > "$TableWithoutHeadersForAnalysisOfStatus"
cat $TableWithoutHeadersForAnalysisOfStatus >> $Table
echo "=============================================================================================================" >> $Table


# Find if there was regression
regression=$(awk  '$4 < -5  { print $4 }' $TableWithoutHeadersForAnalysisOfStatus  | sort -n | head -1)

# Update the status to FAIL if there was a regression, This value of status can be used in Jenkins to send email to team
if [ "$regression" ]
then
  status="FAIL"
else
  status="PASS"
fi

cat "$Table"
