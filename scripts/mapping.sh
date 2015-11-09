#!/bin/bash
# USING 
# ./bwa.sh <BAM FILE PATH> <NUMBER OF THREADS> <REFERENCE GENOME> <OUTPUT DIR> <READ_GROUP> <GROUP_ID> <CHR_NUM>
#

#read_grp=$(samtools view -H $1 | grep '^@RG'| uniq | sed 's/\t/\\t/g' | grep 'ID:');
#grp_id=$(samtools view -H $1 | grep '^@RG'| cut -f2 | sed 's/ID:/\ /g');

read_grp=$5
grp_id=$6
chr_num=$7


samtools view -f 2 -u -r $grp_id $1 $chr_num > tmpIn.ubam;

touch empty.sam && echo -e $read_grp >> empty.sam;

samtools view -u $1 "empty_region" > empty.ubam 2> /dev/null;

sizeEmpty="$(du -b empty.ubam | cut -f 1)"; printf "Empty bam file size = %-6d\n" "$sizeEmpty";
sizeTmpIn="$(du -b tmpIn.ubam | cut -f 1)"; printf "Input bam file size = %-6d\n" "$sizeTmpIn";

[[ "$sizeTmpIn" -gt "$sizeEmpty" ]] && \
samtools sort -n -o -l 0 -@ 4 tmpIn.ubam _shuf | \
bam bam2FastQ --in -.ubam --readname --noeof --firstOut /dev/stdout --merge --unpairedout un.fq 2> /dev/null | \
bwa mem -p -M -t $2 -R "$read_grp" $3 - | \
samtools view -Shu - | \
samtools sort    -o -l 0 -@ 4 - _sort > out.bam;

mkdir -p $4$grp_id"_chr_"$chr_num

[[ ! -a out.bam ]] && (samtools view -Sb empty.sam > out.bam 2> /dev/null) || true;

samtools index out.bam out.bai;

echo "$(date "+%T %D") Moving files to Storage";
mv -f out.bam $4$grp_id"_chr_"$chr_num/out.bam;
mv -f out.bai $4$grp_id"_chr_"$chr_num/out.bai;

rm tmpIn.ubam  un.fq empty.sam  empty.ubam

echo "$(date "+%T %D") Moving done";
