Gluster Performance
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
| build     | UNDEF     | Which build to use for performance test it can be upstream or custom. In case of custom build you also need to provide one of the following : **custom_build_url,  custom_build_path, custom_build_repo_url** |
| custom_build_url    | UNDEF     | Url of the custom build to be used for perf test |
| custom_build_path    | UNDEF     | Local path of the rpms created |
| custom_build_repo_url    | UNDEF     | Url of the custom build repository to be used for perf test |
|  benchmarking_tools   | UNDEF     | When set it will install the benmarking tools i.e. smallfile test and izone |
|  backend_variables   | UNDEF     | Path to yaml file where backend variables are defined. The file backend-vars.sample from the repository, can  be copied and changed based on the disks available in your cluster. |
|  cleanup_vars   | UNDEF     | Path to yaml file where cleanup variables are defined. The file cleanup-vars.sample from the repository, can be copied and changed based on the current configuration of your cluster. |
|  rhsm_vars   | UNDEF     | Path to yaml file where rhsm_vars variables are defined. The file rhsm_vars.sample from the repository, can be copied and changed. |
|  use_rhsm_repository | UNDEF     | if you don't want to use rhsm repository then set this variable to 0 else set it to 1. |
|  tool   | UNDEF     | The benchmarking tool that we need to use to do the test. This can be "smallfile" or "iozone" or "fio". |
| download_results_at_location  | UNDEF  | location where the results should be downloaded once the test is completed. |
| collect_pcplog   | UNDEF     | When set it will installa and collect the pcp logs. |

### **Note:** If single place for all variables is desired then all the variables can be put in just one file and its path specified in backend_variables, cleanup_vars and rhsm_vars

Dependencies
------------
Gluster.infra
https://github.com/gluster/gluster-ansible-infra

Gluster.cluster
https://github.com/gluster/gluster-ansible-cluster

Usage
------

[Please refere to configuring and running performance test suite](Executing-Perf-Test.md)

License
-------

LGPLv2

Author Information
------------------

Rinku Kothiya, <rkothiya@redhat.com>
