###########################################
# Session 10: Correlation & Regression    #
###########################################

# Section 1: Setup ---------------------------------------------------------

# Load the tidyverse and here

# Install and load corrplot and broom

# Read in the employee survey data

# Section 2: Correlation - The Concept -------------------------------------

# (Concept - no code. Be ready to state: correlation ranges -1 to +1,
#  sign is direction, magnitude is strength, and correlation is NOT
#  causation.)

# Section 3: Computing Correlation -----------------------------------------

# Correlation between satisfaction and engagement with cor()

# Correlation with salary (handle the NAs with use = "complete.obs")

# Use cor.test() to get a p-value and confidence interval

# Section 4: Pearson vs Spearman -------------------------------------------

# Pearson correlation of satisfaction and autonomy

# Spearman correlation of the same pair - when would they differ?

# Section 5: The Correlation Matrix ----------------------------------------

# Select the numeric columns

# Compute the full correlation matrix (round to 2 dp)

# Section 6: Visualizing the Correlation Matrix ----------------------------

# Basic corrplot

# Cleaner corrplot: upper triangle, coefficients shown, rotated labels

# Section 7: Simple Linear Regression --------------------------------------

# Fit lm(satisfaction ~ engagement)

# Look at summary() - find the slope, the p-value, and R-squared

# Section 8: Tidy Model Output with broom ----------------------------------

# tidy() the model - the coefficient table as a data frame

# glance() the model - the one-row fit summary

# augment() the model - fitted values and residuals

# Section 9: Multiple Predictors -------------------------------------------

# Fit lm(satisfaction ~ engagement + autonomy)

# Compare R-squared to the simple model

# Add salary as a third predictor and check the summary

# Section 10: Checking the Model -------------------------------------------

# Plot residuals vs fitted for the multiple model

# Section 11: MAIN EXERCISE ------------------------------------------------

# 1. Compute a correlation matrix for the numeric variables

# 2. Visualize it with corrplot

# 3. Fit a simple regression predicting satisfaction from engagement

# 4. Extract the tidy coefficients with broom

# 5. Write the interpretation sentence for the engagement slope

# 6. Fit a multiple regression adding autonomy, compare R-squared

# 7. Plot residuals vs fitted for the multiple model and comment

# BONUS: Going Further -----------------------------------------------------

# Plot the regression line over the data with geom_smooth(method = "lm")

# Use predict() to estimate satisfaction for hypothetical new employees

# Fit on scaled predictors to compare their relative strength
