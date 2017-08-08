#!/bin/bash
##################################################################
#
# GRACE-SERIAL Queue Monitoring Cron
#
# Purpose: Monitor the grace-serial queue to ensure it is not in 
# any other state than "mix."
#
# Written by: Jeaime Powell - jpowell@tacc.utexas.edu
# Added to Cron: 08/07/2017
#
##################################################################

##Check to make sure script is being run from master
if [ "$(hostname)" != "master" ]; then
        echo "This script must be run on the master node - EXITING"
        exit
fi

## exports slurm paths
export PATH=/opt/slurm/default/bin:/opt/apps/tacc/bin:/opt/slurm/default/lib/perl5/site_perl/5.10.0/x86_64-linux-thread-multi:/opt/apps/admin/bin/:/home1/00770/build/stack/losf:$PATH
export MANPATH=$MANPATH:/opt/slurm/default/share/man:/usr/share/man
export TACC_SHOWQ_CONF=/opt/apps/tacc/bin/showq.conf

## PULLS GRACE-SERIAL STATUS
gracestatus=$(/opt/slurm/default/bin/sinfo -p grace-serial|grep -v PARTITION|awk '{print $5}')

## Used for testing
#gracestatus=draing
## End testing


if [[ "$gracestatus" != "mix" && "$gracestatus" != "idle" ]];then 
	clestate="$(ssh -o LogLevel=QUIET -t smw ssh -o LogLevel=QUIET -t boot "xtprocadmin -n nid01343|tail -n 1"|awk '{print $5}')"
	mungestate="$(ssh -o LogLevel=QUIET -t smw ssh -o LogLevel=QUIET -t boot ssh -o LogLevel=QUIET -t nid01343 "ps -elf|grep munge"|awk '{if ($4 != "/usr/sbin/munged") {print "DOWN"} else {print "OK"}}')"
	slurmstate="$(ssh -o LogLevel=QUIET -t smw ssh -o LogLevel=QUIET -t boot ssh -o LogLevel=QUIET -t nid01343 "ps -elf|grep slurmd|grep root"|awk '{if ($4 == "") {print "DOWN"} else {print "OK"}}')"
	echo "The grace-serial queue is in an abnormal state of "$gracestatus" @ ""$(date +"%Y%m%d %H:%M")" > /tmp/grace-serial-status.log
	echo " " >> /tmp/grace-serial-status.log
	echo $(/opt/slurm/default/bin/sinfo -p grace-serial|grep -v PARTITION) >> /tmp/grace-serial-status.log
	echo " " >> /tmp/grace-serial-status.log
	echo "Grace-serial node nid01343 Current Status" >> /tmp/grace-serial-status.log
	echo "--------------------------------------------------------" >> /tmp/grace-serial-status.log
	echo "Munge service: "$mungestate >> /tmp/grace-serial-status.log
	echo "Slurm service: "$slurmstate >> /tmp/grace-serial-status.log
	echo "CLE xtprocadmin state: "$clestate >> /tmp/grace-serial-status.log


	cat /tmp/grace-serial-status.log|mail -s "[LS5 Monitoring] The Grace-serial queue status is in $gracestatus" -S from=root@LS5.master.tacc.utexas.edu jpowell@tacc.utexas.edu nthorne@tacc.utexas.edu ops@tacc.utexas.edu minyard@tacc.utexas.edu
fi
