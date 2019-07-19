## Necessary libraries

library(haven)
library(tidyverse)

## Opening my SPPS database and convert it to R file

rawdata<-"/Users/han.coyle/Documents/DPsych_ClinNeuro/2016/PhD_2016/Data/SPSS Databases/COMBINED_COG_PhD.sav"

## the following is to ensure that the SPSS data is loaded correctly so you can see variable labels and value labels 
#load database as a list
COMBINED_COG_PhD<-haven::read_spss(rawdata,user_na=FALSE)
save(COMBINED_COG_PhD,file="~/Documents/PHD-Data-Analysis/PHD-Data-Analysis/COMBINED_COG_PhD.Rdata")

## Initial data cleaning steps
#create a look up table to convert numeric codes into meaninful strings
lut <-c ("1" = "control", "2" = "mtbi")
lut_1 <- c ("1" = "female", "2" = "male")

#combine/use this to relabel 1 and 2's to control and mtbi- add to df
COMBINED_COG_PhD$group <- lut[COMBINED_COG_PhD$group]
COMBINED_COG_PhD$sex <- lut_1[COMBINED_COG_PhD$sex]

lut2 <-c ("1" = "yes", "2" = "no")
lut3 <-c("1"= "retrograde", "2"="anterograde", "3"= "retrograde and anterograde", "4"= "nil", "5"="NA" )
lut4 <- c("1"= "haemotoma", "2"= "haemmorhage", "3" = "fracture", "4"= "haemotoma and fracture", 
          "5"= "haemmorhage and haemotoma", "6"="nill")

#tidying up variable names
names(COMBINED_COG_PhD) <- tolower(names(COMBINED_COG_PhD))

#change levels to labels
COMBINED_COG_PhD$headinjury_hx <- lut2[COMBINED_COG_PhD$headinjury_hx]
COMBINED_COG_PhD$loc <- lut2[COMBINED_COG_PhD$loc]
COMBINED_COG_PhD$amnesia <- lut3[COMBINED_COG_PhD$amnesia]
COMBINED_COG_PhD$ct_pathology <- lut4[COMBINED_COG_PhD$ct_pathology]

#change into factors
COMBINED_COG_PhD$ct_pathology <- as.factor(COMBINED_COG_PhD$ct_pathology)

#change variable names trials
colnames(COMBINED_COG_PhD)[colnames(COMBINED_COG_PhD) == 'trial1_bl'] <- 'bvmt_t1_bl'
colnames(COMBINED_COG_PhD)[colnames(COMBINED_COG_PhD) == 'trial2_bl'] <- 'bvmt_t2_bl'
colnames(COMBINED_COG_PhD)[colnames(COMBINED_COG_PhD) == 'trial3_bl'] <- 'bvmt_t3_bl'

colnames(COMBINED_COG_PhD)[colnames(COMBINED_COG_PhD) == 'ss_fwd_bl'] <- 'ds_fwd_bl'
colnames(COMBINED_COG_PhD)[colnames(COMBINED_COG_PhD) == 'ss_bck_bl'] <- 'ds_bwd_bl'
colnames(COMBINED_COG_PhD)[colnames(COMBINED_COG_PhD) == 'ss_total_bl'] <- 'ds_total_bl'
colnames(COMBINED_COG_PhD)[colnames(COMBINED_COG_PhD) == 'ss_fwd_t1'] <- 'ds_fwd_t1'
colnames(COMBINED_COG_PhD)[colnames(COMBINED_COG_PhD) == 'ss_bck_t1'] <- 'ds_bwd_t1'
colnames(COMBINED_COG_PhD)[colnames(COMBINED_COG_PhD) == 'ss_total_t1'] <- 'ds_total_t1'
colnames(COMBINED_COG_PhD)[colnames(COMBINED_COG_PhD) == 'ss_fwd_t1'] <- 'ds_fwd_t2'
colnames(COMBINED_COG_PhD)[colnames(COMBINED_COG_PhD) == 'ss_bck_t1'] <- 'ds_bwd_t2'
colnames(COMBINED_COG_PhD)[colnames(COMBINED_COG_PhD) == 'ss_total_t1'] <- 'ds_total_t2'
colnames(COMBINED_COG_PhD)[colnames(COMBINED_COG_PhD) == 'intials'] <- 'initals'
colnames(COMBINED_COG_PhD)[colnames(COMBINED_COG_PhD) == 'rpq_10_mtbi'] <- 'rpq_10_mtbi_t1'

#attach to database
attach(COMBINED_COG_PhD)

#save cleaned data as a R data file (so don't have to do cleaning step everytime)
save(COMBINED_COG_PhD, file="~/Documents/PHD-Data-Analysis/PHD-Data-Analysis/Analysis/Data/COMBINED_COG_PhD.Rdata")
load("COMBINED_COG_PhD.Rdata") # only loads data set, not any of the df subframes that were created.


# Load tidyverse library
library(tidyverse)

