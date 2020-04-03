
### Ahmed DataSHIELD R script ------------------------------------------------------
rm(list=ls())

### LOAD REQUIRED PACKAGES --------------------
library(opal)
library(dsBaseClient)
library(dsStatsClient)
library(dsGraphicsClient)
library(dsModellingClient)
#install_github("datashield/dsBetaTestClient", ref = "master", force = TRUE)
library(dsBetaTestClient)
#install.packages("metafor")
library(metafor)
sessionInfo()


### CREATE DATAFRAMES WITH LOGIN CREDENTIALS --------------------

logindata_genr <- data.frame(
  server = c("lifecycle_genr"),
  url = c("https://cohort1-opal.test.molgenis.org"),
  user="administrator", 
  password="?LifeCycleCohort1!", 
  table = c(
    "lifecycle_genr.1_0_non_repeated_measures", 
    "lifecycle_genr.1_0_monthly_repeated_measures")
)

logindata_alsp <- data.frame(
  server = c("lifecycle_alspac"),
  url = c("https://cohort2-opal.test.molgenis.org"),
  user="administrator", 
  password="?LifeCycleCohort2!", 
  table = c(
    "lifecycle_alspac.1_0_non_repeated_measures", 
    "lifecycle_alspac.1_0_monthly_repeated_measures")
)


### LOGIN TO OPAL SERVERS -------------------

opals_genr <- datashield.login(
  logins=logindata_genr, 
  assign=FALSE
)

opals_alsp <- datashield.login(
  logins=logindata_alsp, 
  assign=FALSE
)

opals_genr
opals_alsp


### CREATE LIST OF NON REPEAT AND REPEAT VARIABLES --------

nonrep_vars <- list(
  "child_id", "sex", "coh_country", "preg_dia", 
  "agebirth_m_y", "preg_smk", "parity_m"
)

monthrep_vars <- list(
  "child_id", "age_years", "age_months", 
  "height_", "weight_", "height_age", "weight_age"
)


### ASSIGN NON REPEAT AND REPEAT VARIABLES IN EACH COHORT -------------

# NON REPEATS
datashield.assign(
  opals_genr, "nonreps", 
  c("lifecycle_genr.1_0_non_repeated_measures"), 
  variables=nonrep_vars
)

datashield.assign(
  opals_alsp, "nonreps", 
  c("lifecycle_alspac.1_0_non_repeated_measures"), 
  variables=nonrep_vars
)

#REPEATS
datashield.assign(
  opals_genr, "monthreps", 
  "lifecycle_genr.1_0_monthly_repeated_measures", 
  variables=monthrep_vars
)

datashield.assign(
  opals_alsp, "monthreps", 
  "lifecycle_alspac.1_0_monthly_repeated_measures", 
  variables=monthrep_vars
)

ds.summary('nonreps', datasources = c(opals_genr, opals_alsp))
ds.summary('monthreps', datasources = c(opals_genr, opals_alsp))


### CREATE BMI AND MERGE IT WITH REPEAT VARIABLES -----------

ds.assign(
  toAssign='monthreps$weight_/(((monthreps$height_/100))^2)', 
  newobj='BMI', 
  datasources = c(opals_genr, opals_alsp)
)

ds.cbind(
  x = c('BMI', 'monthreps'), 
  newobj = "monthrepsBMI", 
  datasources = c(opals_genr, opals_alsp)
)

ds.summary('monthrepsBMI', datasources = c(opals_genr, opals_alsp))
ds.summary('monthrepsBMI$BMI', datasources = c(opals_genr, opals_alsp))

### RESHAPE REPEATS DATA TO WIDE -------------

ds.reShape.o(
  data.name='monthrepsBMI',
  timevar.name = 'age_months',
  idvar.name = 'child_id',
  v.names=c('BMI', 'height_', 'weight_', 'height_age', 'weight_age'), 
  direction = 'wide', 
  newobj = "monthrepsBMI_wide",
  datasources = c(opals_genr, opals_alsp)
)

ds.summary('monthrepsBMI_wide', datasources = c(opals_genr, opals_alsp))


### MERGE THE NON REPEAT AND REPEAT DATA ----------

ds.merge.o(
  x.name = 'monthrepsBMI_wide', 
  y.name = 'nonreps', 
  by.x.names = 'child_id',
  by.y.names = 'child_id', 
  newobj = 'GD_BMI_data',
  datasources = c(opals_genr, opals_alsp)
)


### CHECK DATA / DESCRIPTIVE ANALYSIS ----------

## N ROWS / COLUMNS, COL NAMES, DATASET CLASS --
ds.summary('GD_BMI_data', datasources = c(opals_genr, opals_alsp))
# GENR: BMI.12 BMI.36 BMI.48 BMI.60 
# ALSP: BMI.24 BMI.36 BMI.48 BMI.72


## MISSING GD AND BMI ---
ds.numNA(x='GD_BMI_data$preg_dia', c(opals_genr, opals_alsp))
ds.numNA(x='GD_BMI_data$BMI.12', datasources = c(opals_genr))
ds.numNA(x='GD_BMI_data$BMI.24', datasources = c(opals_alsp))
ds.numNA(x='GD_BMI_data$BMI.36', datasources = c(opals_genr, opals_alsp))
ds.numNA(x='GD_BMI_data$BMI.48', datasources = c(opals_genr, opals_alsp))
ds.numNA(x='GD_BMI_data$BMI.60', datasources = c(opals_genr))
ds.numNA(x='GD_BMI_data$BMI.72', datasources = c(opals_alsp))


## 1D TABS OF CATEGORICAL DATA ---
SEX_tab <- ds.table1D(
  x='GD_BMI_data$sex', 
  type = "split", 
  datasources = c(opals_genr, opals_alsp)
) 
SEX_tab


GD_tab <- ds.table1D(
  x='GD_BMI_data$preg_dia', 
  type = "split", 
  datasources = c(opals_genr, opals_alsp)
)
GD_tab


SMK_tab <- ds.table1D(
  x='GD_BMI_data$preg_smk', 
  type = "split", 
  datasources = c(opals_genr, opals_alsp)
)
SMK_tab


## TAB GD BY SEX COMBINED / BY COHORT ---
GD_sex <- ds.table2D(
  x='GD_BMI_data$preg_dia', 
  y='GD_BMI_data$sex', 
  type='combine', 
  # type='split', 
  datasources = c(opals_genr, opals_alsp)
)
GD_sex


## N AND MEAN BMI AT EACH AGE ---
#ds.summary(x='GD_BMI_data$BMI.12', datasources = c(opals_genr))
ds.mean(x='GD_BMI_data$BMI.12', datasources = c(opals_genr))
ds.mean(x='GD_BMI_data$BMI.24', datasources = c(opals_alsp))
ds.mean(x='GD_BMI_data$BMI.36', type='split', datasources = c(opals_genr, opals_alsp))
ds.mean(x='GD_BMI_data$BMI.48', type='split', datasources = c(opals_genr, opals_alsp))
ds.mean(x='GD_BMI_data$BMI.60', datasources = c(opals_genr))
ds.mean(x='GD_BMI_data$BMI.72', datasources = c(opals_alsp))


## MEAN BMI BY SEX ---
BMI36_sex <- ds.meanByClass(
  x='GD_BMI_data$BMI.36~GD_BMI_data$sex', 
  type = "split", 
  datasources = c(opals_genr, opals_alsp)
)
BMI36_sex


### CREATE COMPLETE CASE ANAYSIS DATAFRAME ----

myvectors <- c(
  'GD_BMI_data$preg_dia', 'GD_BMI_data$BMI.36', 
  'GD_BMI_data$height_age.36', 'GD_BMI_data$sex', 'GD_BMI_data$preg_smk')

ds.dataframe(
  x = myvectors, 
  newobj = 'GD_BMI36_cca', 
  completeCases = T, 
  datasources = c(opals_genr, opals_alsp)
)

ds.summary('GD_BMI36_cca', datasources = c(opals_genr, opals_alsp))
ds.summary('GD_BMI36_cca$sex', datasources = c(opals_genr, opals_alsp))
ds.summary('GD_BMI36_cca$preg_dia', datasources = c(opals_genr, opals_alsp))
ds.summary('GD_BMI36_cca$preg_smk', datasources = c(opals_genr, opals_alsp))
ds.summary('GD_BMI36_cca$BMI.36', datasources = c(opals_genr, opals_alsp))
ds.summary('GD_BMI36_cca$height_age.36', datasources = c(opals_genr, opals_alsp))


### Fit STANDARD LINEAR REGRESSION MODEL -------------

# BMI AGE 36 ON GD BY COHORT, ADJ FOR AGE AND SEX --
bmi36_gd_alsp <- ds.glm(
  formula='GD_BMI36_cca$BMI.36 ~ GD_BMI36_cca$preg_dia + GD_BMI36_cca$height_age.36 + GD_BMI36_cca$sex + GD_BMI36_cca$preg_smk', 
  datasources = c(opals_alsp), 
  family='gaussian'
)

bmi36_gd_genr <- ds.glm(
  formula='GD_BMI36_cca$BMI.36 ~ GD_BMI36_cca$preg_dia + GD_BMI36_cca$height_age.36 + GD_BMI36_cca$sex + GD_BMI36_cca$preg_smk', 
  datasources = c(opals_genr), 
  family='gaussian'
)

### META-ANALYSIS OUTSIDE DataSHIELD WITH METAFOR ---

betas = c(bmi36_gd_alsp$coefficients["preg_dia1", "Estimate"], 
          bmi36_gd_genr$coefficients["preg_dia1", "Estimate"])

seis = c(bmi36_gd_alsp$coefficients["preg_dia1", "Std. Error"],
         bmi36_gd_alsp$coefficients["preg_dia1", "Std. Error"])

# RANDOM-EFFECTS META-ANALYSIS ----
bmi36_gd_ma <- rma (betas, sei=seis)

bmi36_gd_ma

### FORREST PLOT ------
par(mfrow=c(1,1))
forest(bmi36_gd_ma, slab=c("ALSPAC", "Generation R"))
dev.off()

### LOGOUT ------------
datashield.logout(opals_alsp)
datashield.logout(opals_genr)
