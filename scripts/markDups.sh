#!/bin/bash
#USING
# ./markDups.sh <INPUT_BAM_FILE> <TMP_DIR> <OUT_DIR>
input=$1
tmpDir=$2
outDir=$3
threads=$4
java -d64 -XX:ParallelGCThreads=$threads -XX:+UseParallelOldGC -XX:+AggressiveOpts -Xmx4096M -jar /usr/local/picardtools/picard-tools-1.129/picard.jar MarkDuplicates \
TMP_DIR=$tmpDir \
OUTPUT=$tmpDir/out.bam \
METRICS_FILE=$tmpDir/out.metrics \
ASSUME_SORTED=True \
CREATE_INDEX=True \
COMPRESSION_LEVEL=0 \
MAX_RECORDS_IN_RAM=1000000 \
VALIDATION_STRINGENCY=SILENT \
VERBOSITY=INFO \
INPUT=$input;

mv -f $tmpDir/out.metrics $outDir/out.metrics;
echo "$(date "+%T %D") Moving files to Storage";
[[ -a $tmpDir/out.bam ]] && mv -f $tmpDir/out.bam $outDir/out.bam;
[[ -a $tmpDir/out.bai ]] && mv -f $tmpDir/out.bai $outDir/out.bai;
echo "$(date "+%T %D") Moving done";
cd && /bin/rm -rf $tmpDir;
