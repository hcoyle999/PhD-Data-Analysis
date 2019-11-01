library(magrittr)
library(Rmisc)

## script to compare BL alpha power and T1 alpha power
here<-"~/Documents/PHD-Data-Analysis/PHD-Data-Analysis"
setwd(here) #main path/homedirectory
setwd("./Analysis/Data/eeg_resting_power")
#load data (already clean)
#load("power_df.Rdata")
#load("power_df_t1.Rdata") 
#load("power_df_t2.Rdata")

#for alpha only
load("power_df_ROI_bl.Rdata")
load("power_df_ROI_t1.Rdata")
load("power_df_ROI_t2.Rdata")

# add timepoints 
power_df_ROI_bl$timepoint <- 'BL'
power_df_ROI_t1$timepoint <- 'T1'
power_df_ROI_t2$timepoint <- 'T2'  # add timepoint column

power_df_all <- rbind(power_df_ROI_bl,power_df_ROI_t1,power_df_ROI_t2)

lut <-c ("Control" = "control", "TBI" = "mtbi")
power_df_all$group <- lut[power_df_all$group]

# look just at alpha absolute power
str(power_df_all)
#tidy new dataset
power_df_all$group<-factor(power_df_all$group)
power_df_all$condition<-factor(power_df_all$condition)
power_df_all$timepoint<-factor(power_df_all$timepoint)
power_df_all$power_type<-factor(power_df_all$power_type)
power_df_all<- power_df_all %>%
  dplyr::rename(code = "id")

# get in order to put into SPSS (though should be able to add to df?)
alpha_df<-power_df_all %>%
  mutate(id= as.numeric(id)) %>%
  group_by(group, timepoint) 

write_csv(alpha_df, "alpha_df_ROI.csv")


alpha_summary<- alpha_df %>%
  group_by(group, timepoint) %>%
  select(alpha) %>%
  set_colnames(c("group","timepoint", "alpha")) %>%
  gather(key="measure", value= "alpha_power", -group, -timepoint, na.rm=TRUE) %>%
  summarySE(measurevar="alpha_power", groupvars=c("group","measure", "timepoint"))

# quick graph as a bar graph
alpha_summary %>%
  mutate(measure=factor(measure, labels ="alpha")) %>%
  ggplot(aes(x=measure, y=alpha_power, fill=group)) + 
  geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=alpha_power-se, ymax=alpha_power+se),
                width=.2,                    # Width of the error bars
                position=position_dodge(.9))+
  ylab("Alpha Power") +
  facet_grid(~timepoint)+
  theme_light() +
  scale_fill_manual(values=c("deepskyblue1","royalblue4"))+
  ggtitle(" ROI Mean Absolute Power Eyes Closed") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        axis.title.x=element_blank(),
        axis.text.x=element_blank())

setwd(here)
setwd("./Analysis/Figures")
ggsave("alpha_power_ROI_long.png") ## this plot is for pre submission seminar


  # quick graph as a line graph
  
  gbase<- alpha_summary %>%
    ggplot(aes(y= alpha_power, x= timepoint, colour=group))+
    geom_point()  #+ facet_grid(~group)
    #geom_errorbar(aes(ymin = alpha_power - se, ymax = alpha_power + se),
                  #width=.2) ## optional SE bars, make graph look messy though
  
  
  gline <- gbase + geom_line() 
  alpha_summary$time = as.numeric(alpha_summary$timepoint)
  gline <- gline %+% alpha_summary
  print(gline + aes(x=time)+
          scale_x_continuous(breaks=c(1:3), labels=c("BL", "T1", "T2")))
  
  
  ## subset the data frame to look at alpha power in mTBI participants ONLY but across the three timepoints
  tbi_subset<- power_df_all %>%
    filter(group == "TBI") %>%
    filter(condition == "ec") %>%
    select(id, group, condition, alpha, timepoint) # create df with just the info I need
  
  tbi_subset <-subset(tbi_subset,!id %in% c(104, 106, 108, 113, 114,
                                            115, 117,  123, 128))  #these are ppl who only have bsl data                                          
  
  str(tbi_subset)
  #tbi_subset$timepoint<- as.numeric(tbi_subset$timepoint) # to fix error change timepoint back from factor to numeric
  
  # plot individual mTBI data
  ggplot(data =  tbi_subset, aes(x = timepoint, y = alpha, group=1)) + geom_line() +
    facet_wrap(~id)
  
  
  ## do same for control
  control_subset<- power_df_all %>%
    filter(group == "Control") %>%
    filter(condition == "ec") %>%
    select(id, group, condition, alpha, timepoint) # create df with just the info I need
  
  control_subset <-subset(control_subset,!id %in% c(104, 106, 108, 113, 114,
                                            115, 117,  123, 128))  #these are ppl who only have bsl data                                          
  
  str(control_subset)
  control_subset$id <- as.numeric(control_subset$id)
  control_subset<- control_subset %>%
    arrange(id) # get codes in correct order
  #tbi_subset$timepoint<- as.numeric(tbi_subset$timepoint) # to fix error change timepoint back from factor to numeric
  ggplot(data =  control_subset, aes(x = timepoint, y = alpha, group=1)) + geom_line() +
    facet_wrap(~id)
  
  
  str(power_df_all)
  power_df_all$id <-as.numeric(power_df_all$id)
  # bar graph of summary stats of individuals who did ALL measures
  power_df_subset <-subset(power_df_all,id %in% c('101', '105', '107',  
                                                  '109',  '110', '111', '118','119',   
                                                  '122', '124','125','127','129','130',
                                                  '1','2','3','4','5','6',
                                                  '8', '9','10',  '11', '12','13',
                                                  '14','17', '18','20', '21','22',
                                                  '23','25','26','28')) 

  
  power_df_subset_sum<- power_df_subset %>% 
    filter(condition== "ec") %>%
    group_by(group, timepoint) %>%
    select(alpha) %>%
    set_colnames(c("group","timepoint", "alpha")) %>%
    gather(key="measure", value= "alpha_power", -group, -timepoint, na.rm=TRUE) %>%
    summarySE(measurevar="alpha_power", groupvars=c("group","measure", "timepoint"))
  
  power_df_subset_sum %>%
    mutate(measure=factor(measure, labels ="alpha")) %>%
    ggplot(aes(x=measure, y=alpha_power, fill=group)) + 
    geom_bar(position=position_dodge(), stat="identity") +
    geom_errorbar(aes(ymin=alpha_power-se, ymax=alpha_power+se),
                  width=.2,                    # Width of the error bars
                  position=position_dodge(.9))+
    ylab("Alpha Power") +
    facet_grid(~timepoint)+
    theme_light() +
    scale_fill_manual(values=c("deepskyblue1","royalblue4"))+
    ggtitle("Mean Absolute Power Eyes Closed (full sample)") +
    theme(plot.title = element_text(hjust = 0.5),
          plot.subtitle = element_text(hjust = 0.5),
          axis.title.x=element_blank())  ## so this is a graph of just individuals who did BL, T1 and T2
                                        ## 
  
  #quick stats
  t<- power_df_all %>%
    filter(timepoint == "T2") %>%
    filter(condition == "ec") %>%
    select(id, group, alpha)
  
  t$group <- factor(t$group)
  str(t)
  t.test(alpha ~ group, data = t)  # sig group differences at BL but not at T1 or T2 (matches cluster based stats)
  
  
  # add to main df
  alpha_add<- power_df_all %>%
    spread(key=timepoint, value= alpha ) %>%
    dplyr::rename(
      alpha_bl = "BL",
      alpha_t1 = "T1",
      alpha_t2 = "T2"
    ) %>%
    select(code, group, alpha_bl, alpha_t1, alpha_t2)
  
  #COMBINED_COG_PhD<- merge(COMBINED_COG_PhD, alpha_add, by= c("code", "group"))
  # save(COMBINED_COG_PhD, file="~/Documents/PHD-Data-Analysis/PHD-Data-Analysis/Analysis/Data/COMBINED_COG_PhD.Rdata")
  save(power_df_all,file="~/Documents/PHD-Data-Analysis/PHD-Data-Analysis/Analysis/Data/power_df_all.Rdata")
  
  