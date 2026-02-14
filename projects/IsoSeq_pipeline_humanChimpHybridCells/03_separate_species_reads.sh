#!/bin/bash
#SBATCH --job-name=sepSpecies
#SBATCH --time=6:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=vbehrens@stanford.edu
#SBATCH --account=kingsley

module load samtools/1.9

SAMPLE=CHAf-D1.fl
HUMAN_REGIONS_FILE=hg38.regions.bed
CHIMP_REGIONS_FILE=pt6.regions.bed
THREADS=8

##### MAKE A FILE WITH READS THAT MAP TO HUMAN GENOME #####
samtools view --threads $THREADS -b -q 1 -L $HUMAN_REGIONS_FILE -o ${SAMPLE}.aligned_hg38pt6.sorted_mappedToHumanONLY.bam ${SAMPLE}.aligned_hg38pt6.sorted.bam
samtools index -@ $THREADS ${SAMPLE}.aligned_hg38pt6.sorted_mappedToHumanONLY.bam

##### MAKE A SEPARATE FILE WITH READS THAT MAP TO CHIMP GENOME #####
samtools view --threads $THREADS -b -q 1 -L $CHIMP_REGIONS_FILE -o ${SAMPLE}.aligned_hg38pt6.sorted_mappedToHumanONLY.bam ${SAMPLE}.aligned_hg38pt6.sorted.bam
samtools index -@ $THREADS ${SAMPLE}.aligned_hg38pt6.sorted_mappedToChimpONLY.bam