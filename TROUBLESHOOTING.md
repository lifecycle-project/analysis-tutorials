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