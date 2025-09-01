# Build ROCm (v6.4.1)
## Prerequisites / Target
- RHEL 9.4
- Disk usage  : 50GB
- Proxy neds to be set on the compute node (standard SOCKS5) : https://kb.hlrs.de/platforms/index.php/SSH_Tunnel_with_Proxy
- The procedure reuse the runfile installer mechanism : https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/rocm-runfile-installer.html#rocm-runfile-installer
  
- Adjust the  Target Directory in the script

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




  
