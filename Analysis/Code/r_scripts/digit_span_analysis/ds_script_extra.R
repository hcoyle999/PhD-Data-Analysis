 # additional digit span code # 

load("~/Documents/PHD-Data-Analysis/PHD-Data-Analysis/Analysis/Data/ds_df_wide.Rdata")
load("~/Documents/PHD-Data-Analysis/PHD-Data-Analysis/Analysis/Data/ds_df_narrow.Rdata")

# ---- Plotting ----

# exclude participants not used in ERP analysis 
ds_df_wide <-subset(ds_df_wide,!id %in% c(7,8, 15, 16, 17, 101, 103, 113, 121, 125, 128))
ds_df_narrow <-subset(ds_df_narrow,!id %in% c(7,8, 15, 16, 17, 101, 103, 113, 121, 125, 128))
# 23 controls, 23 mTBI participants

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

# boxplot (for all timepoints, BL-T1-T2)
Pre_Post %>%
  mutate (timepoint= factor(timepoint, levels=c("BL_Pre", "BL_Post", "T1_Pre", "T1_Post", "T2_Pre", "T2_Post"))) %>%
  ggplot(aes(x=timepoint, y=accuracy,colour=group,label=id)) +
  geom_boxplot() +
  #coord_flip()
  
  
  # geom point graph
  ggplotly(a)

p <- ggplot(ds_df_narrow, aes(x = timepoint, y = accuracy,
                              color = timepoint, palette="Paired", add = "jitter", shape = timepoint)) +
  geom_boxplot()

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




# check normality for each group and timepoint (though I think am only interested 
#in if the difference score is normally distributed)
library(dlookr)
ds_normality<- ds_df_excluded %>%
  group_by(group) %>%
  normality() %>%
  filter(p_value < 0.05)

i %>% 
  group_by(group, timepoint) %>% 
  do(tidy(shapiro.test(.$value)))

interaction.plot(i$timepoint, i$group, i$value) #interaction plot
interaction.plot(i$group, i$timepoint, i$value) 

shapiro.test(ds_df_excluded$bl_pre) #normal
shapiro.test(ds_df_excluded$bl_post) #non normal

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

# Run two way ANOVA

# for comparing groups analysis
# get data into correct format
i<-ds_df_wide %>%
  select(id, group, bl_pre, bl_post) %>%
  gather(key=timepoint, value= value, -group, -id) 

#compute the difference
i$timepoint<- factor(i$timepoint, levels= c("bl_pre","bl_post")) #change timepoint to a factor
diff_ds <- with(i, 
                value[timepoint == "bl_pre"] - value[timepoint == "bl_post"]) #calculate difference score

shapiro.test(diff_ds) #check difference score is normally distributed (is across both groups)
#violates normality

#two way ANOVA
ds_aov <- aov(value ~ group * timepoint, data = i)
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


#plot with facet grid by group
ggplot(i, aes(x=timepoint, y=value, colour=group)) + 
  geom_boxplot() +
  facet_grid(~group)

# non parametric altnerative
kruskal.test(value ~ group, data = i)

pairwise.wilcox.test(i$value, i$group,
                     p.adjust.method = "BH")


#plotting

ggplot(ds_df_excluded, aes(x))

