## Install the necassary libraries

install.packages("devtools", "opaladmin")

# load the packages

library("opaladmin")

library("devtools")

# Install clientside package:

install_github("datashield/dsBetaTestClient", ref = "master", force = TRUE)

# setup credential object
server <- c("dnbc")
url <- c("https://opal-dnbc.test.molgenis.org")
username <- c("administrator")
password <- c("admin")
table <- c("lifecycle_dnbc.1_0_non_repeated_measures")
logindata <- data.frame(server,url,username,password,table)
#logout just in case
datashield.logout(opals)
#log in
opals <- datashield.login(logins=logindata,assign=TRUE)

# install serverside package
dsadmin.install_package(opals, 'dsBetaTest', githubusername='datashield', ref = 'master')

library("dsBetaTestClient")
