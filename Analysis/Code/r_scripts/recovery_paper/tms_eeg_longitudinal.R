# first get data into R (should only need to do this once)
here<-"~/Documents/PHD-Data-Analysis/PHD-Data-Analysis"
setwd(here) #main path/homedirectory
#load data (already clean)
setwd("./Analysis/Data")


n100_all_df<-read_csv(file="mean_n100_amp_ALL.csv", col_names= TRUE) #load csv file

# quick tidy
n100_all_df <- n100_all_df %>%
  mutate_if(is.character,funs(factor(.)))


n100_all_wide<- n100_all_df %>%
  spread(key=timepoint, value= mean_100_amp) %>%
  dplyr::rename(
    n100_bl = "BL",
    n100_t1 = "T1",
    n100_t2 = "T2" ) %>%
  select(code, group, n100_bl, n100_t1, n100_t2)

save(n100_all_wide, file="n100_all_wide.Rdata")  #save in wide but tidy format
save(n100_all_df, file="n100_df_all.Rdata")  #save in long but tidy format

# add to main datframe
# COMBINED_COG_PhD<- merge(COMBINED_COG_PhD, n100_all_wide, by= c("code","group"),all=T)
# save(COMBINED_COG_PhD, file="~/Documents/PHD-Data-Analysis/PHD-Data-Analysis/Analysis/Data/COMBINED_COG_PhD.Rdata")


#make summary statistics
n100_all_summary<- n100_all_df %>%
  group_by(group, timepoint) %>%
  select(mean_100_amp) %>%
  set_colnames(c("group", "timepoint", "mean_n100" )) %>%
  gather(key="measure", value= "mean_n100_amp", -group, -timepoint, na.rm=TRUE) %>%
  summarySE(measurevar="mean_n100_amp", groupvars=c("group", "measure", "timepoint"))

## as a line graph
gbase<- n100_all_summary %>%
  ggplot(aes(y= mean_n100_amp, x= timepoint, colour=group))+
  geom_point() 
#geom_errorbar(aes(ymin = alpha_power - se, ymax = alpha_power + se),
#width=.2) ## optional SE bars, make graph look messy though

n100_all_summary$timepoint <- as.factor(n100_all_summary$timepoint)

gline <- gbase + geom_line() 
n100_all_summary$time = as.numeric(n100_all_summary$timepoint)
gline <- gline %+% n100_all_summary
print(gline + aes(x=time)+
        scale_x_continuous(breaks=c(1:3), labels=c("BL", "T1", "T2")))