# Analysis of cognitive data across time 
library(dlookr) #for normality
library(kableExtra) #for pretty tables

# create cog dataframe for baseline
cog_df <- COMBINED_COG_PhD %>%
  dplyr::select( group, code, tma_bl:cowat_bl, tma_t1:cowat_t1,tma_t2:cowat_t2) %>%
  select (-starts_with("trial")) #don't include individual BVMT

##---- Do some data tidying----
#change col names so are consistent
colnames(cog_df)[colnames(cog_df) == 'tma_bl'] <- 'tma_t_bl'
colnames(cog_df)[colnames(cog_df) == 'tma_t1'] <- 'tma_t_t1'
colnames(cog_df)[colnames(cog_df) == 'tma_t2'] <- 'tma_t_t2'

colnames(cog_df)[colnames(cog_df) == 'tmb_bl'] <- 'tmb_t_bl'
colnames(cog_df)[colnames(cog_df) == 'tmb_t1'] <- 'tmb_t_t1'
colnames(cog_df)[colnames(cog_df) == 'tmb_t2'] <- 'tmb_t_t2'

colnames(cog_df)[colnames(cog_df) == 'arithmetic_bl'] <- 'arithmetic_t_bl'
colnames(cog_df)[colnames(cog_df) == 'arithmetic_t1'] <- 'arithmetic_t_t1'
colnames(cog_df)[colnames(cog_df) == 'arithmetic_t2'] <- 'arithmetic_t_t2'

colnames(cog_df)[colnames(cog_df) == 'cowat_bl'] <- 'cowat_t_bl'
colnames(cog_df)[colnames(cog_df) == 'cowat_t1'] <- 'cowat_t_t1'
colnames(cog_df)[colnames(cog_df) == 'cowat_t2'] <- 'cowat_t_t2'

colnames(cog_df)[colnames(cog_df) == 'coding_bl'] <- 'coding_t_bl'
colnames(cog_df)[colnames(cog_df) == 'coding_t1'] <- 'coding_t_t1'
colnames(cog_df)[colnames(cog_df) == 'coding_t2'] <- 'coding_t_t2'

colnames(cog_df)[colnames(cog_df) == 'totalbvmt_bl'] <- 'totalbvmt_t_bl'
colnames(cog_df)[colnames(cog_df) == 'totalbvmt_t1'] <- 'totalbvmt_t_t1'
colnames(cog_df)[colnames(cog_df) == 'totalbvmt_t2'] <- 'totalbvmt_t_t2'

colnames(cog_df)[colnames(cog_df) == 'lns_bl'] <- 'lns_t_bl'
colnames(cog_df)[colnames(cog_df) == 'lns_t1'] <- 'lns_t_t1'
colnames(cog_df)[colnames(cog_df) == 'lns_t2'] <- 'lns_t_t2'

colnames(cog_df)[colnames(cog_df) == 'symbolsearch_bl'] <- 'symbolsearch_t_bl'
colnames(cog_df)[colnames(cog_df) == 'symbolsearch_t1'] <- 'symbolsearch_t_t1'
colnames(cog_df)[colnames(cog_df) == 'symbolsearch_t2'] <- 'symbolsearch_t_t2'

colnames(cog_df)[colnames(cog_df) == 'ravl_t2_bl'] <- 'ravlt_t2_bl'
colnames(cog_df)[colnames(cog_df) == 'ravl_t2_t1'] <- 'ravlt_t2_t1'
colnames(cog_df)[colnames(cog_df) == 'ravl_t2_t2'] <- 'ravlt_t2_t2'


# put in long format 
cog_df_long<- cog_df %>% 
  gather(key   = measure,
         value = value,
         dplyr::ends_with('bl'),
         dplyr::ends_with('t1'),
         dplyr::ends_with('t2')) %>%
         separate(measure, c("measure","domain", "timepoint")) %>%
         mutate_if(is.character,funs(factor(.))) ## make factor

# create summary statistics
cog_sum <-cog_df_long %>%
  summarySE(measurevar="value", groupvars=c("group","measure", "domain", "timepoint"), na.rm=TRUE)

##--- Function for longitudinal graph * clever! ----
long_graph <- function(df) {
  ggplot(df, aes(y=value, colour= measure)) + #change colour to measure or domain depending on str of data
    geom_point() + 
    facet_grid(~group)
  
  gline <- gbase + geom_line() 
  df$time = as.numeric(df$timepoint)
  gline <- gline %+% df
  print(gline + aes(x=time)+
          scale_x_continuous(breaks=c(1:3), labels=c("BL", "T1", "T2"))) }

##---- Graph congnitive data across time----

# 1. RAVLT

## A. Graph the ravlt (trials 1-5)
ravlt_g<- cog_sum %>%
  filter(measure=="ravlt") %>%
  filter(str_detect(domain, "^t")) %>% #filter by domain that starts with t (magic!)
  filter(!domain== "t") #but not total score (as alters graph scale too much)

  gbase<- ravlt_g %>%
  ggplot(aes(y= value, colour=domain))+
  geom_point() + facet_grid(~group)
  gline <- gbase + geom_line() 
  ravlt_g$time = as.numeric(ravlt_g$timepoint)
  gline <- gline %+% ravlt_g
  print(gline + aes(x=time)+
        scale_x_continuous(breaks=c(1:3), labels=c("BL", "T1", "T2")))

long_graph(ravlt_g)

## B. Graph the ravlt (total and recognition)

#2. Working Memory Index (DSF and DSB)

wmi_t<- cog_sum %>%
  filter(measure %in% c("ds","lns"))

long_graph(wmi_t)

#3. Trails A and B
trails_t<- cog_sum %>%
  filter(str_detect(measure, "^tm")) %>%
  mutate(measure= as.factor(measure)) %>%
  mutate(domain = as.character(domain))

str(trails_t)

gbase<- ggplot(trails_t, aes(y=value, colour= measure)) +
  geom_point() + 
  facet_grid(~group)

gline <- gbase + geom_line() 
trails_t$time = as.numeric(trails_t$timepoint)
gline <- gline %+% trails_t
print(gline + aes(x=time)+
        scale_x_continuous(breaks=c(1:3), labels=c("BL", "T1", "T2"))) 

# 4. Processing Speed Index 
psi_g<- cog_sum %>%
  filter(measure %in% c("coding", "symbolsearch"))

long_graph(psi_g)

# 5. COWAT
cowat_g<- cog_sum %>%
  filter(measure== "cowat")

long_graph(cowat_g)

##---- Stats comparisons for congnitive data across time----

# just doing t-tests
# make new dataframe for T1
cog_data_t1 <- select(COMBINED_COG_PhD, group, tma_t1:bvmt_delayrecall_t1, wtar) %>%
              mutate(group= as.factor(group))

#A. Run descriptive stats and check for missing data 
cog_descriptives <- cog_data_t1 %>%
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
cog_normality<- cog_data_t1 %>%
  group_by(group) %>%
  normality() %>%
  filter(p_value < 0.05) # stats consult suggest normality of distribution not important

#C. Check for equality of variance (across all variables in cog_data_bl by group)
# test for equality of variances 
cog_variance<- cog_data_t1 %>%
  select_if(is.numeric) %>%
  map_df(~ broom::tidy(var.test(. ~ group)), .id = 'var') %>%
  select(var, statistic, p.value, method) %>%
  filter(p.value < 0.05)        ### if for some reason is not working, check have used 

attach(cog_data_t1) 

#D. Statistical analysis of group differences  # test for difference in means at T1 BETWEEN groups
#if data is normal -all variables
cog_ttest_t1<- cog_data_t1 %>%
  select_if(is.numeric) %>%
  map_df(~ broom::tidy(aov(. ~ group + wtar)), .id = 'var') %>%  # ancova controlling for wtar
  select(var, term, df, statistic, p.value) %>%
  filter(!term=="Residuals") %>%
  filter(p.value < 0.05)

# check with III sum of squares
contrasts(cog_data_t1$group)<- contr.helmert(2)
wtar_model=aov(ravlt_t5_t1~group + wtar, data=cog_data_t1)

Anova(wtar_model, type="III")


library(kableExtra)
cog_ttest_t1<- cog_ttest_t1 %>%
  kable() %>%
  kable_styling()

# quick look at within group comparisons
tbi_cog_all <-subset(cog_df,!code %in% c( 103, 104, 106, 108, 112, 113,
                                        114, 115, 116, 117, 120, 121, 123, 126, 128)) #N= 15

#BL vs T1

tbi_cog_long<- tbi_cog_all %>% #put into long format
  gather(key   = measure,
         value = value,
         dplyr::ends_with('bl'),
         dplyr::ends_with('t1'),
         dplyr::ends_with('t2')) %>%
  separate(measure, c("measure","domain", "timepoint")) %>%
  mutate_if(is.character,funs(factor(.))) %>% ## make factor
  filter(group =="mtbi", timepoint %in% c("bl", "t1")) %>% 
  mutate(code= as.character(code))


tbi_cog_wide<- tbi_cog_long %>%
  mutate(measure = paste(measure, domain, sep="_")) %>%
  select(-domain) %>%
  spread(key=measure, value= value) %>%
  mutate(timepoint= factor(timepoint, levels=c("bl", "t1"))) # %>%
  #drop_na() #tried this because paired t-test issues but still not working

attach(tbi_cog_wide)

tbi_cog_stats<- tbi_cog_wide %>%
  select_if(is.numeric) %>%
  map_df(~ broom::tidy(t.test(. ~ timepoint), paired=TRUE), .id = 'var') %>%
  select(var, statistic, p.value, method) ## not working
           
  tbi_cog_wide$timepoint

  t.test(cowat_t~timepoint, paired=TRUE, data= tbi_cog_wide)
  
  # lets do some descriptives
  tbi_cog_wide %>%
    group_by(timepoint) %>%
    summarise_if(., is.numeric, .funs=c("mean"=mean, "sd"=sd),na.rm=TRUE) 
  

# make new dataframe for T2
cog_data_t2 <- select(COMBINED_COG_PhD, group, tma_t2:bvmt_delayrecall_t2)

#A. Run descriptive stats and check for missing data 
cog_descriptives <- cog_data_t2 %>%
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
cog_normality<- cog_data_t2 %>%
  group_by(group) %>%
  normality() %>%
  filter(p_value < 0.05) # stats consult suggest normality of distribution not important

#C. Check for equality of variance (across all variables in cog_data_bl by group)
# test for equality of variances 
cog_variance<- cog_data_t2 %>%
  select_if(is.numeric) %>%
  map_df(~ broom::tidy(var.test(. ~ group)), .id = 'var') %>%
  select(var, statistic, p.value, method) %>%
  filter(p.value < 0.05)                  ### if for some reason is not working, check have used
### attach(cog_data_bl) 

#D. Statistical analysis of group differences  # test for difference in means 
#if data is normal -all variables
cog_ttest_t2<- cog_data_t2 %>%
  select_if(is.numeric) %>%
  map_df(~ broom::tidy(t.test(. ~ group)), .id = 'var') %>%
  select(var, estimate1, estimate2, statistic, p.value, method) %>%
  setNames(c(var='variable',estimate1='control_mean', estimate2='mtbi_mean',
             statistic='t_stat',p.value='p_value',method='method'))

library(kableExtra)
cog_ttest_t2<- cog_ttest_t2 %>%
  kable() %>%
  kable_styling()

