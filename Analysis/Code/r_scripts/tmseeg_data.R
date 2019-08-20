#TMS-EEG Analysis for Control and mTBI
# Load necessary libraries
library(tidyr, dplyr, broom)
library(tidyverse)

here<-"~/Documents/PHD-Data-Analysis/PHD-Data-Analysis"
setwd(here) #main path/homedirectory
#load data (already clean)
setwd("./Analysis/Data")
load("COMBINED_COG_PhD.Rdata")

#exclude participants 
COMBINED_COG_PhD_teps <-subset(COMBINED_COG_PhD,!code %in% c(7, 16, 102))
#participants without tms-eeg data

#create dataframe for tms-eeg peak to peak analysis for TEP's

teps_p2p<- COMBINED_COG_PhD_teps %>%
  group_by (group) %>%
  select(code, starts_with("teps")) %>%
  ungroup (group)

#replace 0's in latency values with NaN so correspond with matlab output
teps_p2p[teps_p2p==0] <- NaN

#get names of data sets
names(teps_p2p)


teps_p2p %>%
  filter(teps_p2p_n100_negclus_amp_bl_pre >5)

#look for outliers
#replace_outliers (teps_p2p$teps_p2p_n100_negclus_amp_bl_pre)

#make group a factor
teps_p2p$group<- as.factor(teps_p2p$group)

df_amp$group<- as.factor(df_amp$group)

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

# do as a bar graph for PRE
teps_p2p_summary<- teps_p2p %>%
  group_by(group) %>%
  select(teps_p2p_n100_negclus_amp_bl_pre, teps_p2p_n100_posclus_amp_bl_pre, teps_p2p_p60_posclus_amp_bl_pre) %>%
  gather(key="variable", value= "amplitude", -group,na.rm=FALSE) %>%
  mutate(variable=factor(variable, labels =c("N100 Neg clus", 
                                             "N100 Pos clus",
                                             "P60 Pos clus"))) %>%
  group_by(group, variable) %>%
  summarySE(measurevar="amplitude", groupvars=c("group", "variable"))

# bar graph for amplitude Pre for Accuracy
  teps_graph_pre<- teps_p2p_summary %>%
  ggplot(aes(x=variable, y=amplitude, fill=group)) + 
  geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=amplitude-se, ymax=amplitude+se),
                width=.2,                    # Width of the error bars
                position=position_dodge(.9))+
  ylab("Amplitude") +
  #ggtitle("Mean Accuracy Performance") +
  theme_light() +
  #facet_grid(group~variable) +
  scale_fill_manual(values=c("#999999", "#FFB6C1")) +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        axis.title.x=element_blank(),
        legend.position= c(0.9,0.9),
        legend.title = element_blank()) +
  theme(legend.background = element_rect(colour = 'grey', fill = 'white', linetype='solid'))
  
  #save graph
  setwd(here)
  setwd("./Analysis/Figures")
  ggsave("TEPs_P2P_Pre_BL.jpg")
  
  # do as a bar graph for POST (same as above so can put together)
  teps_p2p_summary_post<- teps_p2p %>%
    group_by(group) %>%
    select(teps_p2p_n100_negclus_amp_bl_post, teps_p2p_n100_posclus_amp_bl_post) %>%
    gather(key="variable", value= "amplitude", -group,na.rm=FALSE) %>%
    mutate(variable=factor(variable, labels =c("N100 Neg Cluster", 
                                               "N100 Pos Cluster"))) %>%
                                               
    group_by(group, variable) %>%
    summarySE(measurevar="amplitude", groupvars=c("group", "variable"))
  
  # bar graph for amplitude Pre for Accuracy
  teps_graph_post<- teps_p2p_summary_post %>%
    ggplot(aes(x=variable, y=amplitude, fill=group)) + 
    geom_bar(position=position_dodge(), stat="identity") +
    geom_errorbar(aes(ymin=amplitude-se, ymax=amplitude+se),
                  width=.2,                    # Width of the error bars
                  position=position_dodge(.9))+
    #ylab("Amplitude") +
    #ggtitle("Mean Accuracy Performance") +
    theme_light() +
    #facet_grid(group~variable) +
    scale_fill_manual(values=c("#999999", "#FFB6C1")) +
    theme(plot.title = element_text(hjust = 0.5),
          plot.subtitle = element_text(hjust = 0.5),
          axis.title.x=element_blank(),
          axis.title.y=element_blank(),
          legend.position= c(0.9,0.9),
          legend.title = element_blank()) +
    theme(legend.background = element_rect(colour = 'grey', fill = 'white', linetype='solid'))
  
  #put together and save graph (though have to use export button because squishes x axis names)
  library(ggpubr)
  ggarrange(teps_graph_pre, teps_graph_post, 
            labels = c("A", "B"),
            #ncol = 2, nrow = 2,
            common.legend = TRUE, legend = "right")
  
  ggsave("TEPS_P2P_plot_pubvers.jpg")
  

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

## Look at correlations with cognitive measures 

df_amp<- COMBINED_COG_PhD %>%
  select(group, code, teps_p2p_n100_negclus_amp_bl_pre, teps_p2p_n100_posclus_amp_bl_pre,
         teps_p2p_n100_posclus_amp_bl_post,teps_p2p_n100_negclus_amp_bl_post, 
         teps_p2p_p60_posclus_amp_bl_pre) #create df of just amplitude

#merge with cog_bl

#create df with neuropsych measures and amplitude measures
corr_df<- COMBINED_COG_PhD_teps %>%
  select(group, code, coding_bl,ravlt_t1_bl,tma_bl, tmb_bl, ds_fwd_bl, ds_bwd_bl, teps_p2p_n100_posclus_amp_bl_pre,
         teps_p2p_n100_negclus_amp_bl_pre, teps_p2p_p60_posclus_amp_bl_pre, teps_p2p_n100_posclus_amp_bl_post,
         teps_p2p_n100_negclus_amp_bl_post) 

corr_df$group<- as.factor(corr_df$group)
  
#rename to make shorter
library(data.table)

setnames(corr_df, old=c("teps_p2p_n100_posclus_amp_bl_pre","teps_p2p_n100_negclus_amp_bl_pre",
                        "teps_p2p_p60_posclus_amp_bl_pre",
                        "teps_p2p_n100_posclus_amp_bl_post","teps_p2p_n100_negclus_amp_bl_post"),
         new=c("n100_pos_pre", "n100_neg_pre","p60_pos_pre", "n100_pos_post", "n100_neg_post"))

## Look for correlations
c<-corr_df %>%
  select(-group, -code)

c_1<- cor(c,use = "complete.obs") # create corr matrix

library(Hmisc)
library(corrplot)

c_2<-rcorr(as.matrix(c),type = c("spearman"))

c_2$P #look at p values
c_2$r #look at r values

#visualise corr strength
corrplot(c_1, method="circle") #looks as though coding is positively correlated with N100 neg clusters
 #visualise them
#scatterplot with coding and n100 amplitude and line of best fit
corr_n100_pre<- ggplot(corr_df, aes(x=coding_bl, y=n100_neg_pre, colour=group)) +
  geom_point(shape=17, size= 2)+
  xlab("Coding (total correct)") +
  ylab("N100 amp Pre iTBS") +
  geom_smooth(method=lm, se=FALSE, fullrange=TRUE) +
  scale_color_manual(values=c("#999999", "#FFB6C1")) +
  theme_classic()+
  ylim(0, 8) +
  theme(legend.title=element_blank(),
        legend.background = element_rect(colour = 'grey', fill = 'white', linetype='solid'))
  

#for balance here is the pos cluster
corr_n100_post<-ggplot(corr_df, aes(x=coding_bl, y=n100_neg_post, colour=group)) +
  geom_point(shape=17, size= 2) +
  xlab("Coding (total correct)") +
  ylab("N100 amp Post iTBS") +
  geom_smooth(method=lm, se=FALSE, fullrange=TRUE) +
  scale_color_manual(values=c("#999999", "#FFB6C1")) +
  theme_classic() +
  ylim(0, 8) +
  theme(legend.title=element_blank(),
        legend.background = element_rect(colour = 'grey', fill = 'white', linetype='solid'))


#put them together
ggarrange(corr_n100_pre, corr_n100_post, 
          labels = c("A", "B"),
          #ncol = 2, nrow = 2,
          common.legend = TRUE, legend = "right")

ggsave("N100_corr_coding_scatplot_pubvers.jpg")


# run the stas

#correlation by group
ddply(corr_df, .(group),
      summarise, "corr" = cor(coding_bl, n100_neg_pre, 
                              method = "spearman"))

# corr.test for all
cor.test(corr_df$tmb_bl, corr_df$n100_negclus_amp_post) 
# corr.test by group
cor.test(formula = ~ ravlt_t1_bl + p60_pos_pre,
         data = corr_df,
         subset = group == "control",
         method= "pearson",
         alternative= "greater") # split by group way of doing it without the pretty table

  #plot N100 amplitude vs P60 in Pre
  
  ggplot(df_amp, aes(x=teps_p2p_n100_posclus_amp_bl_pre, y=teps_p2p_p60_posclus_amp_bl_pre, colour=group)) +
    geom_point() +
    geom_smooth(method=lm, se=TRUE, fullrange=FALSE) +
    scale_color_manual(values=c("#999999", "#FFB6C1")) +
    theme_classic()

  
  ggplot(df_amp, aes(x=teps_p2p_n100_negclus_amp_bl_post, y=teps_p2p_n100_posclus_amp_bl_post, colour=group)) +
    geom_point() +
    geom_smooth(method=lm, se=TRUE, fullrange=FALSE) +
    scale_color_manual(values=c("#999999", "#FFB6C1")) +
    theme_classic()
  
names(df_amp)

#scatterplot with coding and n100 amplitude and line of best fit
corr_n100_pre<- ggplot(corr_df, aes(x=ravlt_t1_bl, y=p60_pos_pre, colour=group)) +
  geom_point(shape=17, size= 2)+
  xlab("Coding (total correct)") +
  ylab("N100 amp Pre iTBS") +
  geom_smooth(method=lm, se=FALSE, fullrange=TRUE) +
  scale_color_manual(values=c("#999999", "#FFB6C1")) +
  theme_classic()+
  ylim(0, 8) +
  theme(legend.title=element_blank(),
        legend.background = element_rect(colour = 'grey', fill = 'white', linetype='solid'))


## for associations between clinical and TEP measures
## create new df with clinical measures
corr_df<- COMBINED_COG_PhD_teps %>%
  select(group, code, hads_total_bl,hads_anxiety_bl,hads_depression_bl, rpq_3_bl, rpq_13_bl, mfi_mf_bl, mfi_gf_bl, 
         mfi_rm_bl, mfi_pf_bl, mfi_ra_bl, teps_p2p_n100_posclus_amp_bl_pre,
         teps_p2p_n100_negclus_amp_bl_pre, teps_p2p_p60_posclus_amp_bl_pre, teps_p2p_n100_posclus_amp_bl_post,
         teps_p2p_n100_negclus_amp_bl_post) 


corr_df$group<- as.factor(corr_df$group)

#rename to make shorter
library(data.table)

setnames(corr_df, old=c("teps_p2p_n100_posclus_amp_bl_pre","teps_p2p_n100_negclus_amp_bl_pre",
                        "teps_p2p_p60_posclus_amp_bl_pre",
                        "teps_p2p_n100_posclus_amp_bl_post","teps_p2p_n100_negclus_amp_bl_post"),
         new=c("n100_pos_pre", "n100_neg_pre","p60_pos_pre", "n100_pos_post", "n100_neg_post"))

## Look for correlations
c<-corr_df %>%
  select(-group, -code)

c_1<- cor(c,use = "complete.obs") # create corr matrix

library(Hmisc)
library(corrplot)

c_2<-rcorr(as.matrix(c),type = c("spearman"))

c_2$P #look at p values
c_2$r #look at r values

#visualise corr strength
corrplot(c_1, method="circle")


ggplot(corr_df, aes(x=rpq_13_bl, y=n100_pos_pre, colour=group)) +
  geom_point(shape=17, size= 2)+
  xlab("MFI mental fatigue (total symptom score)") +
  ylab("N100 amp Pre iTBS") +
  geom_smooth(method=lm, se=FALSE, fullrange=TRUE) +
  scale_color_manual(values=c("#999999", "#FFB6C1")) +
  theme_classic()+
  theme(legend.title=element_blank(),
        legend.background = element_rect(colour = 'grey', fill = 'white', linetype='solid'))

# corr.test by group
cor.test(formula = ~ rpq_13_bl + n100_pos_pre,
         data = corr_df,
         subset = group == "mtbi",
         method= "pearson",
         alternative= "less") # split by group way of doing it without the pretty table


## get epoch information 

tribble_paste()
tms_epoch_df<- tibble::tribble(
  ~code, ~Pre, ~Post,    ~Group,
      1,  101,   100, "Control",
      2,   99,    98, "Control",
      3,   97,    88, "Control",
      4,  100,   100, "Control",
      5,   98,    98, "Control",
      6,   98,    98, "Control",
      8,  102,    97, "Control",
      9,   95,    89, "Control",
     10,  100,    95, "Control",
     11,   99,   100, "Control",
     12,   96,    98, "Control",
     13,   98,    99, "Control",
     14,   98,    99, "Control",
     15,   90,    93, "Control",
     17,   99,    97, "Control",
     18,  100,   100, "Control",
     19,   97,    96, "Control",
     20,   99,    71, "Control",
     21,   97,    97, "Control",
     22,   97,    93, "Control",
     23,  100,    98, "Control",
     24,   99,    94, "Control",
     25,   90,    94, "Control",
     26,  100,    97, "Control",
     27,   92,    96, "Control",
     28,  100,    98, "Control",
    101,   99,    86,     "TBI",
    103,   96,    98,     "TBI",
    104,   99,    98,     "TBI",
    105,   93,    99,     "TBI",
    106,   98,    95,     "TBI",
    107,   99,    97,     "TBI",
    108,   98,    84,     "TBI",
    109,   88,    94,     "TBI",
    110,   98,    78,     "TBI",
    111,  102,    96,     "TBI",
    112,   98,    97,     "TBI",
    113,   95,    85,     "TBI",
    114,  100,    90,     "TBI",
    115,   82,    57,     "TBI",
    116,   69,    91,     "TBI",
    117,   97,    91,     "TBI",
    118,   99,    97,     "TBI",
    119,   90,    80,     "TBI",
    120,  100,    98,     "TBI",
    121,   91,    91,     "TBI",
    122,   97,    98,     "TBI",
    123,   91,    94,     "TBI",
    124,  100,   103,     "TBI",
    125,   98,    81,     "TBI",
    126,   76,    97,     "TBI",
    127,   94,    97,     "TBI",
    128,   98,    94,     "TBI",
    129,   93,    86,     "TBI",
    130,   98,    95,     "TBI"
  )

#turn group into a factor
str(tms_epoch_df)
tms_epoch_df$Group<-factor(tms_epoch_df$Group)


#create summary stats table
summary<-tms_epoch_df %>%
  group_by(Group) %>%
  select(Group, Pre, Post) %>%
  summarise_all(list(
    min = ~min,
    max = ~max,
    mean = ~mean,
    sd = ~sd), na.rm=TRUE)

#change table to have a condition column

epoch_df_aov<- tms_epoch_df %>%
  gather(Condition, epoch_number, -Group, -code )

epoch_df_aov$Condition<-as.factor(epoch_df_aov$Condition)

#look for sig differences between the groups
anova<- aov(epoch_number ~ Group * Condition, data = epoch_df_aov)  

summary(anova) #main effect of group

model.tables(anova, type="means", se = TRUE) #look at means and SE

#look for pairwise comparisons
TukeyHSD(anova, which = "Group") #control have a sig higher number of epochs

#look for homogeneity of variance
plot(anova, 1) 
# check normality
plot(anova, 2)

aov_residuals <- residuals(object = anova)
shapiro.test(x = aov_residuals) #not normally distributed


