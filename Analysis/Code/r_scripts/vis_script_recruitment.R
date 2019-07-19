
# read csv file (manually created in excel)
recruitment_tally<-read_csv(file="~/Documents/PHD-Data-Analysis/PHD-Data-Analysis/Analysis/Data/recruitment_tally.csv")

# add names to df
names(recruitment_tally)<- c("dates","group","total_sessions")

#change date from character to date value
recruitment_tally$dates <- as.Date(recruitment_tally$dates, tryFormats = c("%m/%d/%y"),logical=FALSE)

#change group to a factor (control, mtbi)  
recruitment_tally$group<- as.factor(recruitment_tally$group)

#plotting  
library(ggplot2)
graph<- recruitment_tally %>% 
  mutate(dates = as.Date(as.character(dates), "%Y-%d-%m")) %>% 
  ggplot(aes(dates, total_sessions)) + 
  geom_col(aes(fill = group)) + 
  coord_flip() + 
  scale_x_date(date_labels = "%b %Y")+
  labs(x = "", y= "Sessions", title = "Total number of sessions", subtitle =  "Nov-2016 to March-2019")+
  theme_light()+
  theme(plot.title = element_text(hjust = 0.5), 
        plot.subtitle = element_text(hjust = 0.5), 
        legend.position= c(0.8,0.2))

graph 
