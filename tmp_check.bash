#!/bin/bash
#This script uses pdsh to check the /tmp mount on all login nodes
/usr/local/bin/pdsh -w login[1-4],vlogin0[1-5] "df -h /tmp"|/usr/local/bin/dshbak -c
