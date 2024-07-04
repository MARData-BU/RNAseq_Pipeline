#!/bin/bash
#SBATCH -p normal,short       # Partition to submit to
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu 7Gb     # Memory in MB
#SBATCH -J RNASeq           # job name
#SBATCH -o logs/RNASeq.%J.out    # File to which standard out will be written
#SBATCH -e logs/RNASeq.%J.err    # File to which standard err will be written

echo -e "
##########################################################
# PLEASE READ THE BELOW TEXT BEFORE RUNNING THE PIPELINE #
##########################################################

In order to run this RNAseq pipeline, please fill in the config_input_files.txt file. The primary script is this file 'test_pipeline_structure.sh', from which other scripts are called and sent to the cluster.

Be aware that the following modules/packages will need to be installed in your computer for the pipeline to run:
  - bash: STAR (2.7.8a-GCC-10.2.0), SAMtools (1.12-GCC-10.2.0), picard (2.25.1-Java-11), FastQC (0.11.7-Java-1.8.0_162), FastQ-Screen (0.14.1), Bowtie2 (2.4.2-GCC-10.2.0), Python (3.8.6-GCCcore-10.2.0), R (4.0.4-foss-2020b) and Subread (2.0.3).
  - R: openxlsx and stringr.

Please do note that the 'config_input_files.txt' file must be fulfilled leaving an **empty space** between the colon (:) and the input text (e.g: project_directory: /bicoh/MARGenomics/Development/RNASeq/TEST).
Any other version of inputing data (such as project_directory:/bicoh/MARGenomics...) will NOT work for the pipeline.

  ################
  STEPS TO PERFORM
  ################
  - merge: whether you require to merge your data before processing (e.g: for >1 lane) (TRUE/FALSE).
  - quality: whether to compute the quality check(TRUE/FALSE).
  - alignment: whether to compute the alignment (TRUE/FALSE).
  - quantification: whether to compute the quantification (TRUE/FALSE).

  ##################
  GENERAL PARAMETERS
  ##################
  - project_directory: full path for the project directory (e.g:/bicoh/MARGenomics/20230626_MFito_smallRNAseq). Do not include the batch name/folder, if any.
  - project_analysis: full path for the project analysis directory (e.g: directory/bicoh/MARGenomics/20230626_MFito_smallRNAseq/Analysis). Do not include the batch name/folder, if any.
  - functions: full path for the pipeline functions directory.
  - fastq_directory: path for the FASTQ files (e.g: /bicoh/MARGenomics/20230626_MFito_smallRNAseq/rawData). If there are batches, do NOT add them in this path, as the pipeline will automatically
  run through the batch folders if defined correctly.
  - batch_num: total number of batches.
  - bat_folder: batch name (only if batch_num is 1; e.g: FITOMON_01) or else batch prefix (only if batch_num >1; e.g: FITOMON_0). In this second case (batch_num > 1), the pipeline will assume that the batch folders
  are the batch_folder variable pasted with 1:batch_num (e.g: if batch_num is 3 and bat_folder is FITOMON_0, the batch folders will be considered as FITOMON_01, FITOMON_02 and FITOMON_03). If you have only one batch
  and they are not stored in any folder rather than within the fastq_directory, please leave this variable as 'NA', 'FALSE' or '/'.
  - lanes: number of lanes (1, 2, 3...) AFTER the merge. Only used for the generation of the table4QCpresentation.xlsx. If lanes are merged or else the data has NO lanes, this parameter must be 1. 

  ################
  MERGE PARAMETERS
  ################
  - sample_sheet: path to the sample_sheet.xlsx file. Please copy this file from the GitHub repository or else create an Excel with the same column names as the Excel provided. 
  - total_output_files: total output files that will be generated after the merge. It must correspond to the number of rows in the sample_sheet.xlsx file.

  ###################
  ALIGNMENT VARIABLES
  ###################
  - STAR_reference_genome_GTF: gtf file for STAR reference genome (e.g: /bicoh/MARGenomics/AnalysisFiles/Annot_files_GTF/Human/gencode.v41.primary_assembly.annotation.gtf).
  - STAR_reference_genome_FLAT: flat file for STAR reference genome (e.g: /bicoh/MARGenomics/AnalysisFiles/Annot_files_GTF/Human/gencode.v41.flatFile).
  - STAR_reference_genome_RIBOSOMAL_INTERVALS: ribosomal interval list file for the STAR reference genome (e.g: /bicoh/MARGenomics/AnalysisFiles/Annot_files_GTF/Human/gencode.v41.ribosomal.interval_list).
  - STAR_genome_dir: STAR referenge genome directory (e.g: /bicoh/MARGenomics/AnalysisFiles/Annot_files_GTF/Human).
  - run1_suffix: suffix for your R1 samples (e.g: _R1_001.fastq.gz), or else for your samples when the experiment is single-end (e.g: .fastq.gz).
  - paired_end: whether your data has single-end (FALSE) or paired-end (TRUE).

  ########################
  QUANTIFICATION VARIABLES
  ########################
  - Strandness will be automatically set by the pipeline.
  - fastqscreen_config: fastQScreen configuration (e.g: /bicoh/MARGenomics/AnalysisFiles/Index_Genomes_Bowtie2/fastq_screen.conf).


Also please consider the following points when populating the config_input_files.txt and before running the pipeline:
  -Note that if there is only one run (R1), you need to specify the variable -paired_end- as FALSE. Otherwise the pipeline will considered two runs (R1 and R2).
  -If your data contains ONLY 1 batch, please populate the parameter -batch_num- with 1. If your data is stored within a folder named after this unique batch, please
  define the variable -batch_folder- accordingly. If your data is NOT stored within any batch folder, please set the variable -batch_folder- as 'NA', 'FALSE' or '/'. Any
  other definitions of the variable -batch_folder- will be considered as a name for the folder in which batch data is stored.
  -If your data contains more than 1 batch, please consider the following:
      - The parameter -batch_num- refers to the number of batches your data has.
      - The parameter -batch_folder- refers to the PREFIX of your batch folders. This pipeline will consider the prefix and then add the numbers from 1 to batch_num as batch folder names
      (e.g: if -batch_num- is set to 3 and -batch_folder- to 'BATCH_0', the batch folders through which the pipeline will iterate will be 'BATCH_01', 'BATCH_02' and 'BATCH_03').
  -Please read and check the SET PARAMETERS section once you have launched the pipeline in the logs.out file to ensure that all your parameters have been set correctly. This logs.out document
  will be stored within a logs folder generated in the -project_analysis- path.

##################################################################
# PLEASE READ THE BELOW TEXT IF YOU REQUIRE TO MERGE FASTQ FILES #
##################################################################

If MERGE is set to TRUE (if fastq files have to be merged), please note that the Excel file 'sample_sheet.xlsx' must be populated. Please consider the following when doing so:
  - The -total_output_files- variable in the 'config_input_files.txt' must correspond to the total number of files that are to be generated (number of rows in the 'sample_sheet.xlsx').
  - RUNSUFFIX (run1_suffix) in the 'config_input_files.txt' must be defined accordingly to the output file names that the merge will create. Other options will make the pipeline fail.
  - The Excel file 'sample_sheet.xlsx' must be populated with
      - (1) the paths and names of the fastq.gz files and
      - (2) the paths and names in which merged files will be stored. If there are >1 batches and merged files are to be stored in different folders, please consider so when populating the path.
      Also please consider this when populating the variables -batch_num- and -batch_folder- from the 'config_input_files.txt'; if merged data is stored in different folderes according to the batch,
      variables -batch_num- and -batch_folder- must be filled accordingly. The number of batches must correspond to the number of batch folders that are generated AFTER the merge.
      - It is possible to leave empty cells within a row, and also to add new columns, but note that the output path/name must ALWAYS be the last populated column of the spreadsheet, that it
      must be the same column for all rows even though empty spaces are left in some (but not all) rows, and that it must be named 'Output_name'.
      - Column names can be modified with the exception of 'Output_name' column (which MUST be the last column). Please, do NOT modify the name of this column or else the pipeline will not run.
      - Please save the merged files in a different folder than the non-merged files. The pipeline will analyze any file with the prefix defined as run1_suffix, so unless merged and unmerged files
      are stored separately, the pipeline will analyze all of them."

####################################################################################################################################################
#                                                                                                                                                  #
#                                                       -TO BE RUN IN THE COMMAND LINE-                                                            #
# After fulfilling the file 'config_input_files.txt' and 'sample_sheet.xlsx' (if needed), please run the following command in the bash terminal:   #
#                                                                                                                                                  #
# cd DIR (the directory in which your logs output will be stored; usually your Analysis directory within the Project foldery, but bear in mind     #
# that a logs folder must be there!)                                                                                                                #
# INPUT=/bicoh/MARGenomics/Pipelines/RNASeq/config_inputs_files.txt (please modify the directory to where the onfig_inputs_files.txt is located) #
# sbatch /bicoh/MARGenomics/Pipelines/RNASeq/test_pipeline_structure.sh $INPUT                                                                                                         #
#                                                                                                                                                  #
####################################################################################################################################################

PARAMS=$1 #

# Steps to perform
MERGE=$(grep merge: $PARAMS | awk '{ print$2 }')
QC=$(grep QC: $PARAMS | awk '{ print$2 }')
ALIGNMENT=$(grep alignment: $PARAMS | awk '{ print$2 }')
QUANTIFICATION=$(grep quantification: $PARAMS | awk '{ print$2 }')

# General parameters
PROJECT=$(grep project_directory: $PARAMS | awk '{ print$2 }')
WD=$(grep project_analysis: $PARAMS | awk '{ print$2 }')
FUNCTIONSDIR=$(grep functions: $PARAMS | awk '{ print$2 }')
FASTQDIR=$(grep fastq_directory: $PARAMS | awk '{ print$2 }')
BATCH=$(grep batch_num: $PARAMS | awk '{ print$2 }')
BATCH_FOLDER=$(grep batch_folder: $PARAMS | awk '{ print$2 }')
LANES=$(grep lanes: $PARAMS | awk '{ print$2 }')

# Merge parameters
TOTAL_OUT=$(grep total_output_files: $PARAMS | awk '{ print$2 }')
SAMPLE_SHEET=$(grep sample_sheet: $PARAMS | awk '{ print$2 }')

# Alignment parameters
STAR_GTF=$(grep STAR_reference_genome_GTF: $PARAMS | awk '{ print$2 }')
STAR_FLAT=$(grep STAR_reference_genome_FLAT: $PARAMS | awk '{ print$2 }')
STAR_RIBO=$(grep STAR_reference_genome_RIBOSOMAL_INTERVALS: $PARAMS | awk '{ print$2 }')
STAR_DIR=$(grep STAR_genome_dir: $PARAMS | awk '{ print$2 }')
RUNSUFFIX=$(grep run1_suffix: $PARAMS | awk '{ print$2 }')
PAIRED=$(grep paired_end: $PARAMS | awk '{ print$2 }')

# Quantification parameters
FASTQSCREEN_CONFIG=$(grep fastqscreen_config: $PARAMS | awk '{ print$2 }')

mkdir $WD/logs
cd $WD

#if [ $(ls /bicoh/MARGenomics/Development/RNASeq/logs | wc -l) -gt 0 ]
#  then
#  rm /bicoh/MARGenomics/Development/RNASeq/logs/* # remove all previous files in logs (if any)
#  echo "Pipeline logs removed"
#fi

#if [ $(ls $FUNCTIONSDIR/logs | wc -l) -gt 0 ]
#  then
#  rm $FUNCTIONSDIR/logs/* # remove all previous files in logs (if any)
#  echo "Function logs removed"
#fi

echo -e "
######################################################
#############                            #############
#############       SET PARAMETERS       #############
#############                            #############
######################################################
"
echo -e "Please read the below text to ensure that the parameters inputed to the config_input_files.txt are correct. \n"
echo -e "According to the set up, the steps to perform are:\n"
if [ $MERGE == TRUE ]
  then
    echo -e "-Merge Fastq files.\n"
fi

if [ $QC == TRUE ]
then
  echo -e "-QC.\n"
fi

if [ $ALIGNMENT == TRUE ]
then
  echo -e "-Alignment (STAR) and summary metrics (picard).\n"
fi

if [ $QUANTIFICATION == TRUE ]
then
  echo -e "-Quantification.\n"
fi

echo -e "The general parameters are the following. Please check them to ensure that all parameters are correct:\n"
echo "-Project directory is: $PROJECT."
echo "-The working directory is: $WD. This is the location where the function logs will be stored."
echo "-Functions directory is: $FUNCTIONSDIR. Please note that all called functions must be within this directory."
echo "-Fastq directory is: $FASTQDIR. If MERGE has been set as TRUE, please note that the fastq directory must correspond to the directory where the merged files will be stored."
echo "-The number of batches is: $BATCH."

# If batch number is greater than 1, define the batch folders by merging the batch prefix with the number of batches
if [ $BATCH -gt 1 ]; then
  folders=()
  for ((n=1; n<=$BATCH; n++)); do
    folder="${BATCH_FOLDER}${n}"
    folders+=("$folder")
  done

  echo "- The batch prefix is: $BATCH_FOLDER, and the batch folders are:"
  for folder in "${folders[@]}"; do
    echo "  - $folder"
    # Use the folder variable as needed
  done

elif [ $BATCH -eq 1 ]; then
  folders=()
  if [ "$BATCH_FOLDER" == "NA" ] || [ "$BATCH_FOLDER" == "FALSE" ]; then
    folders+=("/")
  else
    folders+=("$BATCH_FOLDER")
  fi

else
  echo "Invalid BATCH value: $BATCH"
fi


if [ $MERGE == TRUE ]
  then
  echo "-The sample sheet is $SAMPLE_SHEET (only used is MERGE has been defined as TRUE)"
  echo "-The total output files to be generated with the merge is: $TOTAL_OUT"
fi

if [ $PAIRED == TRUE ]
  then
    END=PAIRED
    echo "RNA end has been defined as $END END."
    elif [ $PAIRED == FALSE ]
  then
    END=SINGLE

else
  echo -e "RNA end has been defined as $END END."
fi

if [ "$ALIGNMENT" == "TRUE" ]; then
  echo -e "\nFor the alignment, the parameters set are:\n"
  echo "- The STAR GTF file is: $STAR_GTF."
  echo "- The STAR FLAT file is: $STAR_FLAT."
  echo "- The STAR RIBO file is: $STAR_RIBO."
  echo "- The STAR directory is: $STAR_DIR."

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

fi

echo -e "\n The FastQScreen config path is $FASTQSCREEN_CONFIG."


######################################################
#############                            #############
#############        MERGE FILES         #############
#############                            #############
######################################################

if [ $MERGE == TRUE ]
then
    echo -e "
    ######################################################
    #############                            #############
    #############        MERGE FILES         #############
    #############                            #############
    ######################################################
    "
    echo -e "\n\nCreating the fastq directory where the merged files will be stored..."
    mkdir -p $FASTQDIR
    echo -e "\n\nCreating the script to concatenate the FASTQ files...\n\n"

    sbatch $FUNCTIONSDIR/create_merge_file.sh $FUNCTIONSDIR $SAMPLE_SHEET $WD

    until [ -f $WD/merge_to_run.sh ] # we need the merge_to_run.sh created in order to keep running the script. Otherwise, scripts won't be able to keep working.
    do
        sleep 10 # wait 5 seconds
    done

    echo "File found"

    echo -e "\n\nMerging FASTQ files...\n\n"

    sbatch --dependency=$(squeue --noheader --format %i --name create_merge_file) $WD/merge_to_run.sh

    echo -e "\n\nCompressing FASTQ files...\n\n"

    if ls $FASTQDIR/*.fastq >/dev/null 2>&1 # check whether there is any .fastq file
    then
        count=`ls -l $FASTQDIR/*.fastq | wc -l`
        echo $(ls -l $FASTQDIR)
        while [ $count != $TOTAL_OUT ] # check whether ALL the files corresponding to every sample are created or not
        do
          sleep 100 # wait if not
          count=`ls -l $FASTQDIR/*.fastq | wc -l` # check again
          echo "The number of fastq files is $count"
          echo $(ls -l $FASTQDIR)
      done
    else
        sleep 300 # if there is no fastq file, sleep for 300 seconds so some fastq file will be generated
        count=`ls -l $FASTQDIR/*.fastq | wc -l`
        echo $(ls -l $FASTQDIR)
        while [ $count != $TOTAL_OUT ] # check whether ALL the files corresponding to every sample are created or not
        do
          sleep 100 # wait if not
          count=`ls -l $FASTQDIR/*.fastq | wc -l` # check again
          echo "The number of fastq files is $count and it should be $TOTAL_OUT"
          echo $(ls -l $FASTQDIR)
      done
    fi

    echo "All done, there are a total of $count fastq files and it should be $TOTAL_OUT"

    sleep 300

    gzip $FASTQDIR/*.fastq

    count=`ls -l $FASTQDIR/*.fastq.gz | wc -l` # check again
    echo "The number of fastq.gz files is $count."

    while [ $count != $TOTAL_OUT ] # check whether ALL the files have been compressed
    do
        gzip $FASTQDIR/*.fastq
        count=`ls -l $FASTQDIR/*.fastq.gz | wc -l` # check again
          echo "The number of fastq files is $count and it should be $TOTAL_OUT"
    done


    echo -e "\n\nFastQ Files compressed\n\n"
fi

######################################################
#############                            #############
#############             QC             #############
#############                            #############
######################################################

echo -e "
######################################################
#############                            #############
#############             QC             #############
#############                            #############
######################################################
"

if [ "$QC" == "TRUE" ]; then
  if [ "$END" == "SINGLE" ]; then
    echo -e "This is a single-end experiment. RUN1 will be considered as ${R1}. If this is not the case for your data, please check code and inputs file."

    for folder in "${folders[@]}"; do
      echo -e "\n\nPerforming QC analysis for batch $folder.\n\n"
      # FASTQC and  FASTQSCREEN
      echo -e "\n\nLaunching QC loop...\n\n"
      QC_loop_job=$(sbatch --parsable "$FUNCTIONSDIR/QC_loop_and_metrics.sh" "$PROJECT" "$FASTQDIR" "$FUNCTIONSDIR" "$folder" "$FASTQSCREEN_CONFIG" "$R1" "$END" "$LANES" "$RUNSUFFIX")
      echo -e "\n\nQC jobs sent to the cluster.\n\n"
      sbatch --dependency=afterok:${QC_loop_job} $FUNCTIONSDIR/QC_metrics.sh "$PROJECT" "$END" "$LANES" "$RUNSUFFIX" "$FUNCTIONSDIR" "$folder"
    done

  elif [ "$END" == "PAIRED" ]; then
    echo -e "This is a paired-end experiment. RUN1 will be considered as ${R1} and RUN2 as ${R2}. If this is not the case for your data, please check code and inputs file.\n"

    for folder in "${folders[@]}"; do
      echo -e "\n\nPerforming QC analysis for batch $folder.\n\n"
      # FASTQC and  FASTQSCREEN
      echo -e "\n\nLaunching QC loop for R1 samples...\n\n"
      QC_loop_job_R1=$(sbatch --parsable "$FUNCTIONSDIR/QC_loop_and_metrics.sh" "$PROJECT" "$FASTQDIR" "$FUNCTIONSDIR" "$folder" "$FASTQSCREEN_CONFIG" "$R1" "$END" "$LANES" "$RUNSUFFIX")
      echo -e "\n\nLaunching QC loop for R2 samples...\n\n"
      QC_loop_job_R2=$(sbatch --parsable "$FUNCTIONSDIR/QC_loop_and_metrics.sh" "$PROJECT" "$FASTQDIR" "$FUNCTIONSDIR" "$folder" "$FASTQSCREEN_CONFIG" "$R2" "$END" "$LANES" "$RUNSUFFIX")
      echo -e "\n\nQC jobs sent to the cluster.\n\n"
      sbatch --dependency=afterok:${QC_loop_job_R1},${QC_loop_job_R2} $FUNCTIONSDIR/QC_metrics.sh "$PROJECT" "$END" "$LANES" "$RUNSUFFIX" "$FUNCTIONSDIR" "$folder"
    done

  fi

else
  echo -e "\n\nQC will not be performed.\n\n"
fi


######################################################
#############                            #############
#############         ALIGNMENT          #############
#############                            #############
######################################################

echo -e "
######################################################
#############                            #############
#############         ALIGNMENT          #############
#############                            #############
######################################################
"

if [ "$ALIGNMENT" == "TRUE" ]; then
  echo -e "\n\nRunning STAR and picard...\n\n"

  if [ "$END" == "SINGLE" ]; then
    echo -e "This is a single-end experiment. RUN1 will be considered as ${R1}. If this is not the case for your data, please check code and inputs file."
  elif [ "$END" == "PAIRED" ]; then
    echo -e "This is a paired-end experiment. RUN1 will be considered as ${R1} and RUN2 as ${R2}. If this is not the case for your data, please check code and inputs file.\n"
  fi

  for folder in "${folders[@]}"; do
    # STAR
    length_files=$(ls -1 "$FASTQDIR/${folder}"/*"$RUNSUFFIX" | wc -l)

    echo -e "\nAligning $length_files samples from batch $folder...\n"
    STAR=$(sbatch --parsable --array=1-$length_files "$FUNCTIONSDIR/star.sh" "$PROJECT" "$folder" "$RUNSUFFIX" "$FASTQDIR" "$STAR_GTF" "$STAR_FLAT" "$STAR_RIBO" "$STAR_DIR" "$END")
    echo -e "\nAlignment jobs sent to the cluster.\n"

    sbatch --dependency=afterok:"${STAR}" "$FUNCTIONSDIR/ReadMapping_metrics.sh" "$folder" "$PROJECT"
  done
else
  echo -e "\n\nAlignment will not be performed.\n\n"
fi

######################################################
#############                            #############
#############       QUANTIFICATION       #############
#############                            #############
######################################################

echo -e "
######################################################
#############                            #############
#############       QUANTIFICATION       #############
#############                            #############
######################################################
"
# Run quantification and create NGS_summary.xlsx file

if [ "$QUANTIFICATION" == "TRUE" ]; then

  for folder in "${folders[@]}"; do
    # Run quantification
    if [ "$ALIGNMENT" == "TRUE" ]; then
      mkdir -p $PROJECT/Analysis/Quantification
      echo -e "Quantification will be performed after the alignment has finished.\n"

      mkdir -p $PROJECT/Analysis/Quantification/Strandness_check/${folder}

      BAMDIR=$PROJECT/Analysis/ReadMapping/BAM_Files/${folder}

      if ls $BAMDIR/*.bam >/dev/null 2>&1 # check whether there is any .bam file (if alignment is being performed, there might not be any yet)
      then
        BAMFILES=($(ls -1 $BAMDIR/*.bam))
        length_files=$(ls -1 "$BAMDIR"/*.bam | wc -l)
      else
        echo -e "Sleeping for 30 minutes so .bam files are generated..."
        sleep 1800 # give time so the bam files are generated
        BAMFILES=($(ls -1 $BAMDIR/*.bam))
        length_files=$(ls -1 "$BAMDIR"/*.bam | wc -l)
      fi

      CHECK_STRANDNESS=$(sbatch --dependency=afterok:${STAR} --parsable --array=1-$length_files "$FUNCTIONSDIR/check_strandness.sh" "$BAMDIR" "$FUNCTIONSDIR" "$PROJECT" "$folder")

      STRANDNESS_OUT=$(sbatch --dependency=afterok:${CHECK_STRANDNESS} --parsable "$FUNCTIONSDIR/strandness_out.sh" "$PROJECT" "$WD" "$folder" "$FUNCTIONSDIR")

      until [ -f $PROJECT/Analysis/Quantification/Strandness_check/$folder/Strandness_check_out.tsv ]
        do
        echo -e "Strandness_check_out.tsv has not been generated yet. Sleeping for 20 seconds..."
        sleep 20 # wait 20 seconds if the file has not been created yet
        done
      echo -e "Sleeping 500 seconds so the file Strandness_check_out.tsv is properly filled..."
      sleep 500 # give time for the file to be filled

      conclusions=$(awk -F'\t' '{if(NR>1 && $5 != "") print $5}' $PROJECT/Analysis/Quantification/Strandness_check/$folder/Strandness_check_out.tsv)

      # Count occurrences of each value
      reverse_count=$(grep -o 'Reverse' <<< "$conclusions" | wc -l)
      forward_count=$(grep -o 'Forward' <<< "$conclusions" | wc -l)
      no_strand_count=$(grep -o 'No_strandness' <<< "$conclusions" | wc -l)

      # Determine the most frequent value
      if (( $no_strand_count > ($reverse_count + $forward_count) )); then
          echo -e "No_strandness"
          STRAND=0
      elif [ $reverse_count -gt $forward_count ]; then
          echo -e "Strandness has been defined as reverse."
          STRAND=2
      elif [ $reverse_count -lt $forward_count ]; then
          echo -e "Strandness has been defined as forward."
          STRAND=1
      else
          echo -e "Unable to determine strandness."
      fi

      FEATURECOUNTS=$(sbatch --parsable "$FUNCTIONSDIR/feature.counts_new.sh" "$PROJECT" "$folder" "$STAR_GTF" "$FUNCTIONSDIR" "$STRAND")
      echo "Submitted FEATURECOUNTS job with ID: ${FEATURECOUNTS}"

      MULTIQC=$(sbatch --dependency=afterok:${FEATURECOUNTS} --parsable "$FUNCTIONSDIR/ReadMapping_multiqc.sh" "$folder" "$PROJECT")

      sbatch --dependency=afterok:${MULTIQC} "$FUNCTIONSDIR/NGS_summary.sh" "$FUNCTIONSDIR" "$PROJECT" "$WD" "$folder"

    else

      mkdir -p $PROJECT/Analysis/Quantification
      mkdir -p $PROJECT/Analysis/Quantification/Strandness_check/${folder}

      BAMDIR=$PROJECT/Analysis/ReadMapping/BAM_Files/${folder}
      BAMFILES=($(ls -1 $BAMDIR/*.bam))
      length_files=$(ls -1 "$BAMDIR"/*.bam | wc -l)

      CHECK_STRANDNESS=$(sbatch --parsable --array=1-$length_files "$FUNCTIONSDIR/check_strandness.sh" "$BAMDIR" "$FUNCTIONSDIR" "$PROJECT" "$folder")

      STRANDNESS_OUT=$(sbatch --dependency=afterok:${CHECK_STRANDNESS} --parsable "$FUNCTIONSDIR/strandness_out.sh" "$PROJECT" "$WD" "$folder" "$FUNCTIONSDIR")

      until [ -f $PROJECT/Analysis/Quantification/Strandness_check/$folder/Strandness_check_out.tsv ]
        do
        echo -e "Strandness_check_out.tsv has not been generated yet. Sleeping for 20 seconds..."
        sleep 20 # wait 20 seconds if the file has not been created yet        
      done
      echo -e "Sleeping 500 seconds so the file Strandness_check_out.tsv is properly filled..."
      sleep 500 # give time for the file to be filled

      conclusions=$(awk -F'\t' '{if(NR>1 && $5 != "") print $5}' $PROJECT/Analysis/Quantification/Strandness_check/$folder/Strandness_check_out.tsv)

      # Count occurrences of each value
      reverse_count=$(grep -o 'Reverse' <<< "$conclusions" | wc -l)
      forward_count=$(grep -o 'Forward' <<< "$conclusions" | wc -l)
      no_strand_count=$(grep -o 'No_strandness' <<< "$conclusions" | wc -l)

      # Determine the most frequent value
      if (( $no_strand_count > ($reverse_count + $forward_count) )); then
          echo -e "No_strandness"
          STRAND=0
      elif [ $reverse_count -gt $forward_count ]; then
          echo -e "Strandness has been defined as reverse."
          STRAND=2
      elif [ $reverse_count -lt $forward_count ]; then
          echo -e "Strandness has been defined as forward."
          STRAND=1
      else
          echo -e "Unable to determine strandness."
      fi

      FEATURECOUNTS=$(sbatch --parsable "$FUNCTIONSDIR/feature.counts_new.sh" "$PROJECT" "$folder" "$STAR_GTF" "$FUNCTIONSDIR" "$STRAND")
      echo "Submitted FEATURECOUNTS job with ID: ${FEATURECOUNTS}"

      MULTIQC=$(sbatch --dependency=afterok:${FEATURECOUNTS} --parsable "$FUNCTIONSDIR/ReadMapping_multiqc.sh" "$folder" "$PROJECT")

      sbatch --dependency=afterok:${MULTIQC} "$FUNCTIONSDIR/NGS_summary.sh" "$FUNCTIONSDIR" "$PROJECT" "$WD" "$folder"
    fi
  done
fi



