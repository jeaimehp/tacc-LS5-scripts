#!/bin/bash
#This script uses ssh to open a multihop session to the chroot environment on a compute node
blade_name=$1

#Check for input
if [ -z "${blade_name}" ];then
	echo "Usage: goto_nid.bash <cname or nidname>";
	exit
fi
echo "Opening the chroot (shared_root) environment on node "$1
ssh -t smw ssh -t boot ssh -t $1 "/sbin/chroot /dsl"
