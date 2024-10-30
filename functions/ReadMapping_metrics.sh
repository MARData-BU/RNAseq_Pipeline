#!/bin/bash
#SBATCH -p normal,short,long            # Partition to submit to
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu 18Gb     # Memory in MB
#SBATCH -J ReadMapping_metrics          # job name
#SBATCH -o logs/ReadMapping_metrics.%j.out    # File to which standard out will be written
#SBATCH -e logs/ReadMapping_metrics.%j.err    # File to which standard err will be written

# Prepare variables
#------------------
## INPUT
folder=$1
PROJECT=$2
QC=${PROJECT}/QC/${folder}

# Load modules
#------------------
module load Python/3.8.6-GCCcore-10.2.0
module load R/4.1.2-foss-2020b

# Prepare folders
#------------------
mkdir $QC/STAR

# Move to QC folder
cd $QC

#------------------

#=================#
#  Manual summary
#=================#

OUTDIR=$PROJECT/Analysis/ReadMapping/BAM_Files/${folder}
touch $OUTDIR/TotalCounts_Alignment

for i in $OUTDIR/*.final.out; do basename $i >> $OUTDIR/TotalCounts_Alignment; \
grep "Number of input reads" "$i" >> $OUTDIR/TotalCounts_Alignment; grep "Uniquely mapped reads" "$i"\
 >> $OUTDIR/TotalCounts_Alignment; grep "Average mapped length" "$i" >> $OUTDIR/TotalCounts_Alignment;\
 grep "reads mapped to too many loci" "$i" >> $OUTDIR/TotalCounts_Alignment; grep "too many mismatches" "$i"\
 >> $OUTDIR/TotalCounts_Alignment; grep "too short" "$i" >> $OUTDIR/TotalCounts_Alignment;\
 grep "other" "$i" >> $OUTDIR/TotalCounts_Alignment; done


#=================#
#   MultiQC       #
#=================#

# Copy **Log.final.out to QC folder
#cp $PROJECT/Analysis/ReadMapping/BAM_Files/${folder}/*Log.final.out $QC/STAR
ln -s $PROJECT/Analysis/ReadMapping/BAM_Files/${folder}/*Log.final.out $QC/STAR # create hyperlink
#cp $PROJECT/Analysis/ReadMapping/BAM_Files/${folder}/*RNA_Metrics $QC/STAR
ln -s $PROJECT/Analysis/ReadMapping/BAM_Files/${folder}/*RNA_Metrics $QC/STAR # create hyperlink

cd $QC
multiqc . -f -o $QC/multiQC # run multiqc for all files (.) in the QC directory

#=================================#
# Create ReadMapping QC table     #
#=================================#
#LANES=1
#ReadMapping=$DIR/Analysis/ReadMapping
#starDir=$DIR/Analysis/ReadMapping/BAM_Files/${BATCH}
#rnametricsDir=$starDir

#Rscript $DIR/Analysis/ReadMapping/ReadMappingQC.R $ReadMapping $LANES $starDir $rnametricsDir

#====================================#
# Add new RUN metrics to BATCH excel #
#====================================#

#Rscript $DIR/QC/excelQC_addRUNtoBATCH.R ${DIR}/QC/${BATCH} $BATCH $RUN
