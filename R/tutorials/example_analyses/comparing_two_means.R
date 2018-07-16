# Load the necessary libraries

# General R-packages
library(metafor)

# Specific DataSHIELD packages
library(opal)
library(dsBaseClient)
library(dsStatsClient)
library(dsGraphicsClient)
library(dsModellingClient)

# Setup servers
server <- c("test-opal1", "test-opal2")
url <- c("https://opal1.domain.org", "https://opal2.domain.org")
username <- c("usr1", "usr2")
password <- c("pwd1", "pwd2")
table <- c("Tutorials.tutorial_novice", "Tutorials.tutorial_novice")
logindata <- data.frame(server,url,username,password,table)

#hello

# log out

datashield.logout(opals)

# log in

opals <- datashield.login(logins=logindata1,assign=TRUE)

# what is there?

ds.ls()

# detail of table

ds.summary('D')

#describe the studies:
ds.dim(x='D')
#the "combine" comand allows us to identify the total number of observations and variables pooled across 
#all studies:
ds.dim('D', type='combine')


# Comparing two means: is gestational age affected by smoking in pregnancy?

# First step - limit to singleton pregnancies and live births

ds.subset(x = 'D', subset = 'D2', logicalOperator = 'plurality==', threshold = 1)
ds.subset(x = 'D2', subset = 'D3', logicalOperator = 'outcome==', threshold = 1)


# check something happened

ds.table1D('D3$plurality')
ds.table1D('D3$outcome')


#Examine whether there is evidence that gestational age 
#is affected by smoking in pregnancy:
ds.meanByClass(x='D3$ga_bj~D4$preg_smk')

#"preg_smk" needs to be a factor variable for this function to work;
#"preg_smk" is currently not a factor variable
#we can check the class (i.e. integer, character, factor etc.) 
#of by using the "ds.class" function:

ds.class(x='D3$preg_smk')
#we can us the "ds.asFactor" function to create a new pregnancy smoking variable
#which is a factor variable:
ds.asFactor(x='D3$preg_smk', newobj = 'preg_smk_fact', datasources = opals)
#This new variable/vector is not attached to a data frame. 
#We can bind it to a data frame using the "cbind" function.
#To do this, the dataframe and the variable we want to attach must be the same length
#We can check their lengths using the command "ds.length"
ds.length (x='preg_smk_fact')
ds.cbind(x=c('D3', 'preg_smk_fact'), newobj = 'D4', datasources = opals)


mean_by_class = ds.meanByClass(x='D4$ga_bj~D4$preg_smk_fact')
mean_by_class

#computation of the standard error of the mean among non-exposed:
sem0 = as.numeric(gsub(".*\\((.*)\\).*", "\\1", mean_by_class[2,1]))/ sqrt(as.numeric(mean_by_class[1,1]))

#95% confidence intervals of the mean
CI_95_0 =  c(as.numeric(sub(" *\\(.*", "", mean_by_class[2,1])) - 2*sem0, as.numeric(sub(" *\\(.*", "", mean_by_class[2,1])) + 2*sem0)

#computation of the standard error of the mean among exposed:
sem1 = as.numeric(gsub(".*\\((.*)\\).*", "\\1", mean_by_class[2,2]))/ sqrt(as.numeric(mean_by_class[1,2]))

#95% confidence intervals of the mean
CI_95_1 =  c(as.numeric(sub(" *\\(.*", "", mean_by_class[2,2])) - 2*sem1, as.numeric(sub(" *\\(.*", "", mean_by_class[2,2])) + 2*sem1)

CI_95_0
CI_95_1


