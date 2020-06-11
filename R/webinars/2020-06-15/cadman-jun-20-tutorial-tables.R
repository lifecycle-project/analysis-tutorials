################################################################################
## Project: bmi-poc
## Script purpose: Make tables for paper
## Date: 29th April 2020
## Author: Tim Cadman
## Email: t.cadman@bristol.ac.uk
################################################################################

# Here we put the results from "bmi-poc-analysis.R" into some tables for the
# paper
#
# Remaining functionality required is to be able to show median - I haven't
# worked out how to do this in DS yet

source("~/ds-cs-functions/cs-reg-tab.R")

################################################################################
# 1. Descriptive statistics
################################################################################

## ---- Exposures --------------------------------------------------------------
exposure_cat <- descriptives_ss$categorical %>%
  filter(variable == "edu_m") %>%
  mutate(n_perc = paste0(value, " (", valid_perc, ")")) %>%
  select(cohort, variable, category, n_perc) %>%
  pivot_wider(names_from = c(variable, category), values_from = n_perc) 

exposure_cont <- descriptives_ss$continuous %>%
  filter(variable == "ga_all") %>%
  mutate(mean_sd = paste0(mean, " (", std.dev, ")")) %>%
  select(cohort, variable, mean_sd) %>%
  pivot_wider(names_from = variable, values_from = mean_sd)

exposure.tab <- cbind(exposure_cat, select(exposure_cont, -cohort)) %>%
  select(cohort, edu_m_1, edu_m_2, edu_m_3, ga_all)

write.csv(exposure.tab)


## ---- Outcomes ---------------------------------------------------------------
outcomes.tab <- descriptives_ss$continuous %>%
  filter(variable == "bmi.96" | variable == "bmi.168" | 
           variable == "age_months.96" | variable == "age_months.168") %>%
  mutate(mean_sd = paste0(mean, " (", std.dev, ")")) %>%
  select(cohort, variable, mean_sd, valid_n) %>%
  pivot_wider(names_from = variable, values_from = c(mean_sd, valid_n)) %>%
  select(cohort, valid_n_bmi.96, mean_sd_age_months.96, mean_sd_bmi.96,
         valid_n_bmi.168, mean_sd_age_months.168, mean_sd_bmi.168)

write.csv(outcomes.tab)


## ---- Covariates -------------------------------------------------------------
cov_cat.tab <- descriptives_ss$categorical %>%
  filter(variable == "sex" | variable == "parity_bin" | 
         variable == "preg_smk")  %>%
  mutate(n_perc = paste0(value, " (", valid_perc, ")"), 
         missing = paste0(missing_n, " (", missing_perc, ")")) %>%
  select(cohort, variable, category, n_perc, missing) %<>% 
  pivot_wider(names_from = c(variable, category),  
              values_from = c(n_perc, missing))

cov_cont.tab <- descriptives_ss$continuous %>%
  filter(variable == "prepreg_bmi" | variable == "agebirth_m_y") %>%
  mutate(mean_sd = paste0(mean, " (", std.dev, ")"),
         missing = paste0(missing_n, " (", missing_perc, ")")) %>%
  select(cohort, variable, mean_sd, missing) %>%
  pivot_wider(names_from = variable, values_from = c(mean_sd, missing))

cov.tab <- cbind(cov_cat.tab, select(cov_cont.tab, -cohort)) %>%
  select(cohort, n_perc_sex_1, missing_sex_1, n_perc_parity_bin_0,
         missing_parity_bin_0, n_perc_preg_smk_1, missing_preg_smk_1, 
         mean_sd_prepreg_bmi, missing_prepreg_bmi, mean_sd_agebirth_m_y, 
         missing_agebirth_m_y) %>%
  as_tibble()

write.csv(cov.tab)


## ---- Available n by cohort --------------------------------------------------
ds.summary("analysis_df", datasources = coh())


################################################################################
# 2. Analysis stats
################################################################################

## ---- IPD --------------------------------------------------------------------
mat_ed_ipd_stats <- map(mat_ed_ipd, ~regTab(model = ., type = "ipd"))
ga_ipd_stats <- map(ga_ipd, ~regTab(model = ., type = "ipd"))  

names(mat_ed_ipd_stats) <- names(mat_ed_ipd)
names(ga_ipd_stats) <- names(ga_ipd)

mat_ed_ipd_stats
ga_ed_ipd_stats


## ---- SLMA -------------------------------------------------------------------
mat_ed_slma_stats <- map(mat_ed_slma, ~regTab(model = ., type = "slma"))
ga_slma_stats <- map(ga_slma, ~regTab(model = ., type = "slma"))

names(mat_ed_slma_stats) <- names(mat_ed_slma)
names(ga_slma_stats) <- names(ga_slma)

mat_ed_slma_stats
ga_slma_stats



