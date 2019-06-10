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



