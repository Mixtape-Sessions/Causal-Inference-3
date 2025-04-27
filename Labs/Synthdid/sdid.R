# sdid.r for the smoking dataset

# libraries
# devtools::install_github("synth-inference/synthdid")
library(synthdid)
library(ggplot2)
set.seed(12345)

# Loading and preparing the data
data('california_prop99')
setup = panel.matrices(california_prop99)

# Estimating treatment effects
tau.hat = synthdid_estimate(setup$Y, setup$N0, setup$T0)
se = sqrt(vcov(tau.hat, method='placebo'))
print(summary(tau.hat))

# Getting a standard error using placebo
sprintf('point estimate: %1.2f', tau.hat)

# Constructing a simple 95% confidence interval
sprintf('95%% CI (%1.2f, %1.2f)', tau.hat - 1.96 * se, tau.hat + 1.96 * se)

# Plotting SDID estimated trends
plot(tau.hat, se.method='placebo')

# Plotting unit-level contributions
synthdid_units_plot(tau.hat, se.method='placebo')

# Overlaying treated vs synthetic counterfactual
plot(tau.hat, overlay=1,  se.method='placebo')
plot(tau.hat, overlay=.8, se.method='placebo')

# Comparing DiD, SC, and SDID Estimates
tau.sc   = sc_estimate(setup$Y, setup$N0, setup$T0)
tau.did  = did_estimate(setup$Y, setup$N0, setup$T0)
estimates = list(tau.did, tau.sc, tau.hat)
names(estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')

# Plotting all three methods’ unit weights
print(unlist(estimates))
synthdid_units_plot(estimates, se.method='placebo')



