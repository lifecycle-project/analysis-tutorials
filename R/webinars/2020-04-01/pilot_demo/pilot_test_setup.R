install.packages(c('opal', 'opaladmin'), repos=c(getOption('repos'), 'http://cran.obiba.org'), dependencies=TRUE)
install.packages('dsBaseClient', repos=c(getOption('repos'), 'http://cran.datashield.org'), dependencies=TRUE)

library(opal)
library(dsBaseClient)

server <- c("gecko")
url <- c("https://datashield-lifecycle.dev.molgenis.org")
user <- c("administrator") 
password <- c("admin")
table <- c("test.v2_test_dictionary")
#table <- c("test.v2_test_dictionary")
logindata <- data.frame(server,url,user,password,table)
servers <- datashield.login(logins=logindata,assign=T)

# Do some statistical analysis, execute:
ds.mean('D$age')

# When you want to see the mean over different Opal instances, execute
ds.mean('D$age', type='split')

# When you are done, disconnect from DataSHIELD by executing:
datashield.logout(servers)

remove.packages(c('dsbase', 'dsmodelling', 'dsstats'))