#Practical Experiment 4 - DataSHIELD Working Group - September 2018


#LOAD PACKAGES:
library(opal)
library(dsBaseClient)
library(dsStatsClient)
library(dsGraphicsClient)
library(dsModellingClient)
library(datashieldclient)
library(metafor)
# This commented by Theodosia
#LOGIN DATA
server <- c("ninfea", "dnbc", "elfe")
url <- c("ninfea", "dnbc", "elfe")
username <- c("user1", "user3", "user2")
password <- c("pass1", "pass3", "pass2")
table <- c("PracticalExperiment4.practicalexperiment4", "SIDOTEST.practicalexperiment4", "LifecyclePE.practicalexperiment4")

logindata <- data.frame(server, url, username, password, table)
opal <- datashield.login(logins=logindata, assign=T)

##########################
#IDENTIFY OBJECTS
ds.ls()
ds.ls()$ninfea

#Dimension of the objects
ds.dim("D")
ds.dim("D")$dnbc
ds.dim("D", type="combine") #pooled dimension

#########################
#DATA SUMMARY
ds.summary("D")
ds.summary("D")$dnbc

#########################
#EXCLUSIONS
#Possibile also for single cohorts by specifying datasources=opal["cohort name"]

#Only livebirths
ds.subset(x="D", subset="data", logicalOperator='outcome==', threshold=1)
ds.dim("data")

#Only singletons (to avoid creating several datasets, "x" and "subset" are the same and the starting dataset overwritten)
ds.subset(x="data", subset="data", logicalOperator='plurality==', threshold=1)
ds.dim("data")

#Only mothers >=18 & <45 years old
#Is it possibile to use more logical operators for selecting data in a single command?
ds.subset(x="data", subset="data", logicalOperator='agebirth_m_y>=', threshold=18)
ds.subset(x="data", subset="data", logicalOperator='agebirth_m_y<', threshold=45)
ds.dim("data")

#Only children with gestational age >=28 weeks
#NOTE: ga_bj in days (28weeks*7=196 days)

ds.subset(x="data", subset="data", logicalOperator='ga_bj>=', threshold=196)
ds.dim("data")

ds.dim("D", type="combine") #starting pooled dimension 112117
ds.dim("data", type="combine") #final pooled dimension 100863

######################
#DATA INSPECTION
#Cohorts included
ds.table1D("data$cohort_id")

#Sex
ds.table1D("data$sex") #summary over all servers
ds.table1D("data$sex", type="split") #summary for each cohort

#Alternatively
temp=ds.summary("data$sex")
num_studies=length(temp)
study_names=names(temp)
rm(temp)
summary_sex_temp <- ds.summary("data$sex")
summary_sex <- data.frame(matrix(unlist(summary_sex_temp), nrow = num_studies, ncol=6, byrow=TRUE))
rownames(summary_sex) <- study_names
colnames(summary_sex) <- c("type", "N", "male", "female", "count1", "count2")
summary_sex$freqM=as.numeric(as.character(summary_sex$count1))/as.numeric(as.character(summary_sex$N))
summary_sex$freqF=as.numeric(as.character(summary_sex$count2))/as.numeric(as.character(summary_sex$N))

rm(summary_sex_temp)
rm(summary_sex)

#Exposure variables summary
ds.table1D("data$preg_alc") #summary over all servers (54.82% exposed)
ds.table1D("data$preg_alc", type="split") #ninfea (18.1% exposed); dnbc (56.8%); elfe (89.7%)

ds.table1D("data$preg_alc_unit") #summary over all servers
ds.table1D("data$preg_alc_unit", type="split") 

#cross-tabulate
ds.table2D("data$preg_alc", "data$preg_alc_unit")
ds.table2D("data$preg_alc", "data$preg_alc_unit", type="split")

#Outcome summary
ds.table1D("data$weight_who_ga") #summary over all servers (SGA 3.11%)
ds.table1D("data$weight_who_ga", type="split") #ninfea (6.5%); dnbc (2.9%); elfe (1.4%)

#Cross-tabulation exposure-outcome
ds.table2D("data$weight_who_ga", "data$preg_alc")
ds.table2D("data$weight_who_ga", "data$preg_alc", type="split") 
#All SGA children from Elfe are exposed

#Birth weight summary
#ensure all cohorts uploaded the correct variable format
#NB: the functions do not work if variable format differs in any of the cohorts!
ds.class("data$birth_weight")


#Potentially disclosive information such as the minimum and maximum values of numeric vectors are not returned. 
ds.summary("data$birth_weight") #for each cohort

ds.mean ("data$birth_weight") #pooled mean
ds.mean ("data$birth_weight", type="split")

ds.var("data$birth_weight")
ds.var("data$birth_weight", type="split")

ds.quantileMean("data$birth_weight") #pooled
ds.quantileMean("data$birth_weight", type="split") #the same information as in ds.summary

#Alternatively
mean_bw <- data.frame(matrix(unlist(ds.mean("data$birth_weight", type = 'split')), nrow = num_studies, ncol = 1, byrow=TRUE))
var_bw <- data.frame(matrix(unlist(datashield.aggregate(opal, as.symbol("varDS(data$birth_weight)"))), nrow = num_studies, ncol = 1, byrow=TRUE))
summary_bw <- cbind(mean_bw,sqrt(var_bw))
rownames(summary_bw) <- study_names
colnames(summary_bw) <- c("mean", "sd")
rm(mean_bw, var_bw)
summary_bw 

#Covariates
ds.quantileMean("data$agebirth_m_y", type="split") 

ds.class("data$edu_m_0")
ds.table1D("data$edu_m_0")
ds.table1D("data$edu_m_0", type="split") #different baseline maternal educational level between cohorts

ds.class("data$parity_m")
ds.table1D("data$parity_m", type="split") 
#WARNING: Invalid table(s) from 'ninfea' ! Only total values are returned in the output table(s).
#Few subjects in the last category of NINFEA and no subjects in the first category in ELFE.
#As parity is considered as a confounding factor and we are not interested in its particular estimates we
#should consider changing its reference category

ds.class("data$ethn1_m")
ds.table1D("data$ethn1_m", type="split") 
#NINFEA and DNBC do not have data on maternal ethnicity based on grandparents country of birth.
#Consider excluding this variable from the multivariable models.

ds.class("data$preg_smk")
ds.table1D("data$preg_smk", type="split") 


#Data visualisation
#histogram outliers are not shown as these are potentially disclosive
ds.histogram("data$birth_weight")
ds.histogram("data$birth_weight", type="split")

#Warning: ninfea: 314 invalid cells
#Warning: dnbc: 1359 invalid cells
#Warning: elfe: 154 invalid cells

#Contour plots - to visualize a correlation pattern
ds.contourPlot("data$ga_bj", "data$birth_weight")
ds.contourPlot("data$ga_bj", "data$birth_weight", type="split",show="zoomed")

#Heatmap plots
ds.heatmapPlot("data$birth_weight", "data$ga_bj")
ds.heatmapPlot("data$birth_weight", "data$ga_bj", type="split")


############################
#DATA MANAGEMENT
#1) Create variable small for gestational age
ds.table1D("data$weight_who_ga")

ds.recodeLevels('data$weight_who_ga', newCategories=c("1", "0", "0"), newobj='weight_who_ga1')
ds.levels("weight_who_ga1")

ds.changeRefGroup(x='weight_who_ga1', ref='0', newobj='weight_who_ga1', reorderByRef = FALSE)
#NB: keep always reorderByRef = FALSE (set as a default). 
#Otherwise it might assign wrong values when merged with the original dataset

ds.levels("weight_who_ga1")
ds.length ("weight_who_ga1")
ds.length ("data$weight_who_ga")

ds.cbind(x=c("data", "weight_who_ga1"), newobj="data1", datasources=opal)
ds.table1D("data1$weight_who_ga1")

#2) Create a new variable for the preg_alc_unit by combining the last two categories
ds.table1D("data1$preg_alc_unit")
ds.table1D("data1$preg_alc_unit", type="split")

ds.recodeLevels('data1$preg_alc_unit', newCategories=c("0", "1", "2", "2"), newobj='preg_alc_unit_new')
ds.levels("preg_alc_unit_new")
ds.cbind(x=c("data1", "preg_alc_unit_new"), newobj="data1", datasources=opal)
ds.levels("data1$preg_alc_unit_new")
ds.table1D("data1$preg_alc_unit_new")

#3) Maternal pre-pregnancy BMI
ds.summary("data1$prepreg_weight")
ds.summary("data1$height_m")

ds.assign(toAssign="data1$prepreg_weight/((data1$height_m*0.01)^2)", newobj="BMI_m", datasources=opal)
ds.summary("BMI_m")
ds.cbind(x=c("data1", "BMI_m"), newobj="data1", datasources=opal)
ds.summary("data1$BMI_m")

#4) Change reference category for parity (1 becomes reference category)
ds.changeRefGroup(x='data1$parity_m', ref='1', newobj='parity_m_new', reorderByRef = FALSE)
ds.levels("parity_m_new")
ds.length ("parity_m_new")
ds.length ("data1$parity_m")

ds.cbind(x=c("data1", "parity_m_new"), newobj="data1", datasources=opal)
ds.table1D("data1$parity_m_new", type="split") 


#########################
#Check the mean birth weight between children exposed and not exposed to maternal alcohol use during pregnancy

ds.meanByClass("data1$birth_weight~data1$preg_alc")
ds.meanByClass("data1$birth_weight~data1$preg_alc", type="split")

#It seems there is no large difference in birth weight between the two groups (~42 gramms)
ds.meanByClass("data1$birth_weight~data1$preg_alc_unit_new")
ds.meanByClass("data1$birth_weight~data1$preg_alc_unit_new", type="split")

#Check Datashield workshop from Oulu for the code to calculate 95%CI 

#Chi-squared test for SGA and preg_alc
ds.table2D("data1$weight_who_ga1", "data1$preg_alc")
ds.table2D("data1$weight_who_ga1", "data1$preg_alc_unit_new")

#################################
#REGRESSION ANALYSES

#UNIVARIATE MODEL FOR EACH COHORT
ds.class("data1$preg_alc_unit_new")

model1_ninfea=ds.glm(formula="data1$birth_weight~data1$preg_alc", data="data1", family="gaussian", datasources=opal["ninfea"])
model2_ninfea=ds.glm(formula="data1$birth_weight~data1$preg_alc_unit_new", data="data1", family="gaussian", datasources=opal["ninfea"])

model1_dnbc=ds.glm(formula="data1$birth_weight~data1$preg_alc", data="data1", family="gaussian", datasources=opal["dnbc"])
model2_dnbc=ds.glm(formula="data1$birth_weight~data1$preg_alc_unit_new", data="data1", family="gaussian", datasources=opal["dnbc"])

model1_elfe=ds.glm(formula="data1$birth_weight~data1$preg_alc", data="data1", family="gaussian", datasources=opal["elfe"])
model2_elfe=ds.glm(formula="data1$birth_weight~data1$preg_alc_unit_new", data="data1", family="gaussian", datasources=opal["elfe"])

#MULTIVARIATE MODELS FOR EACH COHORT
ds.class("data1$edu_m_0")
ds.class("data1$parity_m")

model3_ninfea=ds.glm(formula="data1$birth_weight~data1$preg_alc + data1$agebirth_m_y + data1$edu_m_0 + data1$parity_m_new + data1$BMI_m + data1$preg_smk", data="data1", family="gaussian", datasources=opal["ninfea"])
model4_ninfea=ds.glm(formula="data1$birth_weight~data1$preg_alc_unit_new + data1$agebirth_m_y + data1$edu_m_0 + data1$parity_m + data1$BMI_m + data1$preg_smk", data="data1", family="gaussian", datasources=opal["ninfea"])

model3_dnbc=ds.glm(formula="data1$birth_weight~data1$preg_alc + data1$agebirth_m_y + data1$edu_m_0 + data1$parity_m_new + data1$BMI_m + data1$preg_smk", data="data1", family="gaussian", datasources=opal["dnbc"])
model4_dnbc=ds.glm(formula="data1$birth_weight~data1$preg_alc_unit_new + data1$agebirth_m_y + data1$edu_m_0 + data1$parity_m + data1$BMI_m + data1$preg_smk", data="data1", family="gaussian", datasources=opal["dnbc"])

model3_elfe=ds.glm(formula="data1$birth_weight~data1$preg_alc + data1$agebirth_m_y + data1$edu_m_0 + data1$parity_m_new + data1$BMI_m + data1$preg_smk", data="data1", family="gaussian", datasources=opal["elfe"])
model4_elfe=ds.glm(formula="data1$birth_weight~data1$preg_alc_unit_new + data1$agebirth_m_y + data1$edu_m_0 + data1$parity_m + data1$BMI_m + data1$preg_smk", data="data1", family="gaussian", datasources=opal["elfe"])

model3_ninfea
model3_ninfea$coefficients

#Create a new vector with coefficients from the stored models
yi=c(model3_ninfea$coefficients["preg_alc1", "Estimate"], 
     model3_dnbc$coefficients["preg_alc1", "Estimate"], 
     model3_elfe$coefficients["preg_alc1", "Estimate"])

yi

#Create a new vector with standard errors from the stored models
sei=c(model3_ninfea$coefficients["preg_alc1", "Std. Error"],
      model3_dnbc$coefficients["preg_alc1", "Std. Error"], 
      model3_elfe$coefficients["preg_alc1", "Std. Error"])

sei

#Random effects model
result1 <- rma (yi, sei=sei)
result1

forest(result1)

###################
#Stratified by sex
ds.subset(x="data1", subset="data1M", logicalOperator='sex==', threshold=1)
ds.subset(x="data1", subset="data1F", logicalOperator='sex==', threshold=2)

model3_ninfeaM=ds.glm(formula="data1M$birth_weight~data1M$preg_alc + data1M$agebirth_m_y + data1M$edu_m_0 + data1M$parity_m_new + data1M$BMI_m + data1M$preg_smk", data="data1M", family="gaussian", datasources=opal["ninfea"])
model3_ninfeaF=ds.glm(formula="data1F$birth_weight~data1F$preg_alc + data1F$agebirth_m_y + data1F$edu_m_0 + data1F$parity_m_new + data1F$BMI_m + data1F$preg_smk", data="data1F", family="gaussian", datasources=opal["ninfea"])

model3_dnbcM=ds.glm(formula="data1M$birth_weight~data1M$preg_alc + data1M$agebirth_m_y + data1M$edu_m_0 + data1M$parity_m_new + data1M$BMI_m + data1M$preg_smk", data="data1M", family="gaussian", datasources=opal["dnbc"])
model3_dnbcF=ds.glm(formula="data1F$birth_weight~data1F$preg_alc + data1F$agebirth_m_y + data1F$edu_m_0 + data1F$parity_m_new + data1F$BMI_m + data1F$preg_smk", data="data1F", family="gaussian", datasources=opal["dnbc"])

model3_elfeM=ds.glm(formula="data1M$birth_weight~data1M$preg_alc + data1M$agebirth_m_y + data1M$edu_m_0 + data1M$parity_m_new + data1M$BMI_m + data1M$preg_smk", data="data1M", family="gaussian", datasources=opal["elfe"])
model3_elfeF=ds.glm(formula="data1F$birth_weight~data1F$preg_alc + data1F$agebirth_m_y + data1F$edu_m_0 + data1F$parity_m_new + data1F$BMI_m + data1F$preg_smk", data="data1F", family="gaussian", datasources=opal["elfe"])

yiM=c(model3_ninfeaM$coefficients["preg_alc1", "Estimate"], 
     model3_dnbcM$coefficients["preg_alc1", "Estimate"], 
     model3_elfeM$coefficients["preg_alc1", "Estimate"])


yiF=c(model3_ninfeaF$coefficients["preg_alc1", "Estimate"], 
     model3_dnbcF$coefficients["preg_alc1", "Estimate"], 
     model3_elfeF$coefficients["preg_alc1", "Estimate"])

seiM=c(model3_ninfeaM$coefficients["preg_alc1", "Std. Error"],
      model3_dnbcM$coefficients["preg_alc1", "Std. Error"], 
      model3_elfeM$coefficients["preg_alc1", "Std. Error"])

seiF=c(model3_ninfeaF$coefficients["preg_alc1", "Std. Error"],
       model3_dnbcF$coefficients["preg_alc1", "Std. Error"], 
       model3_elfeF$coefficients["preg_alc1", "Std. Error"])


#Random effects model
result1M <- rma (yiM, sei=seiM)
result1F <- rma (yiF, sei=seiF)
result1M
result1F

par(mfrow=c(1,2))
forest(result1M, slab=c("NINFEA", "DNBC", "ELFE"))
forest(result1F, slab=c("NINFEA", "DNBC", "ELFE"))
dev.off()


##Subset plot
forest(result1,slab=c("NINFEA", "DNBC", "ELFE"))
forest(result1,order=(result1$ids=c(1,2)), slab=c("NINFEA", "DNBC", "ELFE"))

#Exclude one-by-one
result1.1 <- rma (yi, sei=sei, subset=c(1,2))
result1.1
result1

forest(result1.1, slab=c("NINFEA", "DNBC"))

       
result1.2 <- rma (yi, sei=sei, subset=c(1,3))
result1.2
result1
       
forest(result1.2, slab=c("NINFEA", "ELFE"))
              

#################################
#REGRESSION ANALYSES - SGA

model5_ninfea=ds.glm(formula="data1$weight_who_ga1~data1$preg_alc", data="data1", family="binomial", datasources=opal["ninfea"])
model6_ninfea=ds.glm(formula="data1$weight_who_ga1~data1$preg_alc_unit_new", data="data1",family="binomial", datasources=opal["ninfea"])

model5_dnbc=ds.glm(formula="data1$weight_who_ga1~data1$preg_alc", data="data1", family="binomial", datasources=opal["dnbc"])
model6_dnbc=ds.glm(formula="data1$weight_who_ga1~data1$preg_alc_unit_new", data="data1", family="binomial", datasources=opal["dnbc"])

model5_elfe=ds.glm(formula="data1$weight_who_ga1~data1$preg_alc", data="data1", family="binomial", datasources=opal["elfe"])
model6_elfe=ds.glm(formula="data1$weight_who_ga1~data1$preg_alc_unit_new", data="data1", family="binomial", datasources=opal["elfe"])

model5_ninfea
model5_ninfea$coefficients

#MULTIVARIATE MODELS SGA
model7_ninfea=ds.glm(formula="data1$weight_who_ga1~data1$preg_alc + data1$agebirth_m_y + data1$edu_m_0 + data1$parity_m_new + data1$BMI_m + data1$preg_smk", data="data1", family="binomial", datasources=opal["ninfea"])
model8_ninfea=ds.glm(formula="data1$weight_who_ga1~data1$preg_alc_unit_new + data1$agebirth_m_y + data1$edu_m_0 + data1$parity_m_new + data1$BMI_m + data1$preg_smk", data="data1", family="binomial", datasources=opal["ninfea"])

model7_dnbc=ds.glm(formula="data1$weight_who_ga1~data1$preg_alc + data1$agebirth_m_y + data1$edu_m_0 + data1$parity_m_new + data1$BMI_m + data1$preg_smk", data="data1", family="binomial", datasources=opal["dnbc"])
model8_dnbc=ds.glm(formula="data1$weight_who_ga1~data1$preg_alc_unit_new + data1$agebirth_m_y + data1$edu_m_0 + data1$parity_m_new + data1$BMI_m + data1$preg_smk", data="data1", family="binomial", datasources=opal["dnbc"])

model7_elfe=ds.glm(formula="data1$weight_who_ga1~data1$preg_alc + data1$agebirth_m_y + data1$edu_m_0 + data1$parity_m_new + data1$BMI_m + data1$preg_smk", data="data1", family="binomial", datasources=opal["elfe"])
model8_elfe=ds.glm(formula="data1$weight_who_ga1~data1$preg_alc_unit_new + data1$agebirth_m_y + data1$edu_m_0 + data1$parity_m_new + data1$BMI_m + data1$preg_smk", data="data1", family="binomial", datasources=opal["elfe"])
# Did not converge after 15 iterations

ds.table2D("data1$weight_who_ga1", "data1$preg_alc_unit_new", type="split") 
#All SGA children from Elfe are exposed
ds.table2D("data1$weight_who_ga1", "data1$preg_alc", type="split") 



#Include only NINFEA and DNBC
yi2=c(model7_ninfea$coefficients["preg_alc1", "Estimate"], 
     model7_dnbc$coefficients["preg_alc1", "Estimate"])

sei2=c(model7_ninfea$coefficients["preg_alc1", "Std. Error"],
      model7_dnbc$coefficients["preg_alc1", "Std. Error"])

#Random effects model
result2 <- rma (yi2, sei=sei2)
result2

forest(result2, slab=c("NINFEA", "DNBC"), transf=exp)


datashield.logout(opal)


#New changes


