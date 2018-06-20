# Server-ids (can be random names)
server <- c("test-opal1","test-opal2") 
# These IP addresses change	
url <- c("https://opal1.domain.org", "https://opal2.domain.org")
# Federal analysis user
user <- c("usr1", "usr2") 
# Should be certificate but for demo purposes we use a password
password <- c("pw1", "pw2")
# The data tables uses in the tutorial
# The syntax is c(“#ProjectName#”, “#TableName#”)
table <- c("Tutorials.tutorial_beginner", "Tutorials.tutorial_beginner") 
# Object for logindata
logindata <- data.frame(server,url,user,password,table)
opals <- datashield.login(logins=logindata,assign=TRUE)

# Do some statistical analysis, execute:
ds.mean('D$age')

# When you want to see the mean over different Opal instances, execute
ds.mean('D$age', type='split')

# When you are done, disconnect from DataSHIELD by executing:
datashield.logout(opals)
