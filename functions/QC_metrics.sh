#!/bin/bash
#SBATCH -p short,normal            # Partition to submit to
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu 6Gb     # Memory in MB
#SBATCH -J QC_metrics          # job name
#SBATCH -o logs/QC_metrics.%j.out    # File to which standard out will be written
#SBATCH -e logs/QC_metrics.%j.err    # File to which standard err will be written

# QC Analysis of RNASeq samples of project:

# Prepare variables
#------------------
PROJECT=$1
END=$2
LANES=$3
RUNSUFFIX=$4
FUNCTIONSDIR=$5

QC=${PROJECT}/QC

# Load modules
#------------------
module load Python/3.8.6-GCCcore-10.2.0 # el més actualitzat
module load R/4.0.4-foss-2020b
echo -e "Python and R modules loaded."
# Prepare folders
#------------------
mkdir $QC/multiQC

# Move to QC folder
cd $QC
echo -e "Moving path to $QC.\n"
#------------------

#=================#
#   MultiQC       #
#=================#
multiqc . -f -o $QC/multiQC

#=================================#
# Create table 4 QC presentation  #
#=================================#

if [ $END == SINGLE ]
    then 
    R=1 # single-end
    elif [ $END == PAIRED ]
        then
        R=2 # paired-end
fi

Rscript $FUNCTIONSDIR/table4QCpresentation.R $QC $LANES $R $RUNSUFFIX # QC dir, numer of lanes, paired end, color for duplications


#====================================#
# Add new RUN metrics to BATCH excel #
#====================================#

# No aplica ja que no hi ha batches en aquest cas

# RUN=/
# Rscript $DIR/QC/${BATCH}/excelQC_addRUNtoBATCH.R ${DIR}/QC/${BATCH} $BATCH $RUN
