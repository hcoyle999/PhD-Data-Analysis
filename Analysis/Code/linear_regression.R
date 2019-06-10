#correlations ( just playing around)
COMBINED_COG_PhD %>%
  corr.test(formula = ~ age + wtar) # won't work in pipe....?

cor.test(formula = ~ age + wtar,
         data = COMBINED_COG_PhD) # will work


cor.test(~ age + wtar,
         COMBINED_COG_PhD,
         subset = group == "control") # can subset based on the data
#https://bookdown.org/ndphillips/YaRrr/correlation-cor-test.html



#Information/tutorial comes from https://ourcodingclub.github.io/2017/03/15/mixed-models.html

# with linear regression it is good practice to standardise your explanatory variables before proceeding so they have a mean of 0 and a standard deviation of 1
COMBINED_COG_PhD$age2 <- scale(COMBINED_COG_PhD$age)
COMBINED_COG_PhD$Coding_BL2 <- scale(COMBINED_COG_PhD$Coding_BL)

#only need to transform explanatory variables (so delete this column from df)
COMBINED_COG_PhD$Coding_BL2 <- NULL
# question is processing speed affected by age?

# fit the model with processing speed as the response and age as the predictor
basic.lm <- lm(Coding_BL ~ age, data= COMBINED_COG_PhD)
summary(basic.lm)
# create df and remove labels otherwise can't plot with ggplot (also remove class!!!!) - and snaps for getting the pipe to work.

library(labelled)
lm_df<- COMBINED_COG_PhD  %>% 
  remove_labels() %>%
  select(group, age, Coding_BL) %>%
  data.frame()

lm_df$age2 <- scale(lm_df$age)

#plot the data with ggplot2
(prelim_plot <- ggplot(lm_df, aes(x = age, y = Coding_BL)) +
    geom_point() +
    geom_smooth(method = "lm")) #possibly the older you are the slower you are?

#plot the residuals
plot(basic.lm, which = 1)  #red line should be nearly flat like the dotted grey line
#plot qq plot
plot(basic.lm, which = 2) #points should ideally fall onto the diagonal dashed line
#look at processing speed between  two groups
boxplot(Coding_BL ~ group, data = lm_df)
#plot it and colour points by group
(colourplot<-ggplot(lm_df, aes(x = age, y = Coding_BL, colour = group)) +
    geom_point(size=2) +
    xlab("Age")+
    ylab("Processing Speed")+
    theme_classic()+
    theme(legend.position = "none") +
    theme(plot.title = element_text(hjust = 0.5))+
    ggtitle("Relationship between Age and Processing Speed")
)
#look at data split by group
(split_plot <- ggplot(aes(age, Coding_BL), data = lm_df) + 
    geom_point() + 
    facet_wrap(~ group) + 
    xlab("Age") + 
    ylab("Processing Speed"))

# dont want run two seperate anaylses- want to use all the data but account for data from different groups

#add group as a fixed effect to our basic linear model to estimate differences in processing speed between the groups
group.lm <- lm(age ~ Coding_BL + group, data = lm_df)
summary(group.lm)

#however that is not what I am interested in, want to control for the variation coming from group

#want to know whether there is an association between age and processign speed, AND we want to know if that association exists after controlling for the variation in group

mixed.lmer <- lmer(Coding_BL ~ age2 + (1|group), data = lm_df)
summary(mixed.lmer)
plot(mixed.lmer)

qqnorm(resid(mixed.lmer))
qqline(resid(mixed.lmer))


