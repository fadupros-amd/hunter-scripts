# Build TENSORFLOW (v2.18)
## Prerequisites / Target
- Cray-Python v3.11.7
- ROCm 6.2.2
- Disk usage  : 25GB

## Proxy
- Bazel build infrastructure is implemented for Tensorflow framework. Unfiortunatelly, the Socks5 proxy protocol available on Hunter is not supported. A specific setup is required to build tensorflow on the target compute node of Hunter. This is based on squid to setup the required proxy.



### Hunter - Login Node

Submit a job to get a node (using local scratch in this exemple):
``` bash
qsub -I -select=1:nodetype=mi300a:node_type_storage=localscratch -l walltime=02:00:00
```
Environment variables:

-   `$pbs_computenode`
-   `$name_computenode`

------------------------------------------------------------------------

### Localhost (setup for Ubuntu) 

Install and configure **squid**:

``` bash
sudo apt-get install -y squid
vi /etc/squid/squid.conf
sudo systemctl restart squid
```

#### Test the proxy

``` bash
curl -I -x http://127.0.0.1:3128 https://www.google.com
```

------------------------------------------------------------------------

#### Export Job ID

``` bash
export PBS_JOBID=$pbs_computenode
```

------------------------------------------------------------------------

#### SSH Configuration

Edit your `~/.ssh/config`:

``` ssh
Host aac7
  HostName aac7.amd.com
  User user1
  IdentityFile /home/user1/.ssh/key_aac7

Host hunter
  HostName hunter.hww.hlrs.de
  User userhunter
  IdentityFile /home/user1/.ssh/key_hunter
  ProxyJump aac7

Host compute
  HostName $name_computenode.hsn.hunter.hww.hlrs.de
  User userhunter
  ProxyJump aac7,hunter
```

------------------------------------------------------------------------

#### SSH Access

Ensure ssh keys are available in your `~/.ssh` repository.

Connect to compute node via jump hosts:

``` bash
ssh -J aac7,hunter -o SendEnv=PBS_JOBID -R 12345:127.0.0.1:3128 compute
```

------------------------------------------------------------------------

### Hunter - Compute Node

Run the Tensorflow build script in the target directory:

``` bash
./build_tensorflow_218_hunter.sh
```




  
