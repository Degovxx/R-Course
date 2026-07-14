############################################
# Session 4: Debugging & Troubleshooting   #
############################################

# Section 1: Common Error Types --------------------------------------------

# Run each of these broken lines one at a time.
# Read the error message. What does it tell you?

# Syntax error: missing parenthesis
mean(c(1, 2, 3))

# Object not found: typo in variable name
my_data <- c(10, 20, 30)
mean(my_Data)

# Type mismatch: math on characters
"10" + 5

# What is the difference between an error, a warning, and a message?
c("1", "A", 4) |>
  as.numeric()

# Section 2: Reading Error Messages ----------------------------------------

# Practice reading this error:
x <- 3
log(as.character(x))
# What is the WHERE? What is the WHAT?

# Run this and explain the warning:
as.numeric(c("1", "2", "three"))

# Section 3: Inspection Tools ----------------------------------------------

# Create a sample data frame to practice with
library(tidyverse)

sample_df <- tibble(
  id = paste0("P", sprintf("%03d", 1:20)),
  department = rep(c("Sales", "Engineering", "HR", "Marketing"), 5),
  satisfaction = c(4, 3, 5, 2, 4, 3, 4, 5, 1, 3, 4, 2, 5, 3, 4, 2, 3, 5, 4, 3),
  tenure_years = c(2, 5, 1, 8, 3, 6, 2, 4, 10, 3, 1, 7, 2, 5, 3, 9, 4, 1, 6, 2)
)

# Use str() to examine the structure
str(sample_df)

# Use glimpse() to examine the structure (tidyverse version)
glimpse(sample_df)

# Use summary() to get a statistical overview
summary(sample_df)

# Use class() on the data frame and on individual columns

# Use head() and tail() to look at the beginning and end
tail(sample_df)

# Use dim(), nrow(), ncol() to check dimensions
dim(sample_df)

# Section 4: Systematic Debugging Strategy ---------------------------------

# THE WORKFLOW:
# 1. READ the error message
# 2. IDENTIFY which line caused it
# 3. INSPECT the objects on that line
# 4. ISOLATE the problem (run sub-expressions separately)
# 5. FIX and test
# 6. RE-RUN from the top

# Practice: This pipeline gives 0 rows. Why?
sample_df |>
  filter(department == "Sales") |>
  summarize(mean_sat = mean(satisfaction), median_sat = median(satisfaction))

# Equivalent to:
summarize(filter(sample_df, department == "Sales"), mean_sat = mean(satisfaction))

# Base R
tibble(
  mean_sat = mean(sample_df[sample_df[, "department"] == "Sales", ]$satisfaction),
  median_sat = median(sample_df[sample_df[, "department"] == "Sales", ]$satisfaction)
)

# Use unique() to check what values are actually in the column

# Fix the filter and re-run

# We can get aggregates easily
sample_df |>
  group_by(department) |>
  summarize(mean_sat = mean(satisfaction), median_sat = median(satisfaction))


# Section 5: Using browser() and debug() ----------------------------------

# This function has a bug. It returns all NAs when there are missing values.
calc_z_scores <- function(x) {
  browser()
  x_mean <- mean(x, na.rm = TRUE)
  x_sd <- sd(x, na.rm = TRUE)
  z <- (x - x_mean) / x_sd
  return(z)
}

# Test with clean data (works fine):
calc_z_scores(c(10, 20, 30, 40, 50))

# Test with NAs (broken):
calc_z_scores(c(10, 20, NA, 40, 50))

# Add browser() inside the function to step through it

# What value does x_mean have? Why?

# Fix the function

# Section 6: Reproducible Examples with reprex -----------------------------

# What makes a good reprex?
# 1. Minimal code that reproduces the problem
# 2. Self-contained (no external data)
# 3. Shows the error or unexpected output
# 4. Says what you expected

# Use dput() to create reproducible data from an existing object
dput(head(sample_df, 5))

# Practice: write a reprex for a date parsing problem
# (copy to clipboard and run reprex::reprex() if the package is installed)

# Section 7: Getting Help Effectively --------------------------------------

# Look up help for a function you've used before
?mean

# Search for functions related to a topic
??correlation

# Find vignettes (long-form guides) for a package
# vignette("dplyr")

# Section 8: MAIN EXERCISE ------------------------------------------------
# Debug these broken scripts. Each has 1-3 bugs.

# --- Bug Script 1: Basic errors (3 bugs) ---
# This should compute summary stats for mtcars mpg column.
# library(tidyverse
# mtcars_data <- mtcars
# mean_mpg <- mean(mtcars_data$MPG)
# cat("Mean MPG:" mean_mpg, "\n")

# --- Bug Script 2: Type issues (2 bugs) ---
# This should calculate average survey score and find high scorers.
# survey_scores <- c("4", "5", "3", "4", "5", "2", "4")
# avg_score <- mean(survey_scores)
# cat("Average score:", avg_score, "\n")
# high_scorers <- survey_scores[survey_scores > 3]
# cat("Number scoring above 3:", length(high_scorers), "\n")

# --- Bug Script 3: Data frame operations (3 bugs) ---
employees <- tibble(
  name = c(
    "Alice", "Bob", "Charlie", "Diana", "Edward",
    "Fiona", "George", "Hannah", "Ian", "Julia"
  ),
  department = c(
    "Sales", "Engineering", "Sales", "HR", "Engineering",
    "Marketing", "Sales", "HR", "Engineering", "Marketing"
  ),
  salary = c(
    55000, 72000, 58000, 61000, 75000,
    53000, 57000, 63000, 71000, 52000
  ),
  years = c(3, 7, 2, 5, 8, 1, 4, 6, 7, 2)
)

# senior_employees <- employees %>%
#   filter(years >= 5)
#   summarize(avg_salary = mean(salary))
#
# engineering <- employees %>%
#   filter(Department == "Engineering")
#
# salary_by_dept <- employees %>%
#   group_by(department) %>%
#   summarize(avg = mean(Salary))

# --- Bug Script 4: Function debugging (2 bugs) ---
# This function should summarize a numeric column by name.
# summarize_column <- function(df, col_name) {
#   values <- df$col_name
#   tibble(
#     mean = mean(values),
#     sd = sd(values),
#     n = length(values),
#     n_missing = sum(is.na(values))
#   )
# }
# summarize_column(employees, "salary")

# --- Bug Script 5: browser() practice ---
# This function gives wrong results. Use browser() to find out why.
calc_weighted_score <- function(scores, weights) {
  total <- sum(scores * weights)
  weighted_avg <- total / sum(scores)
  return(weighted_avg)
}

test_scores <- c(85, 90, 78)
test_weights <- c(0.3, 0.5, 0.2)
calc_weighted_score(test_scores, test_weights)
# Expected: 85.1
# Got: ???
# Add browser() to the function, step through, and fix it.

# BONUS: Common Gotchas ----------------------------------------------------

# What does NA == NA return? Why?

# What happens if you assign T <- FALSE? Try it, then clean up with rm(T)

# What is the difference between df$col and df[["col"]]?

# What is the difference between | and %in% for checking multiple values?
