################################################################################
## Project: bmi-poc
## Script purpose: Condcut analysis
## Date: 29th April 2020
## Author: Tim Cadman
## Email: t.cadman@bristol.ac.uk
################################################################################

require(opal)
require(dsBaseClient)
require(stringr)
require(dplyr)
require(magrittr)


## Call the function I wrote to get the stats in a useful form
source("~/ds-cs-functions/cs-get-stats.R")


################################################################################
# 1. Descriptives  
################################################################################

## This is just using the ds.summary function
test <- ds.summary("analysis_df$parity_bin")
str(test)


# Alternatively we can use a function I wrote which provides more details and
# gives you the output in a list of categorical and continuous variables
descriptives_ss <- cs.getStats(
  df = "analysis_df",
  vars = c(exp.vars, out.vars, cov.vars, other.vars)
)


################################################################################
# 2. Check available data  
################################################################################
bmi_available


################################################################################
# 3. IPD meta-analysis  
################################################################################

## ---- Maternal education -----------------------------------------------------
mat_ed_ipd <- list(

  bmi_96 = ds.glm(
  formula = "bmi.96 ~ edu_m + sex + age_months.96 + ninfea_dummy + moba_dummy",
  data = "analysis_df", 
  family = "gaussian"),

  bmi_168 = ds.glm(
  formula = "bmi.168 ~ edu_m + sex + age_months.168 + ninfea_dummy",
  data = "analysis_df", 
  family = "gaussian", 
  datasources = opals[c("genr", "ninfea")])
)

out <- ds.glm(
  formula = "bmi.96 ~ edu_m + sex + age_months.96 + ninfea_dummy + moba_dummy",
  data = "analysis_df", 
  family = "gaussian")

out

## ---- Gestational age at birth -----------------------------------------------
ga_ipd <- list(
  
  bmi_96 = ds.glm(
  formula = "bmi.96 ~ ga_all + edu_m + prepreg_bmi + preg_smk + agebirth_m_y + 
             parity_bin + sex + age_months.96 + ninfea_dummy + moba_dummy",
  data = "analysis_df", 
  family = "gaussian"),

  bmi_168 = ds.glm(
  formula = "bmi.168 ~ ga_all + edu_m + prepreg_bmi + preg_smk + agebirth_m_y + 
             parity_bin + sex + age_months.168 + ninfea_dummy",
  data = "analysis_df", 
  family = "gaussian", 
  datasources = opals[c("genr", "ninfea")])
)


################################################################################
# 3. Two-stage meta-analysis  
################################################################################

## ---- Maternal education -----------------------------------------------------
mat_ed_slma <- list(

  bmi_96 =  ds.glmSLMA(
  formula = "bmi.96 ~ edu_m + sex + age_months.96",
  data = "analysis_df", 
  family = "gaussian", 
  datasources = opals),

  bmi_168 = ds.glmSLMA(
  formula = "bmi.168 ~ edu_m + sex + age_months.168",
  data = "analysis_df", 
  family = "gaussian", 
  datasources = opals[c("genr", "ninfea")])
)

str(mat_ed_slma)

## ---- Gestational age at birth -----------------------------------------------
ga_slma <- list(
  bmi_96 =   ds.glmSLMA(
  formula = "bmi.96 ~ ga_all + edu_m + prepreg_bmi + preg_smk + agebirth_m_y + 
             parity_bin + sex + age_months.96",
  data = "analysis_df", 
  family = "gaussian", 
  datasources = opals),


  bmi_168 = ds.glmSLMA(
  formula = "bmi.168 ~ ga_all + edu_m + prepreg_bmi + preg_smk + agebirth_m_y + 
             parity_bin + sex + age_months.168",
  data = "analysis_df", 
  family = "gaussian", 
  datasources = opals[c("genr", "ninfea")])
)





