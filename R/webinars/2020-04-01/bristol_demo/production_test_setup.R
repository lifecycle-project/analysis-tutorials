#Author: Angela
#Purpose: LifeCycle pet study
#Date: 10 March 2020
install.packages('opal', repo = 'http://cran.obiba.org', dependencies = T)
install.packages('dsBaseClient', repo = 'http://cran.datashield.org', dependencies = T)
install.packages('metafor')
install.packages('meta', repo = "http://cran.r-project.org")

library(metafor)
library(meta)
library(opal)
library(dsBaseClient)

server <- c("gecko")
url <- c("https://datashield-lifecycle.dev.molgenis.org")
user <- c("administrator")
password <- c("admin")
table <- c("lc_gecko_core_2_0.2_0_core_1_1_non_rep")
logindata <- data.frame(server, url, user, password,table)

### LOGIN TO OPAL SERVERS -------------------

datashield.logout(opals)
opals <- datashield.login(logins=logindata, assign=F)


### CREATE LIST OF NON REPEAT AND REPEAT VARIABLES --------

outcome_nonrep <- list ("child_id", "allergy_inh_m", "allergy_any_m", "asthma_ever_CHICOS",
                        "asthma_ever_MeDALL", "asthma_current_MeDALL", "asthma_current_ISAAC",
                        "anaphylaxis", "pets_preg") ## 9 variables

outcome_rep <- list ("child_id", "age_years", "asthma_", "asthma_med_", "asthma_med_spec_", "whe_", "FEV1_z_", "FVC_z_", "FEV1FVC_z_",
                     "repro_", "FeNO_", "inh_all_sens_SPT_", "inh_all_sens_IgE_HDM_", "inh_all_sens_IgE_CAT_",
                     "inh_all_sens_IgE_RYE_", "inh_all_sens_IgE_MOULD_")  ## 16 variables

core_nonrep <- list ("child_id", "mother_id", "cob_m", "ethn1_m", "ethn2_m",  "ethn3_m",  "eusilc_income_quintiles", "preg_smk",
                     "preg_cig", "agebirth_m_y", "sibling_pos","asthma_m", "asthma_bf", "sex",   "breastfed_excl",
                     "breastfed_any", "breastfed_ever", "mode_delivery", "birth_weight", "ga_bj", "ga_lmp",  "plurality",
                     "outcome", "cats_preg", "dogs_preg", "cats_quant_preg", "dogs_quant_preg" ) ## 26 variables

core_rep <- list ("child_id", "age_years", "edu_m_", "occupcode_m_", "famsize_child", "famsize_adult")  ## 6 variables


exposure_rep <- list ("child_id", "age_years", "pets_", "cats_", "dogs_", "cats_quant_", "dogs_quant_")  ## 7 variables


################### ASSIGN VARIABLES---------------------------------------------

#Gecko
#I do not have data on this one
datashield.assign(
  opals['gecko'], "outcome_nonrep",
  c("lc_gecko_outcome_1_0.1_0_outcome_1_0_non_rep"),
  variables=outcome_nonrep
)

datashield.assign(
  opals['gecko'], "outcome_rep",
  c("lc_gecko_outcome_1_0.1_0_outcome_1_0_yearly_rep"),
  variables=outcome_rep
)

datashield.assign(
  opals['gecko'], "core_nonrep",
  "lc_gecko_core_2_0.2_0_core_1_1_non_rep",
  variables=core_nonrep
)

datashield.assign(
  opals['gecko'], "core_rep",
  "lc_gecko_core_2_0.2_0_core_1_1_yearly_rep",
  variables=core_rep
)

datashield.assign(
  opals['gecko'], "exposure_rep",
  "lc_gecko_core_2_0.2_0_core_1_1_yearly_rep",
  variables=exposure_rep
)

###### Check all variables assigned correctly----------

ds.ls()

#check the variables are there  #### CAN WE PUT THIS IN A LOOP???? ###
all_vars1 = ds.summary('outcome_nonrep', opals)
all_vars2 = ds.summary('core_rep', opals)
all_vars3 = ds.summary("exposure_rep", datasources = opals)
all_vars4 = ds.summary("outcome_nonrep", datasources = opals)
all_vars5 = ds.summary("outcome_rep", datasources = opals)


all_vars1 = as.data.frame(lapply(X=all_vars1,FUN = function(x){
  temp = sort(x[[4]])
}))
all_vars2 = as.data.frame(lapply(X=all_vars2,FUN = function(x){
  temp = sort(x[[4]])
}))
all_vars3 = as.data.frame(lapply(X=all_vars3,FUN = function(x){
  temp = sort(x[[4]])
}))
all_vars4 = as.data.frame(lapply(X=all_vars4,FUN = function(x){
  temp = sort(x[[4]])
}))
all_vars5 = as.data.frame(lapply(X=all_vars5,FUN = function(x){
  temp = sort(x[[4]])
}))

################ Reshaping data ---------------------------------------------------

#1) Exposure data
ds.subset(x = 'exposure_rep', subset = 'pets', logicalOperator = 'age_years<=', threshold = 3) # limit to 0-<4years

ds.summary('pets', datasources = opals)

ds.reShape(
  data.name='pets',
  timevar.name = 'age_years',
  idvar.name = 'child_id',
  v.names=c("pets_", "cats_",  "dogs_", "dogs_quant_", "cats_quant_"),
  direction = 'wide',
  newobj = "pets_wide",
  datasources = opals
)

ds.summary('pets_wide', datasources = opals)


#2) Family size data
ds.subset(x='core_rep', subset = 'hhsize', cols = c('famsize_child', 'famsize_adult', 'child_id', 'age_years'), datasources = opals)
ds.subset(x = 'hhsize', subset = 'hhsize', logicalOperator = 'age_years<=', threshold = 2)

#Create a new variable which is the total family size (adults + children)
myvectors <- c('hhsize$famsize_child', 'hhsize$famsize_adult')
ds.vectorCalc(x=myvectors, calc='+', newobj = 'famsize')
ds.cbind(x=c('hhsize', 'famsize'), newobj = 'hhsize', datasources = opals)


ds.reShape(
  data.name='hhsize',
  timevar.name = 'age_years',
  idvar.name = 'child_id',
  v.names=c("famsize_child", "famsize_adult", "famsize"),
  direction = 'wide',
  newobj = "hhsize_wide",
  datasources = opals
)

ds.summary('hhsize_wide', datasources = opals)

# 3) Outcome data

ds.reShape(
  data.name='outcome_rep',
  timevar.name = 'age_years',
  idvar.name = 'child_id',
  v.names=c("asthma_", "asthma_med_", "asthma_med_spec_", "FeNO_", "FEV1FVC_z_", "FEV1_z_", "FVC_z_",
            "inh_all_sens_IgE_CAT_", "inh_all_sens_IgE_HDM_", "inh_all_sens_IgE_MOULD_",
            "inh_all_sens_IgE_RYE_", "inh_all_sens_SPT_", "repro_", "whe_"),
  direction = 'wide',
  newobj = "outcome_wide",
  datasources = opals
)


ds.summary('outcome_wide', datasources = opals)

#####Subset SES data ---------------------------------------------------

# keep only baseline data for maternal education and maternal occupational code covariates (age_years==0):
ds.subset(x='core_rep', subset = 'ses', cols = c('edu_m_', 'occupcode_m_', 'child_id', 'age_years'), datasources = opals)
ds.subset(x = 'ses', subset = 'ses', logicalOperator = 'age_years==', threshold = 0)
ds.table1D("ses$age_years", type='split', datasources = opals)
ds.summary('ses', datasources = opals)

### MERGE DATA FRAMES  -----------------------------

# NON-REPEATED EXPOSURE/COVARIATE DATA WITH NON-REPEATED OUTCOME DATA

ds.summary('core_nonrep', datasources = opals)
ds.summary('outcome_nonrep', datasources = opals)

ds.merge(
  x.name = 'core_nonrep',
  y.name = 'outcome_nonrep',
  by.x.names = 'child_id',
  by.y.names = 'child_id',
  newobj = 'D',
  datasources = opals
)

ds.summary('D', datasources = opals)
ds.summary('pets_wide', datasources = opals)


### WITH RESHAPED REPEATED EXPOSURE DATA ----------

ds.merge(
  x.name = 'pets_wide',
  y.name = 'D',
  by.x.names = 'child_id',
  by.y.names = 'child_id',
  newobj = 'D',
  datasources = opals
)

ds.summary("D", datasources = opals)

# WITH HHSIZE DATA

ds.merge(
  x.name = 'hhsize_wide',
  y.name = 'D',
  by.x.names = 'child_id',
  by.y.names = 'child_id',
  newobj = 'D',
  datasources = opals
)

ds.summary("D", datasources = opals)

# WITH SES DATA

ds.merge(
  x.name = 'ses',
  y.name = 'D',
  by.x.names = 'child_id',
  by.y.names = 'child_id',
  newobj = 'D',
  datasources = opals
)

ds.summary("D", datasources = opals)

# WITH REPEATED MEASURE OUTCOME DATA

ds.merge(
  x.name = 'outcome_wide',
  y.name = 'D',
  by.x.names = 'child_id',
  by.y.names = 'child_id',
  newobj = 'D',
  datasources = opals
)

ds.summary("D$asthma_ever_CHICOS", datasources = opals)
ds.summary("D$pets_preg", datasources = opals)

gecko = ds.glm(formula = 'asthma_ever_CHICOS~pets_preg', data = 'D', family = 'binomial', datasources = opals)

gecko

#Meta-analysis:
yi <- c(gecko$coefficients["pets_preg1","Estimate"],
        gecko$coefficients["pets_preg1","Estimate"])
sei <- c(gecko$coefficients["pets_preg1","Std. Error"],
         gecko$coefficients["pets_preg1","Std. Error"])
#Random effects model:
res <- rma(yi, sei=sei)
res
forest(res, xlab="OR", transf=exp, refline=1, slab=c("gecko"))


ds.summary("D", datasources = opals)
