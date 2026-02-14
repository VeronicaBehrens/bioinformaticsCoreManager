#!/bin/bash
#SBATCH --job-name=minimap2
#SBATCH --time=60:00:00
#SBATCH --cpus-per-task=12
#SBATCH --mem=128G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=vbehrens@stanford.edu
#SBATCH --account=kingsley

module load samtools/1.9
module load minimap2/2.28

##### DEFINE VARIABLES #####
SAMPLE=CHAf-D1.fl                                                 # human-chimp hybrid sample
REF_GENOME=/labs/kingsley/jsong4/ref/Hs_GRCh38_pt6/hg38.pt6.fa    # composite human-chimp reference genome
THREADS=12

##### CONVERT LONG-READ ISO-SEQ DATA FROM (UNMAPPED) BAM TO FASTA #####
samtools fasta ${SAMPLE}.bam > ${SAMPLE}.fasta
pigz -p $THREADS ${SAMPLE}.fasta

##### MAP READS TO A COMPOSITE HUMAN-CHIMP GENOME (hg38.pt6.fa) #####
minimap2 -t $THREADS -a -x splice:hq -u f -Y -o ${SAMPLE}.aligned_hg38pt6.bam $REF_GENOME ${SAMPLE}.fasta.gz
samtools sort --threads $THREADS ${SAMPLE}.aligned_hg38pt6.bam > ${SAMPLE}.aligned_hg38pt6.sorted.bam
samtools index -@ $THREADS ${SAMPLE}.aligned_hg38pt6.sorted.bam

##### KEEP ONLY UNIQUELY-MAPPED READS (Q>=1) #####
samtools view -b --threads $THREADS -q 1 ${SAMPLE}.aligned_hg38pt6.sorted.bam > ${SAMPLE}.aligned_hg38pt6.sorted.MAPQ0removed.bam
samtools index -@ $THREADS ${SAMPLE}.aligned_hg38pt6.sorted.MAPQ0removed.bam