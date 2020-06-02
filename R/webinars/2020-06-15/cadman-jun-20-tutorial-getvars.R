################################################################################
## Project: bmi-poc
## Script purpose: Prepare data for analysis    
## Date: 29th April 2020
## Author: Tim Cadman
## Email: t.cadman@bristol.ac.uk
################################################################################

library(opal)
library(dsBaseClient)

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
  "child_id", "sex", "agebirth_m_y", "preg_smk", "parity_m", "height_m", 
  "prepreg_weight", "ga_bj"
  )

## monthly repeated
monthrep.vars <- list(
  "child_id", "age_years", "age_months", "height_", "weight_", "height_age", 
  "weight_age"
  )

## yearly repeated
yearrep.vars <- list(
  "child_id", "edu_m_", "age_years"
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
    stringsAsFactors = FALSE))
  

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



################################################################################
# 2. Add blank variables where cohorts don't have data  
################################################################################

# To perform operations across multiple cohorts, DS needs the same variables to
# exist in each cohort. We use "ds.dataFrameFill" to add blank columns where
# they are not present for some cohorts. We use the same name for the output
# because the function only creates a new dataframe if the variables are missing
# for that cohort.

ds.dataFrameFill("nonrep", "nonrep")
ds.dataFrameFill("yearrep", "yearrep")


################################################################################
# 3. Correct classes of blank variables  
################################################################################

# At present ds.dataFrameFill doesn't make the filled variable the same class
# as the original. This can cause problems later when we use ds.summary, as
# it gets upset if the variables don't have the same class.


## ---- First look to see where there are class discrepancies ------------------

## Non-repeated
check_nonrep <- sapply(nonrep.vars, function(x){
  
  ds.class(paste0("nonrep$", x))
  
})

colnames(check_nonrep) <- nonrep.vars
check_nonrep


## Yearly repeated
check_yearrep <- sapply(yearrep.vars, function(x){
  
  ds.class(paste0("yearrep$", x))
  
})

colnames(check_yearrep) <- yearrep.vars
check_yearrep


## ---- Fix problem variables --------------------------------------------------

ds.asInteger("nonrep$ga_bj", newobj = "ga_bj_rev")

sapply(names(opals), function(x){
  
  ds.dataFrame(c("nonrep", "ga_bj_rev"), newobj = "nonrep", 
               datasources = opals[x])
  
})

ds.class("nonrep$ga_bj_rev")


################################################################################
# 3. Create baseline maternal education variable
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
  v.names = "edu_m_", 
  direction = "wide", 
  newobj = "baseline_wide"
)


## ---- Rename baseline_vars more sensible names ----------------------------------------

# Currently the baseline variables we've made don't have great names because
# they've been generated automatically by the reshape function. So we give them
# some better names. In datashield we can't just add a new variable to an 
# existing dataframe; instead we have to create a new dataframe containing that 
# variable and merge it back together.

ds.assign(
  toAssign = "baseline_wide$edu_m_.0",
  newobj = "edu_m"
)  


sapply(names(opals), function(y){
  
  ds.cbind(
    x = c("nonrep", "edu_m"), 
    newobj = 'nonrep_2',
    datasources = opals[y]
  )
})


################################################################################
# 4. Calculate BMI scores 
################################################################################

# "ds.assign" also lets us use simple formula to create new variables

## ---- First we derive BMI scores ---------------------------------------------
ds.assign(
  toAssign='monthrep$weight_/((monthrep$height_/100)^2)', 
  newobj='bmi'
)  


## ---- Now we merge back with monthly repeated dataset ------------------------
sapply(names(opals), function(x){
  
  ds.cbind(
    x = c('bmi', 'monthrep'), 
    newobj = 'monthrep',
    datasources = opals[x]
  )
})


################################################################################
# 5. Create BMI variables corresponding to age brackets 
################################################################################

# As with everything in DS, this is a bit fiddly! We can dream that one day 
# dplyr will be implemented :)
#
# What we are trying to do here is create 2 variables which capture BMI within
# two time periods. If a given subject has BMI measurements within each of these
# periods, they will have values for both. If they have more than 2 values 
# within a given time period, we select the earliest.

## ---- First create list of categories and age thresholds ---------------------

# Here we create a reference table which shows the upper and lower age bands
# for each of the variables we want to create

bmi_cats <- list(
  bmi_24 = data.frame(varname = "bmi_24", lower = 0, upper = 24, 
                      stringsAsFactors = FALSE),
    bmi_49_96 = data.frame(varname = "bmi_49_96", lower = 49, upper = 96, 
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

sapply(names(opals), function(z){
  
  sapply(bmi_cats, function(y){
    
    ds.assign(
      toAssign = paste0("(", y[, "varname"], "$age_months * 0)+", y[, "upper"]), 
      newobj = "age_cat",
      datasources = opals[z]
    )
    
    ds.cbind(
      x = c(y[, "varname"], "age_cat"), 
      newobj = y[, "varname"],
      datasources = opals[z]
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

sapply(names(opals), function(y){
  
  ds.cbind(
    x = c('bmi_poc', 'prepreg_bmi'), 
    newobj = 'bmi_poc', 
    datasources = opals[y])
})

ds.dataFrameFill("bmi_poc", "bmi_poc")

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
# 8. Create one ga variable
################################################################################

# Moba doesn't have ga_bj so we create one variable which represents ga.
ds.assign(
  toAssign = "bmi_poc$ga_bj_rev", 
  newobj = "ga_all",
  datasources = opals[opals!="moba"]
) 

ds.assign(
  toAssign = "bmi_poc$ga_us", 
  newobj = "ga_all",
  datasources = opals["moba"]
)

sapply(names(opals), function(y){
  ds.cbind(
    x = c('bmi_poc', 'ga_all'), 
    newobj = 'bmi_poc', 
    datasources = opals[y]
  )
})


################################################################################
# 9. Create analysis dataset  
################################################################################

# So when it comes to write up the analysis, we need to be able to specify an
# analysis dataset as a subset of all data, e.g. "contained all participants 
# with at least one exposure and outcome"


## ---- First we specify vectors of exposures and outcomes ---------------------
exp.vars <- c("edu_m", "ga_all")  

out.vars <- c("bmi.24", "bmi.96")

cov.vars <- c("sex", "preg_smk", "parity_bin", "prepreg_bmi", "agebirth_m_y")

other.vars <- c("age_months.24", "age_months.96")


## ---- Now we create vars indicating whether any non-missing values are present
anyVarExists(df = "bmi_poc", vars = exp.vars, newvar = "exposure")
anyVarExists(df = "bmi_poc", vars = out.vars, newvar = "outcome")


## ---- Next create another variable indicating whether a valid case -----------
ds.make(toAssign = "any_exposure+any_outcome", newobj = "n_exp_out")

ds.Boole(V1 = "n_exp_out", V2 = "2", Boolean.operator = "==", na.assign = 0, 
         newobj = "valid_case")

## Check how many valid cases to make sure it's plausible
ds.summary("valid_case")


## ---- Now we create a vector of all the variables we want to keep ------------
keep_vars <- c(exp.vars, out.vars, cov.vars, other.vars)


## ---- Create individual dataframes of complete outcomes ----------------------

# Note that we have to do this separately for each cohort. The reason being 
# that "keep.cols" uses the index of the variable rather than the variable
# name and this may be different for each cohort. 

var_index <- lapply(names(opals), function(x){
  
  sapply(keep_vars, function(y){
    
    which(
      str_detect(
        ds.colnames("bmi_poc", datasources = opals[x])[[1]], y) == TRUE)
  })  
})

names(var_index) <- names(opals)


## Now finally we subset based on valid cases and required variables
subset_info <- map2(names(opals), var_index, list)

sapply(subset_info, function(x){
  
  ds.dataFrameSubset(df.name = "bmi_poc", 
                     V1.name = "valid_case", 
                     V2.name = "1", Boolean.operator = "==", 
                     keep.cols = x[[2]],
                     keep.NAs = FALSE, newobj = "analysis_df", 
                     datasources = opals[x[[1]]])
})


## ---- Check that this has worked ok ------------------------------------------
ds.summary("bmi_poc")
ds.summary("analysis_df")

