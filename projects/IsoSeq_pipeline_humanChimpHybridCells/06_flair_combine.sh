#!/bin/bash
#SBATCH --job-name=flComb
#SBATCH --output=logs_06_flair_combine/chr22_log.out
#SBATCH --error=logs_06_flair_combine/chr22_log.err
#SBATCH --time=0:30:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=vbehrens@stanford.edu
#SBATCH --account=kingsley

# initialize activation functions in THIS shell
source "$(conda info --base)"/etc/profile.d/conda.sh
conda activate flair_new

MANIFEST=/labs/kingsley/vbehrens/TADaptations/Isoseq_Kinnex_tetraploids/scripts/06_flair_combine_MANIFEST_chr22ONLY.txt 
OUTPUT_BASE=./flair_transcriptome_results/chr22ONLY_allSamplesCOMBINED_hg38_MAPq0removed

GENOME_FASTA=/labs/kingsley/jsong4/ref/hg38/hg38.fa
GTF=/labs/kingsley/vbehrens/TADaptations/Isoseq_Kinnex_tetraploids/reference_files/gencode.v49.chr_patch_hapl_scaff.annotation.gtf

### FLAIR COMBINE: CREATE A UNIFIED SET OF ISOFORMS BY COMBINING THOSE DISCOVERED ACROSS ALL SAMPLES ###
flair combine --manifest $MANIFEST --output_prefix $OUTPUT_BASE --minpercentusage 10 --filter usageonly --convert_gtf
### NOTE: maybe alter --minpercentusage & --filter in the future

### PREDICT PRODUCTIVITY ###
predictProductivity --input_isoforms ${OUTPUT_BASE}.bed --gtf $GTF --genome_fasta $GENOME_FASTA --firstTIS --output ${OUTPUT_BASE}.isoforms.PredictProductivity

### ADD GENE NAME TO GTF FOR DOWNSTREAM IsoAnnotLite STEP ###
awk 'BEGIN{FS=OFS="\t"}
  /^#/ {print; next}
  {
    if ($9 ~ /gene_name "/) { print; next }

    gene_id=""
    if (match($9, /gene_id "[^"]+"/)) {
      gene_id=substr($9, RSTART+9, RLENGTH-10)
    } else {
      gene_id="UNKNOWN"
    }

    # ensure attrs end with semicolon, then append gene_name
    if ($9 !~ /;[[:space:]]*$/) $9=$9 ";"
    $9=$9 " gene_name \"" gene_id "\";"
    print
  }' "${OUTPUT_BASE}.gtf" > "${OUTPUT_BASE}.withGeneName.gtf"


###########################################################


#Combine transcriptomes between samples.
#If you have a dataset composed of many samples that you want to compare, you want to have a reference transcriptome that works equally well for all samples. To achieve this, first generate a transcriptome for each sample or batch of samples. Next, use FLAIR combine to combine the transcriptomes.

#Make a manifest file pointing to your transcriptomes for all of your samples (see FLAIR combine documentation for more details)

#Run FLAIR combine:

#More stringent combination (keep only spliced isoforms expressed at over 10% of the locus in at least 1 sample)
#flair combine -m MANIFEST.txt -o OUTPUT

#Less stringent combination (keeps anything supported in any file, just combines based on splice junctions and similar ends)
#flair combine -m MANIFEST.txt -o OUTPUT -p 0 -f 1 -s


###########################################################


#usage: combine [-h] -m MANIFEST [-o OUTPUT_PREFIX] [-w ENDWINDOW] [-p MINPERCENTUSAGE] [-c] [-s] [-f FILTER]

#options:
#  -h, --help            show this help message and exit
#  -m MANIFEST, --manifest MANIFEST
#                        path to manifest files that points to transcriptomes to combine. Each line of file should be tab separated with sample name, sample type (isoform or fusionisoform), path/to/isoforms.bed,
#                        path/to/isoforms.fa, path/to/combined.isoform.read.map.txt. fa and read.map.txt files are not required, although if .fa files are not provided for each sample a .fa output will not be
#                        generated
#  -o OUTPUT_PREFIX, --output_prefix OUTPUT_PREFIX
#                        path to collapsed_output.bed file. default: 'collapsed_flairomes'
#  -w ENDWINDOW, --endwindow ENDWINDOW
#                        window for comparing ends of isoforms with the same intron chain. Default:200bp
#  -p MINPERCENTUSAGE, --minpercentusage MINPERCENTUSAGE
#                        minimum percent usage required in one sample to keep isoform in combined transcriptome. Default:10
#  -c, --convert_gtf     [optional] whether to convert the combined transcriptome bed file to gtf
#  -s, --include_se      whether to include single exon isoforms. Default: dont include
#  -f FILTER, --filter FILTER
#                        type of filtering. Options: usageandlongest(default), usageonly, none, or a number for the total count of reads required to call an isoform
