# Build ROCm (v6.4.1)

## Context
- Target OS `RHEL 9.4`
- Disk usage  for this Build : 50GB
- Proxy should be set on the compute node (standard SOCKS5)
  -  https://kb.hlrs.de/platforms/index.php/SSH_Tunnel_with_Proxy
- The script is based on the Runfile installer mechanism
  -  https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/rocm-runfile-installer.html#rocm-runfile-installer
  

## Hunter - Login Node
Submission of an interactive job (with localscratch in this case):

``` bash
qsub -I -select=1:nodetype=mi300a:node_type_storage=localscratch -l walltime=02:00:00
```

## Hunter - Compute Node

- Target Directory should be adapted in this script.
- Run the ROCm build script in the target directory:

``` bash
./build_rocm641_hunter.sh download install
```




  
