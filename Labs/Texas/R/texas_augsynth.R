# Load necessary libraries
library(tidyverse)
library(haven)
# devtools::install_github("ebenmichael/augsynth")
# devtools::install_github("bcastanho/SCtools")
library(augsynth)
library(SCtools)
library(ggplot2)
library(dplyr)

# Load the smoking data
smoking <- haven::read_dta("https://raw.github.com/scunning1975/mixtape/master/synth_smoking.dta") 

# Convert state to character and set treated as numeric
smoking <- smoking %>%
  mutate(
    state = as.character(state),
    treated = as.numeric(state == "3" & year >= 1989)  # 
  )

# Check for any issues in treated assignment
table(smoking$treated, smoking$state == "3")

# Run the augmented synthetic control
syn_tx <- augsynth(
  cigsale ~ treated, 
  unit = state, time = year, data = smoking, 
  progfunc = "ridge", scm = TRUE
)

# When using outcome model: in augsyth(), when set progfunc = 'ridge' (or other functions), we can plot cross-validation MSE by setting cv = T 

list(syn_tx$weights)
summary(syn_tx) 

# Generate the plot with jackknife confidence intervals
plot(syn_tx, inf_type = "jackknife+")

# Assume syn$weights contains the synthetic control weights for each state
weights <- as.data.frame(syn_tx$weights)
colnames(weights) <- "weight"
weights$state <- rownames(weights)

# Convert state to a factor, ordered by weight magnitude
weights <- weights %>%
  mutate(state = fct_reorder(state, abs(weight), .desc = TRUE))

# Plot the weights distribution
ggplot(weights, aes(x = weight, y = state)) +
  geom_point(aes(color = weight > 0), size = 3) +  # Color for positive/negative weights
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray") +  # Vertical line at zero
  scale_color_manual(values = c("blue", "red"), labels = c("Negative", "Positive")) + 
  labs(
    title = "Distribution of (Smoking) Synthetic Control Weights by State",
    x = "Weight",
    y = "State (ordered by absolute weight)"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom") +
  guides(color = guide_legend(title = "Weight Sign"))


# Extract weights (synthetic control weights for each donor unit)
weights <- as.numeric(syn_tx$weights)

# Extract actual treated outcomes
treated_outcomes <- as.data.frame(syn_tx$data$synth_data$Y1plot)
treated_years <- syn_tx$data$time

# Calculate the synthetic control outcome by applying the weights to donor outcomes
donor_outcomes <- as.matrix(syn_tx$data$synth_data$Y0plot)
synthetic_outcomes <- donor_outcomes %*% weights

# Combine treated and synthetic outcomes into one data frame for plotting
plot_data <- data.frame(
  Year = treated_years,
  Treated = unlist(treated_outcomes),
  Synthetic = synthetic_outcomes
)

ggplot(plot_data, aes(x = Year)) +
  geom_line(aes(y = Treated, color = "Treated Outcome")) +
  geom_line(aes(y = Synthetic, color = "Synthetic Control")) +
  labs(
    title = "Estimated Effect of Prop 99 on Smoking",
    subtitle = "Augmented Synthetic Control",
    y = "Black Male Inmates",
    color = "Group"
  ) +
  geom_vline(xintercept = 1993, linetype = "dashed", color = "gray") +  # Add dashed vertical line
  theme_minimal()






# Texas - perfect fit
texas <- haven::read_dta("https://raw.github.com/scunning1975/mixtape/master/texas.dta") 

# create a treated variable
texas$treated = as.numeric(texas$state == 'Texas' & texas$year >= 1993)

# Augmented Synthetic Controls
syn_tx <- augsynth(
  bmprison ~ treated, 
  unit = statefip, time = year, data = texas, 
  progfunc = "ridge", scm = T 
)

# When using outcome model: in augsyth(), when set progfunc = 'ridge' (or other functions), we can plot cross-validation MSE by setting cv = T 

list(syn_tx$weights)
summary(syn_tx) 

# Generate the plot with jackknife confidence intervals
plot(syn_tx, inf_type = "jackknife+")

# Assume syn$weights contains the synthetic control weights for each state
weights <- as.data.frame(syn_tx$weights)
colnames(weights) <- "weight"
weights$state <- rownames(weights)

# Convert state to a factor, ordered by weight magnitude
weights <- weights %>%
  mutate(state = fct_reorder(state, abs(weight), .desc = TRUE))

# Plot the weights distribution
ggplot(weights, aes(x = weight, y = state)) +
  geom_point(aes(color = weight > 0), size = 3) +  # Color for positive/negative weights
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray") +  # Vertical line at zero
  scale_color_manual(values = c("blue", "red"), labels = c("Negative", "Positive")) + 
  labs(
    title = "Distribution of (Prison) Synthetic Control Weights by State",
    x = "Weight",
    y = "State (ordered by absolute weight)"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom") +
  guides(color = guide_legend(title = "Weight Sign"))


# Extract weights (synthetic control weights for each donor unit)
weights <- as.numeric(syn_tx$weights)

# Extract actual treated outcomes
treated_outcomes <- as.data.frame(syn_tx$data$synth_data$Y1plot)
treated_years <- syn_tx$data$time

# Calculate the synthetic control outcome by applying the weights to donor outcomes
donor_outcomes <- as.matrix(syn_tx$data$synth_data$Y0plot)
synthetic_outcomes <- donor_outcomes %*% weights

# Combine treated and synthetic outcomes into one data frame for plotting
plot_data <- data.frame(
  Year = treated_years,
  Treated = unlist(treated_outcomes),
  Synthetic = synthetic_outcomes
)

ggplot(plot_data, aes(x = Year)) +
  geom_line(aes(y = Treated, color = "Treated Outcome")) +
  geom_line(aes(y = Synthetic, color = "Synthetic Control")) +
  labs(
    title = "Estimated Effect of Prison Construction on Black Male Incarceration",
    subtitle = "Augmented Synthetic Control",
    y = "Black Male Inmates",
    color = "Group"
  ) +
  geom_vline(xintercept = 1993, linetype = "dashed", color = "gray") +  # Add dashed vertical line
  theme_minimal()

