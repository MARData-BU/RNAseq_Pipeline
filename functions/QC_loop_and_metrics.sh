#!/bin/bash
#SBATCH -p short,normal           # Partition to submit to
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu 12Gb     # Memory in MB
#SBATCH -J QC_loop           # job name
#SBATCH -o logs/QC_loop.%j.out    # File to which standard out will be written
#SBATCH -e logs/QC_loop.%j.err    # File to which standard err will be written

# Carregar variables amb el readme!!

# QC Analysis of RNASeq samples of project:

# Prepare variables
#------------------

PROJECT=$1
FASTQDIR=$2
FUNCTIONSDIR=$3
folder=$4
FASTQSCREEN_CONFIG=$5
FASTQ_SUFFIX=$6
END=$7
LANES=$8
RUNSUFFIX=$9

echo -e "Project directory has been defined as $PROJECT. \n"
echo -e "Fastq directory has been defined as $FASTQDIR. \n"
echo -e "Functions directory has been defined as $FUNCTIONSDIR. \n"
echo -e "Batch has been defined as $folder.\n"
echo -e "Fastqscreen config file has been defined as $FASTQSCREEN_CONFIG. \n"
echo -e "Fastq suffix has been defined as $FASTQ_SUFFIX. \n"


mkdir -p $PROJECT/QC
mkdir -p $PROJECT/QC/logs
cd "$PROJECT/QC"

#============#
#   FASTQC   #
#============#
echo -e "Creating QC and FastQC directories...\n"
mkdir -p $PROJECT/QC/${folder}/FastQC

echo -e "Directories created.\n"

FASTQC=$(sbatch --array=1-$(ls -l $FASTQDIR/${folder}/*$FASTQ_SUFFIX | wc -l) --parsable $FUNCTIONSDIR/fastqc.sh $PROJECT $folder $FASTQDIR $FASTQ_SUFFIX)
echo -e "Fastqc scripts sent to the cluster.\n"

#=================#
#   FASTQSCREEN   #
#=================#
echo -e "Creating FastqScreen directory...\n"
mkdir -p $PROJECT/QC/${folder}/FastqScreen

echo -e "Directory created.\n"

FASTQSCREEN=$(sbatch --array=1-$(ls -l $FASTQDIR/${folder}/*$FASTQ_SUFFIX | wc -l) --dependency=afterok:${FASTQC} --parsable $FUNCTIONSDIR/fastq_screen.sh $PROJECT $folder $FASTQDIR $FUNCTIONSDIR $FASTQSCREEN_CONFIG $FASTQ_SUFFIX)
echo -e "Scripts sent. They will be launched once FastQC scripts have finished.\n"

#==================#
#   Waiting loop   #
#==================#

check_jobs() {
    # Check if the output of squeue is empty
    if [[ -z $(squeue -h -j ${FASTQC},${FASTQSCREEN}) ]]; then
        # If it is empty, return a failure (non-zero)
        return 1
    else
        # If it is not empty, return a success (zero)
        return 0
    fi
}

echo -e "Entering wait loop to monitor jobs.\n"
while check_jobs; do
    echo -e "Jobs are still running. Sleeping for 100 seconds...\n"
    sleep 100
done

echo -e "All jobs have finished.\n"
