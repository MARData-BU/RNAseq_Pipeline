#!/bin/bash
#SBATCH -p normal,short         # Partition to submit to
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu 7Gb     # Memory in MB
#SBATCH -J NGS_sum           # job name
#SBATCH -o logs/NGS_sum.%J.out    # File to which standard out will be written
#SBATCH -e logs/NGS_sum.%J.err    # File to which standard err will be written

# Read input
FUNCTIONSDIR=$1
PROJECT=$2
WD=$3
batch=$4

#=================================#
# Create NGS_Summary table        #
#=================================#
cd $WD

module load R/4.1.2-foss-2020b
Rscript $FUNCTIONSDIR/NGS_summary.R $PROJECT $batch
