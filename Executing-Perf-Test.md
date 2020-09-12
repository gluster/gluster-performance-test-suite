# Running performance test suite.

Please follow the below steps to run the performance test on your cluster:

1. Make sure that gluster-ansible is installed on the control machine.

2. Create a vault file at GlusterPerformanceTestSuite/group_vars/all/ containing you test machines root password. Note the below command will ask you to set password for your valut file.

```
# mkdir ~/config-for-cluster1
# cd ~/config-for-cluster1
# export EDITOR=vi
# ansible-vault create vault-for-cluster1.ynl=yml
```

In the editor opened write the below lines replace secret with your cluster machines root password.

```
---
vault_machine_pass: secret
```

3. For the script to be able to use this variable we need to create the following file, on the control machine. Please replace "vault-pass" with your vault file password.

```
# echo "vault-pass"  > ~/.vault_pass.txt
```

4. Create a copy of backend-vars.sample and cleanup-vars.sample, so that you can fill in your cluster specific data in it.

```
# cp backend-vars.sample ~/config-for-cluster1/cluster1-backend-vars.yml
# cp cleanup-vars.yml ~/config-for-cluster1/cluster1-cleanup-vars.yml
```

5. Edit backend-vars.yml file to replace the disk and its size information with, your cluster's disk and its size. In the below example I have used /dev/sdb which is a 1TB disk and for which I have given 896G to my thin pool and logical volume. I have also allocated 16 GB for its metadata.

```
# cat ~/config-for-cluster1/cluster1-backend-vars.yml
---
# Set a disk type, Options: JBOD, RAID6, RAID10
gluster_infra_disktype: JBOD

# RAID6 and RAID10 diskcount (Needed only when disktype is raid)
gluster_infra_diskcount: 10
# Stripe unit size always in KiB
gluster_infra_stripe_unit_size: 128

# Variables for creating volume group
gluster_infra_volume_groups:
  - { vgname: 'GLUSTER_vg1', pvname: '/dev/sdb' }
  - { vgname: 'GLUSTER_vg2', pvname: '/dev/sdc' }
  - { vgname: 'GLUSTER_vg3', pvname: '/dev/sdd' }

# Create thinpools
gluster_infra_thinpools:
  - {vgname: 'GLUSTER_vg1', thinpoolname: 'GLUSTER_pool1', thinpoolsize: '896G', poolmetadatasize: '16G'}
  - {vgname: 'GLUSTER_vg2', thinpoolname: 'GLUSTER_pool2', thinpoolsize: '896G', poolmetadatasize: '16G'}
  - {vgname: 'GLUSTER_vg3', thinpoolname: 'GLUSTER_pool3', thinpoolsize: '896G', poolmetadatasize: '16G'}

# Create a thin volume
gluster_infra_lv_logicalvols:
  - { vgname: 'GLUSTER_vg1', thinpool: 'GLUSTER_pool1', lvname: 'GLUSTER_lv1', lvsize: '896G' }
  - { vgname: 'GLUSTER_vg2', thinpool: 'GLUSTER_pool2', lvname: 'GLUSTER_lv2', lvsize: '896G' }
  - { vgname: 'GLUSTER_vg3', thinpool: 'GLUSTER_pool3', lvname: 'GLUSTER_lv3', lvsize: '896G' }

# Mount the devices
gluster_infra_mount_devices:
  - { path: '/gluster/brick1', vgname: 'GLUSTER_vg1', lvname: 'GLUSTER_lv1' }
  - { path: '/gluster/brick2', vgname: 'GLUSTER_vg2', lvname: 'GLUSTER_lv2' }
  - { path: '/gluster/brick3', vgname: 'GLUSTER_vg3', lvname: 'GLUSTER_lv3' }

gluster_cluster_volume: 'testvol'
gluster_cluster_bricks: '/gluster/brick1,/gluster/brick2,/gluster/brick3'


```

6. Update the cluster1-cleanup_vars.yml with the gluster brick and volume information which needs to be deleted from the previous runs.

```
# cat ~/config-for-cluster1/cluster1-cleanup-vars.yml
gluster_volumes: testvol
gluster_infra_reset_mnt_paths:
  - /gluster/brick1
  - /gluster/brick2
  - /gluster/brick3

gluster_infra_reset_volume_groups:
  - GLUSTER_vg1
  - GLUSTER_vg2
  - GLUSTER_vg3

```

7. Edit the hosts file and replace serverN.example.com and clientN.example.com with your machine names. Set the backend_variables and cleanup_vars to point to the appropriate files.

```
$ cat ~/config-for-cluster1/hosts
[all:vars]
gluster_volumes=testvol
gluster_cluster_replica_count=3
node0=server1.example.com
build="upstream"
#build="custom"
#custom_build_url="https://download.gluster.org/pub/gluster/glusterfs/8/8.1/Fedora/fedora-32/x86_64/"
benchmarking_tools=0
backend_variables=~/config-for-cluster1/cluster1-backend-vars.yml
cleanup_vars=~/config-for-cluster1/cluster1-cleanup-vars.yml

[control]
control_machine ansible_host=127.0.0.1 ansible_connection=local

[master_server]
server1.example.com

[master_client]
client1.example.com

[cluster_servers]
server1.example.com
server2.example.com
server3.example.com

[cluster_clients]
client1.example.com
client2.example.com
client3.example.com

[cluster_machines:children]
cluster_servers
cluster_clients

```


8. Run the ansible script as follows, from your control machine:

```
# ansible-playbook  -i ~/config-for-cluster1/hosts  -e @~/config-for-cluster1/vault-for-cluster1.yml  perftest.yml

```

**Note: This will run for a long time depending on the number of nodes and disks on your cluster.**


## Results

Once the test is done you should be having the following files created on your control machine.

* fuse_and_gnfs_mount_result.txt
* PerfTest.log

You can run the small-file-result.sh to extract the results as follows:

```
$ ./small-file-result.sh fuse_and_gnfs_mount_result.txt
create: 2636.48441375
ls-l: 8807.125541
chmod: 1736.76129275
stat: 3092.68011325
read: 3256.1860228
append: 1351.59884275
rename: 235.05624725
delete-renamed: 2565.4863702
mkdir: 795.2569932
rmdir: 464.1749462
cleanup: 5541.57562475
```
