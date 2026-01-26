#####################################
# Session 1: Orientation & R Basics #
#####################################

# Start by showing RStudio panes and emphasizing the difference
# between console (temporary, testing) and scripts (saved, reproducible)
# Demonstrate how to create an R Project: File > New Project > New Directory
# Keyboard shortcuts https://support.posit.co/hc/en-us/articles/200711853-Keyboard-Shortcuts-in-the-RStudio-IDE

# Section 1: Variables and Assignment --------------------------------------
# Explain that <- is the assignment operator (Alt + - shortcut)
# Mention that = also works but <- is preferred R style
# Variables are case-sensitive!

# Assign a numeric value to a variable
my_age <- 42

# Assign a character value (strings must be in quotes)
my_name <- "Scott"

# Print variables to console (just type the name)
my_age # This sends output to console
my_name

# Alternative: use print() function explicitly
print(my_age)
print(my_name)

# Show what happens if you forget quotes around characters
# my_name <- Sarah  # This will error! Sarah looks like a variable name

# Section 2: Data Types ----------------------------------------------------
# R has several basic data types. The main ones are:
# numeric (numbers), character (text), logical (TRUE/FALSE)

# Numeric: any number (integers and decimals)
height_cm <- 177
num_students <- 8

# Character: text strings (always in quotes)
city <- "Seattle"
favorite_color <- "blue"

# Logical: TRUE or FALSE (no quotes! these are special values)
# Demonstrate what happens when quoted or undercase.
# Can use T or F but it's messy.
is_raining <- TRUE
is_sunny <- false

# Check the class (type) of a variable using class()
class(height_cm) # Returns "numeric"
class(city) # Returns "character"
class(is_raining) # Returns "logical"

# Use typeof() to see more detailed type information
# typeof(height_cm)   # Returns "double" (double-precision floating point)
# typeof(num_students) # Also "double" - R stores all numbers as doubles by default

# Section 3: Basic Operators -----------------------------------------------
# Operators allow us to perform operations on data

# Arithmetic operators
10 + 5 # Addition: 15
10 - 5 # Subtraction: 5
10 * 5 # Multiplication: 50
10 / 5 # Division: 2
10^2 # Exponentiation: 100
10 %% 3 # Modulo (remainder): 1
10 %/% 3 # Integer division: 3
10 %/% 3.3

# Store results in variables
sum_result <- 10 + 5
square_result <- 10^2

# Comparison operators (return TRUE or FALSE)
10 > 5 # Greater than: TRUE
10 < 5 # Less than: FALSE
10 >= 10 # Greater than or equal to: TRUE
10 <= 5 # Less than or equal to: FALSE
10 == 10 # Equal to: TRUE (note: double equals!)
10 != 5 # Not equal to: TRUE

# Comparing characters
"apple" == "orange" # FALSE
"apple" == "apple" # TRUE

# Emphasize == for comparison vs = for assignment
# Common beginner mistake: using = when they mean ==

# Logical operators
TRUE & FALSE # AND: FALSE (both must be TRUE)
TRUE | FALSE # OR: TRUE (at least one must be TRUE)
!TRUE # NOT: FALSE (negation)


# Section 4: Vectors -------------------------------------------------------
# Vectors are the fundamental data structure in R
# A vector is a sequence of elements of the same type
# Use c() to combine values into a vector

# Create numeric vectors
ages <- c(25, 30, 35, 40, 45)
temperatures <- c(72.5, 68.3, 75.1, 70.0)

# Create character vectors
fruits <- c("apple", "banana", "cherry")
cities <- c("New York", "Los Angeles", "Chicago")

# Create logical vectors
test_results <- c(TRUE, FALSE, TRUE, TRUE, FALSE)

# Vectors are indexed starting at 1 (not 0 like Python!)
fruits[1] # Returns "apple"
ages[3] # Returns 35

# Vectorized operations: operations apply to each element
ages + 5 # Adds 5 to each age
temperatures * 1.1 # Multiplies each temperature by 1.1
ages > 35 # Returns logical vector: FALSE FALSE FALSE TRUE TRUE

# How is this different from other languages?

# Show what happens with different types
# mixed <- c(1, "two", 3)  # Everything becomes character!
# class(mixed)  # "character" - R coerces to most flexible type

# Section 5: Getting Help --------------------------------------------------
# Learning to find help is crucial! Show multiple methods.

# Method 1: ? for help on a specific function
?mean # Opens help page for mean() function

# Method 2: ?? for searching help across packages
??standard # Searches for "standard" in documentation

# Method 3: help() function (same as ?)
help(mean)

# Method 4: help.search() (same as ??)
help.search("standard deviation")

# Method 5: example() shows examples of how to use a function
example(mean)

# The help page structure:
# - Description: what the function does
# - Usage: syntax and arguments
# - Arguments: what each parameter means
# - Value: what the function returns
# - Examples: working code examples (scroll down!)

# Section 6: Installing and Loading Packages ------------------------------
# Packages extend R's functionality
# Think of them like apps you install on your phone

# Install a package (only need to do ONCE per computer)
# Run this in the CONSOLE, not in your script
# install.packages("praise")

# Explain why we don't put install.packages() in scripts:
# - It's slow and unnecessary to reinstall every time
# - Can cause issues in collaborative settings
# - Only needs to happen once per machine

# Load a package (need to do EVERY SESSION you want to use it)
library(praise)

# Use a function from the package
praise() # Gives random praise messages

# Show the difference between installed vs loaded
# installed.packages()  # Shows all installed packages
# search()              # Shows loaded packages

# Section 7: MAIN EXERCISE -------------------------------------------------
# This ties together everything we've learned
# Walk through this step-by-step with students

# Create a vector of numeric values
# Let's use test scores as an example
test_scores <- c(85, 92, 78, 90, 88, 76, 95, 89, 84, 91, 87, 93)

# Mention we could also generate random data:
# test_scores <- round(runif(20, min = 60, max = 100))

# Calculate the mean (average)
mean_score <- mean(test_scores)
mean_score # 87.33333

# Calculate the median (middle value)
median_score <- median(test_scores)
median_score # 88.5

# Calculate the standard deviation (spread of data)
sd_score <- sd(test_scores)
sd_score # 5.757608

# Explain what each statistic tells us:
# - Mean: average score (affected by outliers)
# - Median: middle value (resistant to outliers)
# - SD: how spread out the scores are (higher = more variation)

# Print a formatted summary message
# Use paste() to combine text and numbers
summary_message <- paste(
  "Mean:",
  round(mean_score, 2),
  "| Median:",
  round(median_score, 2),
  "| SD:",
  round(sd_score, 2)
)
print(summary_message)

# Alternative: print each on a separate line
cat("Summary Statistics for Test Scores:\n")
cat("Mean:  ", round(mean_score, 2), "\n")
cat("Median:", round(median_score, 2), "\n")
cat("SD:    ", round(sd_score, 2), "\n")

# Introduce the summary() function - a quick way to get stats
summary(test_scores)


# BONUS: Work with built-in data -------------------------------------------
# R comes with many built-in datasets for practice
# This is perfect for learning without needing to import external files

# Load the mtcars dataset (automatically available in R)
data(mtcars) # Makes the dataset available in your environment

# List available datasets with: data()

# View the first few rows
head(mtcars) # Shows first 6 rows by default
head(mtcars, 10) # Can specify number of rows

# View the structure of the dataset
str(mtcars) # Shows data types and sample values

# Get summary statistics for all variables
summary(mtcars)

# Explain the $ operator for accessing columns
# dataframe$column_name extracts a specific column as a vector

# Calculate mean miles per gallon (mpg)
mean_mpg <- mean(mtcars$mpg)
mean_mpg # 20.09062

# Calculate median horsepower (hp)
median_hp <- median(mtcars$hp)
median_hp # 123

# Calculate standard deviation of weight (wt, in 1000 lbs)
sd_wt <- sd(mtcars$wt)
sd_wt # 0.978457

# Show how to get help on datasets
?mtcars # Explains what each column means

# Create a comprehensive summary
cat("\n===== MTCARS Dataset Summary =====\n")
cat("Number of cars:", nrow(mtcars), "\n")
cat("Number of variables:", ncol(mtcars), "\n\n")
cat("Average MPG:", round(mean_mpg, 2), "\n")
cat("Median Horsepower:", median_hp, "\n")
cat("SD of Weight:", round(sd_wt, 2), "\n")

# =============================================================================
# END OF SESSION 1
# =============================================================================

# NOTES FOR NEXT TIME:
# - Reinforce project-based workflow at start of each session
# - Have students practice keyboard shortcuts (Alt+- for <-, Ctrl+Enter to run)
# - Emphasize reproducibility: everything in a script, nothing just in console
# - Next session: vectors in depth, data frames, reading in external data

# COMMON STUDENT MISTAKES TO WATCH FOR:
# 1. Forgetting quotes around character values
# 2. Using = instead of <- for assignment (works, but not idiomatic)
# 3. Using = instead of == for comparison (this will error or give wrong results)
# 4. Forgetting to load packages with library()
# 5. Case sensitivity issues (MyVariable vs myvariable)
# 6. Running install.packages() in scripts repeatedly

# ASSESSMENT IDEAS:
# - Have students create their own numeric vector and compute mean/median/sd
# - Ask them to fix broken code with common errors
# - Give them a new built-in dataset and ask for summary statistics
