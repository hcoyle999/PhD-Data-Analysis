


#1. Calculating % change
##-----function for calc % change----
pct_change <- function(df) {
  #df$timepoint<- c("1","2","3") # make timepoint a number
  baseline<- df$mean_sympt[1] # baseline value
  pct_change_1 <- ((df$mean_sympt[2]/baseline-1 )* 100) #compare t1 to bl
  pct_change_2<- ((df$mean_sympt[3]/baseline-1 )* 100) # compare t2 to bl
  x <- c(0, pct_change_1, pct_change_2) # create a vector of values
  df[ , "pct_change"]<- x # add new column to df
  return(df)
}

##-----A. MFI Data-----

# from main datagrame, select variables of interest and put into long format
# first for fatigue symptoms ( total score)
mfi_pct<- COMBINED_COG_PhD %>%
  group_by(group) %>%
  select(mfi_total_bl, mfi_total_t1, mfi_total_t2) %>%
  gather(key   = measure,
        value = mean_score, -group) %>%
  drop_na() %>%
  separate(measure, 
           c("measure", "domain","timepoint")) %>%
  mutate_if(is.character,funs(factor(.))) %>%
  select(group, measure, timepoint, mean_score)

# do for data frames seperately
mfi_pct_c<-mfi_pct %>%
  filter(group=="control") %>%
  group_by(timepoint) %>%
  summarise_if(., is.numeric, .funs=c("mean_sympt"=mean),na.rm=TRUE) 

mfi_pct_c$group<- "control" # add group
mfi_pct_c$measure<- "mfi" # add measure


mfi_pct_t<-mfi_pct %>%
  filter(group=="mtbi") %>%
  group_by(timepoint) %>%
  summarise_if(., is.numeric, .funs=c("mean_sympt"=mean),na.rm=TRUE) 

mfi_pct_t$group<- "mtbi"
mfi_pct_t$measure<- "mfi"

# apply functions
mfi_pct_c<-  pct_change(mfi_pct_c) # apply function to df and create new column
mfi_pct_t<-  pct_change(mfi_pct_t) # apply function to df
         
#put together         
mfi_pct_change <- rbind(mfi_pct_c,mfi_pct_t)
         
# create graph 
gbase <- ggplot(mfi_pct_change, aes(y=pct_change, colour=group)) + 
         geom_point()  
      
gline <- gbase + geom_line() 

# change time to numeric
mfi_pct_change$time = as.numeric(mfi_pct_change$timepoint)   
#unique(mfi_pct_change$time)
         
         #add to graph 
         gline <- gline %+% mfi_pct_change
         
         #plot graph
         mfi_pct_graph<- gline + aes(x=time)+
                 ylab("% change from BL") +
                 ggtitle("MFI total score") +
                 scale_x_continuous(breaks=c(1:3), labels=c("BL", "T1", "T2")) +
           theme(plot.title = element_text(hjust = 0.5),
                 plot.subtitle = element_text(hjust = 0.5),
                 axis.title.x=element_blank(),
                 legend.position= c(0.2,0.2),
                 legend.title = element_blank(),
                 legend.background = element_rect(colour = 'grey', fill = 'white', linetype='solid'))

###-----B. HADS Data-----                 
  # do same for hads_data  
         hads_pct<- COMBINED_COG_PhD %>%
           group_by(group) %>%
           select(hads_total_bl, hads_total_t1, hads_total_t2) %>%
           gather(key   = measure,
                  value = mean_score, -group) %>%
           drop_na() %>%
           separate(measure, 
                    c("measure", "domain","timepoint")) %>%
           mutate_if(is.character,funs(factor(.))) %>%
           select(group, measure, timepoint, mean_score)
         
         # do for data frames seperately
         hads_pct_c<-hads_pct %>%
           filter(group=="control") %>%
           group_by(timepoint) %>%
           summarise_if(., is.numeric, .funs=c("mean_sympt"=mean),na.rm=TRUE) 
         
         hads_pct_c$group<- "control"
         hads_pct_c$measure<- "hads"
         
         
         hads_pct_t<-hads_pct %>%
           filter(group=="mtbi") %>%
           group_by(timepoint) %>%
           summarise_if(., is.numeric, .funs=c("mean_sympt"=mean),na.rm=TRUE) 
         
         hads_pct_t$group<- "mtbi"
         hads_pct_t$measure<- "hads"
         
         # apply functions
         hads_pct_c<-  pct_change(hads_pct_c) # apply function to df
         hads_pct_t<-  pct_change(hads_pct_t) # apply function to df
         
         #put together         
         hads_pct_change <- rbind(hads_pct_c,hads_pct_t)
         
         # create graph 
         gbase <- ggplot(hads_pct_change, aes(y=pct_change, colour=group)) + 
           geom_point()  
         
         
         gline <- gbase + geom_line() 
         #print(gline + aes(x=timepoint)) # lines don't connect
         
         # change time to numeric
         hads_pct_change$time = as.numeric(hads_pct_change$timepoint)   
         #unique(hads_pct_change$time)
         
         #add to graph 
         gline <- gline %+% hads_pct_change
         
         #plot graph
         hads_pct_graph<- gline + aes(x=time)+
                 ylab("% change from BL") +
                 ggtitle("HADS total score") +
                 scale_x_continuous(breaks=c(1:3), labels=c("BL", "T1", "T2")) +
           theme(plot.title = element_text(hjust = 0.5),
                 plot.subtitle = element_text(hjust = 0.5),
                 axis.title.x=element_blank(),
                 legend.position= c(0.2,0.2),
                 legend.title = element_blank(),
                 legend.background = element_rect(colour = 'grey', fill = 'white', linetype='solid'))
         
           
         
###-----C. Alpha power Data
         alpha_pct<- COMBINED_COG_PhD %>%
           group_by(group) %>%
           select(alpha_bl, alpha_t1, alpha_t2) %>%
           gather(key   = measure,
                  value = mean_score, -group) %>%
           drop_na() %>%
           separate(measure, 
                    c("measure", "timepoint")) %>%
           mutate_if(is.character,funs(factor(.))) %>%
           select(group, measure, timepoint, mean_score)
         
         # do for data frames seperately
         alpha_pct_c<-alpha_pct %>%
           filter(group=="control") %>%
           group_by(timepoint) %>%
           summarise_if(., is.numeric, .funs=c("mean_sympt"=mean),na.rm=TRUE) 
         
         alpha_pct_c$group<- "control"
         alpha_pct_c$measure<- "hads"
         
         
         alpha_pct_t<-alpha_pct %>%
           filter(group=="mtbi") %>%
           group_by(timepoint) %>%
           summarise_if(., is.numeric, .funs=c("mean_sympt"=mean),na.rm=TRUE) 
         
         alpha_pct_t$group<- "mtbi"
         alpha_pct_t$measure<- "hads"
         
         # apply functions
         alpha_pct_c<-  pct_change(alpha_pct_c) # apply function to df
         alpha_pct_t<-  pct_change(alpha_pct_t) # apply function to df
         
         #put together         
         alpha_pct_change <- rbind(alpha_pct_c,alpha_pct_t)
         
         # create graph 
         gbase <- ggplot(alpha_pct_change, aes(y=pct_change, colour=group)) + 
           geom_point()  
         gline <- gbase + geom_line()
         alpha_pct_change$time = as.numeric(alpha_pct_change$timepoint)   
         
         #add to graph 
         gline <- gline %+% alpha_pct_change
         
         #plot graph
         alpha_pct_graph<- gline + aes(x=time)+
           ylab("% change from BL") +
           ggtitle("ALPHA power ROI") +
           scale_x_continuous(breaks=c(1:3), labels=c("BL", "T1", "T2")) +
           theme(plot.title = element_text(hjust = 0.5),
                 plot.subtitle = element_text(hjust = 0.5),
                 axis.title.x=element_blank(),
                 legend.position= c(0.2,0.2),
                 legend.title = element_blank(),
                 legend.background = element_rect(colour = 'grey', fill = 'white', linetype='solid'))
         
###----Put graphs together----###
         library(ggpubr)
         ggarrange(mfi_pct_graph, hads_pct_graph, alpha_pct_graph,
                   labels = c("A", "B", "C"),
                   #ncol = 2, nrow = 2,
                   common.legend = TRUE, legend = "right")