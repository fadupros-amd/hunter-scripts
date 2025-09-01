# Build ROCm (v6.4.1)
## Prerequisites / Target
- RHEL9
- Disk usage  : 50GB
- Proxy neds to be set on the compute node (standard SOCKS5)

## Hunter - Login Node
Submit a job to get a node (localscratch is used):

``` bash
qsub -I -select=1:nodetype=mi300a:node_type_storage=localscratch -l walltime=02:00:00
```

## Hunter - Compute Node

Run the ROCm build script in the target directory:

``` bash
./build_rocm641_hunter.sh download install
```




  
