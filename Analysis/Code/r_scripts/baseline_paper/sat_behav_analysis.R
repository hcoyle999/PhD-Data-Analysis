
## ---- Load libraries ----

library(tidyverse)
library(here)

## ---- SourceFiles ----
here<-"~/Documents/PHD-Data-Analysis/PHD-Data-Analysis"
setwd(here)
setwd("./Analysis/Data/sat_behavioural_analysis")
sat_behav_files <- list.files(pattern=glob2rx("*.txt"), 
                             path=".", 
                             recursive = TRUE,
                             full.names = FALSE)
head(sat_behav_files)
length(sat_behav_files)

## ---- Preprocessing SAT files (raw) ----
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
trial_df<- load_sat_behav(sat_behav_files[15])

#apply to all
sat_df <- map_df(sat_behav_files, load_sat_behav)

# add groups and tidy data
sat_df$Subject.ID<- as.numeric(sat_df$Subject.ID)
sat_df<- mutate(sat_df, group= ifelse(Subject.ID <100, "Control", "TBI"))
sat_df$group<- as.factor(sat_df$group)
glimpse(sat_df)
#new_df <- lapply(sat_behav_files, load_sat_behav)

#make 0's NA's (because are for when 100% accuracy for no go yeilds no RT)
sat_df[sat_df == 0] <- NA

# save data for using later 
save(sat_df, file="~/Documents/PHD-Data-Analysis/PHD-Data-Analysis/Analysis/Data/sat_df.Rdata")


## ---- Analyse the SAT data ----
# first load 
 load("~/Documents/PHD-Data-Analysis/PHD-Data-Analysis/Analysis/Data/sat_df.Rdata")
 
# Final sample = 17 controls, 20 mtbi (37 in total)

# quick visualise the data
# boxplot for Average RT
sat_df %>%
  group_by(group) %>%
  select(group, Condition, Avg.RT) %>%
  ggplot(aes(x=Condition, y = Avg.RT, fill=group))+
  geom_boxplot() +
  scale_fill_manual(values=c("#999999", "#FFB6C1"))+
  facet_grid(~group)
setwd("./Analysis/Figures")
ggsave("Go_No_Go_RT_box.jpg")

#idenitfy the outlier
sat_df %>%
  select(Subject.ID, Condition, group, Avg.RT) %>%
  filter(Condition == "NoGo") %>%
  filter(Avg.RT > 300) #control participant number 21

#create summary stats
library(Rmisc)
sat_RT_summary<- sat_df %>%
  group_by(group, Condition) %>%
  select(Avg.RT) %>%
  set_colnames(c("group","Condition", "Avg.RT")) %>%
  gather(key="measure", value= "Avg.RT", -group, -Condition, na.rm=TRUE) %>%
  summarySE(measurevar="Avg.RT", groupvars=c("group","Condition", "measure"))

# visualise RT in bar for publication 
rt_graph<- sat_RT_summary%>%
  #mutate(measure=factor(measure, labels ="alpha")) %>%
  ggplot(aes(x=Condition, y=Avg.RT, fill=group)) + 
  geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=Avg.RT-se, ymax=Avg.RT+se),
                width=.2,                    # Width of the error bars
                position=position_dodge(.9))+
  ylab("Reaction time (ms)") +
  theme_light() +
  facet_grid(~group) +
  scale_fill_manual(values=c("#999999", "#FFB6C1")) +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        axis.title.x=element_blank()) 

setwd("./Analysis/Figures")
ggsave("Go_No_Go_RT_bar.jpg")

#summary statistics 
sum_sat_df<- sat_df %>%
  group_by(group, Condition) %>%
  select(-Subject.ID) %>%
  summarise_all(.funs=c(mean="mean",sd="sd"),na.rm=TRUE)

#statistical comparisons for RT (with interaction affect)
sat_aov <- aov (Avg.RT ~ group * Condition, data= sat_df)
summary(sat_aov)
etaSquared(sat_aov, anova=TRUE)
tidy(sat_aov)

#post-hoc testing 

TukeyHSD(sat_aov, which = "Condition")  #tukey hsd post hoc

pair_t<- pairwise.t.test(df_pre_post$value, 
                         df_pre_post$group,
                         p.adjust="bonferroni") # pairwise compar post hoc
pair_t <- tidy(pair_t)

pair_t<- pairwise.t.test(sat_df$Avg.RT, 
                          sat_df$group:sat_df$Condition,
                          p.adjust="bonferroni")
pair_t <- tidy(pair_t)

# Visualisation and Stats for Accuracy Data

#create summary scores
library(Rmisc)
sat_acc_summary<- sat_df %>%
  group_by(group, Condition) %>%
  select(Accuracy) %>%
  set_colnames(c("group","Condition", "Accuracy")) %>%
  gather(key="measure", value= "Accuracy", -group, -Condition, na.rm=TRUE) %>%
  summarySE(measurevar="Accuracy", groupvars=c("group","Condition", "measure"))

# boxplot for Accuracy
sat_df %>%
  group_by(group) %>%
  select(group, Condition, Accuracy) %>%
  ggplot(aes(x=Condition, y = Accuracy, fill=group))+
  geom_boxplot() +
  scale_fill_manual(values=c("#999999", "#FFB6C1")) + 
  facet_grid(~group)

# look for outlier
sat_df %>%
  select(Subject.ID, Condition, group, Accuracy) %>%
  filter(Condition == "NoGo") %>%
  filter(Accuracy < 0.80) # control participant number 17 

# visualise accuracy in bar graph
acc_graph<- sat_acc_summary %>%
  #mutate(measure=factor(measure, labels ="alpha")) %>%
  ggplot(aes(x=Condition, y=Accuracy, fill=group)) + 
  geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=Accuracy-se, ymax=Accuracy+se),
                width=.2,                    # Width of the error bars
                position=position_dodge(.9))+
  ylab("% Correct") +
  #ggtitle("Mean Accuracy Performance") +
  theme_light() +
  facet_grid(~group) +
  scale_fill_manual(values=c("#999999", "#FFB6C1")) +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        axis.title.x=element_blank()) 

#save graph
setwd("./Analysis/Figures")
ggsave("Go_No_Go_Acc_bar.jpg")

#Run statistica comparisons for Accuracy (with interaction affect)
sat_aov_acc <- aov (Accuracy ~ group * Condition, data= sat_df)
summary(sat_aov_acc)
tidy(sat_aov_acc)
etaSquared(sat_aov_acc, anova=TRUE)

# Post- hoc testing
TukeyHSD(sat_aov_acc, which = "Condition")  #tukey hsd post hoc
pair_t<- pairwise.t.test(sat_df$Accuracy, 
                         sat_df$group:sat_df$Condition,
                         p.adjust="bonferroni")
pair_t <- tidy(pair_t)

# put two graphs together in ggplot (also create a bar plot of RT for consistency)
library(ggpubr)
ggarrange(rt_graph, acc_graph, 
          labels = c("A", "B"),
          #ncol = 2, nrow = 2,
          common.legend = TRUE, legend = "right")
ggsave("Go_NoGo_plot_pubvers.jpg")


###---- Correlation analysis ----
# get into wide format
sat_df_1 <-sat_df %>%
  group_by(group, Condition) %>%
  select(-Accuracy) %>%
  gather(measure, Avg.RT, -group, -Condition, -Subject.ID) %>%
  spread(Condition, Avg.RT)

colnames(sat_df_1)[colnames(sat_df_1) == 'Go'] <- 'Go_RT'
colnames(sat_df_1)[colnames(sat_df_1) == 'NoGo'] <- 'NoGo_RT'
sat_df_1$measure <-NULL

sat_df_2 <-  sat_df %>%
group_by(group, Condition) %>%
  select(-Avg.RT) %>%
  gather(measure, Accuracy, -group, -Condition, -Subject.ID) %>%
  spread(Condition, Accuracy)

colnames(sat_df_2)[colnames(sat_df_2) == 'Go'] <- 'Go_Acc'
colnames(sat_df_2)[colnames(sat_df_2) == 'NoGo'] <- 'NoGo_Acc'
sat_df_2$measure <-NULL

#merge dfs
all<-merge(sat_df_1, sat_df_2)
#output to csv so can add to SPSS
setwd(here)
setwd("./Analysis/Data")
write.csv(all, "CRT_BL_all.csv") # for putting into SPSS but very slow

cog_1<-COMBINED_COG_PhD %>%
  select(code, group, coding_bl, ds_fwd_bl, tma_bl)
#change names to match and tidy
colnames(all)[colnames(all) == 'Subject.ID'] <- 'code'
#colnames(all)[colnames(all) == 'Group'] <- 'group'


sat_corr_df<-merge(all,cog_1, by= c("code")) ## yay got there in the end
sat_corr_df$group.x <-NULL
colnames(sat_corr_df)[colnames(sat_corr_df) == 'group.y'] <- 'group'

ggplot(sat_corr_df, aes(x=Go_RT, y=coding_bl, colour=group)) +
  geom_point() +
  geom_smooth(method=lm, se=FALSE, fullrange=TRUE) +
  scale_color_manual(values=c("#999999", "#FFB6C1")) +
  theme_classic()

ddply(sat_corr_df, .(group), summarise, "corr" = cor(NoGo_Acc, coding_bl, method = "spearman"))  

mtbi_sat_corr <- sat_corr_df %>%
  subset(group == "mtbi")
control_sat_corr <- sat_corr_df %>%
  subset(group == "control")


ggplot(sat_corr_df, aes(x=Go_RT, y=coding_bl, colour=group)) +
  geom_point() +
  geom_smooth(method=lm, se=FALSE, fullrange=TRUE) +
  scale_color_manual(values=c("#999999", "#FFB6C1")) +
  theme_classic()
cor.test(mtbi_sat_corr$Go_RT, mtbi_sat_corr$coding_bl,alternative="less", method="pearson") 
## CODING - SUMMARY OF RESULTS
# sig neg corr with Go_RT and coding for controls (not for mTBI)
    # suggests  as Total coding score decreases Go_RT increases

## DSF
# no sig correlations

ggplot(sat_corr_df, aes(x=Go_RT, y=tma_bl, colour=group)) +
  geom_point() +
  geom_smooth(method=lm, se=FALSE, fullrange=TRUE) +
  scale_color_manual(values=c("#999999", "#FFB6C1")) +
  theme_classic()
cor.test(control_sat_corr$Go_RT, control_sat_corr$tma_bl,alternative="greater", method="pearson")
cor.test(mtbi_sat_corr$Go_RT, mtbi_sat_corr$tma_bl,alternative="greater", method="pearson") 
# Trails A SUMMARY of RESULTS
 #sig positive correlation with Trails A for both controls and mTBI 
 ## as tma_bl time taken increases, so does Go_RT (suggests that they are a good 
 # measure of processing speed)


## Load in datframe with GFP results added to it

CRT_all<- read_csv('CRT_data_all.csv', col_names =TRUE)
str(CRT_all)

CRT_all$group <- factor(CRT_all$group)                   
CRT_all$measure <- factor(CRT_all$measure)  


CRT_GFP_summary<- CRT_all %>%
  group_by(group) %>%
  filter(measure=="GFP") %>%
  gather(key="condition", value= "GFP", -group, -Subject.ID,-measure) %>%
  summarySE(measurevar="GFP", groupvars=c("group","measure","condition"))

#create graph of global field mean power for both time windows
g<-CRT_GFP_summary %>%
  mutate(condition=factor(condition, labels =c("Go","NoGo"))) %>%
  ggplot(aes(x=condition, y=GFP, fill=group)) + 
  geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=GFP-se, ymax=GFP+se),
                width=.2,                    # Width of the error bars
                position=position_dodge(.9))+
  ylab("Global Mean Field Power") +
  #ggtitle("Global Field Mean Power") +
  theme_light() +
  labs(fill = "Group") +
  facet_grid(~group)+
  scale_fill_manual(values=c("#999999", "#FFB6C1")) +
  theme(plot.title = element_text(hjust = 0.5), 
        plot.subtitle = element_text(hjust = 0.5),
        #axis.text.x=element_blank(),
        axis.title.x=element_blank())
g+ ylim(0,3.5)
ggsave("GFP_CRT.jpg")

##---- Epoch analysis ----
# check epochs do not differ between groups or conditions
library(datapasta)
sat_epoch_df<- tibble::tribble(
  ~code, ~Go_Hit, ~NoGo_other,    ~Group,
      1,     118,         113, "Control",
      9,     117,         103, "Control",
     10,     111,         116, "Control",
     12,     113,         113, "Control",
     13,     115,         107, "Control",
     14,     112,         104, "Control",
     15,      99,          96, "Control",
     17,     108,          81, "Control",
     18,     110,         109, "Control",
     19,     116,         109, "Control",
     20,     111,         104, "Control",
     21,     113,         109, "Control",
     22,     113,         115, "Control",
     23,     117,         117, "Control",
     24,     111,         116, "Control",
     27,     114,         108, "Control",
     28,     118,         106, "Control",
    103,     113,         101,    "mTBI",
    105,     109,         111,    "mTBI",
    106,     119,         113,    "mTBI",
    108,     108,         106,    "mTBI",
    109,     113,         104,    "mTBI",
    110,     116,         107,    "mTBI",
    111,     108,         118,    "mTBI",
    112,     105,         107,    "mTBI",
    113,     114,         110,    "mTBI",
    114,     121,         112,    "mTBI",
    115,     109,         108,    "mTBI",
    116,      95,          90,    "mTBI",
    117,     113,         107,    "mTBI",
    119,     109,         108,    "mTBI",
    120,     114,         111,    "mTBI",
    122,     114,         109,    "mTBI",
    124,     117,         117,    "mTBI",
    127,     106,          83,    "mTBI",
    129,     112,         112,    "mTBI",
    130,     107,         106,    "mTBI"
  )
str(sat_epoch_df)
sat_epoch_df$Group<-factor(sat_epoch_df$Group)

summary<-sat_epoch_df %>%
  group_by(Group) %>%
  select(Group, Go_Hit, NoGo_other) %>%
  summarise_all(list(
    min = ~min,
    max = ~max,
    mean = ~mean,
    sd = ~sd), na.rm=TRUE)

#change table to have a condition column

epoch_df_aov<- sat_epoch_df  %>%
  gather(Condition, epoch_number, -Group, -code )

epoch_df_aov$Condition<-as.factor(epoch_df_aov$Condition)

#look for sig differences between the groups
anova<- aov(epoch_number ~ Group * Condition, data = epoch_df_aov)  

summary(anova) #main effect of condition

model.tables(anova, type="means", se = TRUE) #look at means and SE

#look for pairwise comparisons
TukeyHSD(anova, which = "Condition") #Go condition have a sig higher number of epochs

pairwise.t.test(epoch_df_aov$epoch_number, epoch_df_aov$Condition,
                p.adjust.method = "BH")

summary<-epoch_df_aov %>%
  group_by(Condition) %>%
  select(epoch_number) %>%
  summarise_all(list(
    min = ~min,
    max = ~max,
    mean = ~mean,
    sd = ~sd), na.rm=TRUE)
