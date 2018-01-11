#!/bin/bash
# not may be able to replace this with nvidia-modprobe

#/sbin/modprobe nvidia_384
/sbin/modprobe nvidia_387

if [ "$?" -eq 0 ]; then
  # Count the number of NVIDIA controllers found.
  NVDEVS=`lspci | grep -i NVIDIA`
  N3D=`echo "$NVDEVS" | grep "3D controller" | wc -l`
  NVGA=`echo "$NVDEVS" | grep "VGA compatible controller" | wc -l`

  N=`expr $N3D + $NVGA - 1`
  for i in `seq 0 $N`; do
    mknod -m 666 /dev/nvidia$i c 195 $i
  done

  mknod -m 666 /dev/nvidiactl c 195 255

else
  exit 1
fi

#/sbin/modprobe nvidia_384-uvm
/sbin/modprobe nvidia_387-uvm

if [ "$?" -eq 0 ]; then
  # Find out the major device number used by the nvidia-uvm driver
  D=`grep nvidia-uvm /proc/devices | awk '{print $1}'`

  mknod -m 666 /dev/nvidia-uvm c $D 0
else
  exit 1
fi

# Read more at: http://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#ixzz4zOV1O0bE

# add this to see if it helps - not sure yet
##/sbin/modprobe nvidia_384_drm
/sbin/modprobe nvidia_387_drm


function use_nvidialibs() {
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/lib/nvidia-387"
}

# use nvidia libs as well
use_nvidialibs 

# here is manual results after running manual_nvidia.sh  from the intel xterm

# clee@clee-P65Q:~$ use_nvidialibs 
# clee@clee-P65Q:~$ nvidia-smi
# Fri Dec 15 08:07:47 2017       
# +-----------------------------------------------------------------------------+
# | NVIDIA-SMI 384.90                 Driver Version: 384.90                    |
# |-------------------------------+----------------------+----------------------+
# | GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
# | Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
# |===============================+======================+======================|
# |   0  GeForce GTX 107...  Off  | 00000000:01:00.0 Off |                  N/A |
# | N/A   46C    P0    32W /  N/A |      0MiB /  8114MiB |      0%      Default |
# +-------------------------------+----------------------+----------------------+
                                                                               
# +-----------------------------------------------------------------------------+
# | Processes:                                                       GPU Memory |
# |  GPU       PID   Type   Process name                             Usage      |
# |=============================================================================|
# |  No running processes found                                                 |
# +-----------------------------------------------------------------------------+
# clee@clee-P65Q:~$ python cuda_avail.py 
# True
# clee@clee-P65Q:~$ ls
# anaconda3  configuration.txt  deviceQuery-out    Downloads          Music     Templates
# bin        cuda_avail.py      Documents          manual_nvidia.sh   Pictures  Videos
# code       Desktop            dot.emacs.d-lotus  manual_nvidia.sh~  Public    virtualmachines
# clee@clee-P65Q:~$ 

