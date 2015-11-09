#!/bin/bash
# USING
# ./run.sh <BAM FILE PATH> <NUMBER OF THREADS> <REFERENCE GENOME> <OUTPUT DIR> <READ_GROUP> <GROUP_ID> <SNP_DB>
#

read_grp=$(samtools view -H $1 | grep '^@RG'| uniq | sed 's/\t/\\t/g' | grep 'ID:');
rgs=$(samtools view -H $1 | grep '^@RG'| cut -f2 | sed 's/ID:/\ /g');
bam_list=""
threads=$2
for grp_id in $rgs;
do
	for chr in `seq 1 22` X Y XY MT UN; do 
		header=$(samtools view -H $1 | grep $grp_id | sed 's/\t/\\t/g');
		# mapping input to reference genome
		./mapping.sh $1 $2 $3 $4 $header $grp_id $chr;
		# mark duplicates using picard tools
		tmpDir="tmp_"$grp_id"_chr_"$chr;
		markDups_output=$4$grp_id"_chr_"$chr"/markDups"
		mkdir -p $markDups_output;
		./markDups.sh $4$grp_id"_chr_"$chr"/out.bam" $tmpDir $markDups_output $threads
		# Variant Calling
		vcf_output=$4$grp_id"_chr_"$chr"/vcf/"
		mkdir -p $vcf_output;
		./haplotyper.sh $markDups_output"/out.bam" $tmpDir $3 $threads $5 $vcf_output
	done
done
