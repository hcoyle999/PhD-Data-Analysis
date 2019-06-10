#TMS-EEG Analysis for Control and mTBI
# Load necessary libraries
library(tidyr, dplyr, broom)

here<-"~/Documents/PHD-Data-Analysis/PHD-Data-Analysis"
setwd(here) #main path/homedirectory
#load data (already clean)
setwd("./Analysis/Data")
load("COMBINED_COG_PhD.Rdata")

#exclude participants 
COMBINED_COG_PhD <-subset(COMBINED_COG_PhD,!code %in% c(7, 16, 102))
#participants without tms-eeg data

#create dataframe for tms-eeg peak to peak analysis for TEP's

teps_p2p<- COMBINED_COG_PhD %>%
  group_by (group) %>%
  select(starts_with("teps"))

#replace 0's in latency values with NaN so correspond with matlab output
teps_p2p[teps_p2p==0] <- NaN

#get names of data sets
names(teps_p2p)

#make group a factor
teps_p2p$group<- as.factor(teps_p2p$group)

#box plots of amplitude for both groups for sig clusters Pre iTBS
  ###N100 component (pos cluster and neg cluster ROI) P60 component (pos cluster)
teps_p2p %>%
  select(group, teps_p2p_n100_negclus_amp_bl_pre, teps_p2p_n100_posclus_amp_bl_pre, teps_p2p_p60_posclus_amp_bl_pre) %>%
  gather(key="variable", value= "amplitude", -group,na.rm=FALSE) %>%
  mutate(variable=factor(variable, labels =c("n100_negclus", 
                                             "n100_posclus",
                                             "p60_posclus")))%>%
  ggplot(aes(x=variable, y = amplitude, fill=group))+
  geom_boxplot() +
  scale_fill_manual(values=c("#999999", "#FFB6C1")) +
  ggtitle("Peak Amplitude for ROI Analyses Pre iTBS") +
  theme(plot.title = element_text(hjust = 0.5))

# run quick t-tests
t.test(teps_p2p_n100_negclus_amp_bl_pre~ group)
t.test(teps_p2p_n100_posclus_amp_bl_pre~ group)
t.test(teps_p2p_p60_posclus_amp_bl_pre~ group)
#all significant ( which supports cluster based findings)

#box plots of amplitude for both groups for sig clusters Post iTBS
###N100 component (pos cluster and neg cluster ROI)

teps_p2p %>%
  select(group, teps_p2p_n100_negclus_amp_bl_post, teps_p2p_n100_posclus_amp_bl_post) %>%
  gather(key="variable", value= "amplitude", -group,na.rm=FALSE) %>%
  mutate(variable=factor(variable, labels =c("n100_negclus", 
                                             "n100_posclus")))%>%
  ggplot(aes(x=variable, y = amplitude, fill=group))+
  geom_boxplot() +
  scale_fill_manual(values=c("#999999", "#FFB6C1")) +
  ggtitle("Peak Amplitude for ROI Analyses Post iTBS") +
  theme(plot.title = element_text(hjust = 0.5))

# run quick t-tests
t.test(teps_p2p_n100_negclus_amp_bl_post~ group)
t.test(teps_p2p_n100_posclus_amp_bl_post~ group)
# significant

#run t-tests across whole data frame
teps_p2p %>%
  ungroup(group) %>%
  select_if(is.numeric) %>%
  map_df(~ broom::tidy(t.test(. ~ group)), .id = 'var') %>%
  select(var, estimate1, estimate2, statistic, p.value, method) %>%
  setNames(c(var='variable',estimate1='control_mean', estimate2='mtbi_mean',
             statistic='t_stat',p.value='p_value',method='method')) %>%
  kable() %>%
  kable_styling()

#correlation matrix
library(corrplot)

df_amp<- COMBINED_COG_PhD %>%
  select(group, code, teps_p2p_n100_negclus_amp_bl_pre, teps_p2p_n100_posclus_amp_bl_pre,
         teps_p2p_n100_posclus_amp_bl_post,teps_p2p_n100_negclus_amp_bl_post, 
         teps_p2p_p60_posclus_amp_bl_pre) #create df of just amplitude

df_amp<- df_amp %>%
  rename(n100_pos_pre="teps_p2p_n100_posclus_amp_bl_pre",
        n100_neg_pre="teps_p2p_n100_negclus_amp_bl_pre",
        n100_pos_post="teps_p2p_n100_posclus_amp_bl_post",
        n100_neg_post="teps_p2p_n100_negclus_amp_bl_post",
        p60_pos_pre="teps_p2p_p60_posclus_amp_bl_pre")   # trying to rename so can mere with cog_bl and do corr_mat
                                                        #not working for some reason
#merge with cog_bl

corr_df<- COMBINED_COG_PhD %>%
  select(group, coding_bl,ravlt_t1_bl,teps_p2p_n100_posclus_amp_bl_pre,
         teps_p2p_n100_negclus_amp_bl_pre) 

corr_df$group<- as.factor(corr_df$group)
  
#rename to make shorter
corr_df<- rename(corr_df,"n100_posclus_amp_pre"="teps_p2p_n100_posclus_amp_bl_pre", 
            "n100_negclus_amp_pre"="teps_p2p_n100_negclus_amp_bl_pre")

corr_mat <- cor(corr_df)
corrplot(corr_mat, method="circle")

#scatterplot with coding and n100 amplitude and line of best fit
# resource
#http://www.sthda.com/english/wiki/ggplot2-scatter-plots-quick-start-guide-r-software-and-data-visualization#change-the-point-colorshapesize-automatically
ggplot(corr_df, aes(x=coding_bl, y=n100_negclus_amp_pre, colour=group)) +
  geom_point() +
  geom_smooth(method=lm, se=FALSE, fullrange=TRUE) +
  scale_color_manual(values=c("#999999", "#FFB6C1")) +
  theme_classic()

#for balance here is the pos cluster
ggplot(corr_df, aes(x=coding_bl, y=n100_posclus_amp_pre, colour=group)) +
  geom_point() +
  geom_smooth(method=lm, se=FALSE, fullrange=TRUE) +
  scale_color_manual(values=c("#999999", "#FFB6C1")) +
  theme_classic()

#correlation by group
ddply(corr_df, .(group),
      summarise, "corr" = cor(coding_bl, n100_posclus_amp_pre, 
                              method = "spearman"))
corr_df %>% 
  group_by(group) %>%
  summarize(correlation = cor(coding_bl, n100_posclus_amp_pre)) #this should do what the function
                                                              # above does but not working.
# corr.test for all
cor.test(corr_df$coding_bl, corr_df$n100_posclus_amp_pre) 
# corr.test by group
cor.test(formula = ~ coding_bl + n100_negclus_amp_pre,
         data = corr_df,
         subset = group == "mtbi") # another way of doing it without the pretty table

#correlations returned as a df 
  corr_df %>% 
  nest(-group) %>% 
  mutate(
    test = map(data, ~ cor.test(.x$coding_bl, .x$n100_negclus_amp_pre)),
    tidied = map(test, tidy)
  ) %>%
  unnest(tidied, .drop = TRUE) %>%
  select(group, statistic, parameter, estimate, p.value) %>%
    setNames(c(group='group',statistic='t_stat', parameter='df', estimate='corr',p.value='p_value')) %>%
    #filter(p_value <0.05)
    kable() %>%
    kable_styling() #doesn't have name of comparison I ran in it
    
  
