#!/bin/bash

LogFile="/var/log/PerfTestClient.log"
logger -s "The value of Varaible CLIENT is $CLIENT " 2>> $LogFile

if [ $# -ne 1  ]
then
    echo; echo "Usage: $0 <Server node from where to collect the data>"
    echo; echo "eg:"
    echo; echo "    # $0 server1.example.com output.txt output.txt"
    exit
fi

ServerNode=$1

ssh root@$ServerNode "echo Smallfile TestStarts > /var/log/PerfTest.log  2>&1"
scp /root/collect-info.sh root@$ServerNode:/tmp/
ssh root@$ServerNode "/tmp/collect-info.sh >> /var/log/PerfTest.log  2>&1"

cd /root/

#Operations=( "create" "ls-l" "chmod" "stat" "read" "append" "rename" "delete-renamed" "mkdir" "rmdir" "cleanup" )
Operations=( "create" )

#for((i=0; i<=4; i++))
for((i=0; i<=0; i++))
do
    logger -s "Small file test Iteration $i started" 2>> $LogFile

    for ((j=0; j<${#Operations[@]} ; j++))
    do
        ansible-playbook -i hosts sync-and-drop-cache.yml
        python /small-files/smallfile/smallfile_cli.py --operation ${Operations[$j]} --threads 8 --file-size 64 --files 5000 --top /gluster-mount  --host-set "$(echo $CLIENT | tr -d "[] \'")"
        ssh root@$ServerNode "gluster volume profile testvol info incremental  >> /root/${Operations[$j]}-profile-fuse.txt"
    done
done

mkdir -p /root/fuse-smallfile-profile
cd /root/

# Collect the Server logs
ssh root@$ServerNode "gluster volume info  > /root/volume-info.txt"
scp root@$ServerNode:/root/*.txt /root/fuse-smallfile-profile/
tar cf fuse-smallfile-profile.tar fuse-smallfile-profile
ssh root@$ServerNode "echo Testover  >> /var/log/PerfTest.log  2>&1"
scp root@$ServerNode:/var/log/PerfTest.log /root/

# Log the client config
echo "Client Data : " >> /root/PerfTest.log
/root/collect-info.sh >> /root/PerfTest.log
