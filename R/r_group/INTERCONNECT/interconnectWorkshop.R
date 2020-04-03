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
url <- c("https://opal1.domain.org", "https://opal1.domain.org")
username <- c("usr1", "usr1")
password <- c("pw1", "pw2")
table <- c("Tutorials.tutorial_advanced", "Tutorials.tutorial_advanced")
logindata <- data.frame(server,url,username,password,table)

# log out

datashield.logout(opals)
  
# log in

opals <- datashield.login(logins=logindata1,assign=TRUE)
  
# what is there?
  
ds.ls()
  
# detail of table
  
ds.summary('D')
  
# 1)	Multiple linear regression (wide format) examining the association between
# smoking in pregnancy and gestational age at birth in singleton pregnancies.
  
# Outcome: gestational age in weeks at birth of child, limited to singleton pregnancies
# Exposure: smoking in pregnancy (yes/no)
# Covariates: mother’s age at birth, maternal education at birth
  
# First step - limit to singleton pregnancies
  
ds.subset(x = 'D', subset = 'D2', logicalOperator = 'plurality==', threshold = 1)
  
# check something happened
  
ds.summary('D2')
  
# fit the model. This is fitting one model to both datasets as if they were pooled together
# Might be a good idea to include a 'study' variable to allow different offset for each study
  
ds.glm(formula = 'D2$ga_bj~D2$preg_smk+D2$agebirth_m_d+D2$edu_m_0', data = 'D2', family = 'gaussian')
  
# alternatively you can fit a model to each study and then meta analyse the results to allow between study variation
  
test_opal1_model = ds.glm(formula = 'D2$ga_bj~D2$preg_smk+D2$agebirth_m_d+D2$edu_m_0', data = 'D2', family = 'gaussian', datasources = opals['test-opal1'])
test_opal2_model = ds.glm(formula = 'D2$ga_bj~D2$preg_smk+D2$agebirth_m_d+D2$edu_m_0', data = 'D2', family = 'gaussian', datasources = opals['test-opal2'])
  
# 2)	Logistic regression (wide format) examining the association between average BMI
# in the first two-years of life and obesity at 7 years.
  
# Outcome: obesity at 7 years (yes/no), defined using the Extended International (IOTF)
# BMI cut-offs corresponding to a BMI of 30 (obese) at 
# 18 years (https://www.worldobesity.org/data/cut-points-used/newchildcutoffs/). 
# Exposure: average BMI in the first two years of life. 
# Covariates: birth weight (in kgs)
  
datashield.logout(opals)
  
opals <- datashield.login(logins=logindata1,assign=TRUE)
  
# First step - derive BMI variables to get average BMI in first 2 years (this could be done in Opal)
# Linearly extrapolate 6 and 12 month values to 24 months for test-opal1
# Linearly extrapolate 3 and 12 month values to 24 months for test-opal2
# Average is midpoint of BMI at birth and 24 months
# This is bespoke per study because the time points are different. We don't have to do linear extrapolation,
# could do something else that used 3 time points?
  
#for test-opal1 data
  
ds.subset(x='D', subset = 'E', cols = c('weight_84', 'height_84', 'weight_12', 'height_12', 'weight_3', 'height_3',
                                          'birth_weight', 'birth_length', 'height_age12', 'height_age3',
                                          'sex'), datasources = opals['test-opal2'])
  
ds.subset(x='E', subset = 'E1', completeCases = TRUE, datasources = opals['test-opal2'])
  
# derive BMIs - should do this in Opal?
  
ds.assign(toAssign = "E1$weight_84/((E1$height_84/100)^2)", newobj = 'BMI_7', datasources = opals['test-opal1'])
ds.summary('BMI_7', datasources = opals['test-opal1'])
ds.assign(toAssign = "E1$weight_12/((E1$height_12/100)^2)", newobj = 'BMI_12', datasources = opals['test-opal1'])
ds.summary('BMI_12', datasources = opals['test-opal1'])
ds.assign(toAssign = "E1$weight_3/((E1$height_3/100)^2)", newobj = 'BMI_3', datasources = opals['test-opal1'])
ds.summary('BMI_3', datasources = opals['test-opal1'])
# BMI at birth is slightly different
ds.assign(toAssign = "(E1$birth_weight/1000)/((E1$birth_length/100)^2)", newobj = 'BMI_0', datasources = opals['test-opal1'])
ds.summary('BMI_0', datasources = opals['test-opal1'])
  
#now extrapolate for BMI at 2 years using BMI at 3 and 12 months
ds.assign(toAssign = "(((BMI_12-BMI_3)/(E1$height_age12-E1$height_age3))*(730-E1$height_age12))+BMI_12", newobj = 'BMI_24', datasources = opals['test-opal1'])
ds.summary('BMI_24', datasources = opals['test-opal1'])
ds.assign(toAssign = "(BMI_24+BMI_0)/2", newobj = 'BMI_ave', datasources = opals['test-opal1'])
ds.summary('BMI_ave', datasources = opals['test-opal1'])
  
# for RUG data
  
ds.subset(x='D', subset = 'E', cols = c('weight_84', 'height_84', 'weight_12', 'height_12', 'weight_6', 'height_6',
                                          'birth_weight', 'birth_length', 'height_age12', 'height_age6',
                                          'sex'), datasources = opals['rug'])
  
ds.subset(x='E', subset = 'E1', completeCases = TRUE, datasources = opals['rug'])
  
  
# derive BMIs - should do this in Opal?
  
ds.assign(toAssign = "E1$weight_84/((E1$height_84/100)^2)", newobj = 'BMI_7', datasources = opals['rug'])
ds.summary('BMI_7', datasources = opals['rug'])
ds.assign(toAssign = "E1$weight_12/((E1$height_12/100)^2)", newobj = 'BMI_12', datasources = opals['rug'])
ds.summary('BMI_12', datasources = opals['rug'])
ds.assign(toAssign = "E1$weight_6/((E1$height_6/100)^2)", newobj = 'BMI_6', datasources = opals['rug'])
ds.summary('BMI_6', datasources = opals['rug'])
# BMI at birth is slightly different
ds.assign(toAssign = "(E1$birth_weight/1000)/((E1$birth_length/100)^2)", newobj = 'BMI_0', datasources = opals['rug'])
ds.summary('BMI_0', datasources = opals['rug'])
  
# now extrapolate for BMI at 2 years using BMI at 6 and 12 months
ds.assign(toAssign = "(((BMI_12-BMI_6)/(E1$height_age12-E1$height_age6))*(730-E1$height_age12))+BMI_12", newobj = 'BMI_24', datasources = opals['rug'])
ds.summary('BMI_24', datasources = opals['rug'])
ds.assign(toAssign = "(BMI_24+BMI_0)/2", newobj = 'BMI_ave', datasources = opals['rug'])
ds.summary('BMI_ave', datasources = opals['rug'])
  
# finalise data set to include newly calculated BMI_ave and BMI_7
  
ds.cbind(x=c('E1', 'BMI_ave', 'BMI_7'), newobj = 'D2', datasources = opals)
  
  
# Second step - derive outcome variable (this could be done in Opal,
# or with some new DataSHIELD functions that would allow conditional assignment of an indicator variable)
# This is with criterion of 30 BMI aged 18
  
ds.asNumeric("D2$sex", newobj = "sexNumeric")
ds.assign(toAssign = "BMI_7 + ((sexNumeric-1)*0.2)", newobj = 'BMI_7_adj', datasources = opals)
ds.cbind(x=c('D2', 'BMI_7_adj'), newobj = 'D3')
ds.subset(x='D3', subset = 'D4a', logicalOperator = 'BMI_7_adj>=', threshold = 20.59)
ds.subset(x='D4a', subset = 'D5a', cols = c('birth_weight', 'BMI_ave'))
ds.subset(x='D5a', subset = 'D5a2', completeCases = TRUE)
ds.assign(toAssign = 'D5a2$birth_weight/D5a2$birth_weight', newobj = 'indicator')
ds.cbind(x=c('D5a2', 'indicator'), newobj = 'D6a')
ds.subset(x='D3', subset = 'D4b', logicalOperator = 'BMI_7_adj<', threshold = 20.59)
ds.subset(x='D4b', subset = 'D5b', cols = c('birth_weight', 'BMI_ave'))
ds.subset(x='D5b', subset = 'D5b2', completeCases = TRUE)
ds.assign(toAssign = 'D5b2$birth_weight-D5b2$birth_weight', newobj = 'indicator')
ds.cbind(x=c('D5b2', 'indicator'), newobj = 'D6b')
ds.c(x = c('D6a$birth_weight', 'D6b$birth_weight'), newobj = 'birth_weight')
ds.c(x = c('D6a$BMI_ave', 'D6b$BMI_ave'), newobj = 'BMI_ave')
ds.c(x = c('D6a$indicator', 'D6b$indicator'), newobj = 'indicator')
ds.asFactor(x='indicator', newobj = 'ind_fact')
  
ds.cbind(x=c('birth_weight', 'BMI_ave', 'ind_fact'), newobj = 'D7')
ds.dataframe(x=c('birth_weight', 'BMI_ave', 'ind_fact'), newobj = 'D7')
  
ds.glm(formula = 'D7$ind_fact ~ D7$birth_weight + D7$BMI_ave', data = 'D7', family = 'binomial', maxit = 100)
  
# same thing but with criterion BMI of 25 aged 18
  
ds.asNumeric("D2$sex", newobj = "sexNumeric")
ds.assign(toAssign = "BMI_7 + ((sexNumeric-1)*0.19)", newobj = 'BMI_7_adj', datasources = opals)
ds.cbind(x=c('D2', 'BMI_7_adj'), newobj = 'D3')
ds.subset(x='D3', subset = 'D4a', logicalOperator = 'BMI_7_adj>=', threshold = 17.88)
ds.subset(x='D4a', subset = 'D5a', cols = c('birth_weight', 'BMI_ave'))
ds.subset(x='D5a', subset = 'D5a2', completeCases = TRUE)
ds.assign(toAssign = 'D5a2$birth_weight/D5a2$birth_weight', newobj = 'indicator')
ds.cbind(x=c('D5a2', 'indicator'), newobj = 'D6a')
ds.subset(x='D3', subset = 'D4b', logicalOperator = 'BMI_7_adj<', threshold = 17.88)
ds.subset(x='D4b', subset = 'D5b', cols = c('birth_weight', 'BMI_ave'))
ds.subset(x='D5b', subset = 'D5b2', completeCases = TRUE)
ds.assign(toAssign = 'D5b2$birth_weight-D5b2$birth_weight', newobj = 'indicator')
ds.cbind(x=c('D5b2', 'indicator'), newobj = 'D6b')
ds.c(x = c('D6a$birth_weight', 'D6b$birth_weight'), newobj = 'birth_weight')
ds.c(x = c('D6a$BMI_ave', 'D6b$BMI_ave'), newobj = 'BMI_ave')
ds.c(x = c('D6a$indicator', 'D6b$indicator'), newobj = 'indicator')
ds.asFactor(x='indicator', newobj = 'ind_fact')
  
ds.cbind(x=c('birth_weight', 'BMI_ave', 'ind_fact'), newobj = 'D7')
ds.dataframe(x=c('birth_weight', 'BMI_ave', 'ind_fact'), newobj = 'D7')
  
# pooled analysis. Again, this could be split and a meta- analysis done
  
ds.glm(formula = 'D7$ind_fact ~ D7$birth_weight + D7$BMI_ave', data = 'D7', family = 'binomial', maxit = 100)
  
# illustration of alternative approach doing the work in Opal instead.
# Note this is for RUG only since no access to test-opal1 server
  
server <- c("test-opal1")
url <- c("https://test-opal1.gcc.rug.nl")
username <- "lifecycle"
password <- "?LifeCycle!"
table <- c("Tutorials.tutorial_novice1")
logindata2 <- data.frame(server,url,username,password,table)
    
datashield.logout(opals)
  
opals <- datashield.login(logins=logindata2,assign=TRUE)
  
ds.subset(x='D', subset = 'D2', completeCases = TRUE)
  
# using 25 BMI aged 18
  
ds.glm(formula = 'D2$ind_25 ~ D2$birth_weight + D2$BMI_ave', data = 'D2', family = 'binomial', maxit = 100)
  
# using 30 BMI aged 18
  
ds.glm(formula = 'D2$ind_30 ~ D2$birth_weight + D2$BMI_ave', data = 'D2', family = 'binomial', maxit = 100)
  
# 3)	Multi-level linear regression (long format) examining 
# the association between breastfeeding and BMI between the ages of 6 and 12 years.
# Outcome: BMI of the child between the ages of 6 and 12 years (multiple outcomes) 
# (for the purpose of this practical experiment these won’t be age-standardised).
# Exposure: total duration of any breastfeeding
# Covariates: maternal education at birth, birth weight, sex
# Aim: to explore whether it is possible to analyse data in long format in DataSHIELD 
# and/or develop new methods for this purpose. Determine whether it is possible to reshape data in DataSHIELD.
  
# This analysis seems to require linear mixed models. 
# This is not currently available (I think), but could be developed (I think!)
# It would be possible to do stratified analyses, of course