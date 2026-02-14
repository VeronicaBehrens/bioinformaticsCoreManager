#!/bin/bash
#SBATCH --job-name=quantFlair
#SBATCH --output=logs_08_flair_quantify/chr22_log.out
#SBATCH --error=logs_08_flair_quantify/chr22_log.err
#SBATCH --time=4:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=vbehrens@stanford.edu
#SBATCH --account=kingsley

source "$(conda info --base)"/etc/profile.d/conda.sh
conda activate flair_new
module load bedtools/2.27.1
module load minimap2/2.28

ISOFORMS_DIR=./flair_transcriptome_results
OUTPUT_DIR=./flair_quantify_results
TEMP_DIR=./flair_quantify_results_TEMP

READS_MANIFEST=./08_flair_quantify_MANIFEST_chr22ONLY.txt
FASTA_OF_COLLAPSED_ISOFORMS=${ISOFORMS_DIR}/chr22ONLY_allSamplesCOMBINED_hg38_MAPq0removed.fa
BED12_OF_COLLAPSED_ISOFORMS=${ISOFORMS_DIR}/chr22ONLY_allSamplesCOMBINED_hg38_MAPq0removed.bed
OUTPUT_BASE=${OUTPUT_DIR}/chr22ONLY_allSamples_flairQuantify
THREADS=8

mkdir -p $OUTPUT_DIR
mkdir -p $TEMP_DIR

flair quantify \
     --reads_manifest $READS_MANIFEST \
     --isoforms $FASTA_OF_COLLAPSED_ISOFORMS \
     --isoform_bed $BED12_OF_COLLAPSED_ISOFORMS \
     --output $OUTPUT_BASE \
     --threads $THREADS \
     --temp_dir $TEMP_DIR \
     --tpm \
     --quality 0 \
     --generate_map \
     --output_bam

#     --stringent     # used in previous attempt - don't think should use
#     --check_splice  # used in previous attempt - don't think should use


###############################################


#Default: identifes the best isoform assignment based on alignment quality, fraction of read aligned, and fraction of transcript aligned

#check_splice: adds check for read matching reference transcript at all splice sites

#stringent: adds requirement for read to cover at least 25bp of the first and last exons

#If you need your reads to match your isoforms well, use –check_splice and –stringent, while if you need more reads assigned to isoforms for better statistical comparison, use the default.

#–quality 0 is also reccommended, as this allows slightly better recall as FLAIR can disambiguate some similar isoform alignments.


###############################################


#usage: quantify [-h] -r R -i I [-o O] [-t T] [--temp_dir TEMP_DIR] [--sample_id_only] [--tpm] [--quality QUALITY] [--trust_ends] [--generate_map] [--isoform_bed ISOFORMS] [--stringent] [--check_splice]
#                [--output_bam]

#takes in many long-read RNA-seq reads files and quantifies them against a single transcriptome. A stringent, full-read-match-based approach

#options:
#  -h, --help            show this help message and exit
#  -o O, --output O      output file name base for FLAIR quantify (default: flair.quantify)
#  -t T, --threads T     minimap2 number of threads (4)
#  --temp_dir TEMP_DIR   directory to put temporary files. use './" to indicate current directory (default: python tempfile directory)
#  --sample_id_only      only use sample id in output header
#  --tpm                 Convert counts matrix to transcripts per million and output as a separate file named <output>.tpm.tsv
#  --quality QUALITY     minimum MAPQ of read assignment to an isoform (0)
#  --trust_ends          specify if reads are generated from a long read method with minimal fragmentation
#  --generate_map        create read-to-isoform assignment files for each sample (default: not specified)
#  --isoform_bed ISOFORMS, --isoformbed ISOFORMS
#                        isoform .bed file, must be specified if --stringent or check_splice is specified
#  --stringent           Supporting reads must cover 80 percent of their isoform and extend at least 25 nt into the first and last exons. If those exons are themselves shorter than 25 nt, the requirement becomes
#                        'must start within 4 nt from the start" or "must end within 4 nt from the end"
#  --check_splice        enforce coverage of 4 out of 6 bp around each splice site and no insertions greater than 3 bp at the splice site
#  --output_bam          whether to output bam file of reads aligned to correct isoforms

#required named arguments:
#  -r R, --reads_manifest R
#                        Tab delimited file containing sample id, condition, batch, reads.fq
#  -i I, --isoforms I    FastA of FLAIR collapsed isoforms
