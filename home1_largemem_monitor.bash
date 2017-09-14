#!/bin/bash

## Eviromental variables for slurm
#export PATH=/usr/local/adm/bin:/usr/local/bin:/opt/slurm/default/bin:/opt/apps/tacc/bin:/etc/opt/slurm/default/lib/perl5/site_perl/5.10.0/x86_64-linux-thread-multi:/opt/apps/admin/bin/:/home1/00770/build/stack/losf:$PATH
#export MANPATH=$MANPATH:/etc/opt/slurm/15.08.0/share/man:/usr/share/man

## Pull node status from slurm
slurm_status="$(ssh home1 "/opt/slurm/default/bin/sinfo -R|/usr/bin/sed '1d'")"

##State check
#slurm_status=""
#slurm_status="Test Message"


if [ -z "${slurm_status}" ];then
	exit
fi
echo ""$(date +"%Y%m%d %H:%M")" -  The Slurm instance on home1 reports the following node(s) as state=down" > /tmp/largememqueue-status.log
echo " " >> /tmp/largememqueue-status.log
echo $slurm_status >> /tmp/largememqueue-status.log   

#echo "Sending Email ..."

cat /tmp/largememqueue-status.log|mail -s "[LS5 Monitoring] The Large Memory Queue has nodes down" -S from=root@LS5.master.tacc.utexas.edu jpowell@tacc.utexas.edu nthorne@tacc.utexas.edu #ops@tacc.utexas.edu minyard@tacc.utexas.edu
