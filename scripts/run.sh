#!/bin/bash
# USING
# ./run.sh <BAM FILE PATH> <NUMBER OF THREADS> <REFERENCE GENOME> <OUTPUT DIR> <READ_GROUP> <GROUP_ID>
#

read_grp=$(samtools view -H $1 | grep '^@RG'| uniq | sed 's/\t/\\t/g' | grep 'ID:');
rgs=$(samtools view -H $1 | grep '^@RG'| cut -f2 | sed 's/ID:/\ /g');

for grp_id in $rgs;
do 
	header=$(samtools view -H $1 | grep $grp_id | sed 's/\t/\\t/g');
	./bwa.sh $1 $2 $3 $4 $header $grp_id
done

