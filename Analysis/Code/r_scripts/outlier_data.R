
##--- Identify outliers 

outlierKD <- function(dt, var) {
  var_name <- eval(substitute(var),eval(dt))
  tot <- sum(!is.na(var_name))
  na1 <- sum(is.na(var_name))
  m1 <- mean(var_name, na.rm = T)
  name<- substitute(var)
  par(mfrow=c(2, 2), oma=c(0,0,3,0))
  boxplot(var_name, main=(paste("With outliers_",name)))
  hist(var_name, main=(paste("With outliers_",name)), xlab=NA, ylab=NA)
  outlier <- boxplot.stats(var_name)$out
  mo <- mean(outlier)
  var_name <- ifelse(var_name %in% outlier, NA, var_name)
  boxplot(var_name, main=(paste("Without outliers_",name)))
  hist(var_name, main=(paste("Without outliers_",name)), xlab=NA, ylab=NA)
  na2 <- sum(is.na(var_name))
  message("Outliers identified: ", na2 - na1, " from ", tot, " observations")
  message("Proportion (%) of outliers: ", (na2 - na1) / tot*100)
  message("Mean of the outliers: ", mo)
  m2 <- mean(var_name, na.rm = T)
  message("Mean without removing outliers: ", m1)
  message("Mean if we remove outliers: ", m2)
  response <- readline(prompt="Do you want to remove outliers and to replace with NA? [yes/no]: ")
  if(response == "y" | response == "yes"){
    dt[as.character(substitute(var))] <- invisible(var_name)
    assign(as.character(as.list(match.call())$dt), dt, envir = .GlobalEnv)
    message("Outliers successfully removed", "\n")
    return(invisible(dt))
    text(paste("Outlier Check_",name), pos=1)
  } else{
    message("Nothing changed", "\n")
    text(paste("Outlier Check_",name),pos=1)
    return(invisible(var_name))
  }
}
  
#can do manually for each varaiable
outlierKD(cog_data_bl, tma_bl)

var_names<-dput(names(cog_data_BL))  ## all the variables that outliers need to be checked for
#"tma_bl", "tmb_bl", "ravlt_t1_bl", "ravl_t2_bl", 
#"ravlt_t3_bl", "ravlt_t4_bl", "ravlt_t5_bl", "ravlt_t_bl", "ravlt_a6a5_bl", 
#"ravlt_d_bl", "bvmt_t1_bl", "bvmt_t2_bl", "bvmt_t3_bl", "totalbvmt_bl", 
#"ds_fwd_bl", "ds_bwd_bl", "ds_total_bl", "lns_bl", "coding_bl", 
#"symbolsearch_bl", "ravlt_recognition", "arithmetic_bl", "cowat_bl", 
#"bvmt_delay_recall", "bvmt_recognition"

#or can apply shorter function to whole data frame

# function based on the 1.5X IQR rule
replace_outliers <- function(column) {
  qnt <- quantile(column, probs=c(.25, .75),na.rm=TRUE) #how much of the data is lowest 25% quantile
                                                        # how much of the data in top 75% quantile
  upper_whisker <- 1.5 * IQR(column,na.rm=TRUE) # 1.5 * IQR (diff between 25th and 75th percentiles)
  clean_data <- column
  clean_data[column > (qnt[2] + upper_whisker)] <- median(column, na.rm=TRUE) #if data is above upper whisker
                                                                              #replace with median value
  clean_data[column < (qnt[1] - upper_whisker)] <- median(column, na.rm=TRUE) #if data is below lower whisker                                                                           # replace with median value
                                                                              # replace with median value
  clean_data
}

# apply to whole data frame 
cog_data_outlier_removed <- cog_data_bl %>% 
  group_by(group) %>% 
  mutate_if(is.numeric, replace_outliers) %>%
  ungroup()





