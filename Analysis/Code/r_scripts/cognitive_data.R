#Cognitive  Information for Control and mTBI r script

## --- normality testing for cogntiive data
# create data frame subset
cog_data_bl <- select(COMBINED_COG_PhD, group, wtar:bvmt_recognition,bvmt_total_bl)
cog_data_bl$group<- as.factor(cog_data_bl$group)
COMBINED_COG_PhD$group<- as.factor(COMBINED_COG_PhD$group)
attach(cog_data_bl) #MUST do this or map_df etc won't work

#A. Run descriptive stats and check for missing data 
cog_descriptives <- cog_data_bl %>%
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

#B. Check for normality (and filter by p value)
cog_normality<- cog_data_bl %>%
  group_by(group) %>%
  normality() %>%
  filter(p_value < 0.05) # stats consult suggest normality of distribution not important

#C. Check for equality of variance (across all variables in cog_data_bl by group)
# test for equality of variances 
cog_variance<- cog_data_bl %>%
  select_if(is.numeric) %>%
  map_df(~ broom::tidy(var.test(. ~ group)), .id = 'var') %>%
  select(var, statistic, p.value, method) %>%
  filter(p.value < 0.05)                  ### if for some reason is not working, check have used
                                          ### attach(cog_data_bl) 

#D. Statistical analysis of group differences  # test for difference in means 
#if data is normal -all variables
cog_ttest_all<- cog_data_bl %>%
  select_if(is.numeric) %>%
  map_df(~ broom::tidy(t.test(. ~ group)), .id = 'var') %>%
  select(var, estimate1, estimate2, statistic, p.value, method) %>%
  setNames(c(var='variable',estimate1='control_mean', estimate2='mtbi_mean',
             statistic='t_stat',p.value='p_value',method='method'))

library(kableExtra)
  cog_ttest_all<- cog_ttest_all %>%
  kable() %>%
  kable_styling()
  
cog_ttest_sig<- cog_data_bl %>%
  select_if(is.numeric) %>%
  map_df(~ broom::tidy(t.test(. ~ group)), .id = 'var') %>%
  select(var, estimate1, estimate2, statistic, p.value, method) %>%
  setNames(c(var='variable',estimate1='control_mean', estimate2='mtbi_mean', statistic='t_stat',p.value='p_value',method='method')) %>%
  filter(p_value <0.05)

# if data in non normal
cog_wc_rank<- cog_data_bl %>%
  select_if(is.numeric) %>%
  map_df(~ broom::tidy(wilcox.test(. ~ group)), .id = 'var') %>%
  select(var, statistic, p.value, method) %>%
  filter(p.value <0.05)

cog_wc_rank<- cog_wc_rank %>%
  kable() %>%
  kable_styling()

#2. Create descriptives table for baseline paper
#change categorical variables to factors
myVars <- c(names(cog_data_bl))
myVars <- myVars[-(1:1)] #remove code and group
catVars <- c("group")

#create table by group
cog_tab <- CreateTableOne(vars = myVars, strata = "group" , data = cog_data_bl, factorVars = catVars)

# see results (this is equivalent to running a t-test on each variable (via map_df), however also get SD output)
print(cog_tab)

#see a summary of data (look for skew, kurtosis etc) - but can't save as a dataframe??
summary(cog_tab, digits= 2)
#do.call(cbind, lapply(cog_tab_1, summary))

#get into right format for excel
cog_data_bl_output<- print(cog_tab, exact="stage", quote=TRUE, nospaces=TRUE,printToggle = FALSE)

setwd(here)
setwd("./Analysis/Tables")

# save as excel file
write.csv(cog_data_bl_output, file="cog_data_bl.csv")

#load back in again ( this step is necessary for stargazer)
cog_table<-read_csv(file="cog_data_bl.csv")
#stargazer does not work well wth tbl_df so change to data frame
cog_table<-as.data.frame(cog_table) 

#once back in df format can use in kable to look at data in viewer
cog_table %>%
  kable() %>%
  kable_styling() 

#save as an html so can input into baseline paper 
stargazer(cog_table, title= "Cognitive Data", summary = FALSE, out="cog_data_bl.html")

setwd(here)
setwd("./Analysis/Tables")
save_kable(cog_ttest_all, "./cog_data_output")

#visualising the data (boxplots)

#Attention and WM
# Digit span forwards, backwards, LNS & Arithmetic 
COMBINED_COG_PhD %>%
  group_by(group) %>%
  select(ds_fwd_bl, ds_bwd_bl, lns_bl, arithmetic_bl) %>%
  gather(key="variable", value= "total_score", -group, na.rm=FALSE) %>%
  mutate(variable=factor(variable, levels =c("ds_fwd_bl","ds_bwd_bl","lns_bl", "arithmetic_bl")))%>%
  #t.test(timepoint, DSB, var.equal=TRUE)
  ggplot(aes(x=variable, y = total_score, fill=group))+
  geom_boxplot() +
  scale_fill_manual(values=c("#999999", "#FFB6C1"))

cog_data_bl %>%
  select(group, ds_fwd_bl,ds_bwd_bl,lns_bl, arithmetic_bl) %>%
  select_if(is.numeric) %>%
  map_df(~ broom::tidy(t.test(. ~ group)), .id = 'var') %>%
  select(var, estimate1, estimate2, statistic, p.value, method) %>%
  setNames(c(var='variable',estimate1='control_mean', estimate2='mtbi_mean', statistic='t_stat',p.value='p_value',method='method')) %>%
  #filter(p_value <0.05)
  kable() %>%
  kable_styling()

# Trails A & B
COMBINED_COG_PhD %>%
  group_by(group) %>%
  select(tma_bl,tmb_bl) %>%
  gather(key="variable", value= "total_score", -group, na.rm=FALSE) %>%
  mutate(variable=factor(variable, levels =c("tma_bl","tmb_bl")))%>%
  #t.test(timepoint, DSB, var.equal=TRUE)
  ggplot(aes(x=variable, y = total_score, fill=group))+
  geom_boxplot() +
  scale_fill_manual(values=c("#999999", "#FFB6C1"))

  cog_data_bl %>%
  select(group,tma_bl,tmb_bl) %>%
  select_if(is.numeric) %>%
  map_df(~ broom::tidy(t.test(. ~ group)), .id = 'var') %>%
  select(var, estimate1, estimate2, statistic, p.value, method) %>%
  setNames(c(var='variable',estimate1='control_mean', estimate2='mtbi_mean', statistic='t_stat',p.value='p_value',method='method')) %>%
  #filter(p_value <0.05)
  kable() %>%
  kable_styling()
  
  #Verbal Memory
  COMBINED_COG_PhD %>%
    group_by(group) %>%
    select(ravlt_t1_bl, ravl_t2_bl, ravlt_t3_bl, ravlt_t4_bl, ravlt_t5_bl, ravlt_d_bl) %>%
    gather(key="variable", value= "total_score", -group, na.rm=FALSE) %>%
    mutate(variable=factor(variable, levels =c("ravlt_t1_bl", "ravl_t2_bl", "ravlt_t3_bl", "ravlt_t4_bl", "ravlt_t5_bl", "ravlt_d_bl")))%>%
    #t.test(timepoint, DSB, var.equal=TRUE)
    ggplot(aes(x=variable, y = total_score, fill=group))+
    geom_boxplot() +
    scale_fill_manual(values=c("#999999", "#FFB6C1"))
  
  #total and recognition (as on different scale)
  COMBINED_COG_PhD %>%
    group_by(group) %>%
    select(ravlt_t_bl, ravlt_recognition) %>%
    gather(key="variable", value= "total_score", -group, na.rm=FALSE) %>%
    mutate(variable=factor(variable, levels =c("ravlt_t_bl", "ravlt_recognition")))%>%
    #t.test(timepoint, DSB, var.equal=TRUE)
    ggplot(aes(x=variable, y = total_score, fill=group))+
    geom_boxplot() +
    scale_fill_manual(values=c("#999999", "#FFB6C1"))
  
  cog_data_bl %>%
    select(group, ravlt_t1_bl, ravl_t2_bl, ravlt_t3_bl, ravlt_t4_bl, ravlt_t5_bl, ravlt_d_bl, ravlt_t_bl, ravlt_recognition) %>%
    select_if(is.numeric) %>%
    map_df(~ broom::tidy(t.test(. ~ group )), .id = 'var') %>%
    select(var, estimate1, estimate2, statistic, p.value, method) %>%
    setNames(c(var='variable',estimate1='control_mean', estimate2='mtbi_mean', statistic='t_stat',p.value='p_value',method='method')) %>%
    #filter(p_value <0.05)
    kable() %>%
    kable_styling() #var.equal=TRUE - can include behind group if homogeneity of var
  
    # visual memory
    COMBINED_COG_PhD %>%
      group_by(group) %>%
      select(group, bvmt_t1_bl,bvmt_t2_bl,bvmt_t3_bl) %>%
      gather(key="variable", value= "total_score", -group, na.rm=FALSE) %>%
      mutate(variable=factor(variable, levels =c("bvmt_t1_bl","bvmt_t2_bl","bvmt_t3_bl")))%>%
      #t.test(timepoint, DSB, var.equal=TRUE)
      ggplot(aes(x=variable, y = total_score, fill=group))+
      geom_boxplot() +
      scale_fill_manual(values=c("#999999", "#FFB6C1"))
    

    #create total bvmt_score
    COMBINED_COG_PhD<- COMBINED_COG_PhD %>% 
      mutate(bvmt_total_bl= bvmt_t1_bl + bvmt_t2_bl + bvmt_t3_bl)
    
    COMBINED_COG_PhD %>%
      group_by(group) %>%
      select(group, bvmt_total) %>%
      gather(key="variable", value= "total_score", -group,na.rm=FALSE) %>%
      mutate(variable=factor(variable, levels =c("bvmt_total")))%>%
      #t.test(timepoint, DSB, var.equal=TRUE)
      ggplot(aes(x=variable, y = total_score, fill=group))+
      geom_boxplot() +
      scale_fill_manual(values=c("#999999", "#FFB6C1"))
    
    cog_data_bl %>%
      select(group, bvmt_t1_bl,bvmt_t2_bl,bvmt_t3_bl,bvmt_total_bl) %>%
      select_if(is.numeric) %>%
      map_df(~ broom::tidy(t.test(. ~ group )), .id = 'var') %>%
      select(var, estimate1, estimate2, statistic, p.value, method) %>%
      setNames(c(var='variable',estimate1='control_mean', estimate2='mtbi_mean', statistic='t_stat',p.value='p_value',method='method')) %>%
      #filter(p_value <0.05)
      kable() %>%
      kable_styling() 

    #Processing Speed
    COMBINED_COG_PhD %>%
      group_by(group) %>%
      select(group, coding_bl, symbolsearch_bl) %>%
      gather(key="variable", value= "total_score", -group,na.rm=FALSE) %>%
      mutate(variable=factor(variable, levels =c("coding_bl", "symbolsearch_bl")))%>%
      #t.test(timepoint, DSB, var.equal=TRUE)
      ggplot(aes(x=variable, y = total_score, fill=group))+
      geom_boxplot() +
      scale_fill_manual(values=c("#999999", "#FFB6C1"))
    

    cog_data_bl %>%
      select(group, coding_bl, symbolsearch_bl) %>%
      select_if(is.numeric) %>%
      map_df(~ broom::tidy(t.test(. ~ group )), .id = 'var') %>%
      select(var, estimate1, estimate2, statistic, p.value, method) %>%
      setNames(c(var='variable',estimate1='control_mean', estimate2='mtbi_mean', statistic='t_stat',p.value='p_value',method='method')) %>%
      #filter(p_value <0.05)
      kable() %>%
      kable_styling() 
    
    #Verbal Fluency
    COMBINED_COG_PhD %>%
      group_by(group) %>%
      select(group, cowat_bl) %>%
      gather(key="variable", value= "total_score", -group,na.rm=FALSE) %>%
      mutate(variable=factor(variable, levels =c("coding_bl", "symbolsearch_bl")))%>%
      #t.test(timepoint, DSB, var.equal=TRUE)
      ggplot(aes(x=variable, y = total_score, fill=group))+
      geom_boxplot() +
      scale_fill_manual(values=c("#999999", "#FFB6C1"))
    
    cog_data_bl %>%
      select(group, cowat_bl) %>%
      #filter(cowat_bl >20) %>%
      select_if(is.numeric) %>%
      map_df(~ broom::tidy(t.test(. ~ group )), .id = 'var') %>%
      select(var, estimate1, estimate2, statistic, p.value, method) %>%
      setNames(c(var='variable',estimate1='control_mean', estimate2='mtbi_mean', statistic='t_stat',p.value='p_value',method='method')) %>%
      #filter(p_value <0.05)
      kable() %>%
      kable_styling() #outlier for control group is code=14 (NESB)

    #checking to see if outliers make a difference in the data
    #COMBINED_COG_PhD_1 <- subset(COMBINED_COG_PhD,!code %in% c(14,15))
    #t.test(tmb_bl~ group, COMBINED_COG_PhD_1)
  