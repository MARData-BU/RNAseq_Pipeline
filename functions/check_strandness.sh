#!/bin/bash
#SBATCH -p short       # Partition to submit to
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu 7Gb     # Memory in MB
#SBATCH -J strandness           # job name
#SBATCH -o logs/strandness.%J.out    # File to which standard out will be written
#SBATCH -e logs/strandness.%J.err    # File to which standard err will be written

## This script checks the strandedness of a bam file using RSeQC program
## Done by Marta E. Camarena
## 16th January 2024

BAMDIR=$1
FUNCTIONSDIR=$2
PROJECT=$3
folder=$4
OUTDIR=$PROJECT/Analysis/Quantification/Strandness_check/${folder}
annotation=$5

echo -e "The bam directory is $BAMDIR."
echo -e "The functions directory is $FUNCTIONSDIR."
echo -e "The output directory is $OUTDIR."


BAMFILES=($(ls -1 $BAMDIR/*.bam))
i=$(($SLURM_ARRAY_TASK_ID - 1)) # bash arrays are 0-based
INFILE=${BAMFILES[i]}

echo -e "The bam file being analysed is $INFILE."

sample_name=$(basename "$INFILE" | sed 's/Aligned.sortedByCoord.out.bam//') # retrieve the sample name; remove the path and the "Aligned.sortedByCoord.out.bam"
dir_path=$(dirname "$INFILE")
log_final_out="${dir_path}/${sample_name}Log.final.out"

# annotation=$5

###################### get num of uniquely aligned reads #######################
uniq_mapped_reads=$(sed '9q;d' $log_final_out | awk '{print $6}')

############################## RSEQC ###########################################
module load Miniconda3/4.9.2

infer_experiment.py -r $annotation -i $INFILE -s $uniq_mapped_reads > $OUTDIR/${sample_name}.out

# IF 1++,1--,2+-,2-+" get more signal (Value) then its fr-secondstrand
# and if 1+-,1-+,2++,2-- get more signal (Value) then its fr-firststrand

# This would be REVERSELY STRANDED

# This is PairEnd Data
# Fraction of reads failed to determine: 0.1082
# Fraction of reads explained by "1++,1--,2+-,2-+": 0.0118
# Fraction of reads explained by "1+-,1-+,2++,2--": 0.8800

# Interpret data

#python $FUNCTIONSDIR/strandedness_output.py -tab $OUTDIR/${sample_name}.out -tool featureCounts
#python $FUNCTIONSDIR/strandedness_output.py -tab $OUTDIR/${sample_name}.out -tool stringtie
#python $FUNCTIONSDIR/strandedness_output.py -tab $OUTDIR/${sample_name}.out -tool trinity


