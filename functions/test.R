# Read arguments from bash 
samplesheet=commandArgs()[6]

library(openxlsx)
library(Rfastp)
samplesheet = read.xlsx(samplesheet)

for (i in 1:nrow(samplesheet)){
  
  if(any(is.na(samplesheet[i,]))){ # if there is an NA value in some of the columns
    subset = samplesheet[i,!is.na(samplesheet[i,])] # keep only those columns with values in it
    x = length(subset)
  }
  
  else {
    x = length(samplesheet[i,])
  }
  
  print(paste("The number of files to merge is",x-1))
  
  output_index = length(samplesheet) # the output file is always the last element of the excel file. This will provide the index regardless the NAs on the Excel. 
  
  files_to_merge = c() # create an empty vector to append all the files to be merged
  
  for (j in 1:(x-1)){ # append all files to be merged into one vector. This assumes that the last element from the sample_sheet is the output (merged) file.
    files_to_merge = append(files_to_merge, samplesheet[i,j])
  }
  
  output = samplesheet[i, output_index] 
  
  print(paste("The output file will be", output))
  print(paste("The files to be merged into the output file will be", files_to_merge))
  
  catfastq(output = output, inputFiles = files_to_merge, append = FALSE, paired = FALSE, shuffled = FALSE)
  
}

catfastq(output, inputFiles = allR1, append = TRUE)
rcat(output = output, files_to_merge, length(files_to_merge))
