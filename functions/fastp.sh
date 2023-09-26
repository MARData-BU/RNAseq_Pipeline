#!/bin/bash
#SBATCH -p long,short,normal            # Partition to submit to
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu 10Gb     # Memory in MB
#SBATCH -J fastp           # job name
#SBATCH -o logs/fastp.%j.out    # File to which standard out will be written
#SBATCH -e logs/fastp.%j.err    # File to which standard err will be written

#-------------------------------

module purge  ## Why? Clear out .bashrc /.bash_profile settings that might interfere
module load fastp/201909


fastq=$1
outdir=$2
suffix=$3
name=`basename $fastq`

R1=$suffix
R2=`echo $suffix | sed "s/_R1_/_R2_/"`

#-------------------------------



fastp --thread $SLURM_CPUS_PER_TASK -i $fastq$R1 -I $fastq$R2 \
	-o ${outdir}/${name}${R1} -O ${outdir}/${name}${R2} \
	--html ${outdir}/${name}.fastp.html \
	--json ${outdir}/${name}.fastp.json


