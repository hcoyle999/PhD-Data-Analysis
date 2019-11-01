## characterising the mTBI sample across time

## RPQ follow up questionnaire (maximum score = 40)
## RPQ baseline questionnarie (and control f/u q) (maximum score = 64)

# first create a data frame which has the score
rpq_table<- COMBINED_COG_PhD %>%
  filter(group=="mtbi") %>%
  select(code, rpq_16_bl, rpq_10_t1, rpq_10_t2) %>%
  mutate(rpq_bl_cat = case_when(`rpq_16_bl` >= 49 ~ "very severe",
                             `rpq_16_bl` >= 33 ~ "severe",
                             `rpq_16_bl` >= 17~ "moderate",
                             `rpq_16_bl` >= 1 ~ "mild",
                             `rpq_16_bl` <= 0 ~ "nil")
         %>% as.factor) %>%
  mutate(rpq_t1_cat = case_when(`rpq_10_t1` >= 30 ~ "very severe",
                                `rpq_10_t1` >= 20 ~ "severe",
                                `rpq_10_t1` >= 10~ "moderate",
                                `rpq_10_t1` >= 1 ~ "mild",
                                `rpq_10_t1` <= 0 ~ "nil")
         %>% as.factor) %>%
  mutate(rpq_t2_cat = case_when(`rpq_10_t2` >= 30 ~ "very severe",
                                `rpq_10_t2` >= 20 ~ "severe",
                                `rpq_10_t2` >= 10~ "moderate",
                                `rpq_10_t2` >= 1 ~ "mild",
                                `rpq_10_t2` <= 0 ~ "nil") %>%
           as.factor)

library(dplyr)

rpq_table_sum<- rpq_table %>%
                gather(key   = measure,
                      value = sympt_cat,
           rpq_bl_cat, rpq_t1_cat, rpq_t2_cat) %>%
               separate(measure, c("measure", "timepoint","cat")) %>%
      mutate_if(is.character,funs(factor(.))) %>%
      select (code, timepoint, sympt_cat) %>%
       drop_na()

#get factors in order
rpq_table_sum$sympt_cat <- factor(rpq_table_sum$sympt_cat, levels = c("nil", "mild", "moderate", "severe"))

library(forcats)
proportion <- rpq_table_sum %>%
  group_by(sympt_cat, timepoint) %>%
  tally() %>%
  group_by(timepoint) %>%
  mutate(pct = n / sum(n)*100)

proportion<- proportion %>%
group_by(sympt_cat, timepoint) %>%
  mutate(label_y = paste0(round(cumsum(pct)),"%"))

ggplot(proportion, aes(x = sympt_cat, y= n, fill = timepoint)) + 
    geom_bar(stat = "identity", position = "dodge", color = "grey40") +
    facet_wrap(~timepoint) +
    geom_text(aes(label = label_y), position = position_dodge(0.9),
              vjust = 1.5, color = "white") +
      scale_y_continuous(labels = scales::percent) +
      scale_x_discrete(labels = c("nil" = "nil", "mild" = "mild", 
                                "moderate" = "mod", "severe"= "severe")) +
    theme(axis.title.y=element_blank(),
          axis.title.x=element_blank(),
          axis.text.y=element_blank(),
          legend.position = "bottom",
          legend.background = element_blank(),
          legend.direction="horizontal",
          legend.title = element_blank())

getwd()
setwd(here)
setwd("./Analysis/Figures")
ggsave("PCS_long.jpg")

## sample characteristics of those who dropped out BL to T1

attrit_t1<- subset(COMBINED_COG_PhD,code %in% c(104, 117, 106, 108, 113, 128, 114, 115, 123))

attrit_t1 %>%
  dplyr::select(code, sex, age, ct_pathology,rpq_16_bl,mfi_bl_total,
                hads_total_bl, ravlt_t1_bl) %>%
  kable() %>%
  kable_styling()






  