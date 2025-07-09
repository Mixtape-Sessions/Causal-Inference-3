# Load required libraries
library(fect)
library(haven)
library(ggplot2)

# Read and prepare the baker dataset
baker <- read_dta('https://github.com/scunning1975/mixtape/raw/master/baker.dta')

# Subset data and ensure proper treatment coding
baker_subset <- subset(baker, year <= 2003)
baker_subset$treat <- as.numeric(baker_subset$treat)

# Fit the model
reg1 <- fect(y ~ treat,
             data = baker_subset,
             index = c("id", "year"),
             force = "two-way",
             method = "mc",
             CV = TRUE,
             se = TRUE,
             nboots = 50,
             parallel = FALSE,
             seed = 123)

# Extract overall ATT
overall_ATT <- reg1$att.avg
print(overall_ATT)

# Plot
plot(reg1, theme.bw = TRUE)



# Extract the ATT and SE
att_time <- reg1$att
se_time <- reg1$se.att

# Build a data frame for plotting
att_df <- data.frame(
  time = 1:length(att_time),  # <-- just number the periods 1,2,3,... if no names
  att = att_time,
  se = se_time,
  upper = att_time + 1.96 * se_time,
  lower = att_time - 1.96 * se_time
)

# Plot with ggplot2
ggplot(att_df, aes(x = time, y = att)) +
  geom_line() +
  geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.2) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(x = "Time", y = "ATT", title = "Event Study with 95% Confidence Interval") +
  theme_minimal()