# Starting with the chrom.sizes file from the hg38.pt6 genome:
    # Make a bed file with only human regions
    # Make a bed file with only chimp regions

chrom_sizes_inFileName=./hg38.pt6.chrom.sizes
human_regions_outFileName=./hg38.regions.bed
chimp_regions_outFileName=./pt6.regions.bed

with open(chrom_sizes_inFileName, 'r') as inFile, open(human_regions_outFileName, 'w') as humanOutFile, open(chimp_regions_outFileName, 'w') as chimpOutFile:
    for line in inFile:
        line = line.strip()
        chrom, end = line.split('\t')
        if 'Pt' in chrom:
            print('\t'.join([chrom, '1', end]), file=chimpOutFile)
        else:
            print('\t'.join([chrom, '1', end]), file=humanOutFile)