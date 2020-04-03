library(dsBaseClient)
library(opaladmin)
library(opal)
# Server-ids (can be random names)
server <- c("opal-dev") 
# These IP addresses change	
url <- c("https://cohort1-opal.test.molgenis.org")
# Federal analysis user
user <- c("administrator") 
# Should be certificate but for demo purposes we use a password
password <- c("?LifeCycleCohort1!")
# The data tables uses in the tutorial
# The syntax is c(“#ProjectName#”, “#TableName#”)
table <- c("lc_core_gecko_2_0.2_0_core_gecko_1_0_trimester_rep") 
# Object for logindata
logindata <- data.frame(server,url,user,password,table)
opals <- datashield.login(logins=logindata,assign=F)

# Do some statistical analysis, execute:
ds.mean('D$age')

# When you want to see the mean over different Opal instances, execute
ds.mean('D$age', type='split')

# When you are done, disconnect from DataSHIELD by executing:
datashield.logout(opals)
