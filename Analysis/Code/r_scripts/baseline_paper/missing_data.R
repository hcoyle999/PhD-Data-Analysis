##---dealing with missing data

#load necessary libraries
library(inspectdf)
library(nainar)
library(mice)


# sub set the data frame
cog_data_bl <- select(COMBINED_COG_PhD, group, wtar:bvmt_recognition)
clin_data_bl <- select(COMBINED_COG_PhD, group, hads_anxiety_bl:mfi_mf_bl)

#check missingness for demographic and  bl data
COMBINED_COG_PhD %>%
  select(code:rmt_70) %>%
  inspect_na(show_plot = TRUE)  # too much info so not that useful
 
# data frame % of missing data by variable for cognitive data at BL split by groups
missing_values <- cog_data_bl %>% 
  group_by(group) %>%
  summarize_all(funs(sum(is.na(.))/n()*100)) # as a percentage

# change df format for graphing
missing_values <- gather(missing_values, key="feature",
                         value="missing_pct",-group)
# graph missingness
missing_values %>% 
  filter (missing_pct> 0) %>%
  ggplot(aes(x=reorder(feature,-missing_pct),y=missing_pct))+
  geom_col(aes(fill= group))+
  coord_flip()+theme_bw() #graph of percentage of missing data, only mtbi group has missing

## or can look at total missing data by variable for cognitive data at BL
miss_pct <- cog_data_bl %>% 
  map_dbl(function(x) { round((sum(is.na(x)) / length(x)) * 100, 1) })

miss_pct <- miss_pct[miss_pct > 0] #only variables with missing data

data.frame(miss=miss_pct, var=names(miss_pct), row.names=NULL) %>%
  ggplot(aes(x=reorder(var, -miss), y=miss)) + 
  geom_bar(stat='identity', fill='red') +
  labs(x='', y='% missing', title='Percent missing data by outcome measure') +
  theme(axis.text.x=element_text(angle=90, hjust=1)) #but this is for both groups

# OR create a df to look at missingness and decriptives
cog_data_bl %>% 
  ff_glimpse()

#imputation for missing data (mice=Multivariate Imputation via Chained Equations)
#(https://datascienceplus.com/handling-missing-data-with-mice-package-a-simple-approach/)
library(mice)                             #To impute the missing values, mice package use an algorithm  
init <- mice(cog_data_bl, maxit=0)        # in a such a way that use information from other variables in the dataset 
meth <- init$method                        # to predict and impute the missing values.
predM <- init$predictorMatrix

#If you want to skip a variable from imputation use the code below. 
#This variable will instead be used for prediction.
#meth[c("wtar")]=""

imputed <- mice(cog_data_bl, method=meth, predictorMatrix=predM, m=5) #run imputation
cog_data_bl_imp <- complete(imputed) #change back to data frame with imputation

sapply(cog_data_bl_imp, function(x) sum(is.na(x))) # check for NA's *(have all been removed)

## graphing missingness
# create explanatory and dependent variables to see specifics  
explanatory = c ("age", "education", "sex")
dependent = "wtar"
ff_glimpse(COMBINED_COG_PhD,dependent,explanatory)

## graphing missing data
# https://cran.r-project.org/web/packages/naniar/vignettes/naniar-visualisation.html

#cmissingness with nainar and ggplot
library(naniar)
COMBINED_COG_PhD %>%
  group_by(group) %>%
  ggplot(aes( x=age, y= coding_t1, colour=..missing..)) +
  geom_miss_point()+ 
  facet_wrap(~group)+
  theme(legend.position = "bottom") # graph of missing vs non missing by group

#shadow matrix for viewing missingness
as_shadow(COMBINED_COG_PhD)
bind_shadow(COMBINED_COG_PhD)

#visualise missingness
COMBINED_COG_PhD %>%
  bind_shadow() %>%
  ggplot(aes(x = age,
             fill = coding_t1_NA)) + 
  geom_density(alpha = 0.5)

#visualise for each variable
gg_miss_var(cog_data_bl, show_pct = TRUE) # % of missing values in each variable in a data set

#quick stats on missingness for whole df (for cases, rows, variables- use help function to see it all)
pct_miss(cog_data_bl)
pct_complete(cog_data_bl)
#or for variable
n_miss(COMBINED_COG_PhD$coding_t2)

#numerical summaries (**very helpful - could easily turn into a df **)
miss_var_summary(COMBINED_COG_PhD)
miss_case_summary(COMBINED_COG_PhD)

#numerical summaries by group
group_miss_var <- COMBINED_COG_PhD %>% 
  group_by(group) %>% 
  miss_var_summary

