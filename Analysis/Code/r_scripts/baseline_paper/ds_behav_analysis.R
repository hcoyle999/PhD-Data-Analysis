
## ---- Libraries ----

library(tidyverse)

## ---- SourceFiles ----

#path="Analysis/Data/ds_behavioural_analysis" #may not work due to wd
ds_behav_files <- list.files(pattern=glob2rx("*.txt"), 
                             path="ds_behavioural_analysis", 
                             recursive = TRUE,
                             full.names = TRUE)
head(ds_behav_files)
length(ds_behav_files)

#create filenames and function 
#filenames <- file.path(path, paste0(id, '/',id,"_", timepoint,"_", condition,"-Digit Span.txt"))

## ---- SourceFilesAlternative ----
## save the filenames so we can repeat later on

writeLines(ds_behav_files, "ds_files.lst")
ds_behav_files <- readLines("ds_files.lst")

## Load one for testing purposes

testdf <- read.delim(ds_behav_files[7])

library(readr)

## ---- LoadFunction ----
# Notice that there is no group, participant ID, timepoint (BL, T1, T2) or condition (Pre, Post, Delay)
# That information is in the file path
# Lets write a special function to transform the input data
# Points - tools for manipulating file paths
# tools for pulling apart words - reference regular expressions.
# Special date objects - lubridate

load_ds_behav <- function(filename) {
  if (!file.exists(filename)) {
    warning(paste("Missing", filename))
    return(NULL)
  }
  
  ## pull the filename apart with bash style processing
  pathA <- dirname(filename)
  folder1 <- basename(pathA)
  id<- folder1
  
  folder2<- basename(filename)
  folder2split <- stringr::str_split(folder2, pattern="_")
  timepoint<-folder2split[[1]][2]
  
  folder3<- filename
  condition <- stringr::word(folder3, sep="-")
  condition <-stringr::str_split(condition, pattern="_")
  condition <- condition [[1]][5]
  
  df <- read.table(filename,header = TRUE, sep = "\t",fileEncoding= "ASCII")
  
  ## Add in our new fields -
  df <- mutate(df, sourcefile=filename, id=id, 
               timepoint=timepoint, condition=condition)
  df <- select(df, id, timepoint, condition, everything())
  df <- select(df, -c(Sequence,Response))
  
  # Calculate accuracy and make df smaller
  acc_data<-sum(df$Accuracy=="Correct")
  df<-mutate(df, accuracy=acc_data)
  df<-select(df, id, timepoint, condition, accuracy) 
  df<-head(df,1) 
  return(df)
}

## ---- LoadData ----

 #trial_df<- load_ds_behav(ds_behav_files[10,])

  ds_dflist <- lapply(ds_behav_files, load_ds_behav) 
  ds_df_big <- bind_rows(ds_dflist)

  ## Now we have it working, instantly apply to everything
  ds_df <- map_df(ds_behav_files, load_ds_behav)
  ds_df$timepoint<-paste(ds_df$timepoint,ds_df$condition,sep="_")
  ds_df<-select(ds_df,-condition)
  
  ## ---- Tidydata ----

 
 #two formats- can look at wide or narrow
  #narrow format
 ds_df_narrow<-select(ds_df, id, timepoint, accuracy)
 ds_df_narrow$id<- as.numeric(ds_df_narrow$id) # change from character to numeric so can mutate to create groups
 ds_df_narrow<- mutate(ds_df_narrow, group= ifelse(id <100, "Control", "TBI"))
 ds_df_narrow$group <-as.factor(ds_df_narrow$group) # make group a factor
 ds_df_narrow<- select(ds_df_narrow, "id", "group", "timepoint", "accuracy")
 ds_df_narrow<-set_names(ds_df_narrow, tolower(names(ds_df_narrow)))
 
 #wide format
 ds_df_wide<- spread(ds_df, timepoint, accuracy)
 ds_df_wide<-set_names(ds_df_wide, tolower(names(ds_df_wide)))
 ds_df_wide$id<- as.numeric(ds_df_wide$id) # change from character to numeric so can mutate to create groups
 ds_df_wide<- mutate(ds_df_wide, group= ifelse(id <100, "Control", "TBI"))
 ds_df_wide<- select(ds_df_wide, "id", "group", "bl_pre", "bl_post", "bl_delay", "t1_pre", "t1_post", "t1_delay", "t2_pre", "t2_post", "t2_delay")
 ds_df_wide$group <-as.factor(ds_df_wide$group) # make group a factor
 
 #save so don't have to run each time
 save(ds_df_wide, file="~/Documents/PHD-Data-Analysis/PHD-Data-Analysis/Analysis/Data/ds_df_wide.Rdata")
 save(ds_df_narrow, file="~/Documents/PHD-Data-Analysis/PHD-Data-Analysis/Analysis/Data/ds_df_narrow.Rdata")
 
 load("~/Documents/PHD-Data-Analysis/PHD-Data-Analysis/Analysis/Data/ds_df_wide.Rdata")
 load("~/Documents/PHD-Data-Analysis/PHD-Data-Analysis/Analysis/Data/ds_df_narrow.Rdata")
 # ---- Plotting ----

 #scatter plot of bl_pre and bl_post across groups
 ds_df_wide %>%
   ggplot(aes(bl_pre, bl_post, colour=group))+
   geom_point()
 
 #make timepoint a factor and reorder so looks nice on y axis for graph
 library(plotly)
 library(ggplot2)
 Timepoint<- c("BL_Pre","BL_Post","BL_Delay", "T1_Pre","T1_Post","T1_Delay","T2_Pre","T2_Post","T2_Delay")    
 ds_df_narrow$timepoint <- factor(ds_df_narrow$timepoint,levels= Timepoint, ordered=TRUE,exclude= NULL)
 #note to self, when reording factors, names need to match EXACTLY, watch for pesky underscores)
 
 attach(ds_df_narrow)
 # if I only want to lookat Pre and Post (i.e. drop the delay conditions)
 Pre_Post<- ds_df_narrow[ds_df_narrow$timepoint %in% c("BL_Pre", "BL_Post", "T1_Pre", "T1_Post", "T2_Pre", "T2_Post"), ] 

# boxplot
Pre_Post %>%
   mutate (timepoint= factor(timepoint, levels=c("BL_Pre", "BL_Post", "T1_Pre", "T1_Post", "T2_Pre", "T2_Post"))) %>%
  ggplot(aes(x=timepoint, y=accuracy,colour=group,label=id)) +
   geom_boxplot() +
   coord_flip()

 # geom point graph
 ggplotly(a)
 
 p <- ggplot(ds_df_narrow, aes(x = timepoint, y = accuracy,
                color = timepoint, palette="Paired", add = "jitter", shape = timepoint)) +
      geom_boxplot()
      
 #geom boxplot of all data by timepoints (not seperated into groups)
 
 ggplot(ds_df_narrow, aes(x=timepoint,y = accuracy, fill=group)) + 
   geom_boxplot() 
   
 #geom boxplot of all data by timepoints (separated into groups)
 # ---- Stats ----
 #summary(ds_df)
 library(psych)
 library(dplyr)
 
 ds_df_wide$group<-as.factor(ds_df_wide$group)
 
 # get summary stats
 summary_ds <- ds_df_wide %>%
  describe()%>%
  select(n, mean, sd)
 #can't figure out how to do this by group
 
 ds_df_wide %>% 
   group_by(group) %>%
   tally()    #how many in each group
 
 # summary df of means for each group * ALSO remember this summarise_all () very helpful*
 summary_df_mean<- ds_df_wide %>% 
   group_by(group) %>%
   select(-id) %>%
   summarise_all(.funs=c(mean="mean",sd="sd"),na.rm=TRUE)
                 
      ## for control group!          
 #paired sample t-test (control) testing for difference pre and post in digit span date 
 d<-ds_df_wide%>% #create df
   filter(group== "Control") %>%
   select(id, group, bl_pre, bl_post, bl_delay, t1_pre, t1_post, t1_delay, t2_pre, t2_post, t2_delay)  
   
 #plot (for control data only)
  ds_df_narrow %>%
    filter(group=="Control") %>%
    ggplot(aes(x=timepoint,y = accuracy)) +  geom_boxplot()
 
  t.test(d$bl_pre, d$bl_post, paired=TRUE) # sig difference (p=0.04)
  t.test(d$t1_pre, d$t1_post, paired=TRUE) # no sig diff (p=0.60)
  t.test(d$t2_pre, d$t2_post, paired=TRUE) # no sig diff (p=0.32)
  
 # for TBI group !
  e<-ds_df_wide%>% #create df
    filter(group== "TBI") %>%
    select(id, group, bl_pre, bl_post, bl_delay, t1_pre, t1_post, t1_delay, t2_pre, t2_post, t2_delay)  
  
  t.test(e$bl_pre, e$bl_post, paired=TRUE) #not sif difference (p=0.37)
  t.test(e$t1_pre, e$t1_post, paired=TRUE) 
  t.test(e$t2_pre, e$t2_post, paired=TRUE) 
  
  ds_df_narrow %>%
    filter(group=="TBI", !id==128) %>% # excluding 128 (should probably do this for all analyses)
    ggplot(aes(x=timepoint,y = accuracy)) +  geom_boxplot()
 
# for both groups (and ANOVA)
  
  #check structure 
  str(ds_df_narrow)
  
  h<-ds_df_wide %>%
    select(group, bl_pre, bl_post) %>%
    gather(key=timepoint, value= value, -group) 
    
  timepoint2<- c("bl_pre","bl_post")
  
  #graph it for both groups at BL (pre-post)
  h$timepoint<-factor(h$timepoint, levels=timepoint2, ordered=TRUE)
  ggplot(h, aes(x=timepoint, y=value, color=group)) + 
    geom_boxplot()
  
  #ggplot(h, aes( x = timepoint, y = value, color = group,
         #add = c("mean_se", "dotplot"))) +
         #geom_line()
 
  # two way ANOVA with interaction effect
   ds_aov <- aov(value ~ group + timepoint + group:timepoint, data = h)
   summary(ds_aov) # main effect of group is significant

   model.tables(ds_aov, type="means", se = TRUE)   
   TukeyHSD(ds_aov, which = "timepoint")
   TukeyHSD(ds_aov, which = "group")
   
   plot(ds_aov, 1) #plot homogeneity of variance
   leveneTest(value ~ timepoint*group, data = h)

  # http://www.sthda.com/english/wiki/two-way-anova-test-in-r
   # unbalanced sample sizes ?? 
  
    ## ---- Data only in ERP analysis ----
  
   ## Looking at data sample only included in ERP analyses (excluded  = 008, 009, 015, 017, 101, 103, 113, 121, 125, 128)
   ds_df_excluded <-subset(ds_df_wide,!id %in% c(8,9,15,17,101,103,113,121,125,128)) #should be a total of 46 participants 
                                                                                    # 23 controls, 23 mTBI

   #calculate descriptives table
   ds_descriptives <- ds_df_excluded %>%
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
   #just mean and sd baseline pre and post
   summary_df_mean<- ds_df_excluded %>% 
     group_by(group) %>%
     select(-id) %>%
     summarise_all(.funs=c(mean="mean",sd="sd"),na.rm=TRUE)
   
   # check normality for each group and timepoint (though I think am only interested 
   #in if the difference score is normally distributed)
   library(dlookr)
   ds_normality<- ds_df_excluded %>%
     group_by(group) %>%
     normality() %>%
     filter(p_value < 0.05)
   
   # Q1 - Is there are difference between Pre and Post conditions for both groups
   # Compare mean Pre and Post across whole sample
   
   t.test(ds_df_excluded$bl_pre, ds_df_excluded$bl_post, paired=TRUE) #normal data analysis
                                                                      #not signficant p=0.065
   wilcox.test(ds_df_excluded$bl_pre, ds_df_excluded$bl_post, paired = TRUE, alternative = "two.sided") 
                                                                      #non normal data analysis
                                                                      #p=0.0063
   #means of pre vs post condiiton (when not split by group)
   mean(ds_df_excluded$bl_pre) #mean= 9.23
   mean(ds_df_excluded$bl_post)# mean=9.829
   
   #A = No, means are not sig different 
   
   # Compare group means Pre and Post across whole sample
   summary_df_mean<- ds_df_excluded %>% 
     group_by (group) %>%
     select(-id, bl_pre, bl_post) %>%
     summarise_all(.funs=c(mean="mean",sd="sd"),na.rm=TRUE)
   
   
   #Q2 - Is there a difference between Pre OR Post performance between controls and mTBI
   
   #compare means of bl_pre condiiton by group (control pre vs mtbi pre)
   t.test(bl_pre ~ group, data = ds_df_excluded, paired=FALSE) # normal data analysis
                                                 # not significant, 
                                                 # control mean= 9.74, mtbi mean= 8.75
                                                 # p = 0.1653
   
   wilcox.test(bl_pre ~ group, data = ds_df_excluded)  # non- normal data analysis
                                                       # not significant, p =0.16
   
   #compare means of bl_post condiiton by group (control post vs mtbi post)
   t.test(bl_post ~ group, data = ds_df_excluded, paired=FALSE) # normal data analysis
                                                  # almost significant, 
                                                  # control mean= 10.60, mtbi mean= 9.08
                                                  # p=0.0733
   
   wilcox.test(bl_post ~ group, data = ds_df_excluded) #non- normal data analysis
                                                       # not significant, p=0.1049
   #A = No, not significantly different for either timepoint
   
   #Q2 - Is there a difference between Pre and Post performance for controls OR mtbi
   
   ds_df_excluded %>%
     filter (group== "Control") %>%
     do(tidy(t.test(bl_pre, bl_post, paired = TRUE))) #working but don't trust output.
     
   ds_df_control <- ds_df_excluded %>%
     filter (group== "Control") 
   
   ds_df_mtbi <- ds_df_excluded %>%
     filter (group== "TBI") 
   
   t.test(ds_df_control$bl_pre, ds_df_control$bl_post, paired=TRUE) #no sig diff
   t.test(ds_df_mtbi$bl_pre, ds_df_mtbi$bl_post, paired=TRUE) #no sig diff
   
   #A. No, not significant
   
   # Run ANOVA
   
   # for comparing groups analysis
   # get data into correct format
   i<-ds_df_excluded %>%
     select(group, bl_pre, bl_post) %>%
     gather(key=timepoint, value= value, -group) 
   
   #compute the difference
   i$timepoint<- as.factor(i$timepoint) #change timepoint to a factor
   diff_ds <- with(i, 
             value[timepoint == "bl_pre"] - value[timepoint == "bl_post"]) #calculate difference score
   
   shapiro.test(diff_ds) #check difference score is normally distributed (is across both groups)
                         #violates normality
   
  #two way ANOVA
   ds_aov <- aov(value ~ group + timepoint + group:timepoint, data = i)
   summary(ds_aov) # main effect of group is significant
   
   model = lm(value ~ group*timepoint, data=i)
   Anova(model, type="III") 
   summary(model)   #alternative method?? https://wlperry.github.io/2017stats/05_6_twowayanova.html
   
   model.tables(ds_aov, type="means", se = TRUE)   
   TukeyHSD(ds_aov, which = "timepoint")
   TukeyHSD(ds_aov, which = "group")
   
   library(car) #need for levene's test
   plot(ds_aov, 1) #plot homogeneity of variance
   leveneTest(value ~ timepoint*group, data = i) #homogeneity of variance not violated
   
   ggplot(i, aes(x=timepoint, y=value, color=group)) + 
     geom_boxplot()+
     scale_fill_manual(values=c("#999999", "#FFB6C1"))
   
   # non parametric altnerative
   kruskal.test(value ~ group, data = i)
   
   pairwise.wilcox.test(i$value, i$group,
                        p.adjust.method = "BH")
   
   