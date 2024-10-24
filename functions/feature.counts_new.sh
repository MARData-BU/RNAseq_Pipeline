#!/bin/bash
#SBATCH -p long          # Partition to submit to
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu 50Gb     # Memory in MB
#SBATCH -J counts           # job name
#SBATCH -o logs/counts.%j.out    # File to which standard out will be written
#SBATCH -e logs/counts.%j.err    # File to which standard err will be written

module purge
module load Subread/2.0.3 # més actualitzat a 31/JAN/2023

###################################################################################
############################COUNTS#################################################

PROJECT=$1
folder=$2
STAR_GTF=$3
FUNCTIONSDIR=$4
STRAND=$5
PAIRED=$6

BAMDIR=$PROJECT/Analysis/ReadMapping/BAM_Files/${folder}
OUTDIR=$PROJECT/Analysis/Quantification/CountFiles/${folder}

echo -e "The bam dir is $BAMDIR and the output dir is $OUTDIR."
echo -e "Strandness is $STRAND (0 for unstranded, 1 for stranded, 2 for reversely stranded)."

mkdir -p $OUTDIR

INPUT=`ls $BAMDIR/*.bam | paste -sd " " -`

if [ $PAIRED == TRUE ]
then
# Paired end
  featureCounts -T $SLURM_CPUS_PER_TASK -s $STRAND -p -t exon --countReadPairs --largestOverlap -g gene_name -a $STAR_GTF -o $OUTDIR/CountsTable.txt $INPUT
else
# NOT paired end
  featureCounts -T $SLURM_CPUS_PER_TASK -s $STRAND -t exon --largestOverlap -g gene_name -a $STAR_GTF -o $OUTDIR/CountsTable.txt $INPUT
fi


# el 0 després de la s defineix es unstranded, mentre que 1 es stranded i 2 reversely stranded
