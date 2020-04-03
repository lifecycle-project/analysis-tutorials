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

# 1)	Multiple linear regression (wide format) examining the association between
# smoking in pregnancy and gestational age at birth in singleton pregnancies.

# Outcome: gestational age in weeks at birth of child, limited to singleton pregnancies and live births
# Exposure: smoking in pregnancy (yes/no)
# Covariates: mother's age at birth, maternal education at birth


# First step - limit to singleton pregnancies and live births

ds.subset(x = 'D', subset = 'D2', logicalOperator = 'plurality==', threshold = 1)
ds.subset(x = 'D2', subset = 'D3', logicalOperator = 'outcome==', threshold = 1)


# check something happened

ds.table1D('D3$plurality')
ds.table1D('D3$outcome')

# create a cohort variable
ds.assign(toAssign = "(D3$cohort_id/D3$cohort_id)", newobj = 'cohort', datasources = opals['test-opal1'])
ds.assign(toAssign = "((D3$cohort_id/D3$cohort_id)+1)", newobj = 'cohort', datasources = opals['test-opal2'])

ds.cbind(x=c('D3', 'cohort'), newobj = 'D4', datasources = opals)

#tabulate the new variable separately for each cohort:
ds.table1D(x='D4$cohort', type='split')

#check the distribution of the outcome variable is approximately normal:
ds.histogram(x='D4$ga_bj') 

#Examine whether there is evidence that hgestational age 
#is affected by smoking in pregnancy:
ds.meanByClass(x='D4$ga_bj~D4$preg_smk')

#"preg_smk" needs to be a factor variable for this function to work;
#"preg_smk" is currently not a factor variable
#we can check the class (i.e. integer, character, factor etc.) 
#of by using the "ds.class" function:

ds.class(x='D4$preg_smk')
#we can us the "ds.asFactor" function to create a new pregnancy smoking variable
#which is a factor variable:
ds.asFactor(x='D4$preg_smk', newobj = 'preg_smk_fact', datasources = opals)
#This new variable/vector is not attached to a data frame (default name D ). 
#We can bind it to a data frame using the "cbind" function.
#To do this, the dataframe and the variable we want to attach must be the same length
#We can check their lengths using the command "ds.length"
ds.length (x='preg_smk_fact')
ds.cbind(x=c('D4', 'preg_smk_fact'), newobj = 'D5', datasources = opals)


mean_by_class = ds.meanByClass(x='D5$ga_bj~D5$preg_smk_fact')
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


#Contour plots or heat map plots are used in place of scatter plots 
#(which cannot be used as they are potentially disclosive)
# in DataSHIELD to visualize correlation patterns 
#For e.g.:
ds.contourPlot(x='D4$ga_bj', y='D4$agebirth_m_d')
ds.heatmapPlot(x='D4$ga_bj', y='D4$agebirth_m_d')

#mean centre maternal age:
mean_cen = ds.mean(x='D4$agebirth_m_d')
my_str = paste0('D4$agebirth_m_d-', mean_cen)
ds.assign(toAssign=my_str, newobj='agebirth_m_d_c')
ds.histogram('agebirth_m_d_c')
ds.cbind(x=c('D4', 'agebirth_m_d_c'), newobj = 'D6', datasources = opals)

# fit the model. This is fitting one model to both datasets as if they were pooled together
ds.glm(formula = 'D6$ga_bj~D6$preg_smk+D6$agebirth_m_d_c+D6$edu_m_0+D6$cohort', data = 'D6', family = 'gaussian')

#the help function gives you an explanation of the commands:
help(ds.glm)


# alternatively you can fit a model to each cohort and then meta analyse the results to allow between cohort variation
st1 = ds.glm(formula = 'D6$ga_bj~D6$preg_smk+D6$agebirth_m_d_c+D6$edu_m_0', data = 'D6', family = 'gaussian', datasources = opals['test-opal1'])
st2 = ds.glm(formula = 'D6$ga_bj~D6$preg_smk+D6$agebirth_m_d_c+D6$edu_m_0', data = 'D6', family = 'gaussian', datasources = opals['test-opal2'])

#yi is a vector with the effect size estimates (B coeffecients)
#sei is a vector with the individual cohort standard errors
yi <- c(st1$coefficients["preg_smk","Estimate"], st2$coefficients["preg_smk","Estimate"])
sei <- c(st1$coefficients["preg_smk","Std. Error"], st2$coefficients["preg_smk","Std. Error"])
#Random effects model:
res <- rma(yi, sei=sei)
res
forest(res)
