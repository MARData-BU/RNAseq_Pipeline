#!/bin/bash
#SBATCH -p long   # Partition to submit to
#SBATCH --cpus-per-task=10	#change to 5 if no rush or cluster is full
#SBATCH --mem-per-cpu 9Gb      # Memory in MB
#SBATCH -J STAR                # job name
#SBATCH -o logs/STAR.%A_%a.out    		# Sdt out file name: %j SLURM_JOB_ID; %A SLURM_ARRAY_JOB_ID, %a SLURM_ARRAY_TASK_ID
#SBATCH -e logs/STAR.%A_%a.err    		# Sdt err file name: %j SLURM_JOB_ID; %A SLURM_ARRAY_JOB_ID, %a SLURM_ARRAY_TASK_ID

module load STAR/2.7.8a-GCC-10.2.0
echo -e "STAR module loaded.\n"

#------------------------
# Prapare folders

PROJECT=$1
folder=$2
RUNSUFFIX=$3
FASTQDIR=$4
STAR_GTF=$5
STAR_FLAT=$6
STAR_RIBO=$7
STAR_DIR=$8
END=$9

echo -e "Project directory has been defined as $PROJECT.\n"
echo -e "Batch has been defined as $folder.\n"
echo -e "Fastq directory has been defined as $FASTQDIR. \n"
echo -e "RNAseq end is $END.\n"
echo -e "Star GTF file has been defined as $STAR_GTF. \n"
echo -e "Star flat file has been defined as $STAR_FLAT. \n"
echo -e "Star ribo file has been defined as $STAR_RIBO. \n"
echo -e "Star directory file has been defined as $STAR_DIR. \n"

mkdir -p $PROJECT/Analysis/ReadMapping/BAM_Files/${folder}

if [ $END == SINGLE ]
  then
	R1=$RUNSUFFIX

	echo "RUN suffix will be considered as ${R1}."
  elif [ $END == PAIRED ]
	then
	R1=$RUNSUFFIX

	if [[ $R1 == *R1* ]]
		then
		R2=`echo $RUNSUFFIX | sed "s/R1/R2/"` # this replaces R1 for R2 from the R1 variable
		echo "RUN1 suffix will be considered as ${R1} and RUN2 as ${R2} for this analysis."
	elif [[ $R1 == *read1* ]]
		then
		R2=`echo $RUNSUFFIX | sed "s/read1/read2/"` # this replaces read1 for read2 from the R1 variable
		echo "RUN1 suffix will be considered as ${R1} and RUN2 as ${R2} for this analysis."
	else
		R2=`echo $RUNSUFFIX | sed "s/1/2/"` # this replaces read1 for read2 from the R1 variable
		echo "RUN1 suffix will be considered as ${R1} and RUN2 as ${R2} for this analysis."
	fi
fi


######################################################################################################
##################################### ALIGNMENT ######################################################

	# Prapare input files
	OUTDIR=$PROJECT/Analysis/ReadMapping/BAM_Files/${folder}

	FASTQFILES=($(ls -1 $FASTQDIR/${folder}/*${RUNSUFFIX} | sed "s/$RUNSUFFIX//"))
	i=$(($SLURM_ARRAY_TASK_ID - 1)) # bash arrays are 0-based
	INFILE=${FASTQFILES[i]}
	name=`basename $INFILE`

	echo "Sample $name is being processed."

	if [ $END == SINGLE ]
	then

		echo "Running STAR..."
		STAR --runThreadN $SLURM_CPUS_PER_TASK\
		--genomeDir $STAR_DIR --readFilesIn $INFILE$R1 --readFilesCommand zcat --outFileNamePrefix\
		$OUTDIR/${name} --outSAMattributes All --outSAMtype BAM SortedByCoordinate --outFilterType BySJout\
		--outFilterMultimapNmax 20 --alignSJoverhangMin 8 --alignSJDBoverhangMin 1 --outFilterMismatchNmax 999\
		--outFilterMismatchNoverLmax 0.05 --alignIntronMin 20 --alignIntronMax 1000000 --alignMatesGapMax 1000000\
		--sjdbGTFfile $STAR_GTF
		echo "STAR run successfully!"

	else

		echo "Running STAR..."
		STAR --runThreadN $SLURM_CPUS_PER_TASK\
		--genomeDir $STAR_DIR --readFilesIn $INFILE$R1 $INFILE$R2 --readFilesCommand zcat --outFileNamePrefix\
		$OUTDIR/${name} --outSAMattributes All --outSAMtype BAM SortedByCoordinate --outFilterType BySJout\
		--outFilterMultimapNmax 20 --alignSJoverhangMin 8 --alignSJDBoverhangMin 1 --outFilterMismatchNmax 999\
		--outFilterMismatchNoverLmax 0.05 --alignIntronMin 20 --alignIntronMax 1000000 --alignMatesGapMax 1000000\
		--sjdbGTFfile $STAR_GTF
		echo "STAR run successfully!"
	fi


######################################################################################################
##################################### Create index (.bai)#############################################

module purge
module load SAMtools/1.12-GCC-10.2.0
echo -e "SAMtools module loaded.\n"

	OUTDIR=$PROJECT/Analysis/ReadMapping/BAM_Files/${folder}

	FASTQFILES=($(ls -1 $FASTQDIR/${folder}/*${RUNSUFFIX} | sed "s/$RUNSUFFIX//"))
	i=$(($SLURM_ARRAY_TASK_ID - 1)) ## bash arrays are 0-based
	INFILE=${FASTQFILES[i]}
	name=`basename $INFILE`

	echo "Creating index..."
	samtools index ${OUTDIR}/${name}Aligned.sortedByCoord.out.bam ${OUTDIR}/${name}Aligned.sortedByCoord.out.bai
	echo "Index created successfully!"


######################################################################################################
##################################### RNA METRICS ########################################################

module purge  ## Why? Clear out .bashrc /.bash_profile settings that might interfere
module load picard/2.25.1-Java-11
echo -e "Picard module loaded.\n"

	OUTDIR=$PROJECT/Analysis/ReadMapping/BAM_Files/${folder}

	FASTQFILES=($(ls -1 $FASTQDIR/${folder}/*${RUNSUFFIX} | sed "s/$RUNSUFFIX//"))
	i=$(($SLURM_ARRAY_TASK_ID - 1)) ## bash arrays are 0-based
	INFILE=${FASTQFILES[i]}
	name=`basename $INFILE`

	echo "Computing RNA metrics..."
	java -jar $EBROOTPICARD/picard.jar CollectRnaSeqMetrics \
		I=${OUTDIR}/${name}Aligned.sortedByCoord.out.bam \
		REF_FLAT=$STAR_FLAT\
			RIBOSOMAL_INTERVALS=$STAR_RIBO \
			STRAND=SECOND_READ_TRANSCRIPTION_STRAND \
		O=${OUTDIR}/${name}.RNA_Metrics
	echo "RNA metrics computed successfully!"
