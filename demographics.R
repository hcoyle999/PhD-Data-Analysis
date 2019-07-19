
## --- exploratory data analysis for demographics

#A. Run descriptive stats and check for missing data 
attach(COMBINED_COG_PhD)
dem_descriptives <- COMBINED_COG_PhD %>%
  select(group, age, education, wtar) %>%
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
dem_normality<- COMBINED_COG_PhD %>%
  select(group, age, education, wtar) %>%
  group_by(group) %>%
  normality(age, education, wtar) %>%
  filter(p_value < 0.05) # mtbi age,education and wtar nonormal, control wtar non normal

#C. Check homogeneity of variance
library(broom)
dem_variance<- COMBINED_COG_PhD %>%
  select( age, education, wtar) %>%
  map_df(~ broom::tidy(var.test(. ~ group)), .id = 'var') %>%
  select(var, statistic, p.value, method) ## wtar violates homogeneity of var assumption

#if data is normal
dem_ttest<- COMBINED_COG_PhD %>%
  select( age, education, wtar) %>%
  map_df(~ broom::tidy(t.test(. ~ group)), .id = 'var') %>%
  select(var, estimate1, estimate2, statistic, p.value, method) %>%
  setNames(c(var='variable',estimate1='control_mean', estimate2='mtbi_mean', statistic='t_stat',p.vale='p_vale',method='method'))

# if data in non normal
dem_wc_rank<- COMBINED_COG_PhD %>%
  select( age, education, wtar) %>%
  map_df(~ broom::tidy(wilcox.test(. ~ group)), .id = 'var') %>%
  select(var, statistic, p.value, method)
  
#D. Create tables with demographics data output
library(tableone)
#change categorical variables to factors
myVars <- c("sex","age", "education", "wtar")
catVars <- c("sex")

#create tables for results output
dem_table_norm <- CreateTableOne(vars = myVars, factorVars = catVars, strata = "group",
                            data = COMBINED_COG_PhD) # handling data as normally distributed

dem_table_nonnorm<- print(dem_table_norm, nonnormal= c("age", "education","wtar"), 
                          cramVars = "sex", quote= TRUE) #handling data as non normally distributed

##not currently working- problem to do with JAVA
#export into .csv/ excel and save table 
#library(xlsx)
#tab1Mat<- print(tab1, exact="stage", quote=TRUE, nospaces=TRUE,printToggle = FALSE)
#write.csv(tab1Mat, file="/Users/han.coyle/Documents/PHD-Data-Analysis/PHD-Data-Analysis/Analysis/Tables/demographics.csv")

#library(stargazer)
#the above step is because stargazer can't deal with the data in "table 1" format
#dem_table<-read_csv(file="~/Documents/PHD-Data-Analysis/PHD-Data-Analysis/Analysis/Tables/demographics.csv")
#dem_table<-as.data.frame(dem_table) #stargazer does not work well wth tbl_df so change to data frame
#print(dem_table)

#create stargazer output and save as html
#stargazer(dem_table, title= "Demographic information", summary = FALSE, out="~/Documents/PHD-Data-Analysis/PHD-Data-Analysis/Analysis/Tables/demographics.html")

#visualising the differences with box plots (age, wtar, education)
par(mfrow = c(1,3))
boxplot(age~group, varwidth=TRUE,boxwex= 0.5,main="Age",names=c("control","mTBI"),ylab="Years",xlab="Baseline",col=c("light grey","light pink"))
boxplot(wtar~group, varwidth=TRUE,boxwex= 0.5,main="WTAR",names=c("control","mTBI"),ylab="Total Score",xlab="Baseline",col=c("light grey","light pink"))
boxplot(education~group, varwidth=TRUE,boxwex= 0.5,main="Edcuation",names=c("control","mTBI"),ylab="Years",xlab="Baseline",col=c("light grey","light pink"))


###---mTBI characteristics

#E. Explore mTBI sample characteristics 
#mean time since injury for each session 
#baseline
dys_pst_injury<-COMBINED_COG_PhD %>%
  filter(group=="mtbi") %>%
  select(dateofinjury, baseline, t1, t2) %>%
  mutate(inj2bsl = c(difftime(baseline, dateofinjury))) %>%
  mutate(inj2bsl= as.numeric(inj2bsl)) %>%
  mutate(bsl2t1 = c(difftime(t1, dateofinjury))) %>%
  mutate(bsl2t1= as.numeric(bsl2t1)) %>%
  mutate(t12t2 = c(difftime(t2, dateofinjury))) %>%
  mutate(t12t2= as.numeric(t12t2))

#calc sum stats (mean and SD)
dys_pst_injury_sum <- dys_pst_injury %>%
  select(inj2bsl, bsl2t1, t12t2) %>%
  summarise_all(list(min = ~min,
                     max= ~max,
                     mean= ~mean, 
                     sd= ~sd),na.rm=TRUE) %>%
                    gather(stat, val) %>%
                    separate(stat, 
                      into = c("var", "stat"), 
                      sep = "_") %>%
                    spread(stat, val) %>%
                    select(var, mean, sd, min, max) %>%
                    arrange(factor(var, levels = c("inj2bsl", "bsl2t1", "t12t2"))) #arrange in custom order

#-----------------------------------
# calculate number individuals who had loc
loc_table<- COMBINED_COG_PhD %>%
  filter(group=="mtbi") %>%
  select(code, headinjury_hx, gcs, loc, loc_dur, amnesia, prior_injury,other_injury,ageofinjury) %>%
  mutate(loc= as.factor(loc)) %>%
  count(loc=="yes") %>%
  mutate(percent = n/sum(n)*100) %>%
  mutate_if(is.logical, as.character) %>%
  rename("LOC" = 'loc == "yes"') %>%
  mutate(LOC = if_else(LOC == "TRUE", "yes", "no"))


# mean and sd loc (minutes)
library(psych)
detach("package:dlookr", unload=TRUE) #gets confused beacuse describe function is overruled by dlookr
describe(loc_dur, na.rm=TRUE)

#table of injury type
injury_table<-COMBINED_COG_PhD %>%
  filter(group=="mtbi") %>%
  count(injury_class) %>%
  mutate(percent = n/sum(n)*100)%>%
  arrange(desc(n))

#graph of type of injury - ordered by factor of frequencey
injury_plot<-COMBINED_COG_PhD %>%
  filter(group=="mtbi") %>%
  select(code, injury_class) %>%
  mutate(injury_class= as.factor(injury_class)) %>%
  ggplot(aes(fct_infreq(injury_class))) +
  geom_histogram(stat="count") + # can change fill colours
  theme_classic() +
  labs(x= "Injury Mechanism", y= "Frequency", title = "mTBI injury characteristics")+
  theme(plot.title = element_text(hjust = 0.5),plot.subtitle = element_text(hjust = 0.5))

# save plot to be used in paper or presentation (to do at end)
# setwd(here) # reroute to home wd
# png(filename="Analysis/Figures/injury_char.png")
# plot(injury_plot)
# dev.off()

# table of amnesia type counts
amnesia_table<-COMBINED_COG_PhD %>%
  filter(group=="mtbi") %>%
  count(amnesia)%>%
  arrange(desc(n)) %>%
  mutate(percent = n/sum(n)*100)
          
#barplot of amnesia counts
amnesia_plot<-COMBINED_COG_PhD %>%
  filter(group=="mtbi") %>%
  select(code, amnesia) %>%
  mutate(amnesia= as.factor(amnesia)) %>%
  ggplot(aes(fct_infreq(amnesia))) +
  geom_histogram(stat="count") + # can change fill colours
  theme_classic() +
  labs(x= "Type of Amnesia", y= "Frequency", title = "mTBI amnesia characteristics")+
  theme(plot.title = element_text(hjust = 0.5),plot.subtitle = element_text(hjust = 0.5))

# # save plot to be used in paper or presentation
# png(filename="Analysis/Figures/amnesia_char.png")
# plot(amnesia_plot)
# dev.off()

#put graphs together side by side
library(gridExtra)
comb_plot<- grid.arrange(amnesia_plot, injury_plot, ncol=2)

#Understand more about mTBI sample/feature engineering
#create mtbi table with PCS variable
mtbi_pcs<- COMBINED_COG_PhD %>%
  filter(group=="mtbi") %>%
  select(code, initals, amnesia, rpq_3_bl, rpq_13_bl, rpq_10_mtbi_t1,rpq_mtbi_t2 ) %>%
  mutate(pcs_bl = rpq_3_bl>=1, pcs_t1 = rpq_10_mtbi_t1>=1, pcs_t2 =rpq_mtbi_t2 >=1)

#change logicals to characters (recode)
mtbi_pcs$pcs_bl <- ifelse(mtbi_pcs$pcs_bl == TRUE, "yes", "no")
mtbi_pcs$pcs_t1 <- ifelse(mtbi_pcs$pcs_t1 == TRUE, "yes", "no")
mtbi_pcs$pcs_t2 <- ifelse(mtbi_pcs$pcs_t2 == TRUE, "yes", "no") 

pcs_table<-mtbi_pcs %>%
  count(pcs_bl=="yes")%>%
  mutate(percent = n/sum(n)*100) %>%
  mutate_if(is.logical, as.character) %>%
  rename("PCS" = 'pcs_bl == "yes"') %>%
  mutate(PCS = if_else(PCS == "TRUE", "yes", "no")) %>%
  arrange(desc(n)) # though will depend on how I define on PCS criteria- currently at any presence of sx's

# visualisation of relationship between GCS, PCS symptom severity and LOC (not that meaningful- just playing)
COMBINED_COG_PhD %>%
  filter(group=="mtbi") %>%
  ggplot(aes(x=gcs, y=rpq_13_bl, color=loc)) +
  geom_jitter(alpha=0.3) + 
  scale_color_manual(breaks = c('yes','no'),values=c('darkgreen','red'))


#look at ct_pathology - how many of sample had CT postive findings (n, %)?
ct_path_table<-COMBINED_COG_PhD %>%
  filter(group=="mtbi") %>%
  select(code,gcs,loc,loc_dur,injury_class,ct_pathology) %>%
  mutate(ct_clear= ct_pathology=="nill") %>%
  mutate(ct_clear= ifelse(ct_clear== TRUE, "yes","no")) %>%
  count(ct_clear=="yes")%>%
  mutate(percent = n/sum(n)*100) %>%
  mutate_if(is.logical, as.character) %>%
  rename("ct_clear" = 'ct_clear == "yes"') %>%
  mutate(ct_clear = if_else(ct_clear == "TRUE", "yes", "no")) %>%
  arrange(desc(n))  # again will depend on how we define CT pathology


#plot CT pathology
ct_path_plot<-COMBINED_COG_PhD %>%
  filter(group=="mtbi") %>%
  select(code, ct_pathology) %>%
  mutate(ct_pathology= as.factor(ct_pathology)) %>%
  ggplot(aes(fct_infreq(ct_pathology))) +
  geom_histogram(stat="count") + # can change fill colours
  theme_classic() +
  labs(x= "Type of CT pathology", y= "Frequency", title = "mTBI imaging characteristics")+
  theme(plot.title = element_text(hjust = 0.5),plot.subtitle = element_text(hjust = 0.5))

#counts of diff type of CT pathology
ct_path_type_table<-COMBINED_COG_PhD %>%
  filter(group=="mtbi") %>%
  count(ct_pathology)%>%
  mutate(percent = n/sum(n)*100) %>%
  arrange(desc(n))

## have not included as part of R Markdown files yet
#look at prior head injury
prior_inj_table<-COMBINED_COG_PhD %>%
  filter(group=="mtbi") %>%
  select(code,gcs,loc,loc_dur,prior_injury) %>%
  mutate(prior_inj_hx= prior_injury=="nil") %>%
  mutate(prior_inj_hx = if_else(prior_inj_hx == TRUE, "yes", "no")) %>%
  count(prior_inj_hx=="yes")%>%
  mutate(percent = n/sum(n)*100) %>%
  mutate_if(is.logical, as.character) %>%
  rename("prior_inj_hx" = 'prior_inj_hx == "yes"') %>%
  mutate(prior_inj_hx = if_else(prior_inj_hx == "TRUE", "yes", "no")) %>%
  arrange(desc(n))  # will want to see whether prior injury mediates any response?


#look at presence of other injury (orthopaedic)
other_inj_table<-COMBINED_COG_PhD %>%
  filter(group=="mtbi") %>%
  select(code,gcs,loc,loc_dur,other_injury) %>%
  mutate(other_inj_hx= other_injury=="nil") %>%
  mutate(other_inj_hx = if_else(other_inj_hx == TRUE, "yes", "no")) %>%
  count(other_inj_hx=="yes")%>%
  mutate(percent = n/sum(n)*100) %>%
  mutate_if(is.logical, as.character) %>%
  rename("other_inj_hx" = 'other_inj_hx == "yes"') %>%
  mutate(other_inj_hx = if_else(other_inj_hx == "TRUE", "yes", "no")) %>%
  arrange(desc(n)) 
  
# will prob want to check relationship btw orthopaedic injury and
                    # pain/mood/fatigue score



