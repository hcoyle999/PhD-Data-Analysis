## --- summarising and visualising the mTBI sample characteristics 

loc_table<- COMBINED_COG_PhD %>%
  filter(group=="mtbi") %>%
  select(code, headinjury_hx, gcs, loc, loc_dur, amnesia, prior_injury,other_injury,ageofinjury) %>%
  mutate(loc= as.factor(loc)) %>%
  count(loc=="yes") %>%
  mutate(percent = n/sum(n)*100) %>%
  mutate_if(is.logical, as.character) %>%
  rename("LOC" = 'loc == "yes"') %>%
  mutate(LOC = if_else(LOC == "TRUE", "yes", "no"))


loc_fig<- loc_table %>%    # figure out how to change NA to unknown in label
  select(-n) %>%
  spread(LOC,percent) %>%
  gather(LOC, percentage) %>%
  mutate(LOC=factor(LOC, levels=c("yes","no","NA"), labels=c("yes","no","unknown"))) %>%
  ggplot(aes(x=LOC, y=percentage)) + 
  geom_bar(position=position_dodge(), stat="identity")

injury_table<-COMBINED_COG_PhD %>%
  filter(group=="mtbi") %>%
  count(injury_class) %>%
  mutate(percent = n/sum(n)*100)%>%
  arrange(desc(n))

inj_fig<- injury_table %>%    # figure out how to change NA to unknown in label
  select(-n) %>%
  spread(injury_class ,percent) %>%
  gather(injury_class, percentage) %>%
  mutate(injury_class=factor(injury_class, levels=c("PBA","Fall","HS","Pedestrian","MVA","Other"))) %>%
  ggplot(aes(x=injury_class, y=percentage)) + 
  geom_bar(position=position_dodge(), stat="identity")

amnesia_table<-COMBINED_COG_PhD %>%
  filter(group=="mtbi") %>%
  count(amnesia)%>%
  arrange(desc(n)) %>%
  mutate(percent = n/sum(n)*100)

amnesia_fig<- amnesia_table %>%    # figure out how to change NA to unknown in label
  select(-n) %>%
  spread(amnesia ,percent) %>%
  gather(amnesia, percentage) %>%
  mutate(amnesia=factor(amnesia,, levels=c("retrograde","nil","retrograde and anterograde","NA"))) %>%
  ggplot(aes(x=amnesia, y=percentage)) + 
  geom_bar(position=position_dodge(), stat="identity")

library(ggpubr)
ggarrange(
          labels = c("A", "B", "C"))

ggarrange(inj_fig,
          ggarrange(loc_fig, amnesia_fig,
                    ncol = 2,
                    labels=c("B","C")),
          nrow = 2,
          labels="A",
          common.legend = TRUE, legend = "right")

# RPQ characteristics (do categorical variables, will need to look up code for this)
RPQ<- COMBINED_COG_PhD %>%
  group_by(group) %>%
  select(code, group, rpq_16_bl)


# max total RPQ score is 64
#nil (0), mild (1-16), moderate (17-32), severe (33-48), very severe (49-64)
library(forcats)
rpq_table<- COMBINED_COG_PhD %>%
  filter(group=="mtbi") %>%
  select(rpq_16_bl) %>%
  mutate(rpq_cat = case_when(`rpq_16_bl` >= 49 ~ "very severe",
                             `rpq_16_bl` >= 33 ~ "severe",
                             `rpq_16_bl` >= 17~ "moderate",
                             `rpq_16_bl` >= 1 ~ "mild",
                             `rpq_16_bl` <= 0 ~ "nil")
         %>% as.factor) %>%
  count(rpq_cat)%>%
  arrange(desc(n)) %>%
  mutate(percent = n/sum(n)*100)



install.packages("treemap")
library(treemap)

#data in correct format (have cheated and done in excel)
tribble_paste()

tree_df<-tibble::tribble(
                                           ~cat_variable,              ~type, ~value, ~percent,
                                                    "LOC",              "yes",     12,       40,
                                                    "LOC",               "no",     13,    43.33,
                                                    "LOC",          "unknown",      5,    16.67,
                                                "Amnesia type",       "retrograde",     10,    33.33,
                                                "Amnesia type",             "nil",      9,       30,
                                                "Amnesia type", "retrograde and anterograde",      7,    23.33,
                                                "Amnesia type",          "unknown",      4,    13.33,
                                            "Injury type",          "bicycle",     13,    43.33,
                                            "Injury type",             "fall",      6,       20,
                                            "Injury type",      "head strike",      4,    13.33,
                                            "Injury type",       "pedestrian",      4,    13.33,
                                            "Injury type",              "mva",      3,     9.97,
                                                    "PCS",              "nil",      1,       50,
                                                    "PCS",             "mild",     15,     36.7,
                                                    "PCS",         "moderate",     11,       10,
                                                    "PCS",           "severe",      3,     3.33
                                           )

str(tree_df)

tree_df$cat_variable <- as.factor(tree_df$cat_variable)

palette.HCL.options <- list(hue_start=270, hue_end=360+150)

setwd(here)
setwd("./Analysis/Figures")

png(filename="mtbi_clin_char_tree.png",width=1000, height=700)
treemap<- treemap(tree_df, #Your data frame object
        index= c("cat_variable", "type"), #A list of your categorical variables
        vSize = "value",  #This is your quantitative variable
        type="index", #Type sets the organization and color scheme of your treemap
        palette = "HCL",  #Select your color palette from the RColorBrewer presets or make your own.
        palette.HCL.options = palette.HCL.options,
        title="Clinical characteristics of mTBI group", #Customize your title
        fontsize.title = 20, #Change the font size of the title
        fontsize.labels =c(18, 14)
)
# save treegraph
dev.off()



  