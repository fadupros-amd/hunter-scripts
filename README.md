# Build TENSORFLOW
## Prerequisites / Target
- Cray-Python v3.11.7
- ROCm 6.2.2
- Disk usage is close to '25GB'

## Proxy
- Bazel build infrastructure is implemented for Tensorflow framework. Unfiortunatelly, the Socks5 proxy protocol available on Hunter is not supported. A specific setup is required to build tensorflow on the target compute node of Hunter.



### Hunter - Login Node

Submit a job to get a node:

``` bash
qsub -I -select=1:nodetype=mi300a:node_type_storage=localscratch -l walltime=05:00:00
```

Environment variables:

-   `PBS_JOBID`
-   `nodename`

------------------------------------------------------------------------

### Ubuntu Setup (Proxy / Squid)

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
export PBS_JOBID=85874.hunter-pbs01
```

------------------------------------------------------------------------

#### SSH Configuration

Edit your `~/.ssh/config`:

``` ssh
Host aac7
  HostName aac7.amd.com
  User fabrice_dupros
  IdentityFile /home/dupros/.ssh/FD_moba_lockhart

Host hunter
  HostName hunter.hww.hlrs.de
  User hpdcdupr
  IdentityFile /home/dupros/.ssh/HLRS_cs_20250729
  ProxyJump aac7

Host compute
  HostName x1000c750b00n0.hsn.hunter.hww.hlrs.de
  User hpdcdupr
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

Run the build script:

``` bash
./Script_v2.sh
```




  
