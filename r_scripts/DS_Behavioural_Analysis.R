
## ---- Libraries ----

library(tidyverse)

## ---- SourceFiles ----

path="Analysis/Data/ds_behavioural_analysis"
ds_behav_files <- list.files(pattern=glob2rx("*.txt"), 
                             path="Analysis/Data/ds_behavioural_analysis", 
                             recursive = TRUE,
                             full.names = TRUE)
head(ds_behav_files)
length(ds_behav_files)

#create filenames and function 
#filenames <- file.path(path, paste0(id, '/',id,"_", timepoint,"_", condition,"-Digit Span.txt"))

## ---- SourceFilesAlternative ----
## save the filenames so we can repeat later on

writeLines(ds_behav_files, "ds_files.lst")
ds_behav_files <- readLines("ds_files.lst")

## Load one for testing purposes

testdf <- read.delim(ds_behav_files[7])

library(readr)

## ---- LoadFunction ----
# Notice that there is no group, participant ID, timepoint (BL, T1, T2) or condition (Pre, Post, Delay)
# That information is in the file path
# Lets write a special function to transform the input data
# Points - tools for manipulating file paths
# tools for pulling apart words - reference regular expressions.
# Special date objects - lubridate

load_ds_behav <- function(filename) {
  if (!file.exists(filename)) {
    warning(paste("Missing", filename))
    return(NULL)
  }
  
  ## pull the filename apart with bash style processing
  pathA <- dirname(filename)
  folder1 <- basename(pathA)
  id<- folder1
  
  folder2<- basename(filename)
  folder2split <- stringr::str_split(folder2, pattern="_")
  timepoint<-folder2split[[1]][2]
  
  folder3<- filename
  condition <- stringr::word(folder3, sep="-")
  condition <-stringr::str_split(condition, pattern="_")
  condition <- condition [[1]][5]
  
  df <- read.table(filename,header = TRUE, sep = "\t",fileEncoding= "ASCII")
  
  ## Add in our new fields -
  df <- mutate(df, sourcefile=filename, id=id, 
               timepoint=timepoint, condition=condition)
  df <- select(df, id, timepoint, condition, everything())
  df <- select(df, -c(Sequence,Response))
  
  # Calculate accuracy and make df smaller
  acc_data<-sum(df$Accuracy=="Correct")
  df<-mutate(df, accuracy=acc_data)
  df<-select(df, id, timepoint, condition, accuracy) 
  df<-head(df,1) 
  return(df)
}

## ---- LoadData ----

 #trial_df<- load_ds_behav(ds_behav_files[10,])

  ds_dflist <- lapply(ds_behav_files, load_ds_behav) 
  ds_df_big <- bind_rows(ds_dflist)

  ## Now we have it working, instantly apply to everything
  ds_df <- map_df(ds_behav_files, load_ds_behav)
  
  ## ---- Tidydata ----

 ds_df$new<-paste(ds_df$timepoint,ds_df$condition,sep="_")

 ds_df<-select(ds_df, id, new, accuracy)
 ds_df<- spread(ds_df_trial, new, accuracy)
 ds_df<-set_names(ds_df_trial, tolower(names(ds_df_trial)))
 ds_df<- select(ds_df_trial, "id", "bl_pre", "bl_post", "bl_delay", "t1_pre", "t1_post", "t1_delay", "t2_pre", "t2_post", "t2_delay")
 ds_df$id<- as.numeric(ds_df$id) # change from character to numeric so can mutate to create groups
 ds_df<- mutate(ds_df, group= ifelse(id <100, "Control", "TBI"))
 ds_df<- ds_df[c(1,11,2:10)] #reorder columns
 str(ds_df) #check structure
 ds_df$group <-as.factor(ds_df$group) # make group a factor

 # ---- Plotting ----
 attach(ds_df)
 ds_bl_pre_box<-boxplot(bl_pre~group, varwidth=TRUE,boxwex= 0.2,main="Digit Span Pre BL",
                        names=c("control","mTBI"),ylab="Working Memory",xlab="Baseline",col=c("light grey","light pink"))
 #box plot of two groups at baseline for pre
 
 ds_df %>%
   ggplot(aes(x=bl_pre, bl_post, colour=group))+
   geom_point()
 
 # ---- Stats ----
 summary(ds_df)
 describe<-describe(ds_df~group, na.rm=TRUE) 
 describe<-select(describe, group1,mean,sd)
 