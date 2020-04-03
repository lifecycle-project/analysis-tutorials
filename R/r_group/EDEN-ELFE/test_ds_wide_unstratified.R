## Load the library:

library("dsBetaTestClient")

# SET UP SERVERS

server <- c("opal")
url <- c("https://opal.test.molgenis.org")
username <- c("administrator")
password <- c("?01LifeCycle!")
table <- c("MAXIME_TEST.workinggroup2")
logindata <- data.frame(server,url,username,password,table)


datashield.logout(opals)

#log in

opals <- datashield.login(logins=logindata,assign=TRUE)

# what is in the opal instances?

ds.ls()

# detail of table

ds.summary('D')

#### Variables description: ####

## Height between ]7 (84 month) and 8] (95 month):
# Here it is described by a serie of variables: height_84 at 84 months, etc.
# We want to create a summary table, rather than run the descriptive statistics
# once at a time:

# Create a table to store the results

height_table <- data.frame()

# Define the array of month on which we operate

array <- 84:95

for(i in array){
  
  # Get the "real" name of the variable from the array:
  
  test_var <- paste("height_", i, sep = "")
  
  # For each month, fetch the distribution summary:
  
  temp <- ds.summary(paste('D$', test_var, sep = ""))
  
  # Transform the results in an appropriate format:
  
  temp <- unlist(temp[[1]][3])
  
  temp  <- as.numeric(temp)
  
  # And stock it in the proper row/column of the table
  
  for (y in 1:8){
    
    height_table[which(array == i),y] <- temp[y]
    
  }
}

# Get legible column names:

colnames(height_table) <- c("5%", "10%", "25%", "50%", "75%", "90%", "95%", "mean")

# And legible rownames:

rownames(height_table) <- paste("height_", array, sep = "")


## Weight between ]7 (84 month) and 8] (95 month)

# Create a table to store the results

weight_table <- data.frame()

array <- 84:95

for(i in array){
  
  test_var <- paste("weight_", i, sep = "")
  
  temp <- ds.summary(paste('D$', test_var, sep = ""))
  
  temp <- unlist(temp[[1]][3])
  
  temp  <- as.numeric(temp)
  
  for (y in 1:8){
    
    weight_table[which(array == i),y] <- temp[y]
    
  }
}

colnames(weight_table) <- c("5%", "10%", "25%", "50%", "75%", "90%", "95%", "mean")
rownames(weight_table) <- paste("weight_", array, sep = "")

## Child's sex:

ds.table1D('D$sex')

## Maternal education at birth

ds.table1D('D$edu_m_0')

## smoke during pregnancy?

ds.table1D('D$preg_smk')

## Breastfeeding period:

ds.summary('D$breastfed_any')

#### BMI computation: ####

# Define an array ("for which month do we want the BMI?")

array <- 84:95

# Iterate on this array:

# The "simple", non looped function has this form:
# ds.make.o(toAssign = "D$weight_84 / ((D$height_84 / 100) ^2)", newobj = "BMI_84")

# We can automate it by iterating on the array:

for (i in array){
  
  # Define the name of the height, weight, and BMI variables
  
  var_height <- paste("height_", i, sep ="")
  
  var_weight <- paste("weight_", i, sep ="")
  
  var_BMI <- paste("BMI_", i, sep ="")
  
  # Compute the BMI at each age
  
  expr <- paste("D$", var_weight, " / ((D$", var_height, " / 100)^2)", sep ="")
  
  ds.make.o(toAssign = expr, newobj = var_BMI)
  
  # And assign the newly created BMI variable to the dataset
  
  ds.cbind(x=c(var_BMI, 'D'), newobj = 'D')
  
}

# Check the dataset:

ds.summary('D$BMI_84')

## And describe the new variables:

# Create a table to stock the results

BMI_table <- data.frame()

array <- 84:95

for(i in array){
  
  test_var <- paste("BMI_", i, sep = "")
  
  temp <- ds.summary(paste('D$', test_var, sep = ""))
  
  temp <- unlist(temp[[1]][3])
  
  temp  <- as.numeric(temp)
  
  for (y in 1:8){
    
    BMI_table[which(array == i),y] <- temp[y]
    
  }
}

colnames(BMI_table) <- c("5%", "10%", "25%", "50%", "75%", "90%", "95%", "mean")
rownames(BMI_table) <- paste("BMI_", array, sep = "")

#### Retrieve the overweight cutoffs per gender and age: ####

## Create a table to store the cutoffs:

cutoffs <- data.frame(c(17.88, 17.91, 17.95, 17.99, 18.04, 18.08, 18.12,18.17, 18.21, 18.26, 18.31, 18.36),
                      c(17.69, 17.73, 17.78, 17.82, 17.87, 17.91, 17.96,18.01, 18.07, 18.12, 18.17, 18.23))

colnames(cutoffs) <- c("boys", "girls")

rownames(cutoffs) <- c(84:95)

## Create an overweight variable from the data and the boy's cutoffs table:

array <- 84:95

for(i in array){
  
  # Define the variable to be loaded at each iteration of the loop:
  
  initial_var <- paste("D$BMI_", i, sep = "")
  
  dest_var <- paste("overweight_", i, sep ="")
  
  cutoffs_var <- as.character(cutoffs[as.character(i), "boys"])
  
  # Logical test: is the individual above or below the cuttof for his age?:
  
  ds.Boole.o(V1 = initial_var, V2 = cutoffs_var , Boolean.operator = '>=', newobj = dest_var)
  
  # Bind the newly created variable to the dataframe:
  
  ds.cbind(c(dest_var, 'D'), newobj = 'D')
  
}

###### Create the synthetic overweight variable:

##### Remove NA in the overweight variables or the vector summ won't compute:

array <- 84:95

# Put a check in place: avoid vectors which do not have enough people in a modality to pass
# the treshold (otherwise it brings down the whole loop):

avoid <- vector()

for(i in array){
  
  # The variables on which to iterate:
  
  var_name <- paste("overweight_", i, sep ="")
  
  # If it passes the check
  
  if(ds.class(paste("D$", var_name, sep = "")) != "NULL"){
    
    # Remove the NAs by putting 0s in their place
    
    ds.recodeValues.o(paste('D$', var_name, sep = ''), c(1,NA), c(1,0), var_name)
  } else {
    
    # Otherwise, if it doesn't pass the check, store the variable index for later use
    
    avoid <- c(avoid, i)
  }
}

## Alternative script:  transform in long format:

# vary <- list(paste("overweight_", array, sep = ""), 
#              paste("height_", array, sep = ""),
#              paste("weight_", array, sep = ""),
#              paste("BMI_", array, sep = ""))
# 
# var_names <- c("overweight", "height", 'weight', "BMI")

ds.summary('D')

vary <- paste("D$overweight_", array, sep = "")

var_names <- "D$overweight"

drop_var <- c(paste("D$height_", array, sep = ""), paste("D$weight_", array, sep = ""), paste("D$BMI_", array, sep = ""))

ds.reShape.o('D', varying = vary, direction = "long", newobj = 'D_long', timevar.name = "month", idvar.name = "cohort_id")

ds.tapply.o("D$birth_weight", "D$sex", "sum")
ds.tapply.o()
# And use tapply to mark if overweight for a specific age group:

ds.tapply.assign.o("D_long$overweight", "D_long$ID", FUN.name = "sum", newobj = "overweight_synth")

## Create a synthetic overweight variable:

# Define the array:

array_n <- 84:95
array_n <- array_n[!(array_n %in% avoid)]

array <- paste("overweight_", array_n, sep = "")

# Sum the overweight variable to obtain a synthetic overweight variable for each individual:

ds.vectorCalc(x=array, calc = '+', newobj = "overweight")
ds.Boole.o(V1 = "overweight", V2 = "0" , Boolean.operator = '>', newobj = "overweight_n")
ds.cbind(c('overweight_n', 'D'), newobj = 'D')

# Check the dataset:

ds.numNA('overweight_n')

ds.summary('overweight')

ds.summary('D$overweight_n')

#### Regression model: #####

## Check the datatypes:

ds.class("D$overweight_n")

ds.class("D$preg_smk")

ds.class("D$edu_m_0")

ds.class("D$breastfed_ever")

# Can't use any of the breastfed variables: too many NAs:

ds.numNA("D$breastfed_ever")
ds.numNA("D$breastfed_any")

## Correct the datatypes:

ds.asFactor('D$overweight_n', 'overweight_f')
ds.cbind(c('overweight_f', 'D'), 'D')

ds.asFactor.o('D$preg_smk', 'preg_smk_f')
ds.cbind(c('preg_smk_f', 'D'), 'D')

## Stratify on the child's sex:

# Boys:

ds.subset('D', 'D_boys', logicalOperator = 'sex==', threshold = '1')

# Girls:

ds.subset('D', 'D_girls', logicalOperator = 'sex==', threshold = '2')

# Check the dataset:

ds.ls()

## And run the SLMA model: (gives an error... datashield bug?)

## General

ds.glmSLMA.o("overweight_f ~ edu_m_0 + preg_smk", family = "binomial", dataName = "D")

## Stratified:

# Girls:

ds.glmSLMA.o("overweight_f ~ edu_m_0 + preg_smk", family = "binomial", dataName = "D_girls")

# Boys:

ds.glmSLMA.o("overweight_f ~ edu_m_0 + preg_smk", family = "binomial", dataName = "D_boys")

## Run a non-SLMA regression model:

# General:

ds.glm.o("D$overweight_f ~ D$edu_m_0 + D$preg_smk", family = "binomial")

# Boys:

ds.glm.o("D_boys$overweight_f ~ D_boys$edu_m_0 + D_boys$preg_smk", family = "binomial")

# Girls:

ds.glm.o("D_girls$overweight_f ~ D_girls$edu_m_0 + D_girls$preg_smk", family = "binomial")
