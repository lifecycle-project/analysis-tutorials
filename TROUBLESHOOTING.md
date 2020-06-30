# Troubleshooting Opal and DataSHIELD
There are two main areas of interest in this troubleshooting guide:
- Opal management
- R and DataSHIELD developement

## Opal management
Issues concerning data import and export in Opal

### Importing data

- **Source data does not except “≥”**

  If you have a value label with sign “≥”, Opal will not upload (error “File contains invalid characters at row '910'.   Please make sure the file is a valid SPSS file and that you have chosen the correct character set.”)

  If you change this to “=>”,  problem solved

- **Opal version 2.10.4 not usable in IE**

  You can not upload data in Opal Version 2.10.4. You can upgrade Opal to 2.10.9 or try another browser, for example Firefox.

## R and DataSHIELD development

### Install older versions of clientside DataSHIELD functions

Please use the following code to install DataSHIELD 5.1.0 clientside functions.

```R
remove.packages("DSOpal")
remove.packages("dsBaseClient")

install.packages("dplyr")
install.packages("purr")

library(dplyr)
library(purr)

packages <- bind_rows(
  tibble(url = "https://github.com/obiba/cran/blob/gh-pages/src/contrib/Archive/opal/opal_2.6.0.tar.gz?raw=true",
         pkg = "opal_2.6.0.tar.gz"),
  tibble(url = "https://github.com/obiba/cran/blob/gh-pages/src/contrib/Archive/opaladmin/opaladmin_1.20.0.tar.gz?raw=true",
         pkg = "opaladmin_1.20.0.tar.gz"),
  tibble(url = "https://github.com/datashield/cran/blob/gh-pages/src/contrib/Archive/dsBaseClient/dsBaseClient_5.1.0.tar.gz?raw=true",
         pkg = "dsBaseClient_5.1.0.tar.gz"))

packages %>%
  pmap(function(url, pkg) {
    download.file(url = url, destfile = pkg)
    install.packages(pkgs=pkg, type="source", repos=NULL)
    unlink(pkg)
  })

library(opal)
library(dsBaseClient)
```
