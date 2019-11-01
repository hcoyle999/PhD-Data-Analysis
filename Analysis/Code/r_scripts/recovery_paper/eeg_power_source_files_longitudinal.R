library(tidyverse)
library(data.table)

## ---- SourceFiles for Control  ----
here<-"~/Documents/PHD-Data-Analysis/PHD-Data-Analysis"
setwd(here) #main path/homedirectory
#load data (already clean)
setwd("./Analysis/Data/eeg_resting_power/control_t2")
eeg_power_files <- list.files(pattern=glob2rx("*.csv"), 
                              path=".", 
                              recursive = TRUE,
                              full.names = FALSE)
head(eeg_power_files)
length(eeg_power_files)

## save the filenames so we can repeat later on
writeLines(eeg_power_files, "eeg_power_files.lst")
eeg_power_files <- readLines("eeg_power_files.lst")

# load one for testing purposes (or just to do alpha power ec)
df <- read_csv(eeg_power_files[1],col_names = FALSE)
filename<-eeg_power_files[1]

load_eeg_power <- function(filename) {
  if (!file.exists(filename)) {
    warning(paste("Missing", filename))
    return(NULL)
  }
  
  #load file
  df <- read_csv(filename,col_names = FALSE)
  
  #tidy (add col and row names)
  #colnames(df) <- c("1","2","3", "4","5","6","8","9","10","11","12","13","14","15",
                    #"17","18","19","20","21","22","23","24","25","26","27","28") #BL participants (N=26)
  
  
  #colnames(df) <- c("1","2","3", "4","5","6","8","9","10","11","12","13","14","15",
                    #"17","18","19","20","21","22","23","24","25","26","28") #T1 participants (N=25)
  
  colnames(df) <- c("1","2","3", "4","5","6","8","9","10","11","12","13","14",
                   "17","18","20","21","22","23","25","26","27","28") #T2 participants (N= 23)
  
  rownames(df) <- c('AF3',	'AF4',	'F7',	'F5',	'F3',	'F1',	'FZ',	'F2',	'F4',	'F6',	'F8',	'FC5',	'FC3'	,'FC1',	'FCZ'	,'FC2',	'FC4'	,'FC6'	,'T7'	,'C5',
                    'C3',	'C1',	'CZ'	,'C2',	'C4',	'C6'	,'T8'	,'CP5',	'CP3'	,'CP1',	'CP2'	,'CP4',	'CP6'	,'P7',	'P5',	'P3'	,'P1'	,'PZ'	,'P2',
                    'P4',	'P6',	'P8'	,'PO7',	'PO3'	,'POZ',	'PO4',	'PO8',	'O1',	'OZ',	'O2')
  
  # transpose values
  df<-t(df)
  
  #select only electrodes from significant cluster ('F2','FC2','FC4', 'FC6','CZ' , 'C2' ,  'C4', 
                                                  # 'C6' ,  'T8' ,'CP2' , 'CP4' , 'CP6','P2',   'P8')
  
  
  roi = c('F2','FC2','FC4', 'FC6','CZ' , 'C2' ,  'C4','C6' ,  'T8' ,'CP2' , 'CP4' , 'CP6','P2', 'P8')
  
  df<- df [,roi]
  
  #calculate mean for each participant and create new df
  df<-as.data.frame(rowMeans(df))
  
  #pull apart file name for row column name
  all <- stringr::str_split(filename, pattern="_")
  frequency<- all[[1]][2]
  group<- all[[1]][3]
  condition<-all[[1]][4]
  power_type<-all[[1]][5]
  power_type<-stringr::str_split(power_type, "csv")
  power_type<-power_type[[1]][1]
  
  #create new columns I want
  colnames(df)<- frequency
  df$group <- group
  df$condition <- condition
  df$power_type<- power_type
  setDT(df, keep.rownames = "id")[]
  
  #change shape of df
  df<-gather(df, key=frequency, value=mean_power, -group, -condition, - id, -power_type)
  
  return(df) }

#check it works for one
trial_df<- load_eeg_power(eeg_power_files[1])

# if just doing for T1 or T2
eeg_alpha_roi_control_t2<- df

#apply to all
#eeg_df_control_t1 <- map_df(eeg_power_files, load_eeg_power)

# tidy the format
eeg_alpha_roi_control_t2<-eeg_alpha_roi_control_t2 %>%
  spread(key=frequency, value=mean_power)

## ---- SourceFiles for mTBI ----
# do again for TBI 
here<-"~/Documents/PHD-Data-Analysis/PHD-Data-Analysis"
setwd(here) #main path/homedirectory
#load data (already clean)
setwd("./Analysis/Data/eeg_resting_power/tbi_t2")
eeg_power_files <- list.files(pattern=glob2rx("*.csv"), 
                              path=".", 
                              recursive = TRUE,
                              full.names = FALSE)
head(eeg_power_files)
length(eeg_power_files)

## save the filenames so we can repeat later on
writeLines(eeg_power_files, "eeg_power_files.lst")
eeg_power_files <- readLines("eeg_power_files.lst")

# load one for testing purposes
df <- read_csv(eeg_power_files[1],col_names = FALSE)
filename<-eeg_power_files[1]

load_eeg_power <- function(filename) {
  if (!file.exists(filename)) {
    warning(paste("Missing", filename))
    return(NULL)
  }
  
  #load file
  df <- read_csv(filename,col_names = FALSE)
  
  #tidy (add col and row names)
  
  #colnames(df) <- c('101', '102', '103', '104', '105', '106', '107', '108', '109',  '110', '111', '112', 
                   # '113', '114', '115', '116', '117', '118','119','120', 
                   # '121',  '122', '123', '124','125','126','127','128', '129','130') # BL participants
  
  
  #colnames(df) <- c('101', '103', '105', '107', '109',  '110', '111', '112', '116','118','119','120', 
                   # '121',  '122', '124','125','126','127','129','130') # T1 participants
  
  colnames(df) <- c('101', '102', '105', '107', '109',  '110', '111','118','119',
                   '122', '124','125','127','129','130') # T2 participants
  
  
  rownames(df) <- c('AF3',	'AF4',	'F7',	'F5',	'F3',	'F1',	'FZ',	'F2',	'F4',	'F6',	'F8',	'FC5',	'FC3'	,'FC1',	'FCZ'	,'FC2',	'FC4'	,'FC6'	,'T7'	,'C5',
                    'C3',	'C1',	'CZ'	,'C2',	'C4',	'C6'	,'T8'	,'CP5',	'CP3'	,'CP1',	'CP2'	,'CP4',	'CP6'	,'P7',	'P5',	'P3'	,'P1'	,'PZ'	,'P2',
                    'P4',	'P6',	'P8'	,'PO7',	'PO3'	,'POZ',	'PO4',	'PO8',	'O1',	'OZ',	'O2')
  
  # transpose values
  df<-t(df)
  
  #select only electrodes from significant cluster ('F2','FC2','FC4', 'FC6','CZ' , 'C2' ,  'C4', 
  # 'C6' ,  'T8' ,'CP2' , 'CP4' , 'CP6','P2',   'P8')
  roi = c('F2','FC2','FC4', 'FC6','CZ' , 'C2' ,  'C4','C6' ,  'T8' ,'CP2' , 'CP4' , 'CP6','P2', 'P8')
  
  df<- df [,roi]
  
  #calculate mean for each participant and create new df
  df<-as.data.frame(rowMeans(df))
  
  
  #pull apart file name for row column name
  all <- stringr::str_split(filename, pattern="_")
  frequency<- all[[1]][2]
  group<- all[[1]][3]
  condition<-all[[1]][4]
  power_type<-all[[1]][5]
  power_type<-stringr::str_split(power_type, "csv")
  power_type<-power_type[[1]][1]
  
  
  #create new columns I want
  colnames(df)<- frequency
  df$group <- group
  df$condition <- condition
  df$power_type<- power_type
  setDT(df, keep.rownames = "id")[]
  
  #change shape of df
  df<-gather(df, key=frequency, value=mean_power, -group, -condition, - id, -power_type)
  
  return(df) }

#check it works for one
#trial_df<- load_eeg_power(eeg_power_files[1])

eeg_alpha_roi_mtbi_t2 <- df
#apply to all
eeg_df_tbi_t1 <- map_df(eeg_power_files, load_eeg_power)

# tidy the format
eeg_alpha_roi_mtbi_t2<-eeg_alpha_roi_mtbi_t2 %>%
  spread(key=frequency, value=mean_power)

## merge dataframes together
power_df_t1 <- rbind(eeg_df_control_t1,eeg_df_tbi_t1)

#merge alpha df's together
power_df_ROI_t2 <- rbind(eeg_alpha_roi_mtbi_t2,eeg_alpha_roi_control_t2)

## save power_df so do not have to run again 
#save(power_df_t1, file= "~/Documents/PHD-Data-Analysis/PHD-Data-Analysis/Analysis/Data/eeg_resting_power/power_df_t1.Rdata")

save(power_df_ROI_bl, file= "~/Documents/PHD-Data-Analysis/PHD-Data-Analysis/Analysis/Data/eeg_resting_power/power_df_ROI_bl.Rdata")
save(power_df_ROI_t1, file= "~/Documents/PHD-Data-Analysis/PHD-Data-Analysis/Analysis/Data/eeg_resting_power/power_df_ROI_t1.Rdata")
save(power_df_ROI_t2, file= "~/Documents/PHD-Data-Analysis/PHD-Data-Analysis/Analysis/Data/eeg_resting_power/power_df_ROI_t2.Rdata")
