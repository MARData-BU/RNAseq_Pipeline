# RNAseq_Pipeline

##########################################################
# PLEASE READ THE BELOW TEXT BEFORE RUNNING THE PIPELINE #
##########################################################

In order to run this RNAseq pipeline, please fill in the config_input_files.txt file. The primary script is this file 'test_pipeline_structure.sh', from which other scripts are called and sent to the cluster.

Be aware that the following modules/packages will need to be installed in your computer for the pipeline to run:
  - bash: STAR, SAMtools, picard, FastQ-Screen, Bowtie2, FastQC, Python, R, Subread.
  - R: openxlsx, stringr.

Please do note that the 'config_input_files.txt' file must be fulfilled leaving an **empty space** between the colon (:) and the input text (e.g: project_directory: /bicoh/MARGenomics/Development/RNASeq/TEST).
Any other version of inputing data (such as project_directory:/bicoh/MARGenomics...) will NOT work for the pipeline.

  ################
  STEPS TO PERFORM
  ################
  -  merge: whether you require to merge your data before processing (for >1 lane) (TRUE/FALSE).
  -  quality: whether to compute the quality check(TRUE/FALSE).
  - alignment: whether to compute the alignment (TRUE/FALSE).
  - quantification: whether to compute the quantification (TRUE/FALSE).

  ##################
  GENERAL PARAMETERS
  ##################
  - project_directory: full path for the project directory (e.g:/bicoh/MARGenomics/20230626_MFito_smallRNAseq). Do not include the batch name/folder, if any.
  - project_analysis: full path for the project analysis (e.g: directory/bicoh/MARGenomics/20230626_MFito_smallRNAseq/Analysis). Do not include the batch name/folder, if any.
  - functions: full path for the functions directory (unless functions are modified, they are in /bicoh/MARGenomics/Pipelines/smallRNASeq).
  - fastq_directory: path for the FASTQ files (e.g: /bicoh/MARGenomics/20230626_MFito_smallRNAseq/rawData). If there are batches, do NOT add them in this path, as the pipeline will automatically
  run through the batch folders if defined correctly.
  - batch_num: total number of batches.
  - bat_folder: batch name (only if batch_num is 1; e.g: FITOMON_01) or else batch prefix (only if batch_num >1; e.g: FITOMON_0). In this second case (batch_num > 1), the pipeline will assume that the batch folders
  are the batch_folder variable pasted with 1:batch_num (e.g: if batch_num is 3 and bat_folder is FITOMON_0, the batch folders will be considered as FITOMON_01, FITOMON_02 and FITOMON_03). If you have only one batch
  and they are not stored in any folder rather than within the fastq_directory, please leave this variable as 'NA' or 'FALSE'.
  - fastq_suffix: suffix for the fastq files (usually .fastq.gz or .fq.gz).
  - lanes: number of lanes (1, 2, 3...) AFTER the merge. Only used for the generation of the table4QCpresentation.xlsx. If lanes are merged or else the data has NO lanes, this parameter must be 1. 

  ################
  MERGE PARAMETERS
  ################
  - sample_sheet: path to the sample_sheet.xlsx file. Please copy the xlsx file from /bicoh/MARGenomics/Pipelines/smallRNASeq/sample_sheet.xlsx to your folders, but do not modify the original file.
  - total_output_files: total output files that will be generated after the merge. It must correspond to the number of rows in the sample_sheet.xlsx file.

  ###################
  ALIGNMENT VARIABLES
  ###################
  - STAR_reference_genome_GTF: gtf file for STAR reference genome (e.g: /bicoh/MARGenomics/AnalysisFiles/Annot_files_GTF/Human/gencode.v41.primary_assembly.annotation.gtf).
  - STAR_reference_genome_FLAT: flat file for STAR reference genome (e.g: /bicoh/MARGenomics/AnalysisFiles/Annot_files_GTF/Human/gencode.v41.flatFile).
  - STAR_reference_genome_RIBOSOMAL_INTERVALS: ribosomal interval list file for the STAR reference genome (e.g: /bicoh/MARGenomics/AnalysisFiles/Annot_files_GTF/Human/gencode.v41.ribosomal.interval_list).
  - STAR_genome_dir: STAR referenge genome directory (e.g: /bicoh/MARGenomics/AnalysisFiles/Annot_files_GTF/Human).
  - run1_suffix: suffix for your R1 samples (e.g: _R1_001.fastq.gz), if applicable.
  - paired_end: whether your data has single-end (FALSE) or paired-end (TRUE).

  ########################
  QUANTIFICATION VARIABLES
  ########################
  - frw_stranded: whether your RNAseq is stranded (TRUE) or not (FALSE).
  - unstranded: whether your RNAseq is unstranded (TRUE) or not (FALSE).
  - reversely_stranded: whether your RNAseq is reversely-stranded (TRUE) or not (FALSE).
  - fastqscreen_config: fastQScreen configuration (e.g: /bicoh/MARGenomics/AnalysisFiles/Index_Genomes_Bowtie2/fastq_screen.conf).

Also please consider the following points when populating the config_input_files.txt and before running the pipeline:
  - Note that if there is only one run (R1), you need to specify the variable -paired_end- as FALSE. Otherwise the pipeline will considered two runs (R1 and R2).
  - If your data contains ONLY 1 batch, please populate the parameter -batch_num- with 1. If your data is stored within a folder named after this unique batch, please
  define the variable -batch_folder- accordingly. If your data is NOT stored within any batch folder, please set the variable -batch_folder- as NA or FALSE. Any
  other definitions of the variable -batch_folder- will be considered as a name for the folder in which batch data is stored.
  - If your data contains more than 1 batch, please consider the following:
      - The parameter -batch_num- refers to the number of batches your data has.
      - The parameter -batch_folder- refers to the PREFIX of your batch folders. This pipeline will consider the prefix and then add the numbers from 1 to batch_num as batch folder names
      (e.g: if -batch_num- is set to 3 and -batch_folder- to 'BATCH_0', the batch folders through which the pipeline will iterate will be 'BATCH_01', 'BATCH_02' and 'BATCH_03').
  - If quantification needs to be run, please define one of the three following parameters as TRUE depending on your data (RNA strandness): -unstranded-, -stranded- or -reversely_stranded-.
  - Please read and check the SET PARAMETERS section once you have launched the pipeline in the logs.out file to ensure that all your parameters have been set correctly. This logs.out document
  will be stored within a logs folder generated in the -project_analysis- path.

##################################################################
# PLEASE READ THE BELOW TEXT IF YOU REQUIRE TO MERGE FASTQ FILES #
##################################################################

If MERGE is set to TRUE (if fastq files have to be merged), please note that the Excel file 'sample_sheet.xlsx' MUST BE POPULATED. Please consider the following when doing so:
  - The -total_output_files- variable in the 'config_input_files.txt' must correspond to the total number of files that are to be generated.
  - RUNSUFFIX (run1_suffix) in the 'config_input_files.txt' must be defined accordingly to the output names that you define. Other options will make the pipeline fail.
  - The Excel file 'sample_sheet.xlsx' must be populated with
      - (1) the paths and names of the fastq.gz files and
      - (2) the paths and names in which merged files will be stored. If there are >1 batches and merged files are to be stored in different folders, please consider so when populating the path.
      Also please consider this when populating the variables -batch_num- and -batch_folder- from the 'config_input_files.txt'; if merged data is stored in different folderes according to the batch,
      variables -batch_num- and -batch_folder- must be filled accordingly. The number of batches must correspond to the number of batch folders that are generated AFTER the merge.
      - It is possible to leave empty cells within a row, and also to add new columns, but note that the output path/name must ALWAYS be the last populated column of the spreadsheet, that it
      must be the same column for all rows even though empty spaces are left in some (but not all) rows, and that it must be named 'Output_name'.
      - Column names can be modified with the exception of 'Output_name' column (which MUST be the last column). Please, do NOT modify the name of this column or else the pipeline will not run.
      - Please consider saving the merged files in a different folder than the non-merged files. The pipeline will analyze any file with the prefix .fastq.gz, so unless merged and unmerged files
      are stored separately, the pipeline will analyze all of them.
  - If you require to MERGE files and your data has >1 BATCHES, please note that ALL MERGED FILES MUST BE STORED IN THE SAME OUTPUT DIRECTORY.
