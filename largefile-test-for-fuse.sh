#!/bin/bash

if [ $# -ne 2  ]
then
    echo; echo "Usage: $0 <Server node from where to collect the data> <Total number of threads>"
    echo; echo "eg:"
    echo; echo "    # $0 server1.example.com output.txt 16 > output.txt"
    echo; echo "Note: Total number of thread = number of clients  x  4"
    exit
fi

ServerNode=$1
Threads=$2
LogFile="/var/log/PerfTestClient.log"

Options=( "-i 0 -s 8g" "-i 1 -s 8g" "-i 2 -s 2g -J 3 -I" )
TestName=("sequential-write-rewrite" "sequential-read-reread" "random-read-write" )

ssh root@$ServerNode "echo Largefile using Iozone TestStarts > /var/log/PerfTest.log  2>&1"
ssh root@$ServerNode "date >> /var/log/PerfTest.log  2>&1"
scp /root/collect-info.sh root@$ServerNode:/tmp/
ssh root@$ServerNode "/tmp/collect-info.sh >> /var/log/PerfTest.log  2>&1"
ssh root@$ServerNode "gluster volume info >> /var/log/PerfTest.log 2>&1"


for((i=0; i<=4; i++))
do
    for((j=0; j<=2; j++))
    do
        ansible-playbook -i hosts sync-and-drop-cache.yml > /dev/null 2>&1
        ssh root@$ServerNode "gluster volume profile testvol info clear"
        iozone -+m /root/client.ioz -+h $(hostname) -C -w -c -e  -+n -r 64k -t $Threads  ${Options[$j]}
        rc=$?
        ssh root@$ServerNode "gluster volume profile testvol info  > /root/${TestName[$j]}-profile-fuse-large-file-test-run$i.txt"
        if [ $? -eq 0 ]
        then
            logger -s  "${TestName[$j]} iozone test passed" 2>> $LogFile
        else
            logger -s  "${TestName[$j]} iozone test failed" 2>> $LogFile
        fi
    done
    rm -rfv /gluster-mount/*
done

ssh root@$ServerNode "gluster volume info  > /root/volume-info.txt"

cd /root/
mkdir -p /root/fuse-largefile-profile-iozone
scp root@$ServerNode:/root/*.txt /root/fuse-largefile-profile-iozone/
tar cf fuse-largefile-profile-iozone.tar fuse-largefile-profile-iozone

ssh root@$ServerNode "echo Testover  >> /var/log/PerfTest.log  2>&1"
ssh root@$ServerNode "date >> /var/log/PerfTest.log  2>&1"
scp root@$ServerNode:/var/log/PerfTest.log /root/

# Log the client config
echo "Client Data : " >> /root/PerfTest.log
/root/collect-info.sh >> /root/PerfTest.log
