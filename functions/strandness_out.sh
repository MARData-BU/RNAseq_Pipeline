#!/bin/bash
#SBATCH -p short            # Partition to submit to
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu 8Gb     # Memory in MB
#SBATCH -J strand_out           # job name
#SBATCH -o logs/strand_out.%J.out    # File to which standard out will be written
#SBATCH -e logs/strand_out.%J.err    # File to which standard err will be written

module load R/4.2.1-foss-2020b
PROJECT=$1
WD=$2
folder=$3
FUNCTIONSDIR=$4

echo -e "Project directory is $PROJECT"
echo -e "WD is $WD"
echo -e "Batch is $folder"

OUTDIR=$PROJECT/Analysis/Quantification/Strandness_check/${folder}

echo -e "Output directory is $OUTDIR"

cd $WD

Rscript $FUNCTIONSDIR/retrieve_strandness_result.R $OUTDIR
