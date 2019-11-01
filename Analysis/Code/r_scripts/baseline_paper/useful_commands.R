#Useful functions
  # for getting set up/navigating file directories

getwd()        # return your current wd
setwd(dir)     # set your wd (e.g "Users/han.coyle/Documents/PHD-Data-Analysis"
list.files()   # list of all files in that directors
path.expand("~") # tells you what your home directory is
file.choose()  # if you forget where a file is and want to browse for it and then print out
                # full path name 
install.packages("package_name") # install package
detach("package:dlookr", unload=TRUE) #detach package
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

#accessing parts of your df
COMBINED_COG_PhD[,'age'] #access all rows, just age column
COMBINED_COG_PhD[1,] #access just row 1, all column

# quick look at dataset 
glimpse(COMBINED_COG_PhD) #number of observations and variables  
head(COMBINED_COG_PhD) # first few rows
tail(COMBINED_COG_PhD) # last few rows
class(COMBINED_COG_PhD) #what class is your data

ff_glimpse(COMBINED_COG_PhD) #summarises a data frame by numeric (continuous)
                              # variables and factor (discrete) variables.

#operators
 %in% # checks to see if a value is part of the vector we’re 
       #comparing it to
  
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

# calculating descriptive statistics (base R)
mean(x)
sd(x)
var(x)
summary(x) # also helpful because gives you a value for NA's (missing data)

#from library(psych)
skew(x) #measure of asymmetry in your data
kurtosi(x) #measure of "pointedness of your data set"
describe(x) #like summary from base R, use for interval and ratio data
desribeBy(x) #descrip stats seperately for each group

#the by function
by(data= COMBINED_COG_PhD, INDICES = COMBINED_COG_PhD$group, FUN= describe) 
# split by specific variable, have to include, data, indicies and function

#the aggregate function - if you want multiple grouping variables
aggregate( formula = wtar ~ group + sex, # wtar by group and by sex combination
              data = COMBINED_COG_PhD, # data is in the clin.trial data frame
              FUN = mean # print out group means
              )

#standard scores
#SS = (raw score- mean)/sd

#also a handy hint is use of dput for turning outcome of function into an expression you can use in your code snippet- for example
dput(names(COMBINED_COG_PhD[,1:3])) #for variable names as part of df

#create a new variable in df
#df$new.var.name<- (whatever value you want it to be)

mutate() #create new variable
transmutate() #If you only want to keep the new variables

#changing column names in df
names(df)[names(df) == 'old.var.name'] <- 'new.var.name'

#Also good to include a count (n()), or a count of non-missing values (sum(!is.na(x))). 
#That way you can check that you’re not drawing conclusions based on very small amounts of data.

(sum(!is.na(wtar)))

#Can group and ungroup your data
group(group="mtbi")
ungroup(group)


#When using the pipe, the object being passed by the expression on the left side of the pipe
#can be accessed via .
df %>% .$average

#The recode function is a related useful function for dealing with factor names
x <- seq(-5, 5)
recode(sign(x), "1" = "positive", "0" = "zero", "-1" = "nonpositive")

#plotting two graphs next to each other
par(mfrow=c(X,X)) #displays multiple plots on a page 
library(gridExtra)
#create graphs e.g. p<- ....graph  q<- ....graph
grid.arrange(p,q, ncol=2)

# apply a function to each element of a vector
map_dbl(x, mean)

#keyboard shortcuts
#comment a section ( Command + Shift + r)
#insert a section into a script ( Command + Shift + r
#insert a chunk into rmarkdwon (Command + option + i)
# insert the pipe (Command + shift + m )
# insert the assignment operator (option + "+" )
# clear the console (Control + L)
# search all files for a command or word ( Command + Shift + F)
# move cursor to console = Ctrl + 2
# move cursor to command editor = Ctrl + 1
# clear console= Ctrl + L
# run the line in the command window = Command + Enter
# run whole script = Command + Shift + S
# click the **Knit** button to generate a document that includes both content as well as the output 
# of any embedded R code chunks within the document

#remove a variable from the workspace
rm()

#copy and paste data from clipboard into R
tribble_paste()

#pasting a list as a horizontal vector
vector_paste()

#Output to clipboard- useful when making a regrex
df %>%
  head() %>%
  dmdclip()

#creating a factor and assigning levels
group <- as.factor(group)
levels(group) <- c("male", "female")

#formulas = the (outcome) variable, analysed in terms of the pred (predictor) variable".
formula1 <- out ~ pred

# for savings variables to workspace
save.image(file="myfile.Rdata")

# for correlations
cor.test(formula = ~ age + wtar,
         data = COMBINED_COG_PhD) # use formula notation if x and y are in a dataframe

#create a new data set with no NA's
df2<-df1[complete.cases(df1),]