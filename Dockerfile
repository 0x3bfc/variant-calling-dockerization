FROM ubuntu:14.04

MAINTAINER Ahmed Abdullah <ahmedaabdulwahed@gmail.com>

# Update APT repo.
RUN apt-get update -y

# Install required packages
RUN apt-get -y install default-jre default-jdk python python-pip wget unzip zip vim

# Picard Installation
RUN wget -O /tmp/picard-tools-1.129.zip https://github.com/broadinstitute/picard/releases/download/1.129/picard-tools-1.129.zip \
    && mkdir -p /usr/local/picardtools \
    && unzip /tmp/picard-tools-1.129.zip -d /usr/local/picardtools/ \
    && chown -R root:root /usr/local/picardtools \
    && echo 'export PATH=$PATH:/usr/local/picardtools/picard-tools-1.129' >> /root/.bashrc


RUN rm -rf /tmp/*

# BWA, samtools Installation  
RUN apt-get install bwa samtools

# GATK Installation 

ADD GenomeAnalysisTK-3.4-46.tar.bz2 /usr/local/

RUN mkdir -p /usr/local/GenomeAnalysisTK-3.4-46 

ADD GenomeAnalysisTK-3.4-46.tar.bz2 /usr/local/GenomeAnalysisTK-3.4-46/
 
RUN cd /usr/local/GenomeAnalysisTK-3.4-46 && \
	echo 'export PATH=$PATH:/usr/local/GenomeAnalysisTK-3.4-46' >>  /root/.bashrc && \
	chmod 777 /usr/local/GenomeAnalysisTK-3.4-46/* && \	
	cp -rfv /usr/local/GenomeAnalysisTK-3.4-46/* /usr/local/bin/

RUN rm -rf /tmp/*

RUN echo "alias picard='java -jar /usr/local/picardtools/picard-tools-1.129/picard.jar'" >> /root/.bashrc && \
	echo "alias GenomeAnalysisTK='java -jar /usr/local/GenomeAnalysisTK-3.4-46/GenomeAnalysisTK.jar'" >> /root/.bashrc

#open ports private only
EXPOSE 22

# Use baseimage-docker's bash.
CMD ["/bin/bash"]
