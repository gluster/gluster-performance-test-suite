#!/bin/bash

if [ $# -ne 1  ]
then
    echo; echo "Usage: $0 <Server node from where to collect the data>"
    echo; echo "eg:"
    echo; echo "    # $0 server1.example.com output.txt > output.txt"
    exit
fi

ServerNode=$1
LogFile="/var/log/PerfTestClient.log"

TestCase=("sequential-write" "sequential-read" "random-write" "random-read")

ssh root@$ServerNode "echo Largefile using fio TestStarts > /var/log/PerfTest.log  2>&1"
scp /tmp/collect-info.sh root@$ServerNode:/tmp/
ssh root@$ServerNode "/tmp/collect-info.sh >> /var/log/PerfTest.log  2>&1"
ssh root@$ServerNode "gluster volume info >> /var/log/PerfTest.log 2>&1"

# cleanup of old test results, if present
rm -rf /root/fuse-fio-result
for((Run=0; Run<=4; Run++))
do
    for Test in "${TestCase[@]}"
    do
        rm -rf ${Test}.${Run}.txt
    done
done

for((Run=0; Run<=4; Run++))
do
    for Test in "${TestCase[@]}"
    do
        ansible-playbook -i hosts sync-and-drop-cache.yml > /dev/null 2>&1
        ssh root@$ServerNode "gluster volume profile testvol info clear"
        fio --output=${Test}.${Run}.txt --client=client.list ${Test}.fio
        rc=$?
        ssh root@$ServerNode "gluster volume profile testvol info  > /root/${Test}-profile-fuse-large-file-test-run${Run}.txt"
        if [ $? -eq 0 ]
        then
            logger -s  "${Test} fio test passed" 2>> $LogFile
        else
            logger -s  "${Test} fio test failed" 2>> $LogFile
        fi
    done
    rm -rfv /gluster-mount/*
done

ssh root@$ServerNode "gluster volume info  > /root/volume-info.txt"

cd /root/
mkdir -p /root/fuse-largefile-profile-fio
scp root@$ServerNode:/root/*.txt /root/fuse-largefile-profile-fio/
tar cf fuse-largefile-profile-fio.tar fuse-largefile-profile-fio

mkdir -p /root/fuse-fio-result
cp /root/*.txt /root/fuse-fio-result
tar cf fuse-fio-result.tar fuse-fio-result


ssh root@$ServerNode "echo Testover  >> /var/log/PerfTest.log  2>&1"
scp root@$ServerNode:/var/log/PerfTest.log /root/

# Log the client config
echo "Client Data : " >> /root/PerfTest.log
/root/collect-info.sh >> /root/PerfTest.log
