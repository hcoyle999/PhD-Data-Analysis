### Digit Span Analyses- Baseline Paper ##

#----- Digit Span Behavioural Analyses ---------
load("~/Documents/PHD-Data-Analysis/PHD-Data-Analysis/Analysis/Data/ds_df_wide.Rdata")
load("~/Documents/PHD-Data-Analysis/PHD-Data-Analysis/Analysis/Data/ds_df_narrow.Rdata")


# exclude participants not used in ERP analysis 
ds_df_wide <-subset(ds_df_wide,!id %in% c(7,8, 15, 16, 17, 101, 103, 113, 121, 125, 128))
ds_df_narrow <-subset(ds_df_narrow,!id %in% c(7,8, 15, 16, 17, 101, 103, 113, 121, 125, 128))

# think about education as a covariate
#covariates<-COMBINED_COG_PhD %>%
  #subset(!code %in% c(7,8, 15, 16, 17, 101, 103, 113, 121, 123, 125, 128)) %>%
  #select(code, group, education, wtar)

#check correct length
# covariates$code
# ds_df_wide$id
# #change name so they match
# names(covariates)[names(covariates) == 'code'] <- 'id'
# #bind together & tidy
# ds_df_wide<-merge(covariates, ds_df_wide, by= "id")
# ds_df_wide$group.y <- NULL
# names(ds_df_wide)[names(ds_df_wide) == 'group.x'] <- 'group'

# testing to remove outliers 
#ds_df_wide <-subset(ds_df_wide,!id %in% c(2,13))
                    
# plot just for baseline Pre and Post conditions
#create a smaller df
df_pre_post<-ds_df_wide %>%
  select(id, group, bl_pre, bl_post) %>%
  gather(key=timepoint, value= value, -group, -id) 

#make timepoint a factor and set levles
timepoint_levels<- c("bl_pre","bl_post")
df_pre_post$timepoint<-factor(df_pre_post$timepoint, levels=timepoint_levels, ordered=TRUE)

# ---- Plotting ---- #
#graph it for both groups at BL (pre-post) boxplot
ggplot(df_pre_post, aes(x=timepoint, y=value, color=group)) + 
  geom_boxplot()+ 
  scale_fill_manual(values=c("#999999", "#FFB6C1"))+
  facet_grid(~group)

#save plot in Figures folder
setwd("/Users/han.coyle/Documents/PHD-Data-Analysis/PHD-Data-Analysis/Analysis/Figures")
ggsave("ds_pre_post.jpg", width = 4, height = 4)
dev.off()

#graph it as a bar graph
#get it into the right format with error bars
df_pre_post$group<- factor(df_pre_post$group)
ds_summary<- df_pre_post %>%
  group_by(group) %>%
  select(timepoint, value, group) %>%
  summarySE(measurevar="value", groupvars=c("timepoint","group"))

#plot over both time points (pre and post itbs)
ds_pre_post_graph<-ds_summary %>%
  ggplot(aes(x=timepoint, y=value, fill=group)) + 
  geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=value-se, ymax=value+se),
                width=.2,                    # Width of the error bars
                position=position_dodge(.9))+
  ylab("Accuracy (total correct)") +
  #ggtitle("Digit Span Accuracy") +
  theme_light() +
  scale_x_discrete(labels=c("Pre","Post")) +
  #ylim(0, 11) +
  labs(fill = "Group") +
  scale_fill_manual(values=c("#999999", "#FFB6C1")) +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        axis.title.x=element_blank())

ggsave("ds_pre_post_bar.jpg", width = 4, height = 4)
dev.off()
# create graph with single timepoint
  ds_all_summary<-df_pre_post %>%
  spread( timepoint, value) %>%
  mutate(ds_all= ((bl_pre+bl_post)/2)) %>%
  group_by(group) %>%
  select(group,ds_all) %>%
  gather(key="measure", value= "ds_all",-group) %>%
  summarySE(measurevar="ds_all", groupvars=c("group","measure")) 
 
  
  ds_all_graph<- ds_all_summary %>%
    #mutate(measure=factor(measure, labels =c("RPQ 3","RPQ 13", "RPQ Total"))) %>%
    ggplot(aes(x=measure, y=ds_all, fill=group)) + 
    geom_bar(position=position_dodge(), stat="identity") +
    geom_errorbar(aes(ymin=ds_all-se, ymax=ds_all+se),
                  width=.2,                    # Width of the error bars
                  position=position_dodge(.9))+
    ylab("Accuracy (total correct)") +
    #ggtitle("Digit Span Accuracy") +
    theme_light() +
    scale_x_discrete(labels= "Pre + Post")+
    scale_fill_manual(values=c("#999999", "#FFB6C1")) +
    theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5),
          axis.title.x=element_blank()) +
    ylim(0, 11.5)
  
  ggsave("ds_all_bar.jpg", width = 4, height = 4)
  
   #run stats -hmmm paired T-test ( are from same sample but now merged)- seems dodgy
  ds_all <- df_pre_post %>%
    spread( timepoint, value) %>%
    mutate(ds_all= ((bl_pre+bl_post)/2))
  
  t.test(ds_all~ group, data=ds_all, paired=TRUE)

# ---- Descriptives ---- #
#create summary statistics (mean and sd)
summary_df<- ds_df_wide %>% 
  group_by (group) %>%
  select(bl_pre, bl_post) %>%
  summarise_all(.funs=c(mean="mean",sd="sd"),na.rm=TRUE)

#make pretty
summary_df %>%
  kable(digits=2) %>%
  kable_styling()

# ------Statistics ------#
# two way anova
   ds_aov<- aov(value ~ group * timepoint, data = df_pre_post)
   summary(ds_aov) # main effect of group is significant, no sig main effect of timepoint
                  # or sig maain effect of interaction with education level.
   
   results<- tidy(ds_aov)
   
   results %>%
     kable(digits=2) %>%
     kable_styling
   
   #post-hoc testing 
   TukeyHSD(ds_aov, which = "group")  #tukey hsd post hoc
   
   pair_t<- pairwise.t.test(df_pre_post$value, 
                            df_pre_post$group,
                            p.adjust="bonferroni") # pairwise compar post hoc
   pair_t <- tidy(pair_t)

#------- Check Assumptions -------# 
   
# check homogeneity of vairance 
   plot(ds_aov, 1) #  data points 011, 48, 57 are outliers
   library(car)
   leveneTest(value ~ group * timepoint, data = df_pre_post)
   # not sig - homogeneity of variance assumption supported

# check normality 
   plot(ds_aov, 2) #mostly along line, normality seems ok
   # Extract the residuals
   aov_residuals <- residuals(object = ds_aov)
   # Run Shapiro-Wilk test
   shapiro.test(x = aov_residuals ) #normality violated
   
   
   ##publication plot
   library(ggpubr)
   ggarrange(ds_pre_post_graph, ds_all_graph, 
             labels = c("A", "B"),
             #ncol = 2, nrow = 2,
             common.legend = TRUE, legend = "right")
   ggsave("DS_plot_pubvers.jpg")
   
   
   
   
   
#----- Digit Span GFP Analyses ---------

   
gfp_df<-tibble::tribble(
     ~ID,    ~Group,        ~GFP,    ~Time,  ~Condition,
     1, "Control", 1.838849555,  "first",  "Pre_iTBS",
     2, "Control",  1.10749904,  "first",  "Pre_iTBS",
     3, "Control", 1.509338646,  "first",  "Pre_iTBS",
     4, "Control", 0.767327924,  "first",  "Pre_iTBS",
     5, "Control", 1.107853989,  "first",  "Pre_iTBS",
     6, "Control", 1.375872891,  "first",  "Pre_iTBS",
     9, "Control", 1.948746911,  "first",  "Pre_iTBS",
     10, "Control", 1.756109937,  "first",  "Pre_iTBS",
     11, "Control", 2.068154265,  "first",  "Pre_iTBS",
     12, "Control", 1.754365469,  "first",  "Pre_iTBS",
     13, "Control", 0.673357812,  "first",  "Pre_iTBS",
     14, "Control", 1.445604961,  "first",  "Pre_iTBS",
     18, "Control",   0.7186247,  "first",  "Pre_iTBS",
     19, "Control", 0.993059042,  "first",  "Pre_iTBS",
     20, "Control", 0.935658114,  "first",  "Pre_iTBS",
     21, "Control", 2.353149789,  "first",  "Pre_iTBS",
     22, "Control",   1.3827536,  "first",  "Pre_iTBS",
     23, "Control",  0.78469598,  "first",  "Pre_iTBS",
     24, "Control", 0.573047992,  "first",  "Pre_iTBS",
     25, "Control", 1.378246927,  "first",  "Pre_iTBS",
     26, "Control", 1.273793083,  "first",  "Pre_iTBS",
     27, "Control", 1.621204087,  "first",  "Pre_iTBS",
     28, "Control", 1.263900648,  "first",  "Pre_iTBS",
     102,    "mTBI", 1.491742927,  "first",  "Pre_iTBS",
     104,    "mTBI", 1.961915171,  "first",  "Pre_iTBS",
     105,    "mTBI", 1.414015893,  "first",  "Pre_iTBS",
     106,    "mTBI", 1.839384717,  "first",  "Pre_iTBS",
     107,    "mTBI", 0.855766444,  "first",  "Pre_iTBS",
     108,    "mTBI", 1.810733725,  "first",  "Pre_iTBS",
     109,    "mTBI", 1.326622549,  "first",  "Pre_iTBS",
     110,    "mTBI", 2.824841625,  "first",  "Pre_iTBS",
     111,    "mTBI", 1.599255975,  "first",  "Pre_iTBS",
     112,    "mTBI", 1.271883924,  "first",  "Pre_iTBS",
     114,    "mTBI", 1.411647516,  "first",  "Pre_iTBS",
     115,    "mTBI", 2.041038331,  "first",  "Pre_iTBS",
     116,    "mTBI", 1.334038264,  "first",  "Pre_iTBS",
     117,    "mTBI",  2.26236968,  "first",  "Pre_iTBS",
     118,    "mTBI", 2.020699178,  "first",  "Pre_iTBS",
     119,    "mTBI", 1.889297003,  "first",  "Pre_iTBS",
     120,    "mTBI", 1.681232679,  "first",  "Pre_iTBS",
     122,    "mTBI", 1.510425031,  "first",  "Pre_iTBS",
     124,    "mTBI", 1.560433148,  "first",  "Pre_iTBS",
     126,    "mTBI", 1.152167255,  "first",  "Pre_iTBS",
     127,    "mTBI", 1.397645492,  "first",  "Pre_iTBS",
     129,    "mTBI", 1.515857739,  "first",  "Pre_iTBS",
     130,    "mTBI", 1.290029644,  "first",  "Pre_iTBS",
     1, "Control", 1.200002161,  "first", "Post_iTBS",
     2, "Control", 0.988145064,  "first", "Post_iTBS",
     3, "Control", 1.243639142,  "first", "Post_iTBS",
     4, "Control", 1.202361432,  "first", "Post_iTBS",
     5, "Control", 1.485801373,  "first", "Post_iTBS",
     6, "Control", 1.120387338,  "first", "Post_iTBS",
     9, "Control", 1.373559217,  "first", "Post_iTBS",
     10, "Control",  1.39534585,  "first", "Post_iTBS",
     11, "Control", 1.252289301,  "first", "Post_iTBS",
     12, "Control", 1.365313608,  "first", "Post_iTBS",
     13, "Control", 0.902493122,  "first", "Post_iTBS",
     14, "Control", 1.313832139,  "first", "Post_iTBS",
     18, "Control",  0.81406463,  "first", "Post_iTBS",
     19, "Control",  1.55706033,  "first", "Post_iTBS",
     20, "Control", 1.139302306,  "first", "Post_iTBS",
     21, "Control", 1.037309156,  "first", "Post_iTBS",
     22, "Control", 1.811966056,  "first", "Post_iTBS",
     23, "Control", 0.778596755,  "first", "Post_iTBS",
     24, "Control", 0.715838765,  "first", "Post_iTBS",
     25, "Control", 2.228621869,  "first", "Post_iTBS",
     26, "Control", 0.968716045,  "first", "Post_iTBS",
     27, "Control", 0.880801863,  "first", "Post_iTBS",
     28, "Control", 0.960004852,  "first", "Post_iTBS",
     102,    "mTBI", 2.367388221,  "first", "Post_iTBS",
     104,    "mTBI", 2.530631648,  "first", "Post_iTBS",
     105,    "mTBI", 1.254611155,  "first", "Post_iTBS",
     106,    "mTBI", 1.413635546,  "first", "Post_iTBS",
     107,    "mTBI", 1.362784722,  "first", "Post_iTBS",
     108,    "mTBI", 1.808398594,  "first", "Post_iTBS",
     109,    "mTBI", 1.621714255,  "first", "Post_iTBS",
     110,    "mTBI", 1.343230091,  "first", "Post_iTBS",
     111,    "mTBI", 1.706997078,  "first", "Post_iTBS",
     112,    "mTBI", 1.497020584,  "first", "Post_iTBS",
     114,    "mTBI", 0.821941738,  "first", "Post_iTBS",
     115,    "mTBI", 3.965716842,  "first", "Post_iTBS",
     116,    "mTBI", 1.258042731,  "first", "Post_iTBS",
     117,    "mTBI", 1.447433265,  "first", "Post_iTBS",
     118,    "mTBI", 2.045769581,  "first", "Post_iTBS",
     119,    "mTBI", 2.744603656,  "first", "Post_iTBS",
     120,    "mTBI", 1.252690837,  "first", "Post_iTBS",
     122,    "mTBI", 1.632851066,  "first", "Post_iTBS",
     124,    "mTBI",  1.30850497,  "first", "Post_iTBS",
     126,    "mTBI", 1.444662779,  "first", "Post_iTBS",
     127,    "mTBI",  1.00993907,  "first", "Post_iTBS",
     129,    "mTBI",  0.98952092,  "first", "Post_iTBS",
     130,    "mTBI", 1.383119837,  "first", "Post_iTBS",
     1, "Control", 2.068988969, "second",  "Pre_iTBS",
     2, "Control", 1.114578769, "second",  "Pre_iTBS",
     3, "Control", 1.684198935, "second",  "Pre_iTBS",
     4, "Control", 1.290032649, "second",  "Pre_iTBS",
     5, "Control", 1.449733417, "second",  "Pre_iTBS",
     6, "Control", 1.153603673, "second",  "Pre_iTBS",
     9, "Control", 3.707039493, "second",  "Pre_iTBS",
     10, "Control",  2.40710608, "second",  "Pre_iTBS",
     11, "Control", 1.665256742, "second",  "Pre_iTBS",
     12, "Control", 1.236051797, "second",  "Pre_iTBS",
     13, "Control", 0.856830902, "second",  "Pre_iTBS",
     14, "Control", 2.184763562, "second",  "Pre_iTBS",
     18, "Control", 0.883092146, "second",  "Pre_iTBS",
     19, "Control",   1.1613421, "second",  "Pre_iTBS",
     20, "Control", 0.850841696, "second",  "Pre_iTBS",
     21, "Control", 2.931620063, "second",  "Pre_iTBS",
     22, "Control", 1.540320543, "second",  "Pre_iTBS",
     23, "Control", 0.597963239, "second",  "Pre_iTBS",
     24, "Control", 1.045665573, "second",  "Pre_iTBS",
     25, "Control", 1.518519559, "second",  "Pre_iTBS",
     26, "Control", 1.753145122, "second",  "Pre_iTBS",
     27, "Control", 1.517504504, "second",  "Pre_iTBS",
     28, "Control", 2.872082109, "second",  "Pre_iTBS",
     102,    "mTBI", 1.838761242, "second",  "Pre_iTBS",
     104,    "mTBI", 2.482618314, "second",  "Pre_iTBS",
     105,    "mTBI", 1.795916107, "second",  "Pre_iTBS",
     106,    "mTBI", 2.429363289, "second",  "Pre_iTBS",
     107,    "mTBI", 0.884309695, "second",  "Pre_iTBS",
     108,    "mTBI", 1.685964165, "second",  "Pre_iTBS",
     109,    "mTBI", 2.261079767, "second",  "Pre_iTBS",
     110,    "mTBI", 4.675920147, "second",  "Pre_iTBS",
     111,    "mTBI", 1.632046164, "second",  "Pre_iTBS",
     112,    "mTBI", 2.207129595, "second",  "Pre_iTBS",
     114,    "mTBI", 2.431709992, "second",  "Pre_iTBS",
     115,    "mTBI", 2.177354719, "second",  "Pre_iTBS",
     116,    "mTBI", 1.814213642, "second",  "Pre_iTBS",
     117,    "mTBI", 2.464634659, "second",  "Pre_iTBS",
     118,    "mTBI", 3.081884878, "second",  "Pre_iTBS",
     119,    "mTBI", 2.121047156, "second",  "Pre_iTBS",
     120,    "mTBI",  2.55983562, "second",  "Pre_iTBS",
     122,    "mTBI", 2.018171444, "second",  "Pre_iTBS",
     124,    "mTBI", 2.047047096, "second",  "Pre_iTBS",
     126,    "mTBI", 1.613671915, "second",  "Pre_iTBS",
     127,    "mTBI", 2.702468291, "second",  "Pre_iTBS",
     129,    "mTBI", 0.901734698, "second",  "Pre_iTBS",
     130,    "mTBI", 1.363929939, "second",  "Pre_iTBS",
     1, "Control", 1.482912506, "second", "Post_iTBS",
     2, "Control",  1.29526559, "second", "Post_iTBS",
     3, "Control", 2.111823468, "second", "Post_iTBS",
     4, "Control", 1.766818332, "second", "Post_iTBS",
     5, "Control", 1.405150757, "second", "Post_iTBS",
     6, "Control", 1.399734218, "second", "Post_iTBS",
     9, "Control",  1.94981863, "second", "Post_iTBS",
     10, "Control", 2.998013539, "second", "Post_iTBS",
     11, "Control", 1.588302993, "second", "Post_iTBS",
     12, "Control", 2.514856826, "second", "Post_iTBS",
     13, "Control", 1.075832334, "second", "Post_iTBS",
     14, "Control", 2.141303949, "second", "Post_iTBS",
     18, "Control", 0.879849129, "second", "Post_iTBS",
     19, "Control", 1.640846623, "second", "Post_iTBS",
     20, "Control", 0.956282787, "second", "Post_iTBS",
     21, "Control", 1.498958695, "second", "Post_iTBS",
     22, "Control", 1.784845173, "second", "Post_iTBS",
     23, "Control", 1.260528148, "second", "Post_iTBS",
     24, "Control", 2.234414982, "second", "Post_iTBS",
     25, "Control", 1.876109029, "second", "Post_iTBS",
     26, "Control", 1.234567569, "second", "Post_iTBS",
     27, "Control", 1.221074272, "second", "Post_iTBS",
     28, "Control", 2.154767978, "second", "Post_iTBS",
     102,    "mTBI", 2.680384822, "second", "Post_iTBS",
     104,    "mTBI", 3.077620476, "second", "Post_iTBS",
     105,    "mTBI", 1.565845988, "second", "Post_iTBS",
     106,    "mTBI", 3.677050496, "second", "Post_iTBS",
     107,    "mTBI", 1.626153245, "second", "Post_iTBS",
     108,    "mTBI", 2.551598828, "second", "Post_iTBS",
     109,    "mTBI", 2.562038921, "second", "Post_iTBS",
     110,    "mTBI", 2.886891955, "second", "Post_iTBS",
     111,    "mTBI", 2.085106261, "second", "Post_iTBS",
     112,    "mTBI", 1.373134563, "second", "Post_iTBS",
     114,    "mTBI", 1.230557971, "second", "Post_iTBS",
     115,    "mTBI", 3.306749307, "second", "Post_iTBS",
     116,    "mTBI", 1.821458264, "second", "Post_iTBS",
     117,    "mTBI", 3.256351771, "second", "Post_iTBS",
     118,    "mTBI", 3.843733767, "second", "Post_iTBS",
     119,    "mTBI", 2.640133867, "second", "Post_iTBS",
     120,    "mTBI", 2.804309063, "second", "Post_iTBS",
     122,    "mTBI", 2.196673631, "second", "Post_iTBS",
     124,    "mTBI", 2.080635875, "second", "Post_iTBS",
     126,    "mTBI",  1.74699086, "second", "Post_iTBS",
     127,    "mTBI", 1.834552202, "second", "Post_iTBS",
     129,    "mTBI", 0.896601578, "second", "Post_iTBS",
     130,    "mTBI", 1.471167457, "second", "Post_iTBS"
   )   
# the above data is extracted from matlab and is GFP values for Pre and Post iTBS for both groups
# and both timew windows  
# tidy the data frame
   str(gfp_df)
   gfp_df$Group <-factor(gfp_df$Group)
   gfp_df$Condition <-factor(gfp_df$Condition)
   gfp_df$Time <-factor(gfp_df$Time)
   
   #change time period names to ms
   levels(gfp_df$Time) <- c(levels(gfp_df$Time), "92-188 ms", "194-388 ms") 
   gfp_df$Time[gfp_df$Time=="first"]  <- "92-188 ms" 
   gfp_df$Time[gfp_df$Time=="second"]  <- "194-388 ms"  
   
   #do summary statistics
   gfp_df_sum<- gfp_df %>%
     group_by(Group,Time, Condition) %>%
     select(-ID, -Time, -Condition) %>%
     summarise_all(.funs=c("mean_gfp"=mean,"sd_gfp"=sd),na.rm=TRUE)
   
   ## add GFP data to datafram previously created with EEG digit span behavioural data
   load("~/Documents/PHD-Data-Analysis/PHD-Data-Analysis/Analysis/Data/ds_df_wide.Rdata")
   
   # exclude participants that were not included in the EEG data analysis (e.g outliers/not enough epoch)
   ds_df_all <- subset(ds_df_wide,!id %in% c(8, 15, 16, 17, 101, 103, 113, 121, 123, 125, 128))
   
   #select just baseline columns of behav data (as are just looking at bsl (not T1 or T2)
   ds_df_all<- ds_df_all %>%
     select(id, group, bl_pre, bl_post)
  
   # in intial df we have GFP values for time (92-188 and 194-388 for Pre and Post iTBS)
   # what we want is an average across time and condition  (for correlations)
  
    av_gfp<-gfp_df  %>%
     spread(key=Condition, value= GFP) %>% #pull out GFP for Pre and Post at each timepoint
     mutate(Av_GFP = (Pre_iTBS+Post_iTBS)/2) %>% # average over condition (i.e Pre and Post)
     select(ID, Group, Time, Av_GFP) %>%
     spread(key=Time, value= Av_GFP) %>%
     mutate(Av_GFP = (`92-188 ms`+`194-388 ms`)/2) %>% # average over timepoint
     select(ID, Group, Av_GFP) # get total average GFP
    
    #change names
    names(av_gfp) <- tolower(names(av_gfp))
    
    #merge new average GFP data frame with behavioural EEG data
    new_df<- merge(x = ds_df_all, y = av_gfp, by= "id")
    #drop additional column
    new_df$group.y <- NULL
    colnames(new_df)[colnames(new_df) == 'group.x'] <- 'group'
    # average ds behavioural performance
    new_df<-new_df %>%
      mutate(ds_all= ((bl_pre + bl_post)/2)) %>%
      select(id, group, av_gfp, ds_all)
    
    #merge average GFP data and average behav DS frame with clinical and cog measures
    new_df_1<-COMBINED_COG_PhD %>%
      select(code, group, ravlt_t1_bl, ravlt_t_bl, ravlt_recognition, ds_bwd_bl, coding_bl, hads_anxiety_bl, 
             hads_depression_bl, hads_total_bl, mfi_gf_bl, mfi_mf_bl, mfi_ra_bl, mfi_rm_bl, rpq_3_bl,
             rpq_13_bl, rpq_16_bl)
    #put together & tidy
    colnames(new_df_1)[colnames(new_df_1) == 'code'] <- 'id'
    df<-merge(x = new_df, y = new_df_1, by= "id") 
    colnames(df)[colnames(df) == 'group.y'] <- 'group'
    df$group.x = NULL
    
    # df is my final data frame for the digit span data
    # visualise first ( GFP and MFI general fatigue)
    ggplot(df, aes(x=av_gfp, y=mfi_gf_bl, colour=group)) +
      geom_point(shape=17, size= 2)+
      xlab("Average GFP") +
      ylab("MFI General Fatigue ") +
      geom_smooth(method=lm, se=FALSE, fullrange=TRUE) +
      scale_color_manual(values=c("#999999", "#FFB6C1")) +
      theme_classic()+
      theme(legend.title=element_blank(),
            legend.background = element_rect(colour = 'grey', fill = 'white', linetype='solid'))
    
    # correlations with clinical measures
    cor.test(formula = ~ av_gfp + mfi_gf_bl,
             data = df,
             subset = group == "mtbi",
             method= "pearson",
             alternative= "greater")
    
    # visualise first ( GFP and PCS total score)
    ggplot(df, aes(x=av_gfp, y=rpq_13_bl, colour=group)) +
      geom_point(shape=17, size= 2)+
      xlab("Average GFP") +
      ylab("PCS total score") +
      geom_smooth(method=lm, se=FALSE, fullrange=TRUE) +
      scale_color_manual(values=c("#999999", "#FFB6C1")) +
      theme_classic()+
      theme(legend.title=element_blank(),
            legend.background = element_rect(colour = 'grey', fill = 'white', linetype='solid'))
    
    # correlations with clinical measures
    cor.test(formula = ~ av_gfp + rpq_13_bl,
             data = df,
             subset = group == "mtbi",
             method= "pearson",
             alternative= "greater")
    
 # no significant corr with hads_total(trend) or hads_anxiety
    
 # associations with neuropsychological measures
    # first test for consistency with DSB during neuropscyh assessment
    ggplot(df, aes(x=av_gfp, y= ds_bwd_bl, colour=group)) +
      geom_point(shape=17, size= 2)+
      xlab("Average GFP") +
      ylab("DSB total score") +
      geom_smooth(method=lm, se=FALSE, fullrange=TRUE) +
      scale_color_manual(values=c("#999999", "#FFB6C1")) +
      theme_classic()+
      theme(legend.title=element_blank(),
            legend.background = element_rect(colour = 'grey', fill = 'white', linetype='solid'))
    
    # correlations with neuropsych measures
    cor.test(formula = ~ av_gfp + ds_bwd_bl,
             data = df,
             subset = group == "mtbi",
             method= "pearson",
             alternative= "less") # significant negative correlation 
    
    # no significant correlations with ravlt_t1_bl or dsb_bwd_bl 
    
   # associations between GFP and ds performance during the task
    ggplot(df, aes(x=av_gfp, y= ds_all, colour=group)) +
      geom_point(shape=17, size= 2)+
      xlab("Average GFP") +
      ylab("DSB total score") +
      geom_smooth(method=lm, se=FALSE, fullrange=TRUE) +
      scale_color_manual(values=c("#999999", "#FFB6C1")) +
      theme_classic()+
      theme(legend.title=element_blank(),
            legend.background = element_rect(colour = 'grey', fill = 'white', linetype='solid'))
    
    # correlations with neuropsych measures
    cor.test(formula = ~ av_gfp + ds_all,
             data = df,
             subset = group == "mtbi",
             method= "pearson",
             alternative= "less") # significant negative correlation 
    
    ### Previously I had faceted the graph by time window - but for continuity just one graph makes sense.
    
   
   
   