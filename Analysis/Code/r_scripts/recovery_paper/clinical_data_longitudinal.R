library(tidyverse)
library(Rmisc)
library(lme4)
library(sjPlot)

-----## Graphing clinical data across time----
-----## MFI change across time-----
mfi_df <- COMBINED_COG_PhD %>%
  dplyr::select(starts_with("mfi"), group, code)

## wrangle the data into correct format
mfi_long<- mfi_df %>% 
  gather(key   = measure,
         value = sympt_score,
         dplyr::ends_with('bl'),
         dplyr::ends_with('t1'),
         dplyr::ends_with('t2'))

mfi_long<- mfi_long %>% separate(measure, 
                c("measure", "domain","timepoint")) %>%
            mutate_if(is.character,funs(factor(.))) ## make factor
# create summary statistics
mfi_long<-mfi_long %>%
summarySE(measurevar="sympt_score", groupvars=c("group","domain", "timepoint"), na.rm=TRUE)

# create graph (code/guide from https://hopstat.wordpress.com/2015/07/09/line-plots-of-longitudinal-summary-data-in-r-using-ggplot2-2/)
gbase <- ggplot(mfi_long, aes(y=sympt_score, colour=domain)) + 
  geom_point() +
  facet_grid(~group) 
  #geom_errorbar(aes(ymin = sympt_score - se, ymax = sympt_score + se),
                #width=.2) ## optional SE bars, make graph look messy though

gline <- gbase + geom_line() 
print(gline + aes(x=timepoint)) # lines don't connect
 
# change time to numeric
mfi_long$time = as.numeric(mfi_long$timepoint)
unique(mfi_long$time)

#plot graph
gline <- gline %+% mfi_long
print(gline + aes(x=time)+
        scale_x_continuous(breaks=c(1:3), labels=c("BL", "T1", "T2")))

#create a total MFI score
mfi_df_total <- mfi_df %>%
  mutate(mfi_bl_total = mfi_gf_bl + mfi_pf_bl + mfi_ra_bl + mfi_rm_bl + mfi_mf_bl) %>%
  mutate(mfi_t1_total = mfi_gf_t1 + mfi_pf_t1 + mfi_ra_t1 + mfi_rm_t1 + mfi_mf_t1) %>%
  mutate(mfi_t2_total = mfi_gf_t2 + mfi_pf_t2 + mfi_ra_t2 + mfi_rm_t2 + mfi_mf_t2) %>%
  dplyr::select(group, code, mfi_bl_total, mfi_t1_total,mfi_t2_total) %>%
  gather(key = measure, value = sympt_score, - group, -code) %>%
  separate(measure, c("measure", "timepoint", "total")) %>%
  mutate_if(is.character,funs(factor(.))) %>%
  dplyr::select(-total)
  

names(mfi_df)
-----## HADS change across time -----
hads_df <- COMBINED_COG_PhD %>%
  dplyr::select(starts_with("hads"), group, code)

## wrangle the data into correct format
hads_long<- hads_df %>% 
  gather(key   = measure,
         value = sympt_score,
         dplyr::ends_with('bl'),
         dplyr::ends_with('t1'),
         dplyr::ends_with('t2'))

hads_long<- hads_long %>% separate(measure, 
                                 c("measure", "domain","timepoint")) %>%
  mutate_if(is.character,funs(factor(.))) ## make factor
# create summary statistics
hads_long<-hads_long %>%
  summarySE(measurevar="sympt_score", groupvars=c("group","domain", "timepoint"), na.rm=TRUE)

# create graph (code/guide from https://hopstat.wordpress.com/2015/07/09/line-plots-of-longitudinal-summary-data-in-r-using-ggplot2-2/)
gbase <- ggplot(hads_long, aes(y=sympt_score, colour=domain)) + 
  geom_point() + facet_grid(~group)

gline <- gbase + geom_line() 
print(gline + aes(x=timepoint)) # lines don't connect

# change time to numeric
hads_long$time = as.numeric(hads_long$timepoint)
unique(hads_long$time)

#plot graph
gline <- gline %+% hads_long
print(gline + aes(x=time)+
        scale_x_continuous(breaks=c(1:3), labels=c("BL", "T1", "T2")))
  


-----## PCS change across time----
pcs_df_mtbi <- COMBINED_COG_PhD %>%
  dplyr::select(starts_with("rpq"), group, code) %>% 
  dplyr::select(-ends_with("control"),- ends_with("notes"), group, code) %>%
  filter(group == "mtbi")

colnames(pcs_df_mtbi)[colnames(pcs_df_mtbi) == 'rpq_10_mtbi_t1'] <- 'rpq_10_t1'
colnames(pcs_df_mtbi)[colnames(pcs_df_mtbi) == 'rpq_mtbi_t2'] <- 'rpq_10_t2' 

pcs_df_mtbi_long<- pcs_df_mtbi %>% 
  gather(key   = measure,
         value = sympt_score,
         dplyr::ends_with('bl'),
         dplyr::ends_with('t1'),
         dplyr::ends_with('t2')) %>%
  filter(!measure %in% c("rpq_3_bl", "rpq_13_bl")) ## don't include these measures

pcs_long<- pcs_df_mtbi_long %>% separate(measure, 
                                   c("measure", "domain","timepoint")) %>%
  mutate_if(is.character,funs(factor(.))) ## make factor
# create summary statistics
pcs_long<-pcs_long %>%
  summarySE(measurevar="sympt_score", groupvars=c("group","measure", "domain", "timepoint"), na.rm=TRUE)

# create graph (code/guide from https://hopstat.wordpress.com/2015/07/09/line-plots-of-longitudinal-summary-data-in-r-using-ggplot2-2/)
gbase <- ggplot(pcs_long, aes(y=sympt_score)) + 
  geom_point() + facet_grid(~group)

gline <- gbase + geom_line() 
print(gline + aes(x=timepoint)) # lines don't connect

# change time to numeric
pcs_long$time = as.numeric(pcs_long$timepoint)
unique(pcs_long$time)

#plot graph
gline <- gline %+% pcs_long
print(gline + aes(x=time)+
        scale_x_continuous(breaks=c(1:3), labels=c("BL", "T1", "T2")))


## RPQ follow up questionnaire (maximum score = 40)
## RPQ baseline questionnarie (and control f/u q) (maximum score = 64)

#do for mTBI
df1<- pcs_df_mtbi_long %>%
  filter(measure=="rpq_16_bl") %>%
  mutate(perc_sev = ((sympt_score/64)*100))

df2<-pcs_df_mtbi_long %>%
  filter(measure %in% c("rpq_10_t1", "rpq_10_t2")) %>%
  mutate(perc_sev = ((sympt_score/40)*100))

mtbi_sev_percent <-rbind(df1, df2)

# do for controls

# create df
pcs_df_control <- COMBINED_COG_PhD %>%
  dplyr::select(rpq_16_bl,rpq_16_t1,rpq_16_t2, group, code) %>% 
  filter(group=="control")

#make long
pcs_df_control_long<- pcs_df_control %>% 
  gather(key   = measure,
         value = sympt_score,
         dplyr::ends_with('bl'),
         dplyr::ends_with('t1'),
         dplyr::ends_with('t2'))

control_sev_percent <- pcs_df_control_long %>%
  mutate(perc_sev = ((sympt_score/64)*100))

control_sev_percent<- control_sev_percent %>% separate(measure, 
                                         c("measure", "domain","timepoint")) %>%
  mutate_if(is.character,funs(factor(.)))

control_sev_percent <-control_sev_percent %>%
  summarySE(measurevar="perc_sev", groupvars=c("group","measure", "timepoint"), na.rm=TRUE)

## merge two summary df before graphing

pcs_sev_percent <-rbind(mtbi_sev_percent, control_sev_percent)
pcs_sev_percent$group <- as.factor(pcs_sev_percent$group)

save(pcs_sev_percent, file="~/Documents/PHD-Data-Analysis/PHD-Data-Analysis/Analysis/Data/pcs_sum_data.Rdata")
## save as do not want to go through the above hassle again

-----##graph pcs data (as %'s) ##-----
here<-"~/Documents/PHD-Data-Analysis/PHD-Data-Analysis"
setwd(here) #main path/homedirectory
setwd("./Analysis/Data")

load("pcs_sum_data.Rdata")

gbase <- ggplot(pcs_sev_percent, aes(y=perc_sev, colour= group)) + 
  geom_point() #+ facet_grid(~group)

gline <- gbase + geom_line() 
print(gline + aes(x=timepoint)) # lines don't connect

# change time to numeric
pcs_sev_percent$time = as.numeric(pcs_sev_percent$timepoint)
unique(pcs_sev_percent$time)

#plot as line graph
library(viridis)
gline <- gline %+% pcs_sev_percent
print(gline + aes(x=time)+
        scale_x_continuous(breaks=c(1:3), labels=c("BL", "T1", "T2")))+ 
  theme_minimal() +
  scale_color_manual(values=c("#999999", "#E69F00")) +
  theme(legend.position = c(0.8, 0.9))

#plot as bar graph
# first do summary

pcs_sev_sum <- pcs_sev_percent %>%
gather(key   = measure,
       value = perc_sev,
       dplyr::ends_with('bl'),
       dplyr::ends_with('t1'),
       dplyr::ends_with('t2'))  %>% 
       separate(measure, c("measure", "domain","timepoint")) %>%
       mutate_if(is.character,funs(factor(.)))  %>% ## make factor
       summarySE(measurevar="perc_sev", groupvars=c("group","measure", "timepoint"), na.rm=TRUE)

pcs_sev_sum %>%
  mutate(measure=factor(measure, labels ="PCS")) %>%
  ggplot(aes(x=measure, y=perc_sev, fill=group)) + 
  geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin=perc_sev-se, ymax=perc_sev+se),
                width=.2,                    # Width of the error bars
                position=position_dodge(.9))+
  ylab("PCS Severity (% of total score)") +
  facet_wrap(~timepoint)+
  theme_light() +
  scale_fill_manual(values=c("deepskyblue1","royalblue4"))+
  #ggtitle(" ROI GFP Digit Span") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        legend.position = "bottom",
        legend.title=element_blank(),
        strip.background = element_rect(
                           color="dark grey", fill="grey", size=1.5, linetype="solid"),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank())

getwd()
setwd(here)
setwd("./Analysis/Figures")
ggsave("PCS_perc_long.jpg")

### redone the above graph with % severity ( as two measures are not on same scale)



-----### Modelling clinical data across time----

----### MFI Total across time ----
#using mixed linear models
# simple linear model ( Q - how does MFI total score vary by timepoint and group)
m1 <- lm(sympt_score ~ timepoint + group, data = mfi_df_total)
summary(m1)
dwplot(m1)

by_group<- mfi_df_total %>% 
  group_by(group) %>%                     # group data by group
  do(tidy(lm(sympt_score ~ timepoint, data = .))) %>% # run model on each grp
  dplyr::rename(model=group)  # make model variable

dwplot(by_group, 
       vline = geom_vline(xintercept = 0, colour = "grey60", linetype = 2)) + # plot line at zero _behind_ coefs
  theme_bw() + xlab("Coefficient Estimate") + ylab("") +
  ggtitle("Predicting MFI symptoms by Group") +
  theme(plot.title = element_text(face="bold"),
        legend.position = c(0.007, 0.01),
        legend.justification = c(0, 0),
        legend.background = element_rect(colour="grey80"),
        legend.title.align = .5)  ## can see that control's data mostly stay the same whereas mTBI at T1 and T2 decrease

## plot the means as a bar plot
base_plot <- ggplot(mfi_df_total, aes(x = timepoint, y = sympt_score)) +
  facet_grid(~group) +
  stat_summary(aes(fill = factor(timepoint)), fun.y = mean, geom = "bar", color = "black", na.rm = TRUE) + 
  scale_fill_manual(values = c("#66c2a5", "#8da0cb", "#7f66c2")) +  # colorbrewer2.org
  theme(legend.position = "none")
# put individual lines on bar graph
subj_means_plot <- base_plot + 
  stat_summary(aes(group = code), fun.y = mean,  # means from raw data
               geom = "point", shape = 19, size = 4, color = "skyblue1") +
  stat_summary(aes(group = code), fun.y = mean, 
               geom = "line", size = 1.2, color = "skyblue1")

# plot as a box plot
mfi_df_total %>%
  ggplot(aes(x=timepoint, y = sympt_score, fill=group))+
  geom_boxplot(na.rm = TRUE) +
  scale_fill_manual(values=c("deepskyblue1", "royalblue4")) +
  ggtitle("Fatigue severity across timepoints") +
  theme(plot.title = element_text(hjust = 0.5))

#create summary stats and plot
mfi_df_total_sum<- mfi_df_total %>%
  summarySE(measurevar="sympt_score", groupvars=c("group", "timepoint"), na.rm=TRUE)

gbase <- ggplot(mfi_df_total_sum, aes(y=sympt_score, colour=group)) + 
  geom_point(aes(shape=group, size = 5)) +
  geom_errorbar(aes(ymin = sympt_score - se, ymax = sympt_score + se)) +
  ylim(20, 70)

gline <- gbase + geom_line() 
print(gline + aes(x=timepoint)) # lines don't connect

# change time to numeric
mfi_df_total_sum$time = as.numeric(mfi_df_total_sum$timepoint)
unique(mfi_df_total_sum$time)

#plot graph
gline <- gline %+% mfi_df_total_sum
print(gline + aes(x=time)+
        ylab("MFI Total Score") +
        ggtitle("Change over time in fatigue symptoms by group and timepoint") +
        scale_x_continuous(breaks=c(1:3), labels=c("BL", "T1", "T2"))) +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        axis.title.x=element_blank(),
        legend.position= c(0.9,0.9),
        legend.title = element_blank(),
        legend.background = element_rect(colour = 'grey', fill = 'white', linetype='solid'))
## differnt graphing is just to give us an idea of the pattern, at the individual level and group

#Change over time in fatigue symptoms by group and timepoint.
#For the behavioral data, there were two categorical predictors
#(group ,timepoint) along with their interactions, including the two-way interaction.
#each participant was treated as a random variable


#the explanatory variables are: timepoint (within-participants, categorical fixed factor), group (within-participants, categorical fixed factor),
#and participant (participant, random factor)

#sympt_score = response variable

# more modelling
lmer0<- lmer(sympt_score ~ timepoint + (1|code), data = mfi_df_total) #timepoint fixed, subject = random ,
                                                                      # relationship between symt score and time
                                                                      # not accounting for group
# visualise/summary stats
summary(lmer0) # Effect sizes tell us about the strengths of the relationships we are testing
coef(lmer1) # retrieve model coefficients
tidy(lmer1) #tidy 
plot_model(lmer1, type = "re")
library(ggResidpanel)
resid_panel(lmer1) # residuals on a panel

# question is what is the strength and directionality of the relationship between timepoint and symptom score, when
# group*timepoint are fixed effects and subject is a random effect. 

#evaluate model fit (null vs actual)
null.mod<- lmer(sympt_score ~ timepoint + (1|code), data = mfi_df_total, na.action = na.exclude) #timepoint fixed, subject = random , relationship between symt score and time
mfi.mod<- lmer(sympt_score ~ timepoint*group + (1|code), data = mfi_df_total) #na.action = na.exclude) #timepoint fixed, group fixed, timepoint*group interaction fixed, id = random

summary(mfi.mod)

anova(null.mod, mfi.mod) # check sig of output, report chi squared value and df

BIC(null.mod, mfi.mod) # evaluate model fit BIC = Bayesian information criterion,

dwplot(list(null.mod, mfi.mod)) # plot the coefficients of the two models on same  graph

tab_model(
  null.mod, mfi.mod,
  show.ci = FALSE, 
  show.se = TRUE, 
  auto.label = FALSE, 
  string.se = "SE",
  show.icc = FALSE,
  dv.labels = c("Null Model", "MFI Model")) # compare models in table format
                                            # note The marginal R-squared considers only the variance of the fixed effects, while the conditional R-squared takes
                                            # both the fixed and random effects into account.

mfi_df_total$pred.mfi.mod <- fitted(mfi.mod) #add predicted values to df for comparison
                                            # be aware of action of NA values here

subset(mfi_df_total,code == "18") # check how predicted values differ from actual

mfi_df_total %>%
  dplyr::filter(group=="control") %>%
  ggplot() +
  geom_point(aes(x=timepoint,y=sympt_score), color="blue", size=3)  + 
  #facet_grid(~group) +
  geom_line(aes(x=timepoint,y=pred.mfi.mod)) + 
  facet_wrap(~code, ncol=4)    ## graph how predicted and actual values differ
## not working with line for some reason

dotplot(ranef(mfi.mod, condVar=TRUE), strip=FALSE)
#calculating power 
#https://rpsychologist.com/slides/powerlmm-intro-20180411/index.html#96


## Evaluating your model and checking assumptions --> 
library(car)
#1. Assess collinearity and linearity
car::vif(mfi.mod) ## detect multi collineraity in model
                  ## Calculates variance-inflation and generalized variance-inflation factors for linear, generalized linear, and other models.
#A VIF of six means that the variance (a measure of imprecision) of the estimated coefficients is six times higher because of correlation between the two independent variables.
# VIF = 1 (Not correlated)
# 1 < VIF < 5 (Moderately correlated)
# VIF >=5 (Highly correlated)

# resources for evaluating and reporting model
# https://wiki.bcs.rochester.edu/HlpLab/StatsCourses?action=AttachFile&do=get&target=Groningen11.pdf

#  Linearity
plot(mfi_df_total$sympt_score,resid(mfi.mod),
                           ylab="Residuals", xlab="Symptom Score", 
                           main="MFI total symptom score") # plotting residuals against observed value

#Ideally, residual values should be equally and randomly spaced around the horizontal axis.

#if have probs with missing values
length(resid(mfi.mod))
length(mfi_df_total$sympt_score)

mfi_df_total <- mfi_df_total %>%
                drop_na(sympt_score)

qqmath(mfi.mod, id=0.05) # check the residuals of model are normally distributed
                          # overall the line looks straight and therefore pretty normal and suggests that the assumption is not violated. 

#it is assumed that the random effects are normally distributed with the mean zero and the variance-covariance matrix  

ranef(mfi.mod) #examines the random effects (i.e things that are allowed to vary across units,
               #in this case each representing our subject-level effect of code for our participants)

# 2. Assess goodness-of-fit measures: R squared
cor(mfi_df_total$sympt_score, fitted(lmer(sympt_score ~ timepoint*group + (1|code),
                                  data = mfi_df_total,na.action = na.exclude)), use= "complete.obs")^2
#R2 = correlation(observed, fitted)2

# 3. Assess data likelihood: What is the probability that we would
#observe the data we have given the model (i.e. given the
                                          #predictors we chose and given the ‘best’ parameter
                                          #estimates for those predictors).
summary(mfi.mod)
logLik(mfi.mod) # should always be negative, but closer to 0 is better
AIC(mfi.mod) # smaller is better (same with BIC)

lmer_no_na<- lmer(sympt_score ~ timepoint*group + (1|code),
      data = mfi_df_total)
resid_panel(lmer_no_na)  ## get output on residuals (will not work with NA's in data)



