################################################################################
## Project: bmi-poc
## Script purpose: Login details for opal servers
## Date: 7th May 2020
## Author: Tim Cadman
## Email: t.cadman@bristol.ac.uk
################################################################################    

# This is the first of three scripts, which manages logging into the servers.
#
# Here the username and passwords have been blanked out. If you are using git 
# and this is a shared project it is helpful to keep this in a separate file as 
# it can be added to .gitignore and thus not uploaded to the repository.

library(opal)
library(dsBaseClient)

################################################################################
# 1. Define separately for each cohort 
################################################################################

# To make it easier to add login data for new cohorts, first we create separate
# data frames of the login details for each cohort.

## ---- GEN-R -------------------------------------------------------------------
genr.logdata <- data.frame(
  server = "genr",
  url = "https://opal.erasmusmc.nl",
  user="xxxx", 
  password ="xxxx", 
  table = "lifecycle_1_0.1_0_genr_1_0_non_repeated"
)

## ---- NINFEA -----------------------------------------------------------------
ninfea.logdata <- data.frame(
  server = "ninfea",
  url = "https://www.lifecycle-ninfea.unito.it",
  user ="cadman", 
  password ="xxxx", 
  table = "xxxx"
)

## ---- MOBA -------------------------------------------------------------------
moba.logdata <- data.frame(
  server = "moba",
  url = "https://moba.nhn.no",
  user ="xxxx", 
  password ="xxxx", 
  table = "lc_moba_core_2_0.2_0_core_non_rep_bmi_poc_study"
)


################################################################################
# 2. Combine into one dataframe  
################################################################################

# Now we can use 'rbind' to combine into one dataframe. 
logindata <- rbind(genr.logdata, ninfea.logdata, moba.logdata)


################################################################################
# 3. Login using this dataframe  
################################################################################

# We then use this combined dataframe to log in. Note that you need to specify 
# one opal table at login, but you can't specify all the tables you need - you 
# have to assign these later

opals <- datashield.login(
  logins = logindata, 
  assign = FALSE
)