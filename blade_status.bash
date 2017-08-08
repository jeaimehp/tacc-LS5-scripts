#!/bin/bash
#This script uses squeue to determine the state of all the nodes on a blade
blade_cname=$1

#Check for input
if [ -z "${blade_cname}" ];then
	echo "Usage: blade_status <blade_cname>";
	exit
fi
#actual command Ref: https://slurm.schedmd.com/squeue.html for -o variables
grep $blade_cname /etc/hosts|awk '{print "echo "$3,$2";""squeue -o \"%A %t %e %L\" -w "$2}'|bash
