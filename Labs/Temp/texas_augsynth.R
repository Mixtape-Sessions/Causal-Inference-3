library(tidyverse)
library(haven)
# devtools::install_github("ebenmichael/augsynth")
# devtools::install_github("bcastanho/SCtools")
library(augsynth)
library(SCtools)

texas <- haven::read_dta("https://raw.github.com/scunning1975/mixtape/master/texas.dta") 

# create a treated variable
texas$treated = as.numeric(texas$state == 'Texas' & texas$year >= 1993)

# Synthetic control (Abadie, et al. 2010) --------------------------------------
syn <- augsynth(
  bmprison ~ treated, 
  unit = statefip, time = year, data = texas, 
  # Settings to use `augsynth` to estimate synthetic control
  progfunc = "None", scm = T
)

summary(syn)
# compute point-wise confidence intervals using the Jackknife+ procedure
plot(syn, inf_type = "jackknife+")

# Augmented Synthetic Controls - No covariate ----------------------------------
syn_tx <- augsynth(
  bmprison ~ treated, 
  unit = statefip, time = year, data = texas, 
  progfunc = "ridge", scm = T 
)

# When using outcome model: in augsyth(), when set progfunc = 'ridge' (or other functions), we can plot cross-validation MSE by setting cv = T 
plot(syn_tx, cv = T)

list(syn_tx$weights)
summary(syn_tx) 
plot(syn_tx, inf_type = "jackknife+") 


# Augmented Synthetic Controls - With covariates -------------------------------
augsynth_tx <- augsynth(
  # covariates are put behind vertical bar |
  bmprison ~ treated | poverty + income + alcohol + aidscapita + black + perc1519, 
  unit = statefip, time = year, data = texas, 
  progfunc = "ridge", scm = T 
)

summary(augsynth_tx)
plot(augsynth_tx, inf_type = "jackknife+")
