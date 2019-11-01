#Clinical Information for Control and mTBI
# Load necessary libraries
library(tidyr, dplyr, broom)

## --- normality testing for demographics
# create data frame subset
clin_data_bl <- select(COMBINED_COG_PhD,code, group, hads_anxiety_bl:mfi_mf_bl)
clin_data_bl$group<- as.factor(clin_data_bl$group)

#A. Run descriptive stats and check for missing data 
attach(clin_data_bl)
clin_descriptives <- clin_data_bl %>%
  select(group:mfi_mf_bl) %>%
  group_by(group) %>%
  skimr::skim_to_wide() %>%
  dplyr::select(type,
                group,
                variable,
                missing,
                complete,
                mean,
                sd,
                median = p50,
                hist)

#B. Check normality
library(dlookr)
clin_normality<- clin_data_bl %>%
  group_by(group) %>%
  normality() %>%
  filter(p_value < 0.05) # a lot of the data is non-normal (highly skewed)

# C. Check homogeneity of variance
library(broom)
clin_variance<- clin_data_bl %>%
  select(hads_anxiety_bl:mfi_mf_bl) %>%
  map_df(~ broom::tidy(var.test(. ~ group)), .id = 'var') %>%
  select(var, statistic, p.value, method) %>%
  filter(p.value < 0.05) # a lot of the data violates homogeneity of variance
                        ### if for some reason is not working, check have used
                        ### attach(clin_data_bl)


#D. Statistical analysis of group differences
#if data is normal
clin_ttest<- clin_data_bl %>%
  select( hads_anxiety_bl:mfi_mf_bl) %>%
  map_df(~ broom::tidy(t.test(. ~ group)), .id = 'var') %>%
  select(var, estimate1, estimate2, statistic, p.value, method) %>%
  setNames(c(var='variable',estimate1='control_mean', estimate2='mtbi_mean', statistic='t_stat',p.value='p_value',method='method'))

clin_ttest %>%
  kable() %>%
  kable_styling()

var.test(hads_anxiety_bl~group) #variances are NOT equal
t.test(hads_anxiety_bl~ group, var.equal=FALSE)

# if data in non normal
clin_wc_rank<- clin_data_bl %>%
  select( hads_anxiety_bl:mfi_mf_bl) %>%
  map_df(~ broom::tidy(wilcox.test(. ~ group)), .id = 'var') %>%
  select(var, statistic, p.value, method)

##---clinical_data_table

#change categorical variables to factors
clin_vars <- c(names(clin_data_bl))
clin_vars <- clin_vars[-(1:2)] #remove code and group
catVars_2 <- c("group")

#create table by group
clin_table_norm <- CreateTableOne(vars = clin_vars, strata = "group" , data = clin_data_bl, 
                             factorVars = catVars_2) #handling data as normally distributed


# # or alternate way to run descriptives/summary of data (includes skew, kurtosis)
clin_sum<- summary(clin_table_norm, digits= 2)


clin_table_nonnorm<- print(clin_table_norm, nonnormal= clin_vars, 
                           quote= TRUE) #handling data as non normally distributed

    #Only need to the following once - to create tables.
# #export into .csv/ excel and save table 
# clin_table_norm<- print(clin_table, exact="stage", quote=TRUE, nospaces=TRUE,printToggle = FALSE)
# write.csv(clin_table_norm, file="/Users/han.coyle/Documents/PHD-Data-Analysis/PHD-Data-Analysis/Analysis/Tables/clin_table.csv")
# 
# clin_table<-read_csv(file="~/Documents/PHD-Data-Analysis/PHD-Data-Analysis/Analysis/Tables/clin_table.csv")
# clin_table<-as.data.frame(clin_table) #stargazer does not work well wth tbl_df so change to data frame
# 
# #create stargazer output and save as html
# stargazer(clin_table, title= "Clinical information", summary = FALSE, out="~/Documents/PHD-Data-Analysis/PHD-Data-Analysis/Analysis/Tables/clin_table.html")


#visualising the data (boxplots)

#for PCS differences
par(mfrow=c(1,2))
boxplot(rpq_3_bl~group, varwidth=TRUE,boxwex= 0.5,main="RPQ-3",names=c("control","mTBI"),ylab="Symptom Severity",xlab="Baseline",col=c("light grey","light pink"))
boxplot(rpq_13_bl~group, varwidth=TRUE,boxwex= 0.5,main="RPQ-13",names=c("control","mTBI"),ylab="Symptom Severity",xlab="Baseline",col=c("light grey","light pink"))

# for mood differences
par(mfrow = c(1,3))
boxplot(hads_depression_bl~group, varwidth=TRUE,boxwex= 0.5,main="Depressive Sx's",names=c("control","mTBI"),ylab="Symptom Severity",xlab="Baseline",col=c("light grey","light pink"))
boxplot(hads_anxiety_bl~group, varwidth=TRUE,boxwex= 0.5,main="Anxiety Sx's",names=c("control","mTBI"),ylab="Symptom Severity",xlab="Baseline",col=c("light grey","light pink"))
boxplot(hads_total_bl~group, varwidth=TRUE,boxwex= 0.5,main="Total Sx's",names=c("control","mTBI"),ylab="Symptom Severity",xlab="Baseline",col=c("light grey","light pink"))

#for fatigue differences
par(mfrow=c(1,5))
boxplot(mfi_gf_bl~group, varwidth=TRUE,boxwex= 0.5,main="General Fatigue",names=c("control","mTBI"),ylab="Symptom Severity",xlab="Baseline",col=c("light grey","light pink"))
boxplot(mfi_mf_bl~group, varwidth=TRUE,boxwex= 0.5,main="Mental Fatigue",names=c("control","mTBI"),ylab="Symptom Severity",xlab="Baseline",col=c("light grey","light pink"))
boxplot(mfi_pf_bl~group, varwidth=TRUE,boxwex= 0.5,main="Physical Fatigue",names=c("control","mTBI"),ylab="Symptom Severity",xlab="Baseline",col=c("light grey","light pink"))
boxplot(mfi_ra_bl~group, varwidth=TRUE,boxwex= 0.5,main="Reduced Activity",names=c("control","mTBI"),ylab="Symptom Severity",xlab="Baseline",col=c("light grey","light pink"))
boxplot(mfi_rm_bl~group, varwidth=TRUE,boxwex= 0.5,main="Reduced Motivation",names=c("control","mTBI"),ylab="Symptom Severity",xlab="Baseline",col=c("light grey","light pink"))

#for health outcomes differences
par(mfrow=c(1,4))
boxplot(sf36_energy_bl~group, varwidth=TRUE,boxwex= 0.5,main="Energy",names=c("control","mTBI"),ylab="Symptom Severity",xlab="Baseline",col=c("light grey","light pink"))
boxplot(sf36_gh_bl~group, varwidth=TRUE,boxwex= 0.5,main="General Health",names=c("control","mTBI"),ylab="Symptom Severity",xlab="Baseline",col=c("light grey","light pink"))
boxplot(sf36_mh_bl~group, varwidth=TRUE,boxwex= 0.5,main="Mental Health",names=c("control","mTBI"),ylab="Symptom Severity",xlab="Baseline",col=c("light grey","light pink"))
boxplot(sf36_pain_bl~group, varwidth=TRUE,boxwex= 0.5,main="Pain",names=c("control","mTBI"),ylab="Symptom Severity",xlab="Baseline",col=c("light grey","light pink"))
par(mfrow=c(1,4))
boxplot(sf36_pf_bl~group, varwidth=TRUE,boxwex= 0.5,main="Physical Functioning",names=c("control","mTBI"),ylab="Symptom Severity",xlab="Baseline",col=c("light grey","light pink"))
boxplot(sf36_remo_bl~group, varwidth=TRUE,boxwex= 0.5,main="Role Emotional Functioning",names=c("control","mTBI"),ylab="Symptom Severity",xlab="Baseline",col=c("light grey","light pink"))
boxplot(sf36_rphys_bl~group, varwidth=TRUE,boxwex= 0.5,main="Role Physical Functioning",names=c("control","mTBI"),ylab="Symptom Severity",xlab="Baseline",col=c("light grey","light pink"))
boxplot(sf36_sf_bl~group, varwidth=TRUE,boxwex= 0.5,main="Social Functioning",names=c("control","mTBI"),ylab="Symptom Severity",xlab="Baseline",col=c("light grey","light pink"))


#plotting more generally

glimpse(clin_data_bl)

clin_data_bl %>%
  ggplot(aes(x=)) # up to 33 mins into video. facet grid by sex is interesting. 

#Publication ready plot

#make summary df for HADS data
library(Rmisc)
library(ggpubr)

  hads_summary<- clin_data_bl %>%
       group_by(group) %>%
         select(hads_anxiety_bl, hads_depression_bl, hads_total_bl) %>%
         set_colnames(c("group","Anxiety", "Depression", "Total_Score")) %>%
         gather(key="measure", value= "symptom_score", -group, na.rm=TRUE) %>%
         summarySE(measurevar="symptom_score", groupvars=c("group","measure"))
  
  hads_graph<- ggplot(hads_summary, aes(x=measure, y=symptom_score, fill=group)) + 
    geom_bar(position=position_dodge(), stat="identity") +
    geom_errorbar(aes(ymin=symptom_score-se, ymax=symptom_score+se),
                  width=.2,                    # Width of the error bars
                  position=position_dodge(.9))+
    #xlab("Mood Measure") +
    ylab("Symptom Severity") +
    ggtitle("Hospital Anxiety and Depression Scale (HADS)") +
    theme_light() +
    scale_fill_manual(values=c("#999999", "#FFB6C1")) +
    theme(plot.title = element_text(hjust = 0.5),
          plot.subtitle = element_text(hjust = 0.5),
          axis.title.x=element_blank(),
          legend.position = "none") 
  
  hads_graph + ylim(0,13) # make limit bigger so can fit 
    
  # save plot in Figures folder
  setwd(here)
  setwd("./Analysis/Figures")
  ggsave("hads_plot.png")
  
  
  #make summary df for Fatigue data
  library(Rmisc)
  library(ggsignif)
  mfi_summary<- clin_data_bl %>%
    group_by(group) %>%
    select(mfi_gf_bl, mfi_mf_bl, mfi_pf_bl, mfi_ra_bl, mfi_rm_bl) %>%
    set_colnames(c("group","General Fatigue","Mental Fatigue", "Physical Fatigue", "Reduced Activity", 
                   "Reduced Motivation")) %>%
    gather(key="measure", value= "symptom_score", -group, na.rm=TRUE) %>%
    summarySE(measurevar="symptom_score", groupvars=c("group","measure"))
  
  mfi_graph<- ggplot(mfi_summary, aes(x=measure, y=symptom_score, fill=group)) + 
    geom_bar(position=position_dodge(), stat="identity") +
    geom_errorbar(aes(ymin=symptom_score-se, ymax=symptom_score+se),
                  width=.2,                    # Width of the error bars
                  position=position_dodge(.9))+
    #xlab("Fatigue Dimension") +
    ylab("Symptom Severity") +
    ggtitle("Multidimensional Fatigue Inventory\n (MFI)") +
    theme_light() +
    scale_fill_manual(values=c("#999999", "#FFB6C1")) +
    theme(plot.title = element_text(hjust = 0.5), 
          plot.subtitle = element_text(hjust = 0.5),
          axis.title.x=element_blank()) 
   
    mfi_graph + ylim(0,14)
  # save plot in Figures folder
  setwd(here)
  setwd("./Analysis/Figures")
  ggsave("mfi_plot.png")
  
  rpq_summary<- clin_data_bl %>%
    group_by(group) %>%
    select(rpq_13_bl, rpq_3_bl, rpq_16_bl) %>%
    set_colnames(c("group","RPQ 3","RPQ 13", "RPQ Total")) %>%
    gather(key="measure", value= "symptom_score", -group, na.rm=TRUE) %>%
    summarySE(measurevar="symptom_score", groupvars=c("group","measure"))
  
  rpq_graph<- rpq_summary %>%
    mutate(measure=factor(measure, labels =c("RPQ 3","RPQ 13", "RPQ Total"))) %>%
    ggplot(aes(x=measure, y=symptom_score, fill=group)) + 
    geom_bar(position=position_dodge(), stat="identity") +
    geom_errorbar(aes(ymin=symptom_score-se, ymax=symptom_score+se),
                  width=.2,                    # Width of the error bars
                  position=position_dodge(.9))+
    #xlab("mTBI symptom measure") +
    ylab("Symptom Severity") +
    ggtitle("Rivermead Post Concussion\n Questionnaire (RPQ)") +
    theme_light() +
    scale_fill_manual(values=c("#999999", "#FFB6C1")) +
    theme(plot.title = element_text(hjust = 0.5),
          plot.subtitle = element_text(hjust = 0.5),
          axis.title.x=element_blank(),
          legend.position = "none")
    
    rpq_graph + ylim(0,19) # make limit bigger so can fit 
  
    # save plot in Figures folder
    setwd(here)
    setwd("./Analysis/Figures")
    ggsave("rpq_plot.png")
    
    #make publication ready plot
    library(ggpubr)
    library("gridExtra")
    ggarrange(mfi_graph,
              ggarrange(rpq_graph, hads_graph, 
                        ncol = 2,
                        labels=c("B","C")),
             nrow = 2,
             labels="A",
             common.legend = TRUE, legend = "right")
    
    ggsave("Clin_Measures_plot_pubvers.jpg")
             
    # Are there associations between clinical measure and cognitive factors
    
    corr_df_clin<- COMBINED_COG_PhD %>%
      select(group, code, coding_bl, ravlt_t1_bl, tma_bl, tmb_bl, ds_fwd_bl, ds_bwd_bl,
             hads_anxiety_bl, hads_depression_bl, rpq_16_bl, mfi_gf_bl, mfi_mf_bl) 
    
    corr_df_clin$group<- as.factor(corr_df_clin$group)
    
    c<-corr_df_clin %>%
      select(-group, -code)
    
    c_1<- cor(c,use = "complete.obs") # create corr matrix
    
    library(Hmisc)
    library(corrplot)
    
    c_2<-rcorr(as.matrix(c),type = c("spearman"))
    
    c_2$P #look at p values
    c_2$r #look at r values
    
    #visualise corr strength
    corrplot(c_1, method="circle")
    
    corr_mf_coding<- ggplot(corr_df_clin, aes(x=ds_bwd_bl, y=mfi_mf_bl, colour=group)) +
      geom_point(shape=17, size= 2)+
      xlab("Coding (total correct)") +
      ylab("MFI mental fatigue score") +
      geom_smooth(method=lm, se=FALSE, fullrange=TRUE) +
      scale_color_manual(values=c("#999999", "#FFB6C1")) +
      theme_classic()+
      theme(legend.title=element_blank(),
            legend.background = element_rect(colour = 'grey', fill = 'white', linetype='solid'))
    
            
  
    corr_df_clin$mfi_mf_bl
    
    cor.test(formula = ~ ds_bwd_bl + mfi_mf_bl,
             data = corr_df_clin,
             subset = group == "mtbi",
             method= "pearson",
             alternative= "less") # split by group way of doing it without the pretty table
    
    ## unpacking/characterising clinical data in more detail 
    clin_data_bl %>%
      select(group,code, rpq_3_bl, rpq_13_bl) %>%
      filter(group=="mtbi") %>%
      arrange(rpq_13_bl)
    