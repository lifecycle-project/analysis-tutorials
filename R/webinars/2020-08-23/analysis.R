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
#library(remotes)
#install_github("lifecycle-project/ds-helper")
library(dsHelper)

ls("package:dsBaseClient")

################################################################################
# 1. Assign additional opal tables  
################################################################################

# The command to assign additional tables is "datashield.assign". However 
# currently you can't assign all tables using one call to this function, 
# because it will only work if all cohorts have named the tables identically,
# which they haven't. We get around this by (i) creating vectors of all the
# variables we require, (ii) creating a table with the names of required 
# tables for each cohort, and (iii) use "pmap" to iterate through the rows of
# this table using "datashield.assign"

## ---- Create variable lists --------------------------------------------------

## non-repeated 
nonrep.vars <- c("child_id", "preg_smk", "preg_ht", "cohort_id")

## monthly repeated
monthrep.vars <- c("child_id", "age_months", "height_", "weight_")

## ---- Make tibble of details for each cohort ---------------------------------
cohorts_tables <- bind_rows(
  tibble(
    opal_name = "genr",
    table = c(
      "lifecycle_1_0.1_0_genr_1_0_non_repeated",
      "lifecycle_1_0.1_0_genr_1_0_monthly_repeated")),
  tibble(
    opal_name = "gecko",
    table = c(
      "lc_gecko_core_2_1.2_1_core_1_1_non_rep",
      "lc_gecko_core_2_1.2_1_core_1_1_monthly_rep"))) %>%
  mutate(type = rep(c("nonrep", "monthrep"), 2))

## ---- Assign tables ----------------------------------------------------------
cohorts_tables %>%
  pwalk(function(opal_name, table, type){
    
    datashield.assign(
      opal = opals[opal_name], 
      symbol = type, 
      value = table, 
      variables = eval(parse(text = paste0(type, ".vars"))))
  })


## ---- Convert age_months to numeric ------------------------------------------

## We do this to avoid problems later when sorting the datasets
ds.asNumeric(
  x.name = "monthrep$age_months", 
  newobj = "age_n"
)

names(opals) %>%
  map(
    ~ds.dataFrame(
      x= c("monthrep", "age_n"), 
      newobj = "monthrep", 
      datasources = opals[.])
  )

## Check this
dh.classDescrepancy("monthrep")

################################################################################
# 2. Calculate BMI scores from monthly repeated measures data
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


## Check this
ds.summary("monthrep")

## Remove temporary object
ds.rm("bmi")

################################################################################
# 3. Create outcome variable (the long way)
################################################################################

## -------------------------------------------------------------------------- ##
## TEACHING PURPOSES ONLY - CODE NOT PART OF CREATING DS VARIABLES

# Here I'm making a supporting table with random values to illustrate how
# I'm creating the variables. This is because it is not possible to directly
# view data using DS so it can be hard to visualise what we're doing.

supporting_info <- tibble(
  child_id = c(1, 2, 2, 3, 4, 5, 5, 5, 6, 7),
  bmi = c(14, 14, 15, 18, 19, 13, 12, 14, 15, 12), 
  age_n = c(10, 20, 22, 90, 100, 25, 30, 110, 7, 45)) %>%
print()
## -------------------------------------------------------------------------- ##

## Use ds.Boole to create a vector (same length as "monthrep") indicating
## whether each subject has a value of "age_months_num" > 0. Repeat with < 60.
ds.Boole(
  V1 = "monthrep$age_n", 
  V2 = 20, 
  Boolean.operator = ">", 
  newobj = "bmi_20")

ds.Boole(
  V1 = "monthrep$age_n", 
  V2 = 60, 
  Boolean.operator = "<=", 
  newobj = "bmi_60")

## -------------------------------------------------------------------------- ##
## TEACHING PURPOSES ONLY - CODE NOT PART OF CREATING DS VARIABLES
supporting_info %<>%
  mutate(bmi_20 = ifelse(age_n > 20, 1, 0)) %>%
  print()

supporting_info %<>%
  mutate(bmi_60 = ifelse(age_n <= 60, 1, 0)) %>%
  print()

ds.summary("bmi_20")
ds.summary("bmi_60")

## -------------------------------------------------------------------------- ##

## Now multiply them together. This creates a new vector with a value of 1 if
## both conditions are met
ds.assign(
  toAssign = "bmi_20*bmi_60", 
  newobj = "bmi_20_60_a")

supporting_info %<>%
  mutate(bmi_20_60_a = bmi_20*bmi_60) %>%
  print()

## Now we want to subset to keep only those observations within this age band
ds.dataFrameSubset(
  df.name = "monthrep", 
  V1.name = "bmi_20_60_a", 
  V2.name = "1", 
  Boolean.operator = "==", 
  keep.NAs = TRUE, 
  newobj = "bmi_20_60_b")

## We can see that the subset contains fewer cases than the original
ds.summary("monthrep")
ds.summary("bmi_20_60_b")


## -------------------------------------------------------------------------- ##
## TEACHING PURPOSES ONLY - CODE NOT PART OF CREATING DS VARIABLES
bmi_20_60_b <- supporting_info %>%
  filter(bmi_20_60_a == 1) %>%
  print()
## -------------------------------------------------------------------------- ##


## Now we need to sort the dataset we've created. The reason for this will 
## become apparent shortly
names(opals) %>%
  map(
    ~ds.dataFrameSort(
    df.name = "bmi_20_60_b", 
    sort.key.name = "bmi_20_60_b$age_n", 
    sort.descending = FALSE, 
    newobj = "bmi_20_60_c", 
    datasources = opals[.])
  )


## -------------------------------------------------------------------------- ##
## TEACHING PURPOSES ONLY - CODE NOT PART OF CREATING DS VARIABLES
bmi_20_60_c <- bmi_20_60_b %>%
  arrange(age_n) %>%
  print()
## -------------------------------------------------------------------------- ##

  
## Now we need to create a variable indicating the age band. We use this
## variable below to get the correct name for the new outcome variable when
## we reshape from long to wide.
ds.assign(
  toAssign = "(bmi_20_60_c$age_months * 0)+60", 
  newobj = "age_cat") 


## We can see that we've made a vector the same length as "bmi_20_60_c" with
## all values of 60.
ds.summary("bmi_20_60_c")
ds.summary("age_cat")


## -------------------------------------------------------------------------- ##
## TEACHING PURPOSES ONLY - CODE NOT PART OF CREATING DS VARIABLES
bmi_20_60_c %<>%
  mutate(age_cat = 60) %>%
  print()

## -------------------------------------------------------------------------- ##

## Join this new variable back with the main dataframe
names(opals) %>%
  map(
    ~ds.dataFrame(
      x = c('bmi_20_60_c', 'age_cat'), 
      newobj = 'bmi_20_60_d',
      datasources = opals[.]
    )
  )

ds.summary("bmi_20_60_d")

## Now we convert our dataframe from long to wide format. A helpful feature of
## ds.reShape is that if there are multiple rows with the same id then all but
## the first is dropped. As we have sorted our dataframe in ascending order,
## this means if a subject has more than one observation within the timeframe
## then the earliest is taken.
ds.reShape(
  data.name = "bmi_20_60_d",
  timevar.name = "age_cat",
  idvar.name = "child_id",
  v.names = c("bmi", "age_months"), 
  direction = "wide", 
  newobj = "bmi_20_60_e")


## -------------------------------------------------------------------------- ##
## TEACHING PURPOSES ONLY - CODE NOT PART OF CREATING DS VARIABLES
bmi_20_60_wide <- bmi_20_60_c %>%
  group_by(child_id) %>%
  slice_head() %>%
  pivot_wider(
    id_cols = child_id,
    names_from = age_cat,
    values_from = c(bmi, age_n),
    names_sep = ".") %>%
print()
## -------------------------------------------------------------------------- ##

## Now join these variables with our non-repeated measures dataset
ds.merge(
  x.name = "nonrep",
  y.name = "bmi_20_60_e",
  by.x.names = "child_id",
  by.y.names = "child_id",
  all.x = TRUE,
  newobj = "analysis_df"
)

ds.summary("analysis_df")

## Have a look at the variables we've created
dh.getStats(df = "analysis_df", vars = c("bmi.60", "age_months.60"))

## "bmi.60" is bmi between age 0 -60
## "age_months.60" is child's at age bmi measurement. Checking this is a good 
## way to check whether derivation has worked as this value should be within
## your age bands.

ds.summary("analysis_df$age_months.60")

# Yes, we can see that the mean and the 5 - 95% centiles are within the 
# expected values.


################################################################################
# 4. We can also do this using a function I've written  
################################################################################
dh.makeOutcome(
  df = "monthrep", 
  outcome = "bmi", 
  age_var = "age_months", 
  bands = c(20, 60), 
  mult_action = "earliest")

ds.merge(
  x.name = "nonrep",
  y.name = "bmi_derived",
  by.x.names = "child_id",
  by.y.names = "child_id",
  all.x = TRUE,
  newobj = "analysis_df_2"
)

## Compare results
dh.getStats(df = "analysis_df", vars = c("bmi.60", "age_months.60"))
dh.getStats(df = "analysis_df_2", vars = c("bmi.60", "age.60"))

################################################################################
# 5. This is especially useful if we want to make multiple outcome variables  
################################################################################
dh.makeOutcome(
  df = "monthrep", 
  outcome = "bmi", 
  age_var = "age_months", 
  bands = c(20, 40, 60, 80, 90, 120), 
  mult_action = "earliest")

ds.merge(
  x.name = "nonrep",
  y.name = "bmi_derived",
  by.x.names = "child_id",
  by.y.names = "child_id",
  all.x = TRUE,
  newobj = "analysis_df_3"
)

dh.getStats(
  df = "analysis_df_3", 
  vars = c("bmi.40", "age.40", "bmi.80", "age.80", "bmi.120", "age.120")
)

ds.summary("analysis_df_3$age.120")

ds.summary("bmi_derived")

################################################################################
# 6. Longer explanation of how dh.makeOutcome works for multiple variables
################################################################################

## ---- Create table with age bands --------------------------------------------
bmi_cats <- tibble(
  varname = rep(c("bmi_0_24", "bmi_60_84", "bmi_144_168"), each = 2),
  value = c(0, 24, 60, 84, 144, 168),
  op = rep(c(">=", "<"), 3),
  new_df_name = paste0("bmi_", value)
)

bmi_cats


## ---- ds.Boole ---------------------------------------------------------------

# Use each row from this table in a call to ds.Boole. Here we make six vectors
# indicating whether or not the value meets the evaluation criteria
bmi_cats %>%
  pmap(function(value, op, new_df_name, ...){
    ds.Boole(
      V1 = "monthrep$age_n", 
      V2 = value, 
      Boolean.operator = op, 
      newobj = new_df_name)
  })


## ---- Create second table with assign conditions -----------------------------
assign_conditions <- bmi_cats %>%
  group_by(varname) %>%
  summarise(condition = paste(new_df_name, collapse="*")) 

## ---- Assign variables indicating membership of age band ---------------------

# Here we use the rows from the table "assign_conditions" in calls to ds.assign.
# This creates three vectors (0/1) indicating whether subject is within that
# age band
assign_conditions %>%
  pmap(function(condition, varname){
    ds.assign(
      toAssign = condition, 
      newobj = varname)
  })


## ---- Now we want to find out which cohorts have data ------------------------

# Once we start deriving multiple outcome variables for multiple cohorts, we'll
# find that not all cohorts have the available data. Here we make a table 
# indicating which cohorts have data for which of the outcomes we are going
# to derive. We then use this table to create the variables only in the cohorts
# for which the data exists.

data_available <- assign_conditions %>%
  pmap(function(varname, ...){ds.mean(varname)}) 

data_available <- map_dfr(
  data_available, ~.x$Mean.by.Study[, "EstimatedMean"]) %>%
  map_dfr(~ifelse(.x == 0, "no", "yes")) %>%
  mutate(varname = assign_conditions$varname) %>%
  select(varname, everything())

data_available

## ---- Create a new table listing which subsets to create ---------------------
bmi_to_subset <- data_available %>%
  pivot_longer(
    cols = -varname, 
    names_to = "cohort", 
    values_to = "available") %>%
  filter(available == "yes") %>%
  select(-available) %>%
  mutate(new_subset_name = paste0(varname, "_a"))

bmi_to_subset

## ---- Create subsets ---------------------------------------------------------
bmi_to_subset %>%
  pmap(
    function(varname, cohort, new_subset_name){
      ds.dataFrameSubset(
        df.name = "monthrep", 
        V1.name = varname, 
        V2.name = "1", 
        Boolean.operator = "==", 
        keep.NAs = FALSE, 
        newobj = new_subset_name, 
        datasources = opals[cohort])
    })

## ---- Sort subsets -----------------------------------------------------------
bmi_to_subset %>%
  pmap(function(cohort, new_subset_name, varname){
    
    ds.dataFrameSort(
      df.name = new_subset_name, 
      sort.key.name = paste0(new_subset_name, "$age_n"), 
      newobj = paste0(varname, "_b"), 
      sort.descending = TRUE, 
      datasources = opals[cohort])
    
  })

## Now we create variables indicating the age of subset
bmi_to_subset %<>%
  mutate(value = str_extract(varname, '[^_]+$'), 
         age_cat_name = paste0(varname, "_age"))

bmi_to_subset %>%
  pmap(
    function(cohort, new_subset_name, value, age_cat_name, ...){
      ds.assign(
        toAssign = paste0("(", new_subset_name, "$age_months * 0)+", value), 
        newobj = age_cat_name, 
        datasources = opals[cohort])
    })


## ---- Join age variables with subsets ----------------------------------------
bmi_to_subset %>%
  pmap(function(varname, cohort, age_cat_name, ...){
  
     ds.dataFrame(
      x = c(paste0(varname, "_b"), age_cat_name), 
      newobj = paste0(varname, "_c"),
      datasources = opals[cohort]
    )}
  )

## ---- Convert subsets to wide form -------------------------------------------
bmi_to_subset %>%
  pmap(
    function(cohort, varname, age_cat_name, ...){
      ds.reShape(
        data.name = paste0(varname, "_c"),
        timevar.name = age_cat_name,
        idvar.name = "child_id",
        v.names = c("bmi", "age_months"), 
        direction = "wide", 
        newobj = paste0(varname, "_wide"),
        datasources = opals[cohort])
    })

## ---- Merge back with non-repeated dataset -----------------------------------
made_vars <- bmi_to_subset %>%
  arrange(cohort) %>%
  group_by(cohort) %>%
  summarise(subs = paste(varname, collapse = ",")) %>%
  select(subs) %>%
  map(~strsplit(., ","))

finalvars <- made_vars$sub %>% map(~paste0(., "_wide"))

names(finalvars) <- sort(names(opals))

finalvars %>%
  imap(function(.x, .y){
    
    if(length(.x) == 1){
      
        ds.dataFrame(
        x = .x, 
        newobj = 'analysis_df',
        datasources = opals[.y])
      
    }
    
    if(length(.x) == 2){
      
      ds.merge(
        x.name = .x[[1]],
        y.name = .x[[2]],
        by.x.names = "child_id",
        by.y.names = "child_id",
        all.x = TRUE,
        newobj = "analysis_df", 
        datasources = opals[.y])
      
    }
    
    if(length(.x) >2){
      
      ds.merge(
        x.name = .x[[1]],
        y.name = .x[[2]],
        by.x.names = "child_id",
        by.y.names = "child_id",
        all.x = TRUE,
        newobj = "analysis_df", 
        datasources = opals[.y])
      
      remaining <- tibble(
        dfs = .x[3: length(.x)], 
        cohort = rep(.y, length(dfs)))
      
      remaining %>%
        pmap(function(dfs, cohort){
          ds.merge(
          x.name = "analysis_df",
          y.name = dfs,
          by.x.names = "child_id",
          by.y.names = "child_id",
          all.x = TRUE,
          newobj = "analysis_df", 
          datasources = opals[cohort])
        
    })
    
    }
    
  })


ds.summary("analysis_df")

################################################################################
# 5. Create multiple outcome variables the easiest way!  
################################################################################
dh.makeOutcome(
  df = "monthrep", 
  outcome = "bmi", 
  age_var = "age_months", 
  bands = c(0, 60), 
  mult_action = "earliest")

ds.summary("bmi_derived")

dh.getStats(df = "analysis_df", vars = c("bmi.60", "age_months.60"))
dh.getStats(df = "bmi_derived", vars = c("bmi.60", "age.60"))







