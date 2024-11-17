# Load required libraries
library(PanelMatch)
library(panelView)
library(haven)
library(pacman)
library(gsynth)

# Read and prepare the baker dataset
baker = read_dta('https://github.com/scunning1975/mixtape/raw/master/baker.dta')

# Create a proper panel structure
# First, let's examine the treatment timing
print("Treatment dates distribution:")
print(table(baker$treat_date))

# Subset data and ensure proper treatment coding
baker_subset <- baker[baker$year <= 2003, ]
baker_subset$treat <- as.numeric(baker_subset$treat)

# Check for missing values
print("Missing values summary:")
print(sapply(baker_subset, function(x) sum(is.na(x))))

# Verify panel structure
print("Number of unique IDs:")
print(length(unique(baker_subset$id)))
print("Years per ID:")
print(table(table(baker_subset$id)))

# Run matrix completion with more robust settings
reg1 <- gsynth(y ~ treat,
               data = baker_subset,
               index = c("id", "year"),
               estimator = "mc",
               nlambda = 5,        # Reduced from 10
               CV = TRUE,
               k = 5,             # Reduced from 10
               force = "two-way",
               se = TRUE,
               #nboots = 50,      # Reduced from 200
               na.rm = TRUE,
               parallel = FALSE,
               seed = 123)        # Added seed for reproducibility

# Generate summary
summary(reg1)

# Create plot with basic settings
plot(reg1, theme.bw = TRUE)

