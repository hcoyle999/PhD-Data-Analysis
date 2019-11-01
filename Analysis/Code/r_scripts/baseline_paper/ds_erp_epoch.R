#load in data from excel using tribble_paste()
tribble_paste()
epoch_df<- tibble::tribble(
     ~Group, ~ID, ~Pre, ~Post,
  "control",   1,   40,    27,
  "control",   2,   39,    43,
  "control",   3,   57,    38,
  "control",   4,   60,    40,
  "control",   5,   52,    47,
  "control",   6,   55,    65,
  "control",   9,   28,    49,
  "control",  10,   27,    52,
  "control",  11,   34,    22,
  "control",  12,   44,    45,
  "control",  13,   98,    98,
  "control",  14,   29,    29,
  "control",  18,   22,    33,
  "control",  19,   29,    53,
  "control",  20,   20,    18,
  "control",  21,   30,    33,
  "control",  22,   28,    23,
  "control",  23,   43,    61,
  "control",  24,   25,    46,
  "control",  25,   32,    45,
  "control",  26,   35,    50,
  "control",  27,   34,    21,
  "control",  28,   40,    38,
     "mtbi", 102,   16,    21,
     "mtbi", 104,   45,    60,
     "mtbi", 105,   45,    37,
     "mtbi", 106,   26,    28,
     "mtbi", 107,   28,    35,
     "mtbi", 108,   22,    28,
     "mtbi", 109,   31,    55,
     "mtbi", 110,   40,    30,
     "mtbi", 111,   33,    30,
     "mtbi", 112,   37,    26,
     "mtbi", 114,   62,    35,
     "mtbi", 115,   14,    19,
     "mtbi", 116,   46,    44,
     "mtbi", 117,   29,    22,
     "mtbi", 118,   16,    22,
     "mtbi", 119,   20,    28,
     "mtbi", 120,   19,    23,
     "mtbi", 122,   24,    21,
     "mtbi", 124,   35,    44,
     "mtbi", 126,   60,    62,
     "mtbi", 127,   25,    19,
     "mtbi", 129,   52,    52,
     "mtbi", 130,   22,    36
  )
#turn group into a factor
str(epoch_df)
epoch_df$Group<-factor(epoch_df$Group)

epoch_df_excluded <-subset(ds_df_wide,!id %in% c(13)) #re run with outlier excluded.


#create summary stats table
summary<-epoch_df %>%
  group_by(Group) %>%
  select(Group, Pre, Post) %>%
  summarise_all(list(
    min = ~min,
    max = ~max,
    mean = ~mean,
    sd = ~sd), na.rm=TRUE)

#change table to have a condition column

epoch_df_aov<- epoch_df %>%
  gather(Condition, epoch_number, -Group, -ID )

epoch_df_aov$Condition<-as.factor(epoch_df_aov$Condition)

#look for sig differences between the groups
anova<- aov(epoch_number ~ Group + Condition, data = epoch_df_aov)  

summary(anova) #main effect of group

model.tables(anova, type="means", se = TRUE) #look at means and SE

#look for pairwise comparisons
TukeyHSD(anova, which = "Group") #control have a sig higher number of epochs

pairwise.t.test(epoch_df_aov$epoch_number, epoch_df_aov$Group,
                p.adjust.method = "BH")

#look for homogeneity of variance
plot(anova, 1) # identifies point 11 and 57 (both control participant 13) as outlier
                # has unusually high number of epochs (98 in each)
# check normality
plot(anova, 2)

#extract residuals
aov_residuals <- residuals(object = anova)
shapiro.test(x = aov_residuals )

library(car) #companion to applied regression package
#check for homogeneity of variance violations
leveneTest(epoch_number ~ Group * Condition, data = epoch_df_aov)
#p-value is not less than the significance level of 0.05.
#This means that there is no evidence to suggest that the variance 
#across groups is statistically significantly different. Therefore,
#we can assume the homogeneity of variances in the different groups.


#if remove (control participant 13) and re run group difference becomes
#non significant (but not sure I have grounds to do this- as normality and
# homogeneity of var aren't violated)