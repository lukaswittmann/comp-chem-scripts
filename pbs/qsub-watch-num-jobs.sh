#!/bin/bash

user='username'

maxqueue=100 # ajust to hpc cluster
currqueue=$(qstat -u &user | grep -c &user)

while [ $currqueue -ge $maxqueue ]
do
sleep 60 # ajust to jobtiming
currqueue=$(qstat -u wittmann | grep -c wittmann)
echo Currently $currqueue of $maxqueue jobs in queue 
done

qsub $job
currqueue=$(($currqueue+1))
echo Currently $currqueue of $maxqueue jobs in queue
