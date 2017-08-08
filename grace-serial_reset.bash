#!/bin/bash
#########################################################
#         Grace-Serial Node Reset			#
#                                                       #
# Created: 8/3/2017					#
# Written by: Je'aime Powell - jpowell@tacc.utexas.edu	#
#                                                  	#
# Purpose:                                         	#
# This script is used to reset nid01343 after an    	#
# "admindown" event due to over-subscription from  	#
# the shared jobs.                                 	#
#                                                  	#
# Workflow:                                        	# 
# 1. Check nid01343 for "munge" service running    	#
# 	a. If not found run FixNode munge		#
# 2. Check nid01343 for "slurmd" service running   	#
# 	a. If not found run FixNode slurm		#
# 3. Check boot "xtprocadmin" for node state       	#
#	a. If in "admindown" set to "up"		#
# 4. On master set nid01343 to state "resume"      	#
#########################################################

## Check/Report munge and slurm services on nid01343


clestate="$(ssh -o LogLevel=QUIET -t smw ssh -o LogLevel=QUIET -t boot "xtprocadmin -n nid01343|tail -n 1"|awk '{print $5}')"
##Down State Test
#clestate="down"

if [ "$clestate" == "down" ]; then
        echo " "
	echo "Possible hardware problem with nid01343, contact LS5 administrative staff"
	echo " "
	exit 0
fi


mungestate="$(ssh -o LogLevel=QUIET -t smw ssh -o LogLevel=QUIET -t boot ssh -o LogLevel=QUIET -t nid01343 "ps -elf|grep munge"|awk '{if ($4 != "/usr/sbin/munged") {print "DOWN"} else {print "OK"}}')"
slurmstate="$(ssh -o LogLevel=QUIET -t smw ssh -o LogLevel=QUIET -t boot ssh -o LogLevel=QUIET -t nid01343 "ps -elf|grep slurmd|grep root"|awk '{if ($4 == "") {print "DOWN"} else {print "OK"}}')"
echo "Grace-serial nid01343 Current Status "$(date +"%Y%m%d")
echo "--------------------------------------------------------" 

#Testing 
#-----------------------#
#mungestate="DOWN"
#slurmstate="DOWN"
#clestate="admindown"

#----------------------#
#End Testing Block
echo "Munge service: "$mungestate
echo "Slurm service: "$slurmstate
echo "CLE xtprocadmin state: "$clestate

if [ "$mungestate" == "OK" ] && [ "$slurmstate" == "OK" ] && [ "$clestate" == "up" ]; then
        echo "Everything is all good on nid01343 in the grace-serial queue"
        echo " "
	ssh -o LogLevel=QUIET -t sdb '/opt/slurm/default/bin/sinfo -p grace-serial'
        echo " "
	ssh -o LogLevel=QUIET -t sdb '/opt/slurm/default/bin/squeue -p grace-serial'
	exit 0
fi

if [ "$clestate" == "down" ]; then
        echo "Possible hardware problem, contact LS5 administrative staff"
fi

if [ "$mungestate" == "DOWN" ] && [ "$slurmstate" == "OK" ]; then
	echo "Restarting munge"
	ssh -o LogLevel=QUIET -t sdb "/opt/cray/nodehealth/5.1-1.0502.64995.8.11.ari/bin/pcmd -i -n 1343 '/opt/apps/admin/bin/FixNode slurm'|grep -v complete"
	ssh -o LogLevel=QUIET -t sdb 'scontrol update node=nid01343 state=resume reason="munge restart"'

elif [ "$mungestate" == "OK" ] && [ "$slurmstate" == "DOWN" ]; then        
	echo "Restarting slurm"
        ssh -o LogLevel=QUIET -t sdb "/opt/cray/nodehealth/5.1-1.0502.64995.8.11.ari/bin/pcmd -i -n 1343 '/opt/apps/admin/bin/FixNode slurm'|grep -v complete"
        ssh -o LogLevel=QUIET -t sdb 'scontrol update node=nid01343 state=resume reason="slurm restart"'

elif [ "$mungestate" == "DOWN" ] && [ "$slurmstate" == "DOWN" ]; then
        echo "Restarting munge and slurm"
        ssh -o LogLevel=QUIET -t sdb "/opt/cray/nodehealth/5.1-1.0502.64995.8.11.ari/bin/pcmd -i -n 1343 '/opt/apps/admin/bin/FixNode slurm'|grep -v complete"
        ssh -o LogLevel=QUIET -t sdb 'scontrol update node=nid01343 state=resume reason="munge and slurm restart"'
fi

if [ "$clestate" == "admindown" ]; then
	echo "Returning nid01343 to up state in CLE"
	ssh -o LogLevel=QUIET -t smw ssh -o LogLevel=QUIET -t boot "xtprocadmin -n nid01343 -k s up"
	ssh -o LogLevel=QUIET -t sdb 'scontrol update node=nid01343 state=resume reason="CLE node up after shared service admindown"'
fi



mungestate="$(ssh -o LogLevel=QUIET -t smw ssh -o LogLevel=QUIET -t boot ssh -o LogLevel=QUIET -t nid01343 "ps -elf|grep munge"|awk '{if ($4 != "/usr/sbin/munged") {print "DOWN"} else {print "OK"}}')"
slurmstate="$(ssh -o LogLevel=QUIET -t smw ssh -o LogLevel=QUIET -t boot ssh -o LogLevel=QUIET -t nid01343 "ps -elf|grep slurmd|grep root"|awk '{if ($4 == "") {print "DOWN"} else {print "OK"}}')"
clestate="$(ssh -o LogLevel=QUIET -t smw ssh -o LogLevel=QUIET -t boot "xtprocadmin -n nid01343|tail -n 1"|awk '{print $5}')"
echo " "
echo "Post corrective action on Grace-serial nid01343 Status @ "$(date +"%Y%m%d")
echo "--------------------------------------------------------" 
echo "Munge service: "$mungestate
echo "Slurm service: "$slurmstate
echo "CLE xtprocadmin state: "$clestate
echo " "
ssh -o LogLevel=QUIET -t sdb '/opt/slurm/default/bin/sinfo -p grace-serial'
echo " "
ssh -o LogLevel=QUIET -t sdb '/opt/slurm/default/bin/squeue -p grace-serial'
