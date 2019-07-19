

library(tidyverse) #formatting data for analysis
library(psych) #package for descriptive and analytic statistics
library(dplyr) #manipulating your data
library(ggplot2) #visualising your results
library(plyr) #manipulating your data (splitting, applying and combining)
library (lme4) #linear models
library (psycho) #format the output of statistical methods to directly paste them into a manuscript
library(tableone) #creating descriptive output tables (e.g. mean, SD and t-test)
library(gridExtra) #displays 2 (or more) ggplots on a page
library(finalfit) #quickly create elegant regression results tables and plots when modelling
library(broom) #convert output from regression, lm and t-tests into data.frame format 
library(knitr) # tibble/data frame in nice output (Kntir:kable) 
library(stargazer) # creating APA table output from R 


#can make plots with code or with the help of the esquisse package
esquisse::esquisser() #loads the GUI for ggplot2 (!!)
#https://github.com/dreamRs/esquisse/blob/master/README.md 

## gg theme assist is another helpful addin
#To edit ggplot2 themes, just highlight a ggplot2 object in your current script and     run the Addin from the Addins menu. ggplot2 will analyze your current plot, update   
#its defaults to your current specification and give you a preview. 