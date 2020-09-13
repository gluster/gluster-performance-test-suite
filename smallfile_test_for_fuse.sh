#!/bin/bash

LogFile="/var/log/PerfTestClient.log"
logger -s "The value of Varaible CLIENT is $CLIENT " 2>> $LogFile

if [ $# -ne 2  ]
then
    echo; echo "Usage: $0 <Server node from where to collect the data> <Name of the output file which needs to be attached to email>"
    echo; echo "eg:"
    echo; echo "    # $0 server1.example.com output.txt > output.txt"
    exit
fi

OutputFileName=$2
ServerNode=$1


cat <<EOF > /tmp/collect_info.sh
#!/bin/bash
uname -r

    Files=( "dirty_ratio" "dirty_background_ratio" "swappiness" "vfs_cache_pressure"  )

    for (( i = 0; i < ${#Files[@]} ; i++ ))
    do
        echo "cat /proc/sys/vm/${Files[$i]}"
        cat /proc/sys/vm/${Files[$i]}
    done

    echo "cat /sys/block/sda/queue/scheduler"
    cat /sys/block/sda/queue/scheduler
EOF

chmod 755 /tmp/collect_info.sh

ssh root@$ServerNode "echo TestStarts >> /var/log/PerfTest.log  2>&1"
scp /tmp/collect_info.sh root@$ServerNode:/tmp/
ssh root@$ServerNode "/tmp/collect_info.sh >> /var/log/PerfTest.log  2>&1"

cd /root/

Operations=( "create" "ls-l" "chmod" "stat" "read" "append" "rename" "delete-renamed" "mkdir" "rmdir" "cleanup" )

for((i=0;i<=4;i++))
do
    logger -s "Small file test Iteration $i started" 2>> $LogFile

    for (( i = 0; i < ${#Operations[@]} ; i++ ))
    do
        ansible-playbook -i hosts sync-and-drop-cache.yml
        python /small-files/smallfile/smallfile_cli.py --operation ${Operations[$i]} --threads 8 --file-size 64 --files 5000 --top /gluster-mount  --host-set "$(echo $CLIENT | tr -d "[] \'")"
        ssh root@$ServerNode "gluster volume profile testvol info incremental  >> /root/${Operations[$i]}-profile-fuse.txt"
    done
done

mkdir -p /root/profile-for-fuse-and-gnfs
cd /root/

# Collect the Server logs
ssh root@$ServerNode "gluster volume info  > /root/volume-info.txt"
scp root@$ServerNode:/root/*.txt /root/profile-for-fuse-and-gnfs/
tar cf profile-for-fuse-and-gnfs.tar profile-for-fuse-and-gnfs
ssh root@$ServerNode "echo Testover  >> /var/log/PerfTest.log  2>&1"
scp root@$ServerNode:/var/log/PerfTest.log /root/

# Log the client config
echo "Client Data : " >> /root/PerfTest.log
/tmp/collect_info.sh >> /root/PerfTest.log

