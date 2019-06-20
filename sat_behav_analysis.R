
## ---- Libraries ----

library(tidyverse)

## ---- SourceFiles ----

path="Analysis/Data/sat_behavioural_analysis" #may not work due to wd
setwd(path)
sat_behav_files <- list.files(pattern=glob2rx("*.txt"), 
                             #path="sat_behavioural_analysis", 
                             recursive = TRUE,
                             full.names = FALSE)
head(sat_behav_files)
length(sat_behav_files)

## ---- SourceFilesAlternative ----
## save the filenames so we can repeat later on
writeLines(sat_behav_files, "sat_files.lst")
sat_behav_files <- readLines("sat_files.lst")

## If path is not correct 
#getwd()
#setwd("sat_behavioural_analysis")

# load one for testing purposes
#df <- read.delim(sat_behav_files[5], header=TRUE)

load_sat_behav <- function(filename) {
  if (!file.exists(filename)) {
    warning(paste("Missing", filename))
    return(NULL)
  }
  
  ## pull the filename apart with bash style processing
  id <- stringr::str_split(filename, pattern="_")
  id<- id[[1]][1]
  #load file
  df <- read.delim(filename,header = TRUE, sep = "\t",fileEncoding= "ASCII")
  #only keep the columns I want
  df<- select(df, Subject.ID, Condition, Accuracy, Avg.RT)
  #change ID numbers
  df$Subject.ID<- id
  
return(df) }

#check it works for one
#trial_df<- load_sat_behav(sat_behav_files[1])

#apply to all
sat_df <- map_df(sat_behav_files, load_sat_behav)

# add groups and tidy data
sat_df$Subject.ID<- as.numeric(sat_df$Subject.ID)
sat_df<- mutate(sat_df, group= ifelse(Subject.ID <100, "Control", "TBI"))
sat_df$group<- as.factor(sat_df$group)
glimpse(sat_df)
#new_df <- lapply(sat_behav_files, load_sat_behav)

#visualise the datat

# boxplot for Average RT
sat_df %>%
  group_by(group) %>%
  select(group, Condition, Avg.RT) %>%
  ggplot(aes(x=Condition, y = Avg.RT, fill=group))+
  geom_boxplot() +
  scale_fill_manual(values=c("#999999", "#FFB6C1"))

# boxplot for Accuracy
sat_df %>%
  group_by(group) %>%
  select(group, Condition, Accuracy) %>%
  ggplot(aes(x=Condition, y = Accuracy, fill=group))+
  geom_boxplot() +
  scale_fill_manual(values=c("#999999", "#FFB6C1"))

#summary statistics 
sum_sat_df<- sat_df %>%
  group_by(group, Condition) %>%
  summarize(mean_RT= mean(Avg.RT, na.rm=TRUE), mean_Acc= mean(Accuracy, na.rm=TRUE))

#stat comparisons 
sat_aov <- aov (Avg.RT ~ group * Condition, data= sat_df)
summary(sat_aov)

sat_df %>%
  select(Subject.ID, Condition, group, Avg.RT) %>%
  filter(Condition == "NoGo") %>%
  filter(Avg.RT > 300)
