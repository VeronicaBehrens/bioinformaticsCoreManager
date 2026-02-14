#!/bin/bash
#SBATCH --job-name=QC_iso
#SBATCH --output=logs_09_SQANTI3_QC/chr22_log.out
#SBATCH --error=logs_09_SQANTI3_QC/chr22_log.err
#SBATCH --time=4:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=vbehrens@stanford.edu
#SBATCH --account=kingsley

source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate sqanti3
export PATH="$CONDA_PREFIX/bin:$PATH"

ISOFORMS_GTF=/labs/kingsley/vbehrens/TADaptations/Isoseq_Kinnex_tetraploids/scripts/flair_transcriptome_results/chr22ONLY_allSamplesCOMBINED_hg38_MAPq0removed.withGeneName.gtf
REF_GTF=/labs/kingsley/vbehrens/TADaptations/Isoseq_Kinnex_tetraploids/input_reference_files/gencode.v49.chr_patch_hapl_scaff.annotation.gtf
REF_GENOME=/labs/kingsley/jsong4/ref/hg38/hg38.fa
CAGE_PEAKS_BED=/labs/kingsley/vbehrens/TADaptations/Isoseq_Kinnex_tetraploids/input_reference_files/hg38_fair+new_CAGE_peaks_phase1and2_promoters.bed
GFF3_FOR_isoAnnotLite=/labs/kingsley/vbehrens/TADaptations/Isoseq_Kinnex_tetraploids/input_reference_files/Homo_sapiens_GRCh38_Ensembl_86.gff3
OUTPUT_PREFIX=chr22ONLY-allSamples
OUTPUT_DIR=/labs/kingsley/vbehrens/TADaptations/Isoseq_Kinnex_tetraploids/scripts/SQANTI3_QC_output
NUM_CPUS=4

mkdir -p $OUTPUT_DIR

##### QUALITY CHECK THE UNIFIED SET OF ISOFORMS #####
##### CREATE A GFF3 COMPATIBLE WITH TAPPAS FOR DOWNSTREAM DIFFERENTIAL ISOFORM USAGE #####
sqanti3_qc.py \
     --isoforms $ISOFORMS_GTF \
     --refGTF $REF_GTF \
     --refFasta $REF_GENOME \
     --CAGE_peak $CAGE_PEAKS_BED \
     --isoAnnotLite \
     --gff3 $GFF3_FOR_isoAnnotLite \
     --output $OUTPUT_PREFIX \
     --dir $OUTPUT_DIR \
     --cpus $NUM_CPUS \
     --force_id_ignore \
     --aligner_choice minimap2 \
     --report both \
     --genename


###################################################

#usage: sqanti3_qc.py [-h] --isoforms ISOFORMS --refGTF REFGTF --refFasta REFFASTA [--min_ref_len MIN_REF_LEN] [--force_id_ignore] [--fasta] [--genename] [--novel_gene_prefix NOVEL_GENE_PREFIX] [-s SITES]
#                     [-w WINDOW] [--aligner_choice {minimap2,deSALT,gmap,uLTRA}] [-x GMAP_INDEX] [--skipORF] [--orf_input ORF_INPUT] [--short_reads SHORT_READS] [--SR_bam SR_BAM] [--CAGE_peak CAGE_PEAK]
#                     [--polyA_motif_list POLYA_MOTIF_LIST] [--polyA_peak POLYA_PEAK] [--phyloP_bed PHYLOP_BED] [-e EXPRESSION] [-c COVERAGE] [-fl FL_COUNT] [--isoAnnotLite] [--gff3 GFF3] [-o OUTPUT] [-d DIR]
#                     [--saturation] [--report {html,pdf,both,skip}] [--isoform_hits] [--ratio_TSS_metric {max,mean,median,3quartile}] [-t CPUS] [-n CHUNKS] [-l {ERROR,WARNING,INFO,DEBUG}] [--is_fusion] [-v]
#                     [--bugsi {human,mouse}]

#Structural and Quality Annotation of Novel Transcript Isoforms

#options:
#  -h, --help            show this help message and exit

#Required arguments:
#  --isoforms ISOFORMS   Isoforms (FASTA/FASTQ) or GTF format. It is recommended to provide them in GTF format, but if it is needed to map the sequences to the genome use a FASTA/FASTQ file with the --fasta
#                        option.
#  --refGTF REFGTF       Reference annotation file (GTF format)
#  --refFasta REFFASTA   Reference genome (Fasta format)

#Customization and filtering:
#  --min_ref_len MIN_REF_LEN
#                        Minimum reference transcript length (default: 0 bp)
#  --force_id_ignore     Allow the usage of transcript IDs non related with PacBio's nomenclature (PB.X.Y)
#  --fasta               Use when running SQANTI by using as input a FASTA/FASTQ with the sequences of isoforms
#  --genename            Use gene_name tag from GTF to define genes. Default: gene_id used to define genes
#  --novel_gene_prefix NOVEL_GENE_PREFIX
#                        Prefix for novel isoforms (default: None)
#  -s SITES, --sites SITES
#                        Set of splice sites to be considered as canonical, in a comma separated list. (default: ATAC,GCAG,GTAG)
#  -w WINDOW, --window WINDOW
#                        Size of the window in the genomic DNA screened for Adenine content downstream of TTS (default: 20)

#Aligner and mapping options:
#  --aligner_choice {minimap2,deSALT,gmap,uLTRA}
#                        Select your aligner of choice: minimap2, deSALT, gmap, uLTRA (default: minimap2)
#  -x GMAP_INDEX, --gmap_index GMAP_INDEX
#                        Path and prefix of the reference index created by gmap_build. Mandatory if using GMAP .

#ORF prediction:
#  --skipORF             Skip ORF prediction (to save time)
#  --orf_input ORF_INPUT
#                        Input fasta to run ORF on. By default, ORF is run on genome-corrected fasta - this overrides it. If input is fusion (--is_fusion), this must be provided for ORF prediction.

#Orthogonal data inputs:
#  --short_reads SHORT_READS
#                        File Of File Names (fofn, space separated) with paths to FASTA or FASTQ from Short-Read RNA-Seq. If expression or coverage files are not provided, Kallisto (just for pair-end data) and
#                        STAR, respectively, will be run to calculate them.
#  --SR_bam SR_BAM       Directory or fofn file with the sorted bam files of Short Reads RNA-Seq mapped against the genome
#  --CAGE_peak CAGE_PEAK
#                        FANTOM5 Cage Peak (BED format, optional)
#  --polyA_motif_list POLYA_MOTIF_LIST
#                        Ranked list of polyA motifs (text, optional)
#  --polyA_peak POLYA_PEAK
#                        PolyA Peak (BED format, optional)
#  --phyloP_bed PHYLOP_BED
#                        PhyloP BED for conservation score (BED, optional)
#  -e EXPRESSION, --expression EXPRESSION
#                        Expression matrix (supported: Kallisto tsv)
#  -c COVERAGE, --coverage COVERAGE
#                        Junction coverage files (provide a single file, comma-delmited filenames, or a file pattern, ex: "mydir/*.junctions").
#  -fl FL_COUNT, --fl_count FL_COUNT
#                        Full-length PacBio abundance file

#Functional annotation:
#  --isoAnnotLite        Run isoAnnot Lite to output a tappAS-compatible gff3 file
#  --gff3 GFF3           Precomputed tappAS species specific GFF3 file. It will serve as reference to transfer functional attributes

#Output options:
#  -o OUTPUT, --output OUTPUT
#                        Prefix for output files
#  -d DIR, --dir DIR     Directory for output files. (Default: Directory where the script was run.)
#  --saturation          Include saturation curves into report
#  --report {html,pdf,both,skip}
#                        Select report format: html, pdf, both, skip (default: html)
#  --isoform_hits        Report all FSM/ISM isoform hits in a separate file
#  --ratio_TSS_metric {max,mean,median,3quartile}
#                        Define which statistic metric should be reported in the ratio_TSS column (default: max)

#Performance options:
#  -t CPUS, --cpus CPUS  Number of threads used during alignment by aligners. (default: 10)
#  -n CHUNKS, --chunks CHUNKS
#                        Number of chunks to split SQANTI3 analysis in for speed up (default: 1).
#  -l {ERROR,WARNING,INFO,DEBUG}, --log_level {ERROR,WARNING,INFO,DEBUG}
#                        Set the logging level INFO

#Optional arguments:
#  --is_fusion           Input are fusion isoforms, must supply GTF as input
#  -v, --version         Display program version number.
#  --bugsi {human,mouse}
#                        Generate a BUGSI benchmarking report for the given species (human or mouse)
