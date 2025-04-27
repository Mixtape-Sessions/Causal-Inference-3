library(tidyverse)
library(haven)
# devtools::install_github("ebenmichael/augsynth")
library(augsynth)
# devtools::install_github("bcastanho/SCtools")
library(SCtools)
# devtools::install_github("nppackages/scpi")
library(scpi)

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

list(syn$weights)
summary(syn)
# compute point-wise confidence intervals using the Jackknife+ procedure
plot(syn, inf_type = "jackknife+")

# Placebo Spaghetti plot -------------------------------------------------------

extract_y_and_y0 = function(est) { 
  df = data.frame(
    year = est$data$time,
    y_obs = est$data$synth_data$Y1plot[, 1],
    y_synth = predict(est)
  )
  df$te_hat = df$y_obs - df$y_synth
  return(df)
}

res = extract_y_and_y0(syn)
res$unit = "Texas"
res$group = "Treated"

for (unit in setdiff(unique(texas$state), "Texas")) {
  cat(paste0("\n Placebo Unit: ", unit))

  texas$placebo_treated = as.numeric(texas$state == unit & texas$year >= 1993)

  placebo_est = augsynth(
    bmprison ~ placebo_treated, 
    unit = statefip, time = year, data = texas, 
    # Settings to use `augsynth` to estimate synthetic control
    progfunc = "None", scm = T
  )

  placebo_df = extract_y_and_y0(placebo_est)
  placebo_df$unit = unit
  placebo_df$group = "Placebo"
  res <- rbind(res, placebo_df)
}

ggplot(res) +
  geom_vline(
    xintercept = 1992.5, size = 1,
    color = "grey50", linetype = "dotted"
  ) +  
  geom_hline(
    yintercept = 0, size = 1,
    color = "grey50", linetype = "dotted"
  ) + 
  geom_line(
    aes(x = year, y = te_hat, color = group, group = unit), 
    alpha = 0.5, size = 1.2
  ) +
  scale_color_manual(
    values = c("Treated" = "purple", "Placebo" = "grey60")
  ) + 
  theme_bw()

# Synthetic control with LASSO -------------------------------------------------
# Prepare data
synth_df = scpi::scdata(
  df = texas,
  id.var = "state", time.var = "year",
  outcome.var = "bmprison",
  period.pre = 1985:1992, period.post = 1993:2000,
  unit.tr = "Texas",
  unit.co = setdiff(unique(texas$state), "Texas"),
  constant = TRUE
)

# Estimate
result_lasso = scpi::scest(
  synth_df, w.constr = list(name = "lasso", Q = 1)
)

# Plot
(plot_lasso = scpi::scplot(result_lasso))




