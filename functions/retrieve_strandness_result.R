strand_dir=commandArgs()[6]

print(paste("The strandness.out directory is", strand_dir))

data <- data.frame(matrix(ncol = 5, nrow = length(list.files(strand_dir, all.files = F))))
colnames(data) <- c("Sample", "Failed", "Secondstrand", "Firststrand", "Conclusion")

i = 1
for(file in list.files(strand_dir, all.files = F, full.names = T)){
  table <- read.table(file, skip = 2, sep = "\t")
  failed <- as.numeric(gsub("Fraction of reads failed to determine: ", "", table[2,]))
  secondstrand <- as.numeric(gsub("Fraction of reads explained by 1\\+\\+,1\\-\\-,2\\+\\-,2\\-\\+: ", "", table[3,]))
  firststrand <- as.numeric(gsub("Fraction of reads explained by 1\\+\\-,1\\-\\+,2\\+\\+,2\\-\\-: ", "", table[4,]))
  
  if(abs(firststrand-secondstrand) > 0.50){
    conclusion <- ifelse(secondstrand > firststrand, "Forward", "Reverse")
  }
  else{
    conclusion <- "No_strandness"
  }
  sample <- gsub("\\.out", "", basename(file))
  
  data[i,"Sample"] <- sample
  data[i, "Failed"] <- failed
  data[i, "Secondstrand"] <- secondstrand
  data[i, "Firststrand"] <- firststrand
  data[i, "Conclusion"] <- conclusion
  
  i = i+1
}

write.table(data, file.path(strand_dir, "Strandness_check_out.tsv"), sep = "\t", row.names = F)
