################################################################################
## Project: bmi-poc
## Script purpose: Condcut analysis
## Date: 29th April 2020
## Author: Tim Cadman
## Email: t.cadman@bristol.ac.uk
################################################################################


## Check out dataframe fill

library(opal)
library(dsBaseClient)
library(stringr)
library(dplyr)
library(magrittr)


# The purpose of this script is to get descriptive statistics and run models
# serverside, and store the output in clientside R objects. 

## Call the function I wrote to get the stats in a useful form
source("ds-common-getstats.R")

################################################################################
# 1. Descriptives  
################################################################################


## ---- Extract data -----------------------------------------------------------

# Now we extract descriptives using the function "getStats" which I wrote.

descriptives_ss <- getStats(
  varlist = c(exp.vars, out.vars, cov.vars, other.vars),
  df = "analysis_df"
)


################################################################################
# 2. IPD meta-analysis  
################################################################################

# To date I haven't been able to get this to work - will come back to it


#test <- ds.glm(
#  formula = "bmi.96 ~ edu_m_.0 + sex + coh_dummy",
#  data = "bmi_poc", 
#  family = "gaussian",
#  checks = TRUE,
#  datasources = opals_genr
#)


################################################################################
# 3. Two-stage meta-analysis  
################################################################################

## ---- Define function --------------------------------------------------------

# This is another wrapper function to neaten up the code.

regWrap <- function(x){
  ds.glmSLMA(
    formula = x[["model"]],
    data = "analysis_df", 
    family = "gaussian",
    datasources = opals[x[["cohorts"]]])
}

ds.summary("analysis_df$greenyn300")
ds.class("analysis_df$greenyn300")

# Now we apply this function to each exposure

################################################################################
# 4. Maternal education  
################################################################################

## ---- Check available data ---------------------------------------------------
descriptives_ss[[2]] %>%
  filter(variable == "age_months.24" | variable == "age_months.48" | 
         variable == "age_months.96")

## NOTE THAT MOBA DOES HAVE DATA AT AGE 48; HOWEVER THE SD OF THE AGE VARIABLE
## IS ZERO WHICH IS STOPPING THE MODEL FROM RUNNING

out_avail <- list(
  bmi.24 <- c("genr", "ninfea", "raine"), 
  bmi.48 <- c("genr", "ninfea"),
  bmi.96 <- c("genr", "ninfea", "raine", "moba"),
  bmi.168 <- c("genr", "ninfea", "raine")
)

## ---- Define models ----------------------------------------------------------

# First we make a list of model definitions for each outome
mat_ed.mod <- list(
  bmi_0_24 = list(
    model = "bmi.24 ~ edu_m + sex + age_months.24",
    cohorts = out_avail[[1]]),
  bmi_25_48 = list(
    model = "bmi.48 ~ edu_m + sex + age_months.48",
    cohorts = out_avail[[2]]),
  bmi_49_96 = list(
    model = "bmi.96 ~ edu_m + sex + age_months.96",
    cohorts = out_avail[[3]]),
  bmi_97_168 = list(
    model = "bmi.168 ~ edu_m + sex + age_months.168",
    cohorts = out_avail[[4]])
)

## ---- Analysis ---------------------------------------------------------------

# Now apply the wrapper function storing the models in a list
mat_ed.fit <- lapply(mat_ed.mod, regWrap)

# Multiple issues
#
# 1. "Warning namespace ‘dsBase’ is not available and has been replaced
#    by .GlobalEnv when processing object ‘genr.logdata’"
#
# 2. "Error in betamatrix[, k] <- study.summary[[k]]$coefficients[, 1] : 
#    number of items to replace is not a multiple of replacement length".
#    I think this is caused by variance of age_months.48 = 0 for moba


################################################################################
# 5. Gestational age at birth  
################################################################################

## ---- Define models ----------------------------------------------------------

## Note not yet adjusted for ethnicity as no data for NINFEA
## preg_dia and preg_ht also not included because insufficient info in RAINE
## creating disclosure risk

ga.mod <- list(
  bmi_0_24 = list(
    model = "bmi.24 ~ ga_all + edu_m + prepreg_bmi + preg_smk + agebirth_m_y + 
             parity_bin + sex + age_months.24",
    cohorts = out_avail[[1]]),
  bmi_25_48 = list(
    model = "bmi.48 ~ ga_all + edu_m + prepreg_bmi + preg_smk + agebirth_m_y + 
             parity_bin + sex + age_months.48",
    cohorts = out_avail[[2]]),
  bmi_49_96 = list(
    model = "bmi.96 ~ ga_all + edu_m + prepreg_bmi + preg_smk + agebirth_m_y + 
             parity_bin + sex + age_months.96",
    cohorts = out_avail[[3]]),
  bmi_97_168 = list(
    model = "bmi.168 ~ ga_all + edu_m + prepreg_bmi + preg_smk + agebirth_m_y + 
             parity_bin + sex + age_months.168",
    cohorts = out_avail[[4]])
)


## ---- Analysis ---------------------------------------------------------------
ga.fit <- lapply(ga.mod, regWrap)


################################################################################
# 6. Diabetes in pregnancy  
################################################################################

## Note preg_dia exluded because of insufficient information in RAINE

## ---- Define models ----------------------------------------------------------
gest_dia.mod <- list(
  bmi_0_24 = list(
    model = "bmi.24 ~ edu_m + agebirth_m_y + prepreg_bmi +     
             parity_bin + preg_smk + age_months.24",
    cohorts = out_avail[[1]]),
  bmi_25_48 = list(
    model = "bmi.48 ~ edu_m + agebirth_m_y + prepreg_bmi +     
             parity_bin + preg_smk + age_months.48",
    cohorts = out_avail[[2]]),
  bmi_49_96 = list(
    model = "bmi.96 ~ edu_m + agebirth_m_y + prepreg_bmi +     
             parity_bin + preg_smk + age_months.96",
    cohorts = out_avail[[3]]),
  bmi_97_168 = list(
    model = "bmi.168 ~ edu_m + agebirth_m_y + prepreg_bmi +     
             parity_bin + preg_smk + age_months.168",
    cohorts = out_avail[[4]])
)


## ---- Analysis ---------------------------------------------------------------
gest_dia.fit <- lapply(gest_dia.mod, regWrap)





