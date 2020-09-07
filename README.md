Gluster Performace
===================

This will configure gluster on designated machines and execute a performance test on it

Requirements
------------

At minimum three Servers and one client. A control machine from where we would be executing the ansible script. Packages gluster.infra, gluster.cluster should be present on control machine. The user executing this script has to have an ssh key configured. Python3 should be existing on the target machines.

Role Variables
--------------

| Name     | Default  | Description |
| -------- | -------- | --------    |
| gluster_cluster_disperse_count     | UNDEF     | Disperse count for the volume. If this value is specified, a dispersed volume will be created |
| gluster_cluster_replica_count     | UNDEF     | Replica count while creating a volume. Currently replica 3 is supported.|
| node0     | UNDEF     | one of the nodes of the cluster where profile info will be collected|

Dependencies
------------
Gluster.infra
https://github.com/gluster/gluster-ansible-infra

Gluster.cluster 
https://github.com/gluster/gluster-ansible-cluster

Usage 
------

$ ansible-playbook -i hosts perftest.yml

License
-------

LGPLv2

Author Information
------------------

Rinku Kothiya, <rkothiya@redhat.com>
