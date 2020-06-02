################################################################################
## Project: bmi-poc
## Script purpose: Prepare data for analysis    
## Date: 29th April 2020
## Author: Tim Cadman
## Email: t.cadman@bristol.ac.uk
################################################################################

library(opal)
library(dsBaseClient)
library(stringr)

# This is the second of four scripts, which prepares the analysis dataset. 
# 
# The first script deals with logging into each cohort's opal server (which for 
# the purposes of this script are assigned to one R object called "opals"). 
# This is done separately so that sensitive login details can be kept locally 
# and the rest of the script can be shared publically.
#
# The other three scripts used in the analysis are "ds-common-getstats.R" which 
# contains a functions I wrote to extract descriptive statistics, 
# "bmi-poc-analysis" which does the analysis, and "bmi-poc-tables" which creates
# tables for the writeup.

# This command is useful as it lists functionality currently available in DS.
ls("package:dsBaseClient")


################################################################################
# 1. Assign additional opal tables  
################################################################################

# The command to assign additional tables is "datashield.assign". However 
# currently you can't assign all tables using one call to this function, 
# because it will only work if all cohorts have named the tables identically,
# which they haven't. We get around this by (i) creating a list of all the
# variables we require, (ii) creating a dataframe with the names of required 
# tables for each cohort, and (iii) use sapply to iterate through this list 
# using "datashield.assign"

## ---- Create variable lists --------------------------------------------------

## non-repeated 
nonrep.vars <- list(
  "child_id", "sex", "coh_country", "preg_dia", "agebirth_m_y", "preg_smk", 
  "parity_m", "height_m", "prepreg_weight", "ethn3_m", "preg_ht", "ga_bj", 
  "cohort_id")

## monthly repeated
monthrep.vars <- list(
  "child_id", "age_years", "age_months", "height_", "weight_", "height_age", 
  "weight_age"
)

## yearly repeated
yearrep.vars <- list(
  "child_id", "edu_m_", "edu_f1_", "age_years", "ndvi300_", "green_dist_", 
  "green_size_", "greenyn300_", "areases_tert_"
)


## ---- Make list of opal table names for each cohort --------------------------
cohorts_tables <- list(
  genr = data.frame(
    opal_name = "genr",
    wp1_nrm = "lifecycle_1_0.1_0_genr_1_0_non_repeated",
    wp1_mrm = "lifecycle_1_0.1_0_genr_1_0_monthly_repeated",
    wp1_yrm = "lifecycle_1_0.1_0_genr_1_0_yearly_repeated",
    stringsAsFactors = FALSE),
  ninfea = data.frame(
    opal_name = "ninfea",
    wp1_nrm = "lc_ninfea_core_2_0.2_0_core_1_0_non_rep",
    wp1_mrm = "lc_ninfea_core_2_0.2_0_core_1_0_monthly_rep",
    wp1_yrm = "lc_ninfea_core_2_0.2_0_core_1_0_yearly_rep",
    stringsAsFactors = FALSE), 
  moba = data.frame(
    opal_name = "moba",
    wp1_nrm = "lc_moba_core_2_0.2_0_core_non_rep_bmi_poc_study",
    wp1_mrm = "lc_moba_core_2_0.2_0_core_monthly_rep_bmi_poc_study",
    wp1_yrm = "lc_moba_core_2_0.2_0_core_yearly_rep_bmi_poc_study",
    stringsAsFactors = FALSE), 
  raine = data.frame(
    opal_name = "raine",
    wp1_nrm = "lc_raine_core_2_0.2_0_core_1_0_non_rep",
    wp1_mrm = "lc_raine_core_2_0.2_0_core_1_0_monthly_rep",
    wp1_yrm = "lc_raine_core_2_0.2_0_core_1_0_yearly_rep",
    stringsAsFactors = FALSE))
  
  
  #gecko = data.frame(
  #  opal_name = "gecko",
  #  wp1_nrm = "lc_gecko_core_2_0.2_0_core_1_0_non_rep",
  #  wp1_mrm = "lc_gecko_core_2_0.2_0_core_1_0_monthly_rep",
  #  wp1_yrm = "lc_gecko_core_2_0.2_0_core_1_0_yearly_rep",
  #  stringsAsFactors = FALSE)
  


## ---- Assign tables for all cohorts ------------------------------------------

## Non-repeated measures
sapply(cohorts_tables, function(x){
  
  datashield.assign(
    opal = opals[x[, "opal_name"]], 
    symbol = "nonrep", 
    value = x[, "wp1_nrm"], 
    variables = nonrep.vars)
})


## Monthly repeated measures
sapply(cohorts_tables, function(x){
  
  datashield.assign(
    opal = opals[x[, "opal_name"]], 
    symbol = "monthrep", 
    value = x[, "wp1_mrm"], 
    variables = monthrep.vars)
})


## Yearly repeated measures
sapply(cohorts_tables, function(x){
  
  datashield.assign(
    opal = opals[x[, "opal_name"]], 
    symbol = "yearrep", 
    value = x[, "wp1_yrm"], 
    variables = yearrep.vars)
})


## ---- Check that this has worked ---------------------------------------------

ds.ls()
ds.summary("nonrep")
ds.summary("monthrep")
ds.summary("yearrep")

# This looks good. You'll see that where the variable wasn't present (e.g)
# the SEP variables in genr they are not assigned, but you don't get a warning
# message telling you this.


## ---- Fill blank variables with NA -------------------------------------------

# To perform operations across multiple cohorts, DS needs the same variables to
# exist in each cohort. We use "ds.dataFrameFill" to add blank columns where
# they are not present for some cohorts. We use the same name for the output
# because the function only creates a new dataframe if the variables are missing
# for that cohort.

ds.dataFrameFill("nonrep", "nonrep")
ds.dataFrameFill("yearrep", "yearrep")

## ---- Fix class --------------------------------------------------------------

# Hopefully this can be removed once Demitiris has fixed ds.dataFrameFill. The
# current problem is that it doesn't create a variable with the same class as 
# the original, which then breaks ds.summary later on.

## Check where there are class discrepancies

sapply(nonrep.vars, function(x){
  
  ds.class(paste0("nonrep$", x))
  
})

## Fix offenders
ds.asFactor("nonrep$ethn3_m", datasources = opals["moba"], 
            newobj.name = "ethn3_m")

ds.summary("nonrep$ethn3_m", datasources = opals["moba"])

"ethn3_m", "ga_bj", 



ds.class("nonrep$ethn3_m")

ds.dataFrameFill("nonrep", "nonrep")

ds.class("nonrep$ethn3_m")

ds.asFactor("nonrep$ethn3_m", datasources = opals["moba"], newobj.name = "ethn3_m")




################################################################################
# 2. Create baseline SEP variables
################################################################################

## ---- Create variables for parental education in first year of life ----------

# Here we subset the yearly repeated measures dataframe to keep only those 
# values where the child's age = 0 (ie first year of life)

ds.subset(x = 'yearrep', subset = "baseline_vars", 
          logicalOperator = 'age_years==', threshold = 0)


## ---- Convert to wide format -------------------------------------------------

# For this analysis we want our final dataset to be in wide format so we reshape
# it. Note that we need to do this separately for each cohort, because DS throws
# an error if the variable is missing in any of the cohorts. This could be 
# condensed using sapply but I think it's easier to keep track of what variables
# are in each cohort if you do it separately.

ds.reShape(
  data.name = "baseline_vars",
  timevar.name = "age_years",
  idvar.name = "child_id",
  v.names = c("edu_m_", "edu_f1_", "greenyn300_", "green_dist_", "green_size_", 
              "ndvi300_", "areases_tert_"), 
  direction = "wide", 
  newobj = "baseline_wide"
  )


## ---- Rename baseline_vars more sensible names ----------------------------------------

# Currently the baseline variables we've made don't have great names because
# they've been generated automatically by the reshape function. So we give them
# some better names. In datashield we can't just add a new variable to an 
# existing dataframe; instead we have to create a new dataframe containing that 
# variable and merge it back together.

## First create a list with old and new variable names
old_new <- list(
            c("edu_f1_.0", "edu_f"),  c("edu_m_.0", "edu_m"), 
            c("greenyn300_.0", "greenyn300"), c("green_dist_.0", "green_dist"), 
            c("green_size_.0", "green_size"), c("ndvi300_.0", "ndvi300"), 
            c("areases_tert_.0", "areases_tert")
          )

## Now use apply to create variables with new names
sapply(old_new, function(x){
  
  ds.assign(
    toAssign = paste0("baseline_wide$", x[1]),
    newobj = x[2]
  )  
})


## ---- Merge with the non-repeated measures table -----------------------------
sapply(names(opals), function(y){

ds.cbind(
  x = c("nonrep", "edu_f", "edu_m", "greenyn300", "green_dist", 
        "green_size", "ndvi300", "areases_tert"), 
  newobj = 'nonrep_2',
  datasources = opals[y]
)
})


################################################################################
# 3. Calculate BMI scores 
################################################################################

# "ds.assign" lets us use simple formula to create new variables

## ---- First we derive BMI scores ---------------------------------------------
ds.assign(
  toAssign='monthrep$weight_/((monthrep$height_/100)^2)', 
  newobj='bmi'
)  

sapply(names(opals), function(y){
  
ds.cbind(
  x = c('bmi', 'monthrep'), 
  newobj = 'monthrep',
  datasources = opals[y]
)
})
  

################################################################################
# 4. Create BMI variables corresponding to age brackets 
################################################################################

# As with everything in DS, this is a bit fiddly! We can dream that one day 
# dplyr will be implemented :)
#
# What we are trying to do here is create 5 variables which capture BMI within
# 5 time periods. If a given subject has BMI measurements within each of these
# periods, they will have values for all 5. If they have more than 2 values 
# within a given time period, we select the earliest.

## ---- First create list of categories and age thresholds ---------------------

# Here we create a reference table which shows the upper and lower age bands
# for each of the variables we want to create

bmi_cats <- list(
  bmi_24 = data.frame(varname = "bmi_24", lower = 0, upper = 24, 
                      stringsAsFactors = FALSE),
  
  bmi_25_48 = data.frame(varname = "bmi_25_48", lower = 25, upper = 48, 
                         stringsAsFactors = FALSE),
  
  bmi_49_96 = data.frame(varname = "bmi_49_96", lower = 49, upper = 96, 
                         stringsAsFactors = FALSE),
  
  bmi_97_168 = data.frame(varname = "bmi_97_168", lower = 97, upper = 168, 
                          stringsAsFactors = FALSE),
  
  bmi_169 = data.frame(varname = "bmi_169", lower = 169, upper = 215, 
                       stringsAsFactors = FALSE)
)


## ---- Create subsets with observations from specified time periods -----------

# We use sapply to iterate over each element of the above list. The only way
# I've found to do this is in two stages - you create a subset based on the 
# lower bound, then you subset that subset also restricting based on the upper
# bound. The reason you have to do it like this is because the "ds.subset" 
# function only allows you to specify one threshold, ie you can use "> x & < y"

sapply(bmi_cats, function(y){
  
  ds.subset(x = 'monthrep', subset = y[, "varname"], logicalOperator = 'age_months>=', 
            threshold = y[, "lower"]
  )
  
  ds.subset(x = y[, "varname"], subset = y[, "varname"], logicalOperator='age_months<=', 
            threshold = y[, "upper"]
  )
  
})


## ---- Sort subsets by age (youngest first) -----------------------------------

# This next step sorts the subsets by age (youngest first). This is required
# a couple of stages later when we make sure that if a subject has multiple
# observations we select the youngest.

sapply(bmi_cats, function(y){
  
  ds.dataFrameSort(df.name = y[, "varname"], 
                   sort.key.name = paste0(y[, "varname"], "age_months"), 
                   datasources = opals, newobj = y[, "varname"], 
                   sort.descending = FALSE)  
})


## ---- Create new variables indicating the age category -----------------------

# Now within each subset we create a variable indicating the age category.
# Again the way I've done it is very clunky but it works: you multiple their
# age in months by 0 (to give 0), then add the upper threshold value from the
# bmi_cats dataframe we made above.

# This is required for when we reshape back to wide format. Currently the only 
# way I can find to do this is quite clunky but it works.

sapply(names(opals), function(y){
  
  sapply(bmi_cats, function(z){
  
  ds.assign(
    toAssign = paste0("(", z[, "varname"], "$age_months * 0)+", z[, "upper"]), 
    newobj = "age_cat",
    datasources = opals[y]
  )
  
  ds.cbind(
    x = c(z[, "varname"], "age_cat"), 
    newobj = z[, "varname"],
    datasources = opals[y]
  )
  
})
  
})


## ---- Convert subsets to wide form -------------------------------------------

# Up to now all the bmi subsets are in long form. Here we convert to wide form.
# Usefully (as specified in the help file for "ds.reshape") if multiple 
# observations exist per subject the first will be kept and subsequent dropped.
# As we earlier sorted ascending by age this means in the case a subject has
# multiple observations we keep the earliest.

sapply(bmi_cats, function(y){
  
  ds.reShape(
    data.name = y[, "varname"],
    timevar.name = "age_cat",
    idvar.name = "child_id",
    v.names = c("bmi", "age_months"), 
    direction = "wide", 
    newobj = paste0(y[, "varname"], "_wide")
  )
  
})


## ---- Merge these together ---------------------------------------------------

# Here we are merging the dataframe subsets with BMI at each age range back with
# the other non-repeated measures table

ds.merge(
  x.name = "nonrep_2",
  y.name = "bmi_24_wide",
  by.x.names = "child_id",
  by.y.names = "child_id",
  all.x = TRUE,
  newobj = "bmi_poc"
)

sapply(bmi_cats[2:5], function(x){
  ds.merge(
    x.name = "bmi_poc",
    y.name = paste0(x[, "varname"], "_wide"),
    by.x.names = "child_id",
    by.y.names = "child_id",
    all.x = TRUE,
    newobj = "bmi_poc"
  )
})

################################################################################
# 6. Create maternal pre-pregnancy BMI variable  
################################################################################

# This same principle as creating child BMI variables, but we are using data
# already in wide format. We create the new variable (dataframe) and join back
# with the analysis dataframe. 

ds.assign(
  toAssign='bmi_poc$prepreg_weight/(((bmi_poc$height_m/100))^2)', 
  newobj='prepreg_bmi'
)  

ds.dataFrameFill("bmi_poc", "bmi_poc")

sapply(names(opals), function(y){

  ds.cbind(
  x = c('bmi_poc', 'prepreg_bmi'), 
  newobj = 'bmi_poc', 
  datasources = opals[y])
})


################################################################################
# 7. Recode parity to a binary variable  
################################################################################

# We need to recode parity as a binary variable as there are issues with 
# disclosive information later when we run the models if we leave it ordinal.
# Seems to be an issue here that the moba parity variable is character format.

ds.recodeLevels(
  "bmi_poc$parity_m", 
  newCategories = c(0, 1, 1, 1, 1),
  newobj = "parity_bin",
  datasources = opals)

sapply(names(opals), function(y){
ds.cbind(
  x = c('bmi_poc', 'parity_bin'), 
  newobj = 'bmi_poc', 
  datasources = opals[y]
)
})
  

################################################################################
# 8. Create analysis dataset  
################################################################################

# So when it comes to write up the analysis, we need to be able to specify an
# analysis dataset as a subset of all data, e.g. "contained all participants 
# with at least one exposure and outcome"


## ---- First we specify vectors of exposures and outcomes ---------------------
exp.vars <- c("edu_m", "ga_bj", "preg_dia", "greenyn300", "green_dist", 
              "green_size", "ndvi300")  

out.vars <- c("bmi.24", "bmi.48", "bmi.96", "bmi.168", "bmi.215")

cov.vars <- c("sex", "preg_smk", "preg_ht", "parity_bin", "ethn3_m", 
              "height_m", "prepreg_bmi", "agebirth_m_y", "areases_tert")

other.vars <- c("age_months.24", "age_months.48", "age_months.96", 
                "age_months.168")


## ---- Now we create vars indicating whether any non-missing values are present
anyVarExists(df = "bmi_poc", vars = exp.vars, newvar = "exposure")
anyVarExists(df = "bmi_poc", vars = out.vars, newvar = "outcome")


## ---- Next create another variable indicating whether a valid case -----------
ds.make(toAssign = "any_exposure+any_outcome", newobj = "n_exp_out")

ds.Boole(V1 = "n_exp_out", V2 = "2", Boolean.operator = "==", na.assign = 0, 
         newobj = "valid_case")


## ---- Now we create a vector of all the variables we want to keep ------------
keep_vars <- c(exp.vars, out.vars, cov.vars, other.vars)


## ---- Create individual dataframes of complete outcomes ----------------------

# Note that we have to do this separately for each cohort. The reason being 
# that "keep.cols" uses the index of the variable rather than the variable
# name and this may be different for each cohort. 

var_index <- whichVars("bmi_poc", keep_vars)


## Now finally we subset based on valid cases and required variables
sapply(names(opals), function(x){
  
  sapply(var_index, function(y){
    
    ds.dataFrameSubset(df.name = "bmi_poc", 
                       V1.name = "valid_case", 
                       V2.name = "1", Boolean.operator = "==", 
                       keep.cols = y,
                       keep.NAs = FALSE, newobj = "analysis_df", 
                       datasources = opals[x])
    })
  })
  

## ---- Check that this has worked ok ------------------------------------------
ds.summary("analysis_df")
ds.summary("bmi_poc")

