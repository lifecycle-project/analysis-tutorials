# setup credential object
server <- c("dnbc")
url <- c("https://opal-dnbc.test.molgenis.org")
username <- c("administrator")
password <- c("admin")
table <- c("lifecycle_dnbc.1_0_non_repeated_measures", "lifecycle_dnbc.1_0_yearly_repeated_measures", "lifecycle_dnbc.1_0_monthly_repeated_measures")
logindata <- data.frame(server,url,username,password,table)
#logout just in case
datashield.logout(opals)
#log in
opals <- datashield.login(logins=logindata,assign=TRUE)
