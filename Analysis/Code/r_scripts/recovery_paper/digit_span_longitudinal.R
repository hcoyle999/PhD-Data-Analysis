-----## Behavioural Analysis ----

## Load data frames

here<-"~/Documents/PHD-Data-Analysis/PHD-Data-Analysis"
setwd(here) #main path/homedirectory
#load data (already clean)
setwd("./Analysis/Data")
load("ds_df_narrow.Rdata")
load("ds_df_wide.Rdata")

ds_df_narrow<- ds_df_narrow %>%
  separate(timepoint, 
           into = c("timepoint", "condition"), 
           sep = "_") 
  
# BL (original was 23 controls, 24 mTBI, now 24 controls, 26 mTBI)
ds_df_BL<- subset(ds_df_narrow,!id %in% c(7, 15, 16, 17, 113, 121, 123, 128))
## though, be aware I include 008, 101 and 103 as they have enough epochs for a Pre comparison
#ds_df_BL_1<- subset(ds_df_narrow,!id %in% c (7, 8, 15, 16, 17, 113, 121, 125, 128)) #7 not actuall in dataset

ds_df_BL_only<- subset(ds_df_narrow,!id %in% c(7, 8, 15, 16, 17, 101, 103, 113, 121, 123, 125, 128)) %>%
                filter(timepoint=="BL") %>%
                filter(condition=="Pre" | condition=="Post")
# get means and sd
ds_df_sum_BL<- ds_df_BL %>%
  filter(timepoint=="BL") %>%
  filter(condition=="Pre" | condition=="Post") %>%
  group_by (timepoint, condition, group) %>%
  select(-id) %>%
  summarySE(measurevar="accuracy", groupvars=c("group", "condition", "timepoint")) %>%
  mutate_if(is.character,funs(factor(.))) %>%
  select(-se, -ci)

# T1 timepoint ( 20 controls, 17 mTBI)
ds_df_T1 <-subset(ds_df_narrow,!id %in% c(3, 4, 7, 8, 13, 16, 17, 18, 102, 103, 104, 106, 108, 
                                            113, 114, 115, 116, 117, 121, 123, 128))

ds_df_T1_only<- subset(ds_df_narrow,!id %in% c(7, 8, 15, 16, 17, 101, 103, 113, 121, 123, 125, 128)) %>%
  filter(timepoint=="T1") %>%
  filter(condition=="Pre" | condition=="Post")
  
ds_df_sum_T1<- ds_df_T1 %>%
  filter(timepoint=="T1") %>%
  filter(condition=="Pre" | condition=="Post") %>%
  group_by (timepoint, condition, group) %>%
  select(-id) %>%
  summarySE(measurevar="accuracy", groupvars=c("group", "condition", "timepoint")) %>%
  mutate_if(is.character,funs(factor(.))) %>%
  select(-se, -ci)

# T2 timepoint ( 21 controls, 14 mTBI)
ds_df_T2 <-subset(ds_df_narrow,!id %in% c(7, 11, 15, 16, 18, 19, 24, 103, 104, 106, 108, 109, 
                                          112, 113, 114, 115, 116, 117, 120, 121, 123, 126, 128))

ds_df_T2_only<- subset(ds_df_narrow,!id %in% c(7, 8, 15, 16, 17, 101, 103, 113, 121, 123, 125, 128)) %>%
  filter(timepoint=="T2") %>%
  filter(condition=="Pre" | condition=="Post")

ds_df_sum_T2<- ds_df_T2 %>%
  filter(timepoint=="T2") %>%
  filter(condition=="Pre" | condition=="Post") %>%
  group_by (timepoint, condition, group) %>%
  select(-id) %>%
  summarySE(measurevar="accuracy", groupvars=c("group", "condition", "timepoint")) %>%
  mutate_if(is.character,funs(factor(.))) %>%
  select(-se, -ci)

## bind them together for summary graph
ds_df_long_sum<- rbind(ds_df_sum_BL, ds_df_sum_T1, ds_df_sum_T2)
ds_df_long<-rbind(ds_df_BL_only, ds_df_T1_only,ds_df_T2_only)
# visualise the data

# create graph for all domains
gbase <- ggplot(ds_df_long_sum, aes(y=accuracy, colour=condition)) + 
  geom_point() +
  facet_grid(~group) 
#geom_errorbar(aes(ymin = sympt_score - se, ymax = sympt_score + se),
#width=.2) ## optional SE bars, make graph look messy though

gline <- gbase + geom_line() 
print(gline + aes(x=timepoint)) # lines don't connect

# change time to numeric
ds_df_long_sum$time = as.numeric(ds_df_long_sum$timepoint)
unique(ds_df_long_sum$time)

#add to graph 
gline <- gline %+% ds_df_long_sum

#plot graph
print(gline + aes(x=time)+
        ylab("Accuracy") +
        ggtitle("Digit Span accuracy by group, timepoint & condition") +
        scale_x_continuous(breaks=c(1:3), labels=c("BL", "T1", "T2"))) +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        axis.title.x=element_blank(),
        legend.position= c(0.9,0.9),
        legend.title = element_blank(),
        legend.background = element_rect(colour = 'grey', fill = 'white', linetype='solid'))


# run some stats
# BL
ds_df_long %>%
  filter(timepoint =="BL" & condition =="Pre") %>%
  {t.test(.$accuracy ~ .$group)} #not significantly different p= 0.21

# T1
ds_df_long %>%
  filter(timepoint =="T1" & condition =="Pre") %>%
  {t.test(.$accuracy ~ .$group)} # significantly different p= 0.0187

# T2
ds_df_long %>%
  filter(timepoint =="T2" & condition =="Pre") %>%
  {t.test(.$accuracy ~ .$group)} # p = 0.0584


#quick look at within group comparisons (though this will be the 3rd paper analyses- so best to wait)
ds_df_long %>%
  filter(group =="Control", timepoint =="T2") %>% 
  {t.test(.$accuracy ~ .$condition, paired=TRUE)} # i.e. looking to see whether Pre and Post differ

#  lets see whether mTBI differ in BL to T1 
ds_df_T2 %>% #only select participants that did all three timepoints
  filter(group =="TBI", timepoint %in% c("BL", "T1"), condition == "Pre") %>% 
  {t.test(.$accuracy ~ .$timepoint, paired=TRUE)} # i.e. looking to see whether BL and T1 differ - not significant

ds_df_T2 %>% #only select participants that did all three timepoints
  filter(group =="TBI", timepoint %in% c("BL", "T1"), condition == "Pre") %>%
  mutate(id= as.character(id)) %>%
  group_by(timepoint) %>%
  summarise_if(., is.numeric, .funs=c("mean"=mean, "sd"=sd ),na.rm=TRUE) #get mean accuracy

#  lets see whether mTBI differ in T1 to T2 
ds_df_T2 %>% #only select participants that did all three timepoints
  filter(group =="TBI", timepoint %in% c("T1", "T2"), condition == "Pre") %>% 
  {t.test(.$accuracy ~ .$timepoint, paired=TRUE)} # i.e. looking to see whether T1 and T2 differ - not significant

ds_df_T2 %>% #only select participants that did all three timepoints
  filter(group =="TBI", timepoint %in% c("T1", "T2"), condition == "Pre") %>%
  mutate(id= as.character(id)) %>%
  group_by(timepoint) %>%
  summarise_if(., is.numeric, .funs=c("mean"=mean, "sd"=sd ),na.rm=TRUE) #get mean accuracy

#  lets see whether mTBI differ in BL to T2 
ds_df_T2 %>% #only select participants that did all three timepoints
  filter(group =="TBI", timepoint %in% c("BL", "T2"), condition == "Pre") %>% 
  {t.test(.$accuracy ~ .$timepoint, paired=TRUE)} # i.e. looking to see whether BL and T2 differ - yes significant

ds_df_T2 %>% #only select participants that did all three timepoints
  filter(group =="TBI", timepoint %in% c("BL", "T2"), condition == "Pre") %>%
  mutate(id= as.character(id)) %>%
  group_by(timepoint) %>%
  summarise_if(., is.numeric, .funs=c("mean"=mean, "sd"=sd ),na.rm=TRUE) #get mean accuracy



# do percentage change graph (Pre only)

# do for data frames seperately
ds_ds_perc_c <-ds_df_long %>%
  filter(group=="Control" & condition =="Pre") %>%
  group_by(timepoint) %>%
  mutate(id= as.character(id)) %>%
  summarise_if(., is.numeric, .funs=c("mean_sympt"=mean),na.rm=TRUE) 

ds_ds_perc_c$group<- "control"
ds_ds_perc_c$measure<- "digit_span"
ds_ds_perc_c$timepoint<- c("1","2","3")

ds_ds_perc_t <-ds_df_long %>%
  filter(group=="TBI" & condition =="Pre") %>%
  group_by(timepoint) %>%
  mutate(id= as.character(id)) %>%
  summarise_if(., is.numeric, .funs=c("mean_sympt"=mean),na.rm=TRUE) 

ds_ds_perc_t$group<- "tbi"
ds_ds_perc_t$measure<- "digit_span"
ds_ds_perc_t$timepoint<- c("1","2","3")


# apply functions
ds_ds_perc_c<-  pct_change(ds_ds_perc_c) # apply function to df
ds_ds_perc_t<-  pct_change(ds_ds_perc_t) # apply function to df

#put together         
ds_pct_change <- rbind(ds_ds_perc_c,ds_ds_perc_t)

# create graph 
gbase <- ggplot(ds_pct_change, aes(y=pct_change, colour=group)) + 
  geom_point()  


gline <- gbase + geom_line() 
#print(gline + aes(x=timepoint)) # lines don't connect

# change time to numeric
ds_pct_change$time = as.numeric(ds_pct_change$timepoint)   
#unique(mfi_pct_change$time)

#add to graph 
gline <- gline %+% ds_pct_change

#plot graph
ds_pct_change_graph<- gline + aes(x=time)+
  ylab("% change from BL") +
  ggtitle("Digit Span Accuracy \n (% change from baseline)") +
  scale_x_continuous(breaks=c(1:3), labels=c("BL", "T1", "T2")) +
  ylim(-25, 25) +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        axis.title.x=element_blank(),
        legend.position= c(0.9,0.2),
        legend.title = element_blank(),
        legend.background = element_rect(colour = 'grey', fill = 'white', linetype='solid'))





----## Neural Analysis----

----## Get data and tidy----

# first get data into R (should only need to do this once)
here<-"~/Documents/PHD-Data-Analysis/PHD-Data-Analysis"
setwd(here) #main path/homedirectory
#load data (already clean)
setwd("./Analysis/Data")


gfp_all_df<-read_csv(file="Mean_GFP_ALL.csv", col_names= TRUE) #load csv file

# quick tidy
gfp_all_df <- gfp_all_df %>%
    dplyr::rename("code"= "ID") %>%
    dplyr::rename("epoch_win"= "Window") %>%
    mutate_if(is.character,funs(factor(.)))

names(gfp_all_df) <- tolower(names(gfp_all_df))

str(gfp_all_df)

ds_gfp_wide<-gfp_all_df

save(ds_gfp_wide, file="ds_gfp_wide.Rdata")  #save in wide but tidy format

gfp_all_df_1<-gfp_all_df %>%
  subset(epoch_win == "first" | is.na(epoch_win))

gfp_all_df_1<- gfp_all_df_1 %>%
  spread(key=timepoint, value= mean_gfp) %>%
  dplyr::rename(
    gfp_1_bl = "BL",
    gfp_1_t1 = "T1",
    gfp_1_t2 = "T2" ) %>%
  select(code, group, gfp_1_bl, gfp_1_t1, gfp_1_t2)

gfp_all_df_2<-gfp_all_df %>%
  subset(epoch_win == "second" | is.na(epoch_win))

gfp_all_df_2<- gfp_all_df_2 %>%
  spread(key=timepoint, value= mean_gfp) %>%
  dplyr::rename(
    gfp_2_bl = "BL",
    gfp_2_t1 = "T1",
    gfp_2_t2 = "T2" ) %>%
  select(code, group, gfp_2_bl, gfp_2_t1, gfp_2_t2)

#merge df's
ds_gfp_all<- merge(gfp_all_df_1, gfp_all_df_2, by= c("code","group"), all=T)
#COMBINED_COG_PhD<- merge(COMBINED_COG_PhD, gfp_ds_gfp_alladd, by= c("code","group"),all=T)
#save(COMBINED_COG_PhD, file="~/Documents/PHD-Data-Analysis/PHD-Data-Analysis/Analysis/Data/COMBINED_COG_PhD.Rdata")
save(ds_gfp_all, file="ds_gfp_all.Rdata")


----## Make graphs (!) ----
load("ds_gfp_wide.Rdata") # load dataframe in wide format ( is in main df in long format)


#make summary statistics
ds_gfp_summary<- ds_gfp_wide %>%
  group_by(group, timepoint, epoch_win) %>%
  select(mean_gfp) %>%
  set_colnames(c("group", "timepoint", "epoch_win", "mean_gfp" )) %>%
  gather(key="measure", value= "mean_gfp", -group, -timepoint, -epoch_win, na.rm=TRUE) %>%
  summarySE(measurevar="mean_gfp", groupvars=c("group", "measure", "timepoint", "epoch_win"))

## as a line graph
gbase<- ds_gfp_summary %>%
  ggplot(aes(y= mean_gfp, x= timepoint, colour=group))+
  geom_point() +
  facet_grid(~epoch_win) +
  geom_errorbar(aes(ymin = mean_gfp - se, ymax = mean_gfp + se),width=.2) ## optional SE bars,

gline <- gbase + geom_line() 
ds_gfp_summary$time = as.numeric(ds_gfp_summary$timepoint)
gline <- gline %+% ds_gfp_summary
print(gline + aes(x=time)+
        scale_x_continuous(breaks=c(1:3), labels=c("BL", "T1", "T2")))

# change facet labels
# New facet label names for time variable
time.labs <- c("BL", "T1", "T2")
names(time.labs) <-  c("BL", "T1", "T2")
# New facet label names for epoch variable
epoch.labs <- c("92-188 ms", "194-388 ms")
names(epoch.labs) <- c("first","second")

## as a bar graph 
ds_gfp_summary %>%
  mutate(measure=factor(measure, labels ="mean_gfp")) %>%
  ggplot(aes(x=measure, y=mean_gfp, fill=group)) + 
  geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=mean_gfp-se, ymax=mean_gfp+se),
                width=.2,                    # Width of the error bars
                position=position_dodge(.9))+
  ylab("Mean GFP ") +
  facet_grid(epoch_win~timepoint, labeller = labeller(epoch_win = epoch.labs, timepoint = time.labs))+
  theme_light() +
  scale_fill_manual(values=c("deepskyblue1","royalblue4"))+
  #ggtitle(" ROI GFP Digit Span") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        legend.position = "none")

ggboxplot(ds_gfp_wide, x = "timepoint", y = "mean_gfp", color = "group",
          palette = c("#00AFBB", "#E7B800")) +
  facet_grid(~epoch_win)

## run some stats (but these don't take into account that the data is paired samples- will use MLM instead)

res.aov2 <- aov(mean_gfp ~ group*timepoint, data = ds_gfp_wide)
summary(res.aov2)
Anova(res.aov2, type = "III") # for unbalanced designs
model.tables(res.aov2, type="means", se = TRUE) # get means (but these are for first and second epoch win combineded)
TukeyHSD(res.aov2, which = "timepoint")
plot(res.aov2, 1) #homogeneity of variances
leveneTest(mean_gfp ~ group*timepoint, data = ds_gfp_wide) # homogeneity violated
plot(res.aov2, 2) #normality
aov_residuals <- residuals(object = res.aov2)
# Run Shapiro-Wilk test
shapiro.test(x = aov_residuals ) # normality violated
