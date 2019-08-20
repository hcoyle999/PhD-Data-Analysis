## ---- Libraries ----

library(tidyverse)
library(here)
library(data.table)
library(Rmisc)

## ---- SourceFiles ----
here<-"~/Documents/PHD-Data-Analysis/PHD-Data-Analysis"
setwd(here) #main path/homedirectory
#load data (already clean)
setwd("./Analysis/Data/eeg_resting_power/control")
eeg_power_files <- list.files(pattern=glob2rx("*.csv"), 
                              path=".", 
                              recursive = TRUE,
                              full.names = FALSE)
head(eeg_power_files)
length(eeg_power_files)

## ---- SourceFilesAlternative ----
## save the filenames so we can repeat later on
writeLines(eeg_power_files, "eeg_power_files.lst")
eeg_power_files <- readLines("eeg_power_files.lst")

# load one for testing purposes
#df <- read_csv(eeg_power_files[1],col_names = FALSE)
#filename<-eeg_power_files[1]

load_eeg_power <- function(filename) {
  if (!file.exists(filename)) {
    warning(paste("Missing", filename))
    return(NULL)
  }
  
#load file
  df <- read_csv(filename,col_names = FALSE)
  
#tidy (add col and row names)
colnames(df) <- c("1","2","3", "4","5","6","8","9","10","11","12","13","14","15",
                  "17","18","19","20","21","22","23","24","25","26","27","28")

rownames(df) <- c('AF3',	'AF4',	'F7',	'F5',	'F3',	'F1',	'FZ',	'F2',	'F4',	'F6',	'F8',	'FC5',	'FC3'	,'FC1',	'FCZ'	,'FC2',	'FC4'	,'FC6'	,'T7'	,'C5',
                  'C3',	'C1',	'CZ'	,'C2',	'C4',	'C6'	,'T8'	,'CP5',	'CP3'	,'CP1',	'CP2'	,'CP4',	'CP6'	,'P7',	'P5',	'P3'	,'P1'	,'PZ'	,'P2',
                  'P4',	'P6',	'P8'	,'PO7',	'PO3'	,'POZ',	'PO4',	'PO8',	'O1',	'OZ',	'O2')

# transpose values
df<-t(df)

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

#apply to all
eeg_df_control <- map_df(eeg_power_files, load_eeg_power)

# tidy the format
eeg_df_control<-eeg_df_control %>%
  spread(key=frequency, value=mean_power)

# do again for TBI 
here<-"~/Documents/PHD-Data-Analysis/PHD-Data-Analysis"
setwd(here) #main path/homedirectory
#load data (already clean)
setwd("./Analysis/Data/eeg_resting_power/tbi")
eeg_power_files <- list.files(pattern=glob2rx("*.csv"), 
                              path=".", 
                              recursive = TRUE,
                              full.names = FALSE)
head(eeg_power_files)
length(eeg_power_files)

## ---- SourceFilesAlternative ----
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
  colnames(df) <- c("101","102","103", "104","105","106","107", "108","109","110","111","112","113","114","115",
                    "116", "117","118","119","120","121","122","123","124","125","126","127","128","129","130")
  
  rownames(df) <- c('AF3',	'AF4',	'F7',	'F5',	'F3',	'F1',	'FZ',	'F2',	'F4',	'F6',	'F8',	'FC5',	'FC3'	,'FC1',	'FCZ'	,'FC2',	'FC4'	,'FC6'	,'T7'	,'C5',
                    'C3',	'C1',	'CZ'	,'C2',	'C4',	'C6'	,'T8'	,'CP5',	'CP3'	,'CP1',	'CP2'	,'CP4',	'CP6'	,'P7',	'P5',	'P3'	,'P1'	,'PZ'	,'P2',
                    'P4',	'P6',	'P8'	,'PO7',	'PO3'	,'POZ',	'PO4',	'PO8',	'O1',	'OZ',	'O2')
  
  # transpose values
  df<-t(df)
  
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

#apply to all
eeg_df_tbi <- map_df(eeg_power_files, load_eeg_power)

# tidy the format
eeg_df_tbi<-eeg_df_tbi %>%
  spread(key=frequency, value=mean_power)

## merge dataframes together
power_df <- rbind(eeg_df_control,eeg_df_tbi)

# look just at alpha absolute power
str(power_df)
#tidy new dataset
power_df$group<-factor(power_df$group)
power_df$condition<-factor(power_df$condition)
power_df$power_type<-factor(power_df$power_type)

# select the components I want (alpha, aboslute power, ec)
alpha_df<-power_df %>%
  group_by(group) %>%
  filter(power_type=="abs.") %>%
  filter(condition=="ec") %>%
  select(id:alpha)
# quick stat comparison
t.test(alpha ~ group, data=alpha_df)

alpha_summary<- alpha_df %>%
  group_by(group) %>%
  select(alpha) %>%
  set_colnames(c("group","alpha")) %>%
  gather(key="measure", value= "alpha_power", -group, na.rm=TRUE) %>%
  summarySE(measurevar="alpha_power", groupvars=c("group","measure"))

# quick graph 
alpha_summary %>%
  mutate(measure=factor(measure, labels ="alpha")) %>%
  ggplot(aes(x=measure, y=alpha_power, fill=group)) + 
  geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=alpha_power-se, ymax=alpha_power+se),
                width=.2,                    # Width of the error bars
                position=position_dodge(.9))+
  ylab("Alpha Power") +
  ggtitle("Mean Absolute Power") +
  theme_light() +
  scale_fill_manual(values=c("#999999", "#FFB6C1")) +
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5))

# look at absolute power across frequency bands
absolute_df<-power_df %>%
  group_by(group) %>%
  filter(power_type=="abs.")

absolute_summary<- absolute_df %>%
  group_by(group, condition, power_type) %>%
  select(alpha:theta) %>%
  #set_colnames(c("group","condition")) %>%
  gather(key="measure", value= "power", -group, -condition, -power_type, na.rm=TRUE) %>%
  summarySE(measurevar="power", groupvars=c("group","measure","condition","power_type"))

absolute_summary %>%
  mutate(measure=factor(measure, labels =c("alpha","beta","gamma","theta"))) %>%
  mutate(condition=factor(condition, labels =c("eo","ec"))) %>%
  ggplot(aes(x=measure, y=power, fill=group)) + 
  geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=power-se, ymax=power+se),
                width=.2,                    # Width of the error bars
                position=position_dodge(.9))+
  xlab("Frequency band")+
  ylab("Mean EEG Power") +
  ggtitle("Mean Absolute Power") +
  theme_light() +
  scale_fill_manual(values=c("#999999", "#FFB6C1")) +
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5))+
  facet_grid(~condition)
getwd()
setwd("./Analysis/Figures")
ggsave("Absolute_Power.jpg")
 
# look at absolute and relative power

power_summary<- power_df %>%
  group_by(group, condition, power_type) %>%
  select(alpha:theta) %>%
  #set_colnames(c("group","condition")) %>%
  gather(key="measure", value= "power", -group, -condition, -power_type, na.rm=TRUE) %>%
  summarySE(measurevar="power", groupvars=c("group","measure","condition","power_type"))

power_summary$condition = with(power_summary, reorder(Species, Sepal.Width, mean))

power_summary %>%
  filter(power_type=="abs.") %>%
  mutate(measure=factor(measure, levels =c("theta","alpha","beta","gamma"))) %>%
  mutate(condition=factor(condition, labels =c("Eyes Open","Eyes Closed"),levels= c("eo","ec"))) %>%
  #mutate(power_type=factor(power_type, labels =c("abs.","rel."))) %>%
  ggplot(aes(x=measure, y=power, fill=group)) + 
  geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=power-se, ymax=power+se),
                width=.2,                    # Width of the error bars
                position=position_dodge(.9))+
  xlab("Frequency band")+
  ylab("Power (arbitrary units)") +
  #ggtitle("Mean AbsolutePower") +
  theme_light() +
  scale_fill_manual(values=c("#999999", "#FFB6C1")) +
  theme(plot.title = element_text(hjust = 0.5), 
        plot.subtitle = element_text(hjust = 0.5),
        axis.title.x= element_blank(),
        legend.title=element_blank(),
        legend.background = element_rect(colour = 'grey', fill = 'white', linetype='solid'))+
  facet_grid(~condition)

getwd()
setwd(here)
setwd("./Analysis/Figures")
ggsave("Absolute_Power.jpg")

# Does alpha power correlate with verbal memory performance
library(dplyr)
str(power_df)
#create new df with alpha power and verbal memory measures
new_df <- power_df %>%
  filter(power_type =="abs.") %>%
  filter(condition== "ec") %>%
  select(id, group, condition, alpha)
#tidy
colnames(new_df)[colnames(new_df) == 'id'] <- 'code'
  
new_df_1<-COMBINED_COG_PhD %>%
  select(code, group, ravlt_t1_bl, ravlt_t_bl, ravlt_recognition)
#put together
df<-merge(x = new_df, y = new_df_1, by= "code")  
df$group.x = NULL
colnames(df)[colnames(df) == 'group.y'] <- 'group'

#graph
ggplot(df, aes(x=ravlt_t1_bl, y= alpha, colour=group)) +
  geom_point(shape=17, size= 2) +
  xlab("Verbal Memory") +
  ylab("Resting EEG Alpha Power") +
  geom_smooth(method=lm, se=FALSE, fullrange=TRUE) +
  scale_color_manual(values=c("#999999", "#FFB6C1")) +
  theme_classic() +
  theme(legend.title=element_blank(),
        legend.background = element_rect(colour = 'grey', fill = 'white', linetype='solid'))


cor.test(formula = ~ ravlt_t1_bl + alpha,
         data = df,
         subset = group == "mtbi",
         method= "pearson",
         alternative= "less") # split by group way of doing it without the pretty table

# Do power only for significant electrode cluster for alpha power
setwd(here)
setwd("./Analysis/Data/eeg_resting_power/tbi")
TBI_alpha<-read_csv('powermeanALL_alpha_TBI_ec_abs.csv', col_names = FALSE)

#tidy (add col and row names)
colnames(TBI_alpha) <- c("101","102","103", "104","105","106","107", "108","109","110","111","112","113","114","115",
                  "116", "117","118","119","120","121","122","123","124","125","126","127","128","129","130")

rownames(TBI_alpha) <- c('AF3',	'AF4',	'F7',	'F5',	'F3',	'F1',	'FZ',	'F2',	'F4',	'F6',	'F8',	'FC5',	'FC3'	,'FC1',	'FCZ'	,'FC2',	'FC4'	,'FC6'	,'T7'	,'C5',
                  'C3',	'C1',	'CZ'	,'C2',	'C4',	'C6'	,'T8'	,'CP5',	'CP3'	,'CP1',	'CP2'	,'CP4',	'CP6'	,'P7',	'P5',	'P3'	,'P1'	,'PZ'	,'P2',
                  'P4',	'P6',	'P8'	,'PO7',	'PO3'	,'POZ',	'PO4',	'PO8',	'O1',	'OZ',	'O2')


# transpose values
TBI_alpha<-t(TBI_alpha)
#chagnge structure from matrix
TBI_alpha<- as.data.frame(TBI_alpha)
#ROI (electrodes in sig cluster)

TBI_alpha <- TBI_alpha %>%
  select('F2','FC2',  'FC4' , 'FC6', 'CZ' , 'C2' ,  'C4'  ,  'C6' ,  'T8' ,
  'CP2' , 'CP4' , 'CP6','P2', 'P8')

TBI_alpha<- as.data.frame(rowMeans(TBI_alpha))
TBI_alpha$group <- "TBI"
setDT(TBI_alpha, keep.rownames = "id")[]
colnames(TBI_alpha)[colnames(TBI_alpha) == 'rowMeans(TBI_alpha)'] <- 'alpha_power'
 # Do same for control
setwd(here)
setwd("./Analysis/Data/eeg_resting_power/control")
Control_alpha<-read_csv('powermeanALL_alpha_Control_ec_abs.csv', col_names = FALSE)

#tidy (add col and row names)
colnames(Control_alpha) <- c("1","2","3", "4","5","6","8","9","10","11","12","13","14","15",
                                         "17","18","19","20","21","22","23","24","25","26","27","28")

rownames(Control_alpha) <- c('AF3',	'AF4',	'F7',	'F5',	'F3',	'F1',	'FZ',	'F2',	'F4',	'F6',	'F8',	'FC5',	'FC3'	,'FC1',	'FCZ'	,'FC2',	'FC4'	,'FC6'	,'T7'	,'C5',
                         'C3',	'C1',	'CZ'	,'C2',	'C4',	'C6'	,'T8'	,'CP5',	'CP3'	,'CP1',	'CP2'	,'CP4',	'CP6'	,'P7',	'P5',	'P3'	,'P1'	,'PZ'	,'P2',
                         'P4',	'P6',	'P8'	,'PO7',	'PO3'	,'POZ',	'PO4',	'PO8',	'O1',	'OZ',	'O2')


# transpose values
Control_alpha<-t(Control_alpha)
#chagnge structure from matrix
Control_alpha<- as.data.frame(Control_alpha)
#ROI (electrodes in sig cluster)

Control_alpha <- Control_alpha %>%
  select('F2','FC2',  'FC4' , 'FC6', 'CZ' , 'C2' ,  'C4'  ,  'C6' ,  'T8' ,
         'CP2' , 'CP4' , 'CP6','P2', 'P8')

#tidy so can merge
Control_alpha<- as.data.frame(rowMeans(Control_alpha))
Control_alpha$group <- "Control"
setDT(Control_alpha, keep.rownames = "id")[]
colnames(Control_alpha)[colnames(Control_alpha) == 'rowMeans(Control_alpha)'] <- 'alpha_power'


##  then merge
alpha_df_abs<- bind_rows(Control_alpha, TBI_alpha)
str(alpha_df_abs)
alpha_df_abs$group<- factor(alpha_df_abs$group)

#then graph as box plot
alpha_df_abs %>%
  gather(key="variable", value= "power", -group,-id, na.rm=FALSE) %>%
  ggplot(aes(x=variable, y = power, fill=group))+
  geom_boxplot() +
  scale_fill_manual(values=c("#999999", "#FFB6C1")) +
  ggtitle("Alpha for ROI Analyses Resting EEG") +
  theme(plot.title = element_text(hjust = 0.5))

#as bar graph
power_summary<- alpha_df_abs %>%
  group_by(group) %>%
  #set_colnames(c("group","condition")) %>%
  gather(key="measure", value= "power", -group, -id, na.rm=TRUE) %>%
  summarySE(measurevar="power", groupvars=c("group","measure"))

power_summary %>%
  mutate(measure=factor(measure, labels = "Alpha Power"))%>%
  ggplot(aes(x=measure, y=power, fill=group)) + 
  geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=power-se, ymax=power+se),
                width=.2,                    # Width of the error bars
                position=position_dodge(.9)) +
  ylab("Power (arbitrary units)") +
  ggtitle("Resting EEG ROI Alpha Power") +
  theme_light() +
  scale_fill_manual(values=c("#4169E1", "#FF6666")) +
  theme(plot.title = element_text(hjust = 0.5),
          plot.subtitle = element_text(hjust = 0.5),
          axis.title.x=element_blank(),
          #axis.title.y=element_blank(),
          #legend.position= c(0.9,0.9),
          legend.title = element_blank()) +
    theme(legend.background = element_rect(colour = 'grey', fill = 'white', linetype='solid'))

setwd(here)
setwd("./Analysis/Figures")
ggsave("Alpha_plot_pubvers.jpg")


## Look at correlation with clinical measures
new_df_1<-COMBINED_COG_PhD %>%
  select(code, group, ravlt_t1_bl, ravlt_t_bl, ravlt_recognition, coding_bl, hads_anxiety_bl, 
         hads_depression_bl, hads_total_bl, mfi_gf_bl, mfi_mf_bl, mfi_ra_bl, mfi_rm_bl, rpq_3_bl,
         rpq_13_bl)
#put together & tidy
colnames(alpha_df_abs)[colnames(alpha_df_abs) == 'id'] <- 'code'
alpha_df_abs$code<- as.numeric(alpha_df_abs$code)
df<-merge(x = alpha_df_abs, y = new_df_1, by= "code")  
str(alpha_df_abs)
colnames(df)[colnames(df) == 'group.y'] <- 'group'
df$group.x = NULL

#corr matrix
## Look for correlations
c<-df %>%
  select(-group, -code)

c_1<- cor(c,use = "complete.obs") # create corr matrix

library(Hmisc)
library(corrplot)

c_2<-rcorr(as.matrix(c),type = c("spearman"))

c_2$P #look at p values
c_2$r #look at r values

#visualise corr strength (association between alpha power and clinical and neuropsych measures)
corrplot(c_1, method="circle")

ggplot(df, aes(x=mfi_mf_bl, y=alpha_power, colour=group)) +
  geom_point(shape=17, size= 2)+
  xlab("MFI mental fatigue (total symptom score)") +
  ylab("Alpha Power") +
  geom_smooth(method=lm, se=FALSE, fullrange=TRUE) +
  scale_color_manual(values=c("#999999", "#FFB6C1")) +
  theme_classic()+
  theme(legend.title=element_blank(),
        legend.background = element_rect(colour = 'grey', fill = 'white', linetype='solid'))


