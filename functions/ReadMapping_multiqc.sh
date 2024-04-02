#!/bin/bash
#SBATCH -p normal,short            # Partition to submit to
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu 6Gb     # Memory in MB
#SBATCH -J ReadMapping_multiqc          # job name
#SBATCH -o logs/ReadMapping_multiqc.%j.out    # File to which standard out will be written
#SBATCH -e logs/ReadMapping_multiqc.%j.err    # File to which standard err will be written

# QC Analysis of RNASeq samples of project:

folder=$1
PROJECT=$2

echo -e "Batch has been defined as $folder \n"
echo -e "Project directory has been defined as $PROJECT \n"

mikdir -p $PROJECT/QC/multiQC/${folder}

#=============#
#   MultiQC   #
#=============#
# Copy CountsTable.txt.summary to multiqc folder
echo -e "Copying CountsTable.txt.summary to multiqc folder...\n"
#cp $PROJECT/Analysis/Quantification/CountFiles/${folder}/CountsTable.txt.summary $PROJECT/QC/multiQC/
ln -s $PROJECT/Analysis/Quantification/CountFiles/${folder}/CountsTable.txt.summary $PROJECT/QC/multiQC/${folder} # create hyperlink
echo -e "File copied!\n"

cd $PROJECT/QC
module load Python/3.8.6-GCCcore-10.2.0 # més actualitzat a dia 31/Jan/2023

echo -e "Running multiqc...\n"
multiqc . -o $PROJECT/QC/multiQC/${folder} -f
echo -e "Process performed!\n"

