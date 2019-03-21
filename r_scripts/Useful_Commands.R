#Useful functions
  # for getting set up/navigating file directories

getwd()        # return your current wd
setwd(dir)     # set your wd (e.g "Users/han.coyle/Documents/PHD-Data-Analysis"
list.files()   # list of all files in that directors
path.expand("~") # tells you what your home directory is
file.choose()  # if you forget where a file is and want to browse for it and then print out
                # full path name 

  # for looking at raw data
length(object) # number of elements or components
str(object)    # structure of an object 
class(object)  # class or type of an object
names(object)  # names

c(object,object,...)       # combine objects into a vector
cbind(object, object, ...) # combine objects as columns
rbind(object, object, ...) # combine objects as rows 

object     # prints the object

ls()       # list current objects
rm(object) # delete an object

newobject <- edit(object) # edit copy and save as newobject 
fix(object)               # edit in place


# list objects in the working environment
ls()

# prints to console summary of all variables in workspace
library(lsr)
who()

# list the variables in mydata
names(mydata)

# list the structure of mydata
str(mydata)

# list levels of factor v1 in mydata
levels(mydata$v1)

# dimensions of an object
dim(object)

# class of an object (numeric, matrix, data frame, etc)
class(object)

# print mydata 
mydata

# print first 10 rows of mydata
head(mydata, n=10)

# print last 5 rows of mydata
tail(mydata, n=5)

control_df %>% 
  select(code, coding_bl) %>%
  arrange(coding_bl)

COMBINED_COG_PhD$hads_depression_bl %>%
group_by() %>%
  summarize (count=n())

#also a handy hint is use of dput for turning outcome of function into an expression you can use in your code snippet- for example
dput(names(COMBINED_COG_PhD[,1:3])) #for variable names as part of df

#changing column names in df
names(df)[names(df) == 'old.var.name'] <- 'new.var.name'
