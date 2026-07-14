############################################
# Session 4: Debugging & Troubleshooting   #
############################################

# This session builds confidence. Students are going to hit errors
# constantly and the instinct is to panic or Google randomly.
# Teach them to read the error, isolate the problem, and fix it
# systematically. This is one of the most practical sessions in the course.

# Section 1: Common Error Types --------------------------------------------
# Walk through the major categories of errors students will see.
# For each one, SHOW the error first, then explain how to read it.

# --- Syntax Errors ---
# These are the easiest: R can't even parse what you wrote.
# Missing parentheses, commas, quotes, operators, etc.

# Missing closing parenthesis
# mean(c(1, 2, 3)
# Error: unexpected end of input

# Missing comma in c()
# x <- c(1 2 3)
# Error: unexpected numeric constant in "x <- c(1 2"

# Unmatched quotes
# name <- "Alice
# Error: unexpected end of input (+ prompt in console means R is waiting)

# TIP: If you see a + in the console instead of >, R is waiting for
# you to finish an expression. Press Escape to cancel and fix it.

# Extra comma
# x <- c(1, 2, 3,)
# This actually works in R! But it's sloppy. Show that R is lenient here.

# --- Object Not Found ---
# Second most common. The name doesn't match anything in the environment.

# Typo in variable name
my_data <- c(10, 20, 30)
# mean(my_Data)
# Error in mean(my_Data) : object 'my_Data' not found

# Case sensitivity matters!
# R is case-sensitive: my_data, My_Data, MY_DATA are all different

# Forgot to run earlier code (very common in scripts)
# Students write code top to bottom, then jump around.
# If they skip the line that creates an object, everything downstream breaks.

# Forgot to load a package
# ggplot(mtcars, aes(x = mpg, y = hp)) + geom_point()
# Error in ggplot(mtcars, aes(x = mpg, y = hp)) :
#   could not find function "ggplot"

# Fix: library(ggplot2)  or  library(tidyverse)

# --- Type Mismatch Errors ---
# Trying to do something with the wrong data type

# Math on characters
# "10" + 5
# Error in "10" + 5 : non-numeric argument to binary operator

# Translation: you tried math (+) on something that isn't a number

# Using a function that expects a different type
# mean("hello")
# Warning: argument is not numeric or logical: returning NA

# Note: this is a WARNING, not an error. R still runs but gives NA.
# Warnings are R saying "I did what you asked but something seems off."

# Applying a data frame function to a vector
x <- c(1, 2, 3)
# nrow(x)
# NULL (not an error, but not what you expected)
# Use length(x) for vectors, nrow() for data frames

# --- Subscript Out of Bounds ---
x <- c(10, 20, 30)
# x[5]
# Returns NA (not an error for vectors, but unexpected)

# For lists it IS an error:
my_list <- list(a = 1, b = 2)
# my_list[[5]]
# Error in my_list[[5]] : subscript out of bounds

# --- Argument Errors ---
# Wrong number of arguments or misspelled argument names

# mean(c(1, 2, 3), na.rm = TRUE, trim = 0.1)  # This is fine
# mean(c(1, 2, 3), narm = TRUE)
# This silently ignores the typo! Partial matching can mask bugs.
# Use exact argument names.

# --- Dimension Mismatch ---
# Common when combining vectors of different lengths
a <- c(1, 2, 3)
b <- c(10, 20)
# a + b
# Works with a warning about recycling! R recycles the shorter vector.
# Result: 11 22 13 (b gets recycled: 10, 20, 10)
# This can be a silent source of bugs.

# In data frames, mismatched lengths cause errors:
# data.frame(x = 1:3, y = 1:4)
# Error: arguments imply differing number of rows

# Section 2: Reading Error Messages ----------------------------------------
# Teach students to actually READ errors instead of panicking.
# Error messages have a predictable structure.

# Structure of an R error:
# Error in <function_name>(<arguments>) : <description>
#
# "Error in" tells you WHERE the problem is (which function)
# The description tells you WHAT went wrong

# Example: walk through reading this error
# x <- "hello"
# log(x)
# Error in log(x) : non-numeric argument to mathematical function
#
# WHERE: in log(x)
# WHAT: non-numeric argument to mathematical function
# DIAGNOSIS: x is not a number, but log() needs a number
# FIX: check what x actually is with class(x) or str(x)

# Warnings vs Errors:
# - Errors STOP execution. Something is broken.
# - Warnings let code RUN but flag something suspicious.
# - Messages are informational (like when loading packages).

# Example warning:
as.numeric(c("1", "2", "three"))
# Warning: NAs introduced by coercion
# The code ran, but "three" couldn't be converted. Check your data!

# Multiple warnings can pile up. Use warnings() to review them.
warnings()

# Demonstrate: always check warnings. They often reveal data problems
# that would otherwise go unnoticed.

# Section 3: Inspection Tools ----------------------------------------------
# When you hit an error, the first step is always: look at your data.
# These tools help you understand what you actually have.

# Setup: create some objects to inspect
library(tidyverse)

sample_df <- tibble(
  id = paste0("P", sprintf("%03d", 1:20)),
  department = rep(c("Sales", "Engineering", "HR", "Marketing"), 5),
  satisfaction = c(4, 3, 5, 2, 4, 3, 4, 5, 1, 3, 4, 2, 5, 3, 4, 2, 3, 5, 4, 3),
  tenure_years = c(2, 5, 1, 8, 3, 6, 2, 4, 10, 3, 1, 7, 2, 5, 3, 9, 4, 1, 6, 2)
)

# --- print() ---
# The simplest tool. Show the object's value.
print(sample_df)

# For debugging inside functions or loops, print() is essential
# because R doesn't auto-print inside those contexts.

# Print with a label so you know what you're looking at:
cat("=== sample_df after filtering ===\n")
print(sample_df)

# --- str() ---
# Shows the STRUCTURE of an object: types, dimensions, first values
str(sample_df)

# str() is your best friend when something isn't the type you expect.
# "I thought this was numeric but it's actually character"

# Works on anything:
str(list(a = 1, b = "hello", c = TRUE))
str(c(1, 2, 3))
str(lm(satisfaction ~ tenure_years, data = sample_df)) # Complex objects too

# --- class() and typeof() ---
# Quick checks when you suspect a type problem
class(sample_df) # "tbl_df" "tbl" "data.frame"
class(sample_df$id) # "character"
typeof(sample_df$satisfaction) # "double"

# --- glimpse() ---
# Tidyverse version of str(), nicer for data frames
glimpse(sample_df)

# --- summary() ---
# Statistical summary. Good for spotting unexpected ranges, NAs
summary(sample_df)

# --- head() and tail() ---
# View first/last rows
head(sample_df)
head(sample_df, 3)
tail(sample_df, 3)

# --- View() ---
# Opens interactive data viewer in RStudio (capital V!)
View(sample_df)

# View() is great for exploration but:
# - Don't put it in scripts that run non-interactively
# - It opens a new tab each time (can clutter your workspace)
# - Use it in the console, not in your saved script

# --- dim(), nrow(), ncol(), length() ---
# Quick dimension checks
dim(sample_df) # 20 rows, 4 columns
nrow(sample_df) # 20
ncol(sample_df) # 4
length(sample_df) # 4 (number of columns for a data frame!)
# For vectors: length(c(1,2,3)) returns 3

# --- names() ---
names(sample_df) # Column names

# PATTERN: When debugging, the first three things to check are:
# 1. What IS this object? -> class(), str()
# 2. What does it LOOK like? -> print(), head(), View()
# 3. How big is it? -> dim(), length(), nrow()

# Section 4: Systematic Debugging Strategy ---------------------------------
# Teach a repeatable process, not just random poking.

# THE DEBUGGING WORKFLOW:
# 1. READ the error message carefully
# 2. IDENTIFY which line caused the error
# 3. INSPECT the objects on that line (str, class, print)
# 4. ISOLATE the problem (run sub-expressions separately)
# 5. FIX and test
# 6. RE-RUN from the top to make sure nothing else broke

# Example: walk through a multi-step debugging scenario

# Suppose this pipeline throws an error:
# result <- sample_df %>%
#   filter(department == "sales") %>%   # Bug: lowercase "sales"
#   summarize(mean_sat = mean(satisfaction))
# No error, but result has 0 rows! Why?

# Step 1: The output is wrong (0 rows), not an error
# Step 2: Start from the beginning of the pipe

# Isolate each step:
sample_df %>% filter(department == "sales")
# 0 rows! The filter removed everything.

# Step 3: Inspect what's actually in the column
unique(sample_df$department)
# "Sales" "Engineering" "HR" "Marketing"
# It's "Sales" with a capital S, not "sales"

# Step 4: Fix
sample_df %>%
  filter(department == "Sales") %>%
  summarize(mean_sat = mean(satisfaction))
# Works!

# Teach students: when a pipeline gives unexpected results,
# run it one step at a time. Highlight from the top through each
# pipe step and run with Ctrl+Enter.

# Section 5: Using browser() and debug() ----------------------------------
# For problems inside functions, you need to step through the code.

# browser() drops you into an interactive debugging session.
# You can inspect variables, run code, and step through line by line.

# Write a function with a bug:
calc_z_scores <- function(x) {
  x_mean <- mean(x)
  x_sd <- sd(x)
  z <- (x - x_mean) / x_sd
  return(z)
}

# Works fine with clean data:
calc_z_scores(c(10, 20, 30, 40, 50))

# Breaks with NAs:
calc_z_scores(c(10, 20, NA, 40, 50))
# Returns all NA! No error, but wrong.

# Add browser() to step through:
calc_z_scores_debug <- function(x) {
  browser() # Execution pauses here
  x_mean <- mean(x)
  x_sd <- sd(x)
  z <- (x - x_mean) / x_sd
  return(z)
}

# Run it:
# calc_z_scores_debug(c(10, 20, NA, 40, 50))

# In the browser:
# - Type variable names to inspect them
# - n (next) to step to the next line
# - c (continue) to resume running
# - Q (quit) to stop
# - Type any R expression to test it

# After stepping through, you'd see:
# x_mean is NA because mean(c(10, 20, NA, 40, 50)) returns NA
# Fix: add na.rm = TRUE

calc_z_scores_fixed <- function(x) {
  x_mean <- mean(x, na.rm = TRUE)
  x_sd <- sd(x, na.rm = TRUE)
  z <- (x - x_mean) / x_sd
  return(z)
}

calc_z_scores_fixed(c(10, 20, NA, 40, 50))

# debug() is similar but you don't need to edit the function:
# debug(calc_z_scores)       # Turn on debugging for this function
# calc_z_scores(c(10, NA))   # Now it auto-pauses at each line
# undebug(calc_z_scores)     # Turn off debugging

# When to use each:
# - browser(): when you know roughly where the bug is
# - debug(): when you want to step through an entire function
# - print(): when you just need to check a value or two

# RStudio also has visual breakpoints:
# Click in the left margin of the editor to set a red dot.
# When code hits that line, it pauses like browser().

# Section 6: Reproducible Examples with reprex -----------------------------
# When you can't solve a problem yourself, you need to ask for help.
# The key to getting good help is providing a MINIMAL REPRODUCIBLE EXAMPLE.

# A good reprex has:
# 1. Minimal code that reproduces the problem
# 2. Self-contained (doesn't depend on your specific data)
# 3. The error message or unexpected output
# 4. What you expected to happen

# install.packages("reprex")
library(reprex)

# The reprex package formats your example for sharing.
# Copy code to clipboard, then run reprex() and it generates
# a nicely formatted version.

# Example: You're struggling with a date parsing issue.
# BAD question: "My dates aren't working, help?"
# GOOD question with reprex:

# Copy this to clipboard:
# library(lubridate)
# dates <- c("01/15/2024", "2024-02-20", "March 10, 2024")
# ymd(dates)
# # Expected: three valid dates
# # Got: NAs for the first and third

# Then run:
# reprex()

# It produces formatted output with code + results that you can
# paste into Stack Overflow, GitHub Issues, Slack, etc.

# Creating minimal data for reprex:
# Don't share your entire dataset! Create a small example.

# Method 1: Build from scratch
example_data <- data.frame(
  x = c(1, 2, NA, 4),
  y = c("a", "b", "c", "d")
)

# Method 2: Use dput() to create reproducible data
dput(head(sample_df, 5))
# Produces code that recreates those 5 rows exactly.
# Others can paste this into their R session.

# Method 3: Use built-in datasets
# mtcars, iris, airquality, etc. are available to everyone.
# If your bug is about data structure, try to reproduce it with mtcars.

# Section 7: Getting Help Effectively --------------------------------------
# Where to look, in what order.

# Step 1: Read the documentation
?mean # Help for a specific function
help(package = "dplyr") # All functions in a package
vignette("dplyr") # Long-form tutorials
browseVignettes("dplyr") # List all vignettes for a package

# Step 2: Search within R
??correlation # Search all installed help files
help.search("z-score")

# Step 3: Search the web
# - Google: "R" + the error message (in quotes)
# - Stack Overflow: https://stackoverflow.com/questions/tagged/r
# - RStudio Community: https://community.rstudio.com/
# - R-bloggers: https://www.r-bloggers.com/

# TIP: Copy the error message EXACTLY into Google, in quotes.
# This is the single most effective debugging technique.

# Step 4: Ask a human (with a reprex!)
# - Coworkers
# - Stack Overflow (format matters! Use reprex)
# - GitHub Issues (for package-specific bugs)

# Section 8: MAIN EXERCISE ------------------------------------------------
# Debug a series of broken scripts.
# Each script has 1-3 bugs. Students need to find and fix them.

# --- Bug Script 1: Basic errors ---
# This script should compute summary stats for mtcars mpg column.
# There are 3 bugs. Find and fix them.

# BUG VERSION (uncomment to demonstrate):
# library(tidyverse
# mtcars_data <- mtcars
# mean_mpg <- mean(mtcars_data$MPG)
# cat("Mean MPG:" mean_mpg, "\n")

# FIXED VERSION:
library(tidyverse) # Bug 1: missing closing )
mtcars_data <- mtcars
mean_mpg <- mean(mtcars_data$mpg) # Bug 2: MPG -> mpg (case)
cat("Mean MPG:", mean_mpg, "\n") # Bug 3: missing comma after ":"

# --- Bug Script 2: Type issues ---
# This script should calculate average survey score.
# There are 2 bugs.

# BUG VERSION:
# survey_scores <- c("4", "5", "3", "4", "5", "2", "4")
# avg_score <- mean(survey_scores)
# cat("Average score:", avg_score, "\n")
# high_scorers <- survey_scores[survey_scores > 3]
# cat("Number scoring above 3:", length(high_scorers), "\n")

# FIXED VERSION:
survey_scores <- c("4", "5", "3", "4", "5", "2", "4")
survey_scores <- as.numeric(survey_scores) # Bug 1: need numeric conversion
avg_score <- mean(survey_scores)
cat("Average score:", avg_score, "\n")
high_scorers <- survey_scores[survey_scores > 3] # Now works (numeric comparison)
cat("Number scoring above 3:", length(high_scorers), "\n")

# --- Bug Script 3: Data frame operations ---
# This script should filter and summarize employee data.
# There are 3 bugs.

employees <- tibble(
  name = c(
    "Alice",
    "Bob",
    "Charlie",
    "Diana",
    "Edward",
    "Fiona",
    "George",
    "Hannah",
    "Ian",
    "Julia"
  ),
  department = c(
    "Sales",
    "Engineering",
    "Sales",
    "HR",
    "Engineering",
    "Marketing",
    "Sales",
    "HR",
    "Engineering",
    "Marketing"
  ),
  salary = c(
    55000,
    72000,
    58000,
    61000,
    75000,
    53000,
    57000,
    63000,
    71000,
    52000
  ),
  years = c(3, 7, 2, 5, 8, 1, 4, 6, 7, 2)
)

# BUG VERSION:
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

# FIXED VERSION:
senior_employees <- employees %>%
  filter(years >= 5) %>% # Bug 1: missing pipe operator
  summarize(avg_salary = mean(salary))

engineering <- employees %>%
  filter(department == "Engineering") # Bug 2: Department -> department

salary_by_dept <- employees %>%
  group_by(department) %>%
  summarize(avg = mean(salary)) # Bug 3: Salary -> salary

# --- Bug Script 4: Function debugging ---
# This function should return a summary of a numeric column.
# There are 2 bugs.

# BUG VERSION:
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

# Walk through the bugs:
# Bug 1: df$col_name looks for a literal column called "col_name"
#         Need df[[col_name]] for string-based column access
# Bug 2: If values has NAs, mean and sd return NA without na.rm = TRUE
#         (Not triggered by this data, but a lurking bug)

# FIXED VERSION:
summarize_column <- function(df, col_name) {
  values <- df[[col_name]] # Bug 1: $ -> [[ ]]
  tibble(
    mean = mean(values, na.rm = TRUE), # Bug 2: add na.rm
    sd = sd(values, na.rm = TRUE),
    n = length(values),
    n_missing = sum(is.na(values))
  )
}
summarize_column(employees, "salary")
summarize_column(employees, "years")

# --- Bug Script 5: browser() practice ---
# This function should calculate weighted scores but gives wrong results.
# Use browser() to find out why.

# BUG VERSION:
calc_weighted_score <- function(scores, weights) {
  # browser()  # Uncomment to debug
  total <- sum(scores * weights)
  weighted_avg <- total / sum(scores) # Bug: should divide by sum(weights)
  return(weighted_avg)
}

# Test:
test_scores <- c(85, 90, 78)
test_weights <- c(0.3, 0.5, 0.2)
calc_weighted_score(test_scores, test_weights)
# Returns 0.339... but should return 85.1

# Have students add browser(), step through, and find the bug.
# The denominator should be sum(weights), not sum(scores).

# FIXED VERSION:
calc_weighted_score_fixed <- function(scores, weights) {
  total <- sum(scores * weights)
  weighted_avg <- total / sum(weights)
  return(weighted_avg)
}
calc_weighted_score_fixed(test_scores, test_weights)
# Returns 85.1. Correct!

# BONUS: Common Gotchas Collection -----------------------------------------
# A reference list of things that bite everyone eventually.

# 1. = vs == in filter
# filter(df, x = 5)   # WRONG: assigns 5 to x
# filter(df, x == 5)  # RIGHT: tests equality

# 2. | vs %in% for multiple values
# filter(df, x == "a" | x == "b" | x == "c")  # Works but verbose
# filter(df, x %in% c("a", "b", "c"))          # Better

# 3. NA comparisons
NA == NA # Returns NA, not TRUE!
is.na(NA) # Returns TRUE. Always use is.na() to test for NA.

# 4. T vs TRUE
# T and F work as shortcuts, but they can be overwritten:
T <- FALSE # This is legal and terrifying
T # FALSE!
rm(T) # Remove the override
# Always write TRUE/FALSE in full.

# 5. Forgetting to ungroup
# df %>% group_by(x) %>% summarize(n = n())
# If you keep piping after summarize, the data is STILL GROUPED
# by the remaining grouping variables. Use ungroup() or .groups = "drop"

# 6. read.csv vs read_csv
# read.csv  -> base R, converts strings to factors, slower
# read_csv  -> readr/tidyverse, keeps strings as strings, faster

# 7. Namespace conflicts
# Both dplyr and stats have a filter() function.
# If filter() isn't working, try dplyr::filter() explicitly.
# The conflicted package can help: library(conflicted)

# 8. Vectorized vs non-vectorized if
# if() only checks the FIRST element of a vector.
# Use ifelse() or dplyr::if_else() or case_when() for vectors.
# if(c(TRUE, FALSE)) "yes"  # Warning: only first element used

# =============================================================================
# END OF SESSION 4
# =============================================================================

# TEACHING NOTES:
# - This session works best if you live-code the bugs and let students
#   call out what's wrong. Don't just show the fixed version first.
# - Let students struggle with browser() for 5-10 minutes.
#   The discomfort of the interactive debugger is worth pushing through.
# - Emphasize that debugging is a SKILL, not a sign of failure.
#   Professional programmers spend a large fraction of their time debugging.
# - The reprex section is about professional communication. Tie it to
#   how they'd ask a question in Slack or email at work.

# COMMON STUDENT MISTAKES IN THIS SESSION:
# 1. Not reading the full error message
# 2. Changing random things instead of diagnosing first
# 3. Not running code from the top after fixing a bug
# 4. Skipping str()/class() checks and guessing at types
# 5. Being intimidated by the browser() interface

# ASSESSMENT IDEAS:
# - Give students 5 broken scripts of increasing difficulty
# - Ask them to write a reprex for a problem they've encountered
# - Have them explain an error message in plain English
# - Pair debugging: one student writes buggy code, the other fixes it
