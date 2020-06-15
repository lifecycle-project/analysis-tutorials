################################################################################
## Project: bmi-poc
## Script purpose: Prepare data for analysis    
## Date: 29th April 2020
## Author: Tim Cadman
## Email: t.cadman@bristol.ac.uk
################################################################################

require(opal)
require(dsBaseClient)
library(purrr)
library(dplyr)
library(magrittr)
library(tidyr)
library(stringr)

source("~/ds-cs-functions/cs-class-discrepancy.R")
source("~/ds-cs-functions/cs-any-var-exists.R")
source("~/ds-cs-functions/cs-find-vars-index.R")
source("~/ds-cs-functions/cs-rm-lots.R")
source("~/ds-cs-functions/cs-rename-vars.R")

# This command is useful as it lists functionality currently available in DS.
ls("package:dsBaseClient")


################################################################################
# 1a. Assign additional opal tables - the long way  
################################################################################

datashield.assign(
  opal = opals["genr"], 
  symbol = "nonrep", 
  value = "lifecycle_1_0.1_0_genr_1_0_non_repeated", 
  variables = c(
    "child_id", "sex", "agebirth_m_y", "preg_smk", "parity_m", "height_m", 
    "prepreg_weight", "ga_bj", "ga_us", "cohort_id"))
  
datashield.assign(
  opal = opals["ninfea"], 
  symbol = "nonrep", 
  value = "lc_ninfea_core_2_0.2_0_core_1_0_non_rep", 
  variables = c(
    "child_id", "sex", "agebirth_m_y", "preg_smk", "parity_m", "height_m", 
    "prepreg_weight", "ga_bj", "ga_us", "cohort_id"))

datashield.assign(
  opal = opals["moba"], 
  symbol = "nonrep", 
  value = "lc_moba_core_2_0.2_0_core_non_rep_bmi_poc_study", 
  variables = c(
    "child_id", "sex", "agebirth_m_y", "preg_smk", "parity_m", "height_m", 
    "prepreg_weight", "ga_bj", "ga_us", "cohort_id"))

datashield.assign(
  opal = opals["genr"], 
  symbol = "monthrep", 
  value = "lifecycle_1_0.1_0_genr_1_0_monthly_repeated", 
  variables = c(
    "child_id", "age_years", "age_months", "height_", "weight_", "height_age", 
    "weight_age"))

datashield.assign(
  opal = opals["ninfea"], 
  symbol = "monthrep", 
  value = "lc_ninfea_core_2_0.2_0_core_1_0_monthly_rep", 
  variables = c(
    "child_id", "age_years", "age_months", "height_", "weight_", "height_age", 
    "weight_age"))

datashield.assign(
  opal = opals["moba"], 
  symbol = "monthrep", 
  value = "lc_moba_core_2_0.2_0_core_monthly_rep_bmi_poc_study", 
  variables = c(
    "child_id", "age_years", "age_months", "height_", "weight_", "height_age", 
    "weight_age"))

datashield.assign(
  opal = opals["genr"], 
  symbol = "yearrep", 
  value = "lifecycle_1_0.1_0_genr_1_0_yearly_repeated", 
  variables = c("child_id", "edu_m_", "age_years"))

datashield.assign(
  opal = opals["ninfea"], 
  symbol = "yearrep", 
  value = "lc_ninfea_core_2_0.2_0_core_1_0_yearly_rep", 
  variables = c("child_id", "edu_m_", "age_years"))


datashield.assign(
  opal = opals["moba"], 
  symbol = "yearrep", 
  value = "lc_moba_core_2_0.2_0_core_yearly_rep_bmi_poc_study", 
  variables = c("child_id", "edu_m_", "age_years"))

################################################################################
# 1b Assign additional opal tables - the shorter & neater way  
################################################################################

## ---- Create variable vectors ------------------------------------------------

## non-repeated 
nonrep.vars <- c(
  "child_id", "sex", "agebirth_m_y", "preg_smk", "parity_m", "height_m", 
  "prepreg_weight", "ga_bj", "ga_us", "cohort_id")

## monthly repeated
monthrep.vars <- c(
  "child_id", "age_years", "age_months", "height_", "weight_", "height_age", 
  "weight_age")

## yearly repeated
yearrep.vars <- c("child_id", "edu_m_", "age_years")


## ---- Make tibble of details for each cohort ---------------------------------
cohorts_tables <- bind_rows(
  tibble(
    opal_name = "genr",
    table = c(
      "lifecycle_1_0.1_0_genr_1_0_non_repeated",
      "lifecycle_1_0.1_0_genr_1_0_monthly_repeated",
      "lifecycle_1_0.1_0_genr_1_0_yearly_repeated")),
  tibble(
    opal_name = "ninfea",
    table = c(
      "lc_ninfea_core_2_0.2_0_core_1_0_non_rep",
      "lc_ninfea_core_2_0.2_0_core_1_0_monthly_rep",
      "lc_ninfea_core_2_0.2_0_core_1_0_yearly_rep")),
  tibble(
    opal_name = "moba",
    table = c(
      "lc_moba_core_2_0.2_0_core_non_rep_bmi_poc_study",
      "lc_moba_core_2_0.2_0_core_monthly_rep_bmi_poc_study",
      "lc_moba_core_2_0.2_0_core_yearly_rep_bmi_poc_study"))) %>% 
   mutate(type = rep(c("nonrep", "monthrep", "yearrep"), 3), 
          varlist = paste0(type, ".vars"))

cohorts_tables


## ---- Assign tables ----------------------------------------------------------
cohorts_tables %>%
  pmap(function(opal_name, table, type, varlist){
    
    datashield.assign(
      opal = opals[opal_name], 
      symbol = type, 
      value = table, 
      variables = eval(parse(text = varlist)))
  })


## This is an example of the %>% operator
example <- c(23.02, 34.22, 12.11, 23.98, 45.33)

round(mean(example), 2)

example %>%
  mean() %>%
  round(2)

## ---- Check that this has worked ---------------------------------------------
ds.ls()
ds.summary("nonrep")
ds.summary("monthrep")
ds.summary("yearrep")

# This looks good. You'll see that where the variable wasn't present (e.g the 
# ga_bj variable in moba) they are not assigned, but you don't get a warning
# message telling you this.


################################################################################
# 2. Sort out cases where not all cohorts have these variables
################################################################################

# Later on we will need to use ds.summary to get information about variables.
# However, at present it requires that all cohorts have every variable. We make
# things simpler therefore by creating empty variables where they are missing.


## ---- Fill blank variables ---------------------------------------------------
ds.dataFrameFill("nonrep", "nonrep")
ds.dataFrameFill("monthrep", "monthrep")
ds.dataFrameFill("yearrep", "yearrep")


## ---- Check for class discrepancies ------------------------------------------

# At present ds.dataFrameFill doesn't make the filled variable the same class
# as the original. Again this can cause problems later, so here we correct the 
# class of the blank variable. 

## First we check for discrepancies using a function I wrote 
## ("cs.classDiscrepancy")
cs.classDescrepancy(
  df = "nonrep", 
  vars = nonrep.vars)


## ---- Fix problem variables --------------------------------------------------

# Now we fix the problem variables and combine them with their original data
# frame

## Non-repeated
ds.asInteger("nonrep$ga_bj", newobj = "ga_bj_rev")

names(opals) %>%
  map(
    ~ds.dataFrame(
      x= c("nonrep", "ga_bj_rev"), 
      newobj = "nonrep", 
      datasources = opals[.])
      )

## Check this has worked
cs.classDescrepancy(df = "nonrep")
ds.rm("ga_bj_rev")


################################################################################
# 3. Create baseline variables from non repeated tables 
################################################################################

## ---- Gestational age at birth -----------------------------------------------

# Moba has ga_us, whilst the other cohorts have ga_bj. Here we create one ga
# variable from these separate variables.

ds.assign(
  toAssign = "nonrep$ga_bj_rev", 
  newobj = "ga_all",
  datasources = opals[opals!="moba"]
) 

ds.assign(
  toAssign = "nonrep$ga_us", 
  newobj = "ga_all",
  datasources = opals["moba"]
)


## ---- Maternal pre-pregnancy BMI ---------------------------------------------
ds.assign(
  toAssign='nonrep$prepreg_weight/(((nonrep$height_m/100))^2)', 
  newobj='prepreg_bmi'
)  


## ---- Parity -----------------------------------------------------------------

# We need to recode parity as a binary variable as there are issues later with 
# disclosive information when we run the models if we leave it ordinal.

ds.recodeLevels(
  "nonrep$parity_m", 
  newCategories = c(0, 1, 1, 1, 1),
  newobj = "parity_bin")


## ---- Dummy cohort variables -------------------------------------------------

# These are needed for the IPD analysis
coh_dummy <- tibble(
  cohort = c("ninfea_dummy", "moba_dummy"),
  value = c(103, 110))

coh_dummy %>%
  pmap(function(cohort, value){
      ds.Boole(
        V1 = "nonrep$cohort_id", 
        V2 = value,
        Boolean.operator = "==",
        numeric.output = TRUE, 
        na.assign = "NA", 
        newobj = cohort)
      })
    


ds.Boole(
  V1 = "nonrep$cohort_id", 
  V2 = 103,
  Boolean.operator = "==",
  numeric.output = TRUE, 
  na.assign = "NA", 
  newobj = "ninfea_dummy")

ds.Boole(
  V1 = "nonrep$cohort_id", 
  V2 = 110,
  Boolean.operator = "==",
  numeric.output = TRUE, 
  na.assign = "NA", 
  newobj = "moba_dummy")

## ---- Combine these new variables with non-repeated dataframe ----------------

# Datashield always creates new objects rather than adding variables to 
# existing objects. Therefore whenever we create new variables we need to join
# them back with the main dataframe.
#
# There is also currently a problem with the functions "ds.dataFrame" and 
# "ds.cbind" whereby if you try to apply them to all cohorts at once the 
# resulting dataframe can become corrupted. To solve this at the moment we
# manually iterate through each cohort.

names(opals) %>%
  map(
    ~ds.dataFrame(
      x = c("nonrep", "ga_all", "prepreg_bmi", "parity_bin", "ninfea_dummy", 
            "moba_dummy"),
      newobj = "nonrep_2", 
      datasources = opals[.])
  )

cs.rmLots(
  c("ga_all", "prepreg_bmi", "parity_bin", "ninfea_dummy", "moba_dummy"))


################################################################################
# 4. Create baseline maternal education variable from yearly repeated tables
################################################################################

## ---- Subset to keep observations where child's age == 0 ---------------------
ds.subset(
  x = 'yearrep', 
  subset = "baseline_vars", 
  logicalOperator = 'age_years==', 
  threshold = 0)


## ---- Convert to wide format -------------------------------------------------

# For the actual analysis we will want our dataset to be in wide format 
ds.reShape(
  data.name = "baseline_vars",
  timevar.name = "age_years",
  idvar.name = "child_id",
  v.names = c("edu_m_"), 
  direction = "wide", 
  newobj = "baseline_wide")


## ---- Rename baseline_vars more sensible names -------------------------------

# Currently the baseline variables we've made don't have great names because
# they've been generated automatically by the reshape function. So we give them
# some better names using a function I wrote ("cs.renameVars"). This is a short-
# cut which creates the new variables using information provided in a table and
# joins these together in a dataframe.

## First create a list with old and new variable names
old_new <- tribble(
  ~oldvar, ~newvar,
  "edu_m_.0", "edu_m")

  
## Now rename them
cs.renameVars(
  df = "baseline_wide", 
  names = old_new,
  new_df_name = "baseline_renamed")


## Merge back in
names(opals) %>%
  map(
    ~ds.dataFrame(
      x = c("baseline_wide", "baseline_renamed"),
      newobj = "baseline_wide_2",
      datasources = opals[.]
    ))

ds.rm("edu_m")

################################################################################
# 5. Calculate BMI scores from monthly repeated measures data
################################################################################

## ---- First we derive BMI scores ---------------------------------------------
ds.assign(
  toAssign='monthrep$weight_/((monthrep$height_/100)^2)', 
  newobj='bmi'
)  


## ---- Now join these back to the dataframe -----------------------------------
names(opals) %>%
  map(
    ~ds.dataFrame(
      x = c('bmi', 'monthrep'), 
      newobj = 'monthrep',
      datasources = opals[.]
    )
  )

ds.rm("bmi")

################################################################################
# 6. Create BMI variables corresponding to age brackets 
################################################################################

# This is a bit fiddly to do, as currently you can't specify multiple conditions
# to subset. What we do is first create variables (0/1) indicating for each
# row whether the subject is above or below specified age values. We
# then multiply these together, which gives a new variable indicating whether
# both criteria are met (0*0 = 0, 0*1 = 0, 1*0 = 1*1 = 1). We then use these
# variables to create our subsets.

## ---- First make a table of our upper and lower values -----------------------
bmi_cats_a <- bind_rows(
  tibble(
    value = c(49, 97),
    op = ">="),
  tibble(
    value = c(96, 168),
    op = "<=")) %>% 
  mutate(new_df_name = paste0("bmi_", value))

bmi_cats_a
## ---- Now create objects indicating whether conditions are met ---------------

# Although we can't see them directly, they will be vectors of 1s and 0s of the
# same length as the original dataframe in each cohort (monthrep)

bmi_cats_a %>%
  pmap(function(value, op, new_df_name){
    
    ds.Boole(
      V1 = "monthrep$age_months", 
      V2 = value, 
      Boolean.operator = op, 
      newobj = new_df_name)
  })

## ---- Now create objects showing whether age is between two points -----------

## Again we first make a table with the different values we will want to feed
## to our function

bmi_cats_b <- tibble(
  formula = paste0(
    bmi_cats_a %>% filter(op == ">=") %>% pull(new_df_name),
    "*",
    bmi_cats_a %>% filter(op == "<=") %>% pull(new_df_name)), 
  varname = paste0(
    "bmi_",
    bmi_cats_a %>% filter(op == ">=") %>% pull(value),
    "_",
    bmi_cats_a %>% filter(op == "<=") %>% pull(value)))


## Now we create the variables. Again what we are creating is a series of 
## vectors of 1s and 0s indicating whether each row falls between a specified
## age range

bmi_cats_b %>%
  pmap(function(formula, varname){
    
    ds.assign(
      toAssign = formula, 
      newobj = varname)
    
  })


## ---- Now we want to find out which cohorts have data ------------------------
bmi_available <- bmi_cats_b %>%
  pmap(function(varname, ...){ds.mean(varname)}) 

names(bmi_available) <- bmi_cats_b$varname

bmi_available <-map_dfr(
  bmi_available, ~.x$Mean.by.Study[, "EstimatedMean"]) %>%
  map_dfr(~ifelse(.x == 0, "no", "yes")) %>%
  mutate(cohort = names(opals)) %>%
  select(cohort, everything())

bmi_available


## ---- Create a new table listing which subsets to create ---------------------
bmi_to_subset <- bmi_available %>%
  pivot_longer(
    cols = -cohort, 
    names_to = "varname", 
    values_to = "available") %>%
  filter(available == "yes") %>%
  select(-available) %>%
  mutate(new_subset_name = paste0(varname, "_sub"))


## ---- Now create the subsets -------------------------------------------------
bmi_to_subset %>%
  pmap(
    function(cohort, varname, new_subset_name){
      ds.dataFrameSubset(
        df.name = "monthrep", 
        V1.name = varname, 
        V2.name = "1", 
        Boolean.operator = "==", 
        keep.NAs = FALSE, 
        newobj = new_subset_name,
        datasources = opals[cohort])
    })

ds.ls()

## ---- Create new variables indicating the age category -----------------------

# Now within each subset we create a variable indicating the age category.
# Again the way I've done it is very clunky but it works: you multiple their
# age in months by 0 (to give 0), then add the upper threshold value from the
# bmi_cats dataframe we made above.

# This is required for when we reshape back to wide format. Currently the only 
# way I can find to do this is quite clunky but it works.
bmi_to_subset %<>%
  mutate(value = str_extract(varname, '[^_]+$'), 
         age_cat_name = paste0(new_subset_name, "_age_cat"))

bmi_to_subset %>%
  pmap(
    function(cohort, new_subset_name, value, age_cat_name, ...){
      ds.assign(
        toAssign = paste0("(", new_subset_name, "$age_months * 0)+", value), 
        newobj = age_cat_name, 
        datasources = opals[cohort])
    })


## Join back with dataframe
bmi_to_subset %>%
  pmap(
    function(cohort, new_subset_name, age_cat_name, ...){
      ds.dataFrame(
        x = c(new_subset_name, age_cat_name),
        newobj = new_subset_name,
        datasources = opals[cohort])
    })

## ---- Convert subsets to wide form -------------------------------------------

# Up to now all the bmi subsets are in long form. Here we convert to wide form.
# Usefully (as specified in the help file for "ds.reshape") if multiple 
# observations exist per subject the first will be kept and subsequent dropped.
# As we earlier sorted ascending by age this means in the case a subject has
# multiple observations we keep the earliest.
bmi_to_subset %>%
  pmap(
    function(cohort, new_subset_name, age_cat_name, ...){
      ds.reShape(
        data.name = new_subset_name,
        timevar.name = age_cat_name,
        idvar.name = "child_id",
        v.names = c("bmi", "age_months"), 
        direction = "wide", 
        newobj = paste0(new_subset_name, "_wide"),
        datasources = opals[cohort])
    })


################################################################################
# 9. Merge various datasets  
################################################################################

## ---- First we merge the non repeated and yearly repeated --------------------
ds.merge(
  x.name = "nonrep_2",
  y.name = "baseline_wide_2",
  by.x.names = "child_id",
  by.y.names = "child_id",
  all.x = TRUE,
  newobj = "bmi_poc"
)


## ---- Now where there was available BMI data we merge this back in -----------
bmi_to_subset %>%
  pmap(
    function(cohort, new_subset_name, ...){
      ds.merge(
        x.name = "bmi_poc",
        y.name = paste0(new_subset_name, "_wide"),
        by.x.names = "child_id",
        by.y.names = "child_id",
        all.x = TRUE,
        newobj = "bmi_poc", 
        datasources = opals[cohort])
    })

## ---- Create blank columns where data not available --------------------------
ds.dataFrameFill("bmi_poc", "bmi_poc")

ds.summary("bmi_poc")

################################################################################
# 10. Create analysis dataset  
################################################################################

# So when it comes to write up the analysis, we need to be able to specify an
# analysis dataset as a subset of all data, e.g. "contained all participants 
# with at least one exposure and outcome"


## ---- First we specify vectors of exposures and outcomes ---------------------
exp.vars <- c("edu_m", "ga_all")  

out.vars <- c("bmi.96", "bmi.168")

cov.vars <- c("sex", "preg_smk", "parity_bin", "prepreg_bmi", "agebirth_m_y")

other.vars <- c("age_months.96", "age_months.168", "ninfea_dummy", "moba_dummy")


## ---- Now we create vars indicating whether any non-missing values are present
cs.anyVarExists(
  df = "bmi_poc", 
  vars = exp.vars, 
  new_label = "exposure")

cs.anyVarExists(
  df = "bmi_poc", 
  vars = out.vars, 
  new_label = "outcome")


## ---- Next create another variable indicating whether a valid case -----------
ds.make(
  toAssign = "any_exposure+any_outcome", 
  newobj = "n_exp_out")

ds.Boole(
  V1 = "n_exp_out", 
  V2 = "2", 
  Boolean.operator = "==", 
  na.assign = 0, 
  newobj = "valid_case")

## Check how many valid cases to make sure it's plausible
ds.summary("valid_case")


## ---- Now we create a vector of all the variables we want to keep ------------
keep_vars <- c(exp.vars, out.vars, cov.vars, other.vars)


## ---- Drop variables we don't need -------------------------------------------
var_index <- names(opals) %>%
  map(
    ~cs.findVarsIndex(
      df = "bmi_poc", 
      vars = keep_vars, 
      cohorts = .))

## Now finally we subset based on valid cases and required variables
var_index %>%
  imap(
    ~ds.dataFrameSubset(df.name = "bmi_poc", 
                        V1.name = "valid_case", 
                        V2.name = "1", 
                        Boolean.operator = "==", 
                        keep.cols = .x,
                        keep.NAs = FALSE, 
                        newobj = "analysis_df", 
                        datasources = opals[.y]))


## ---- Check that this has worked ok ------------------------------------------
ds.summary("bmi_poc")
ds.summary("analysis_df")


################################################################################
# 11. Clear up environment    
################################################################################

## ---- Remove unneeded objects ------------------------------------------------

## One at a time
ds.rm("bmi_49")

## Multiple together
cs.rmLots(c("bmi_49", "bmi_96"))

## ---- Save workspace ---------------------------------------------------------
datashield.workspace_save(opals, "june15")


## ---- See list of saved workspaces -------------------------------------------
datashield.workspaces(opals)


## ---- Load saved workspace ---------------------------------------------------
opals <- datashield.login(logindata, restore = "june15")


## ---- Remove unneeded workspace ----------------------------------------------
datashield.workspace_rm(opals, "june15")

