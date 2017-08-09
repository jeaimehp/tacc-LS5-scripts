#!/bin/bash
export PATH=/opt/slurm/default/bin:/opt/apps/tacc/bin:/opt/slurm/default/lib/perl5/site_perl/5.10.0/x86_64-linux-thread-multi:/opt/apps/admin/bin/:/home1/00770/build/stack/losf:$PATH
export MANPATH=$MANPATH:/opt/slurm/default/share/man:/usr/share/man
export TACC_SHOWQ_CONF=/opt/apps/tacc/bin/showq.conf

jobnumber=$1
joblog=$(sacct -j $jobnumber -o jobid,partition,start,end -P|sed -n 2p)
#echo $joblog
echo "----------------------------------------------------------"
echo "Summary of JobID "$jobnumber
echo "----------------------------------------------------------"
sacct -j $jobnumber -o jobid,user,jobname,partition,start,end,AllocCPUS,NodeList,state,exitcode|head -n 3
 
jobstart_date=$(echo $joblog|awk -F "|" '{print $3}'|awk -F "T" '{print $1}')
#echo $jobstart_date
jobstart_time=$(echo $joblog|awk -F "|" '{print $3}'|awk -F "T" '{print $2}')
#echo $jobstart_time
jobend_date=$(echo $joblog|awk -F "|" '{print $4}'|awk -F "T" '{print $1}')
#echo $jobend_date
jobend_time=$(echo $joblog|awk -F "|" '{print $4}'|awk -F "T" '{print $2}')
#echo $jobend_time
jobpartition=$(echo $joblog|awk -F "|" '{print $2}')
#echo $jobpartition
echo "----------------------------------------------------------"
echo ""
sacct -S$jobstart_date-$jobstart_time -E$jobend_date-$jobend_time -X -o jobid,user,jobname,partition,start,end,AllocCPUS,NodeList,state -r $jobpartition
