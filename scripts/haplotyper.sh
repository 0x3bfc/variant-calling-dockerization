#!/bin/bash
input=$1
tmpDir=$2
genome_ref=$3
threads=$4
snp_db=$5
output_dir=$6
java -d64 -XX:ParallelGCThreads=$threads -XX:+UseParallelOldGC -XX:+AggressiveOpts -Djava.io.tmpdir=$tmpDir -Xmx16384M \
-jar /usr/local/GenomeAnalysisTK-3.4-46/GenomeAnalysisTK.jar \
-T HaplotypeCaller \
-R $genome_ref \
-D $snp_db \
-o $tmpDir/out.vcf \
-pairHMM VECTOR_LOGLESS_CACHING \
-L 3 \
-nct 1 \
--emitRefConfidence GVCF --variant_index_type LINEAR --variant_index_parameter 128000 \
-A DepthPerAlleleBySample \
-stand_call_conf 30 \
-stand_emit_conf 10 \
-I $input;

echo "$(date "+%T %D") Moving files to Storage";
[[ -a $tmpDir/out.vcf     ]] && mv -f $tmpDir/out.vcf $output_dir/out.vcf;
[[ -a $tmpDir/out.vcf.idx ]] && mv -f $tmpDir/out.vcf.idx $output_dir/out.vcf.idx;
echo "$(date "+%T %D") Moving done";
cd && /bin/rm -rf $tmpDir;
