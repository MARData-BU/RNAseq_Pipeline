args = commandArgs(trailingOnly=TRUE)

# Read arguments
wd <- args[1]
batch <- args[2]

library(openxlsx)
library(stringr)

multiqc = file.path(wd, "QC/multiQC")

general_stats = read.table(file = file.path(multiqc, "/multiqc_data/multiqc_general_stats.txt"), sep = "\t", header = T)

#cols = c("Sample","percent_assigned","Assigned","mapped_percent","uniquely_mapped","percent_duplicates","percent_gc","total_sequences")

general_stats = general_stats[,c("Sample", "featureCounts_mqc.generalstats.featurecounts.percent_assigned", "featureCounts_mqc.generalstats.featurecounts.Assigned",
                                 "STAR_mqc.generalstats.star.uniquely_mapped_percent", "STAR_mqc.generalstats.star.uniquely_mapped", "FastQC_mqc.generalstats.fastqc.percent_duplicates",
                                 "FastQC_mqc.generalstats.fastqc.percent_gc", "FastQC_mqc.generalstats.fastqc.total_sequences")]


colnames(general_stats) = c("Sample", "% Assigned", "M Assigned", "% Aligned", "M Aligned", "% Dups", "% GC", "Total Seqs") # rename columns

NGS_summary = general_stats[!grepl("(_[12]$|_0[12]$|_00[12]$)", general_stats$Sample), ] # return a logical vector indicating whether each element in the "Sample" column ends with "_1/_01/_001" or "_2/_02/_002". If a string ends with either "R1" or "R2", the corresponding element in the logical vector will be TRUE, otherwise FALSE.
# With the previous regexpression we create a table with only the samples and NOT the reads R1-R2



for(row in NGS_summary$Sample){
  
  reads = grep(row, general_stats$Sample, value = T)
  R1 = grep("_1", reads, value = T)[1]
  R2 = grep("_2", reads, value = T)[1]

  # Get the mean duplications per sample
  dups = (general_stats[general_stats$Sample == R1, "% Dups"] + general_stats[general_stats$Sample == R2, "% Dups"])/2
  NGS_summary[NGS_summary$Sample == row, "% Dups"] = dups
  
  # Get the mean GCs per sample
  GCs = (general_stats[general_stats$Sample == R1, "% GC"] + general_stats[general_stats$Sample == R2, "% GC"])/2
  NGS_summary[NGS_summary$Sample == row, "% GC"] = GCs
  
  # Get the total seqs per R1 and R2
  total_R1 = general_stats[general_stats$Sample == R1, "Total Seqs"]
  total_R2 = general_stats[general_stats$Sample == R2, "Total Seqs"]
  
  NGS_summary[NGS_summary$Sample == row, "R1"] = total_R1
  NGS_summary[NGS_summary$Sample == row, "R2"] = total_R2
  
}

# Calculate total reads and pairs
NGS_summary[, "Total (M reads)"] = round((NGS_summary[,"R1"] + NGS_summary[,"R2"])/1000000, digits = 1)
NGS_summary[, "Pairs (M read pairs)"] = round(NGS_summary[, "Total (M reads)"]/2, digits = 1)

# Round numbers to 1 digit
NGS_summary[,"% Assigned"] = round(NGS_summary[,"% Assigned"], digits = 1)
NGS_summary[,"% Dups"] = round(NGS_summary[,"% Dups"], digits = 1)
NGS_summary[,"M Assigned"] = round((NGS_summary[,"M Assigned"]/1000000), digits = 1)

# Reorder columns
NGS_summary = NGS_summary[,c("Sample", "R1", "R2", "Total (M reads)", "Pairs (M read pairs)", "% Dups", "% Aligned", "% Assigned", "M Assigned")]

# Create a header style
headerStyle <- createStyle(
  fontSize = 11, fontColour = "#FFFFFF", halign = "center",
  fgFill = "#4F81BD", border = "TopBottom", borderColour = "#4F81BD"
)

# Save data to file
wb <- createWorkbook()

## Add worksheets
addWorksheet(wb, "NGS_summary")
writeData(wb, "NGS_summary", NGS_summary,  rowNames = F)
addStyle(wb, sheet = "NGS_summary", headerStyle, rows = 1, cols = 1:ncol(NGS_summary), gridExpand = TRUE)
setColWidths(wb, sheet = "NGS_summary", cols =4:5, widths = 16)
saveWorkbook(wb, file.path(wd, paste0("/Analysis/", batch, "/NGS_summary.xlsx")), overwrite = TRUE)
