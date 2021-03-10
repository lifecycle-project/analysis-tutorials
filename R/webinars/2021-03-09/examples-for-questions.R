################################################################################
## Project: lifecycle-tutorials
## Script purpose: Webinar
## Date: 09 March 21
## Author: Tim Cadman
## Email: t.cadman@bristol.ac.uk
################################################################################

################################################################################
# 1. Log in to servers  
################################################################################

builder <- DSI::newDSLoginBuilder()

## ---- RAINE ------------------------------------------------------------------
builder$append(
  server = "raine",
  url = "https://opal.gohad.uwa.edu.au",
  user ="xxxx", 
  password ="xxxx", 
  table = "lc_raine_core_2_1.2_1_core_1_0_non_rep",
  driver = "OpalDriver"
)


## ---- CHOP -------------------------------------------------------------------
builder$append(
  server = "chop",
  url = "https://lifecycle-project.med.uni-muenchen.de",
  user ="xxxx", 
  password ="xxxx", 
  table = "lc_chop_core_2_1.2_1_core_non_rep_bmi_earlylife_poc",
  driver = "OpalDriver"
)

logindata <- builder$build()

conns <- DSI::datashield.login(logins = logindata, assign = FALSE)

ds.ls()

################################################################################
# 2. Assign variables  
################################################################################
nonrep.vars <- c("child_id", "sex", "preg_smk", "parity_m", "weight_who_ga")
yearrep.vars <- c("child_id", "edu_m_", "occup_m_")

datashield.assign(
  conns = conns["raine"], 
  symbol = "nonrep", 
  value = "lc_raine_core_2_1.2_1_core_1_0_non_rep", 
  variables = nonrep.vars)

datashield.assign(
  conns = conns["raine"], 
  symbol = "yearrep", 
  value = "lc_raine_core_2_1.2_1_core_1_0_yearly_rep", 
  variables = yearrep.vars)

datashield.assign(
  conns = conns["chop"], 
  symbol = "nonrep", 
  value = "lc_chop_core_2_1.2_1_core_non_rep_bmi_earlylife_poc", 
  variables = nonrep.vars)

datashield.assign(
  conns = conns["chop"], 
  symbol = "yearrep", 
  value = "lc_chop_core_2_1.2_1_core_yearly_rep_bmi_earlylife_poc", 
  variables = yearrep.vars)

## Note we have created two dataframes here, corresponding to yearly repeated
## measures and non repeated measures

ds.ls()
ds.summary("nonrep")
ds.summary("yearrep")

################################################################################
# Question 1: Subset so only parity == 1  
################################################################################
ds.dataFrameSubset(
  df.name = "nonrep", 
  V1.name = "nonrep$parity_m",
  V2.name = "1",
  Boolean.operator = "==",
  keep.NAs = FALSE,
  newobj = "nonrep_sub")

ds.dim("nonrep")
ds.dim("nonrep_sub")

################################################################################
# Question 2/3/4: Missing variables
################################################################################

# In this example weight_who_ga is missing in CHOP

## ---- Try to do summary of variable ------------------------------------------
ds.summary("nonrep_sub")
ds.summary("nonrep_sub$weight_who_ga")

# Summary fails because variable doesn't exist in CHOP.

# We use ds.dataFrameFill to create a variable with all missing in CHOP

ds.dataFrameFill("nonrep_sub", "nonrep_sub")

## ---- Check now --------------------------------------------------------------
ds.summary("nonrep_sub$weight_who_ga")

# Not sure if I've answered this?

## ---- Missing values example in correlations ---------------------------------

# Different ways of treating missing values in correlations. Note categorical
# variables so probably not the best example
ds.cor(
  x = "nonrep$parity", 
  y = "nonrep$sex", 
  naAction = "pairwise.complete"
)

ds.cor(
  x = "nonrep$parity", 
  y = "nonrep$sex", 
  naAction = "casewise.complete"
)

## ---- Impute missing values by the mean --------------------------------------
ds.numNA(
  x = "nonrep$parity_m"
)

ds.replaceNA(
  x = "nonrep$parity_m", 
  forNA = c(1, 1), 
  newobj = "parity_impute",
  datasources = conns
)

ds.numNA(
  x = "parity_impute"
)

ds.summary("nonrep$parity_m")
ds.summary("parity_impute")

################################################################################
# Question 5: Recode    
################################################################################
ds.summary("nonrep_sub$weight_who_ga", datasources = conns["raine"])

ds.asNumeric(x.name = "nonrep_sub$weight_who_ga", newobj = "weight_num")

ds.recodeValues(
  var.name = "weight_num", 
  values2replace.vector = c(1, 2, 3),
  new.values.vector = c(0, 1, 0),
  newobj = "weight_who_ga_d", 
  datasources = conns["raine"]
)

ds.table("weight_num", "weight_who_ga_d", datasources = conns["raine"])

ds.asFactor(input.var.name = "weight_who_ga_d", newobj.name = "weight_fact", datasources = conns["raine"])

ds.class("weight_fact", datasources = conns["raine"])

################################################################################
# Question 6: glm vs glmSLMA  
################################################################################

# glm virtual pools the data and does a regression on everything at once.

# glm.SLMA performs regression separately on each cohort then meta-analyses
# the coefficients


################################################################################
# More info:  
################################################################################

# Here is a longer script doing lots of data manipulation and analysis for a 
# paper that I'm working on

https://github.com/lifecycle-project/wp4-bmi-poc/blob/master/getvars.R
https://github.com/lifecycle-project/wp4-bmi-poc/blob/master/analysis.R




