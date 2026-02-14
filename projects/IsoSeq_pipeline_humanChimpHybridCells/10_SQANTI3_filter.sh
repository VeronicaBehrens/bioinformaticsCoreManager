#!/bin/bash
#SBATCH --job-name=rules_filter
#SBATCH --output=logs_10_SQANTI3_filter/chr22_log.out
#SBATCH --error=logs_10_SQANTI3_filter/chr22_log.err
#SBATCH --time=0:30:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=vbehrens@stanford.edu
#SBATCH --account=kingsley

source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate sqanti3

module load R/4.3.3
export R_LIBS_USER="$HOME/R/4.3.3/library"

export PATH="$CONDA_PREFIX/bin:$PATH"

INPUT_DIR=/labs/kingsley/vbehrens/TADaptations/Isoseq_Kinnex_tetraploids/scripts/SQANTI3_QC_output
INPUT_FILES_PREFIX=chr22ONLY-allSamples

SQANTI3_CLASSIFICATION_FILE=${INPUT_DIR}/${INPUT_FILES_PREFIX}_classification.txt
ISOANNOTLITE_GFF3_TO_FILTER=${INPUT_DIR}/${INPUT_FILES_PREFIX}.gff3
ISOFORM_FILE_TO_FILTER=${INPUT_DIR}/${INPUT_FILES_PREFIX}_corrected.fasta
GTF_FILE_TO_FILTER=${INPUT_DIR}/${INPUT_FILES_PREFIX}_corrected.gtf
FAA_FILE_TO_FILTER=${INPUT_DIR}/${INPUT_FILES_PREFIX}_corrected.faa
FILTERING_RULES_FILE=./10_SQANTI3_filter_customRules.json

OUTPUT_PREFIX=chr22ONLY-allSamples
OUTPUT_DIR=./SQANTI3_filter_output
NUM_CPUS=4

mkdir -p $OUTPUT_DIR
mkdir -p logs_10_SQANTI3_filter

##### FILTER THE UNIFIED SET OF ISOFORMS #####
##### AFTER THIS, GFF3 IS READY FOR DIFFERENTIAL ISOFORM USAGE ANALYSIS USING TAPPAS #####
sqanti3_filter.py rules \
     --sqanti_class $SQANTI3_CLASSIFICATION_FILE \
     --isoAnnotGFF3 $ISOANNOTLITE_GFF3_TO_FILTER \
     --filter_isoforms $ISOFORM_FILE_TO_FILTER \
     --filter_gtf $GTF_FILE_TO_FILTER \
     --filter_faa $FAA_FILE_TO_FILTER \
     --json_filter $FILTERING_RULES_FILE \
     --cpus $NUM_CPUS --output $OUTPUT_PREFIX --dir $OUTPUT_DIR


#####################################################


#usage: sqanti3_filter.py rules [-h] --sqanti_class SQANTI_CLASS [--isoAnnotGFF3 ISOANNOTGFF3] [--filter_isoforms FILTER_ISOFORMS] [--filter_gtf FILTER_GTF] [--filter_sam FILTER_SAM] [--filter_faa FILTER_FAA]
#                               [-o OUTPUT] [-d DIR] [--skip_report] [-e] [-v] [-c CPUS] [-l {ERROR,WARNING,INFO,DEBUG}] [-j JSON_FILTER]

#Rules filter selected

#options:
#  -h, --help            show this help message and exit

#Required arguments:
#  --sqanti_class SQANTI_CLASS
#                        SQANTI3 QC classification file.

#Input options:
#  --isoAnnotGFF3 ISOANNOTGFF3
#                        isoAnnotLite GFF3 file to be filtered
#  --filter_isoforms FILTER_ISOFORMS
#                        fasta/fastq isoform file to be filtered
#  --filter_gtf FILTER_GTF
#                        GTF file to be filtered
#  --filter_sam FILTER_SAM
#                        SAM alignment of the input fasta/fastq
#  --filter_faa FILTER_FAA
#                        ORF prediction faa file to be filtered by SQANTI3

#Output options:
#  -o OUTPUT, --output OUTPUT
#                        Prefix for output files.
#  -d DIR, --dir DIR     Directory for output files. Default: ./sqanti3_results
#  --skip_report         Skip creation of a report about the filtering

#Filtering options:
#  -e, --filter_mono_exonic
#                        All mono-exonic transcripts are automatically filtered

#Extra options:
#  -v, --version         Display program version number.
#  -c CPUS, --cpus CPUS  Number of CPUs to use. Default: 4
#  -l {ERROR,WARNING,INFO,DEBUG}, --log_level {ERROR,WARNING,INFO,DEBUG}
#                        Set the logging level.
#                        Default: INFO

#Rules specific options:
#  -j JSON_FILTER, --json_filter JSON_FILTER
#                        JSON file where filtering rules are expressed. Rules must be set taking into account that attributes described in the filter will be present in those isoforms that should be kept.
#                        Default: /scg/apps/software/SQANTI3/5.5.1/SQANTI3-5.5.1/src/utilities/filter/filter_default.json

