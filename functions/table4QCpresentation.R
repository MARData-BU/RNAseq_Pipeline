#!/usr/bin/env Rscript
#Júlia Perera
#15/12/2020
#Script to generate QC table from multiQC

# Run like this:
#Rscript table4QCpresentation.R PROJECT LANES R
#Rscript table4QCpresentation.R 20200529_LLSantamaria 1 2

args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)<4) {
  stop("Please provide required arguments: 
       1) path to QC folder 
       2) number of lanes 
       3) single (1) or paired (2) end reads 
       4) run1 suffix (e.g: R1_001)", call.=FALSE)
} 

# Read arguments
QCDir <- args[1]
lanes=as.numeric(args[2])
R=as.numeric(args[3])
t=R*lanes
runsuffix = args[4]

# Set working dir depending on user and machine
setwd(QCDir)

# Load libraries
library(openxlsx)
library(gridExtra)
library(grid)

## create and add a style to the column headers
headerStyle <- createStyle(
  fontSize = 11, fontColour = "#FFFFFF", halign = "center",
  fgFill = "#4F81BD", border = "TopBottom", borderColour = "#4F81BD"
)

################
####### FASTQC
################
table=read.delim2(file.path(QCDir,"/multiQC/multiqc_data/multiqc_fastqc.txt"))
if(R == 1){
  samples=unique(gsub(runsuffix,"",table$Sample))
} else if (R == 2){
  if(grepl("*read1*", runsuffix)){
    samples=unique(gsub("(read1|read2)","",table$Sample))
  } else if (grepl("*R1*", runsuffix)){
    samples=unique(gsub("(R1|R2)","",table$Sample))
  } else if (grepl("*1*", runsuffix)){
    samples=unique(gsub("_*(1|2)$","",table$Sample))
  }
}

#samples=unique(gsub("_S.*_L00.*_R.*_001","",table$Sample)) # UPF
#samples=unique(gsub("_.*_read[12]","",table$Sample)) # CRG

# Prepare table
df=data.frame(matrix(NA,ncol = R*lanes,nrow=length(samples)))
#colnames(df)=c("R1_L001","R2_L001","R1_L002","R2_L002","R1_L003","R2_L003","R1_L004","R2_L004")
colnames(df)=paste0(paste0("L00",1:lanes),paste0("R",1:R))
x=outer(paste0("R",1:R), paste0("L00",1:lanes), FUN = "paste",sep="_")
dim(x) <- NULL
colnames(df)=x
rownames(df)=samples

# Fill table (Read counts)
for (i in 1:length(samples)){
  df[i,]=as.numeric(t(table[(i*t-(t-1)):(i*t),"Total.Sequences"]))
}

#Reorder first all R1, then all R2
df=df[,c(seq(1,t,2),seq(2,t,2))]

# Add total Lib.Size per sample
df$`Total (M.reads)`=round(rowSums(df)/1000000,1)
df$`Pairs (M.read pairs)`=round(df$`Total (M.reads)`/2,1)


# Fill table (%Dups counts)
for (i in 1:length(samples)){
  dup=as.numeric(table[(i*t-(t-1)):(i*t),"total_deduplicated_percentage"])
  dup=100-dup # Fasqc gives % deduplicated, we want % duplicated
  df$`% Dups`[i]=round(mean(as.numeric(sub("%","",dup))),0)
}

# Remove Undetermined
if(length(grep("Undetermined",rownames(df)))!=0){
  df=df[-(grep("Undetermined",rownames(df))),]
}

# Save data to file
wb <- createWorkbook()
## Add worksheets
addWorksheet(wb, "FastQC")
writeData(wb, "FastQC", df,  rowNames = T)
addStyle(wb, sheet = "FastQC", headerStyle, rows = 1, cols = 2:(ncol(df)+1), gridExpand = TRUE)
saveWorkbook(wb, file.path(QCDir,"table4QCpresentation.xlsx"), overwrite = TRUE)

# ############################################
# # Save table as png for QC presentation
# ############################################
# # Color duplications  
# if (colorDup==T){
#   cols <- colorRampPalette(c("green", "yellow", "red"))(nrow(df))[rank(df$`% Dups`)]
#   # change `vec` argument of `findInterval` to suit your cut-points
#   #cols <- c("green" ,"orange", "red") [findInterval(df$`% Dups`, c(0, 40, 60, 100))]
#   t2 <- tableGrob(df["% Dups"], 
#                   theme=ttheme_default(
#                     core=list(bg_params = list(fill=cols))), 
#                   rows = NULL)
#   
#   t1 <- tableGrob(df[,-ncol(df)],theme=ttheme_default())
#   g <- gtable_combine(t1, t2)
# } else{g <- tableGrob(df)}
# ## add border to table
# g <- gtable::gtable_add_grob(g,
#                              grobs = rectGrob(gp = gpar(fill = NA, lwd = 2)),
#                              t = 2, b = nrow(g), l = 1, r = ncol(g))
# ## add border to header
# g <- gtable::gtable_add_grob(g,
#                              grobs = rectGrob(gp = gpar(fill = NA, lwd = 2)),
#                              t = 1, l = 1, r = ncol(g))
# 
# png(file.path(QCDir,paste0(args[5],".png")), height = 100*nrow(df), width = 400*ncol(df),res = 300)
# grid.draw(g)
# dev.off()



#######################
######## FASTQSCREEN
#######################

files=list.files(file.path(QCDir,"FastqScreen"),pattern = "*_screen.txt")
df=as.data.frame(matrix(NA,nrow=length(files),ncol=7))
colnames(df)=c("%Human","%Mouse",
               "%RiboHuman","%RiboMouse",
               "%RiboEuk","%RiboProk",
               "%no hits")
rownames(df)=gsub("_screen.txt","",files)
# Read screen.txt files
telliter <- 5
iter=0
for (file in gsub("_screen.txt","",files)){
  fastqscreen=read.delim(paste0(QCDir,"/FastqScreen/",file,"_screen.txt"),sep="\t",skip = 1,check.names = F)
  rownames(fastqscreen)=fastqscreen$Genome
  df[file,"%Human"]=sum(fastqscreen["Human",c("%One_hit_one_genome","%Multiple_hits_one_genome")])
  df[file,"%Mouse"]=sum(fastqscreen["Mouse",c("%One_hit_one_genome","%Multiple_hits_one_genome")])
  df[file,"%RiboHuman"]=sum(fastqscreen["RibosomalHuman",c("%One_hit_one_genome","%Multiple_hits_one_genome")])
  df[file,"%RiboMouse"]=sum(fastqscreen["RibosomalMouse",c("%One_hit_one_genome","%Multiple_hits_one_genome")])
  df[file,"%RiboEuk"]=sum(fastqscreen["RibosomalEuk_other",c("%One_hit_one_genome","%Multiple_hits_one_genome")])
  df[file,"%RiboProk"]=sum(fastqscreen["RibosomalProk",c("%One_hit_one_genome","%Multiple_hits_one_genome")])
  df[file,"%no hits"]=as.numeric(gsub("%Hit_no_genomes: ","",grep("Hit_no_genome",fastqscreen$Genome,value = T)))
  
  #Print progress
  iter=iter+1
  if( iter %% telliter == 0 ) cat(".")
}
cat("done! Processed",iter,"files\n")

df2=as.data.frame(matrix(NA,nrow=length(samples),ncol=7))
colnames(df2)=c("%Human","%Mouse",
               "%RiboHuman","%RiboMouse",
               "%RiboEuk","%RiboProk",
               "%no hits")
rownames(df2)=samples

# Fill table (Read counts)
for (i in 1:length(samples)){
  df2[i,]=colMeans(df[(i*t-(t-1)):(i*t),])
}

# Remove Undetermined
if(length(grep("Undetermined",rownames(df)))!=0){
  df=df[-(grep("Undetermined",rownames(df))),]
}

## Add worksheets
addWorksheet(wb, "FastqScreen")
writeData(wb, "FastqScreen", df2,  rowNames = T)
addStyle(wb, sheet = "FastqScreen", headerStyle, rows = 1, cols = 2:(ncol(df2)+1), gridExpand = TRUE)
saveWorkbook(wb, file.path(QCDir,"table4QCpresentation.xlsx"), overwrite = TRUE)

cat("QC metrics saved as table4QCpresentation.xlsx \n")

