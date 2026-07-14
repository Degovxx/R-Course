########################################
# Session 3: Importing & Cleaning Data #
########################################

# This session is crucial! Most real data is messy.
# Emphasize: "You'll spend 80% of your time cleaning data, 20% analyzing it"
# Show students this is normal and teach them systematic approaches.

# Section 1: Setup and Required Packages ----------------------------------

# Load tidyverse (includes readr, dplyr, tidyr, etc.)
library(tidyverse)

# Load additional packages for different file formats
library(readxl) # For Excel files
library(here) # For project-relative paths
library(haven) # For SPSS, Stata, SAS files
library(janitor) # For cleaning column names

# Explain each package's purpose:
# - readr: fast, consistent CSV reading (part of tidyverse)
# - readxl: Excel files (.xlsx, .xls)
# - haven: statistical software formats (SPSS, Stata, SAS)
# - here: reproducible file paths
# - janitor: data cleaning utilities

# If packages aren't installed:
# install.packages(c("readxl", "here", "haven", "janitor"))

# Section 2: Working Directories and File Paths ---------------------------
# File paths are a common source of frustration!
# This is worth spending time on.

# Check current working directory
getwd()

# Explain that working directory is where R looks for files
# by default. It's often set to your project folder.

# List files in current directory
list.files()

# List files in a specific subdirectory
list.files("data") # If you have a data folder
list.files(pattern = "\\.csv$") # Only CSV files

# The problem with absolute paths:
# DON'T DO THIS: "C:/Users/Sarah/Documents/MyProject/data/file.csv"
# - Not reproducible across computers
# - Breaks if you move the project
# - Doesn't work for collaborators

# The solution: use here package for project-relative paths
here() # Shows your project root
here("data") # Path to data folder
here("data", "myfile.csv") # Path to specific file

# here() finds your project root by looking for:
# - .Rproj file
# - .git directory
# - .here file
# This makes paths reproducible across different computers!

# Section 3: Reading CSV Files ---------------------------------------------
# CSV is the most common data format
# readr::read_csv() is better than base R's read.csv()

# First, let's create a sample CSV file to work with
sample_data <- tibble(
  id = 1:5,
  name = c("Alice", "Bob", "Charlie", "Diana", "Edward"),
  age = c(25, 30, 28, 35, 27),
  score = c(85.5, 92.3, 78.9, 88.1, 95.7)
)

# Create a data directory if it doesn't exist
if (!dir.exists("data")) {
  dir.create("data")
}

# Write the sample data
write_csv(sample_data, here("data", "sample_data.csv"))

# Read a CSV file using readr::read_csv()
data <- read_csv(here("data", "sample_data.csv"))

# read_csv() automatically:
# - Guesses column types (and shows you the guesses)
# - Treats first row as column names
# - Returns a tibble
# - Is much faster than read.csv()

# View the data
data
head(data, 3)
glimpse(data) # Shows structure and types

# Check the structure
str(data)

# Compare with base R read.csv()
data_base <- read.csv(here("data", "sample_data.csv"))

# Show the differences:
class(data) # "spec_tbl_df" "tbl_df" "tbl" "data.frame"
class(data_base) # "data.frame"

# read.csv() converts strings to factors by default (older R versions)
# read_csv() does not - it keeps them as characters

# Specify column types explicitly (useful for problematic files)
data_typed <- read_csv(
  here("data", "sample_data.csv"),
  col_types = cols(
    id = col_integer(),
    name = col_character(),
    age = col_integer(),
    score = col_double()
  )
)


# Section 4: Reading Excel Files -------------------------------------------
# Excel files are very common in industry/academia
# readxl package handles both .xlsx and .xls

# Create a sample Excel file first
# (In practice, students would have an existing file)
library(writexl)
write_xlsx(sample_data, here("data", "sample_data.xlsx"))

# Read an Excel file
excel_data <- read_excel(here("data", "sample_data.xlsx"))
excel_data

# Excel files can have multiple sheets!

# Create a multi-sheet Excel file
data_list <- list(
  students = sample_data,
  scores = tibble(test = c("Test1", "Test2"), avg = c(85, 90))
)
write_xlsx(data_list, here("data", "multi_sheet.xlsx"))

# List sheet names
excel_sheets(here("data", "multi_sheet.xlsx"))

# Read a specific sheet by name
sheet1 <- read_excel(here("data", "multi_sheet.xlsx"), sheet = "students")
sheet2 <- read_excel(here("data", "multi_sheet.xlsx"), sheet = "scores")

# Read a specific sheet by position
sheet1_alt <- read_excel(here("data", "multi_sheet.xlsx"), sheet = 1)

# Read a specific range of cells
range_data <- read_excel(
  here("data", "multi_sheet.xlsx"),
  sheet = "students",
  range = "A1:C6" # First 3 columns, 6 rows
)

# Skip header rows (useful if Excel has title rows)
skip_data <- read_excel(
  here("data", "sample_data.xlsx"),
  skip = 0 # Number of rows to skip before header
)

# Common Excel issues:
# - Multiple sheets (need to specify which one)
# - Header rows that aren't in row 1
# - Merged cells (cause problems - avoid if possible)
# - Dates stored as numbers (Excel's date system)

# Section 5: Reading SPSS Files --------------------------------------------
# Common in social sciences
# SPSS files often have value labels and metadata

# Create a sample SPSS file (in practice, students would have one)
# This requires haven package
sample_spss <- sample_data %>%
  mutate(gender = c("Male", "Female", "Male", "Female", "Male"))

write_sav(sample_spss, here("data", "sample_data.sav"))

# Read SPSS file
spss_data <- read_sav(here("data", "sample_data.sav"))
spss_data

# SPSS files have special attributes (labels)
# View labels
attr(spss_data$gender, "labels")

# Convert labeled values to factors
spss_data_factors <- as_factor(spss_data)

# Also show read_stata() for Stata files, read_sas() for SAS

# Section 6: Identifying Missing Data --------------------------------------
# Missing data is everywhere in real datasets!
# R represents missing data as NA (Not Available)

# Create a vector with NA values
test_scores <- c(85, 92, NA, 78, NA, 95, 88)
test_scores

# Use is.na() to identify missing values
is.na(test_scores) # Returns logical vector

# Count missing values
sum(is.na(test_scores)) # 2 missing values

# Which positions are missing?
which(is.na(test_scores)) # Positions 3 and 5

# Proportion missing
mean(is.na(test_scores)) # 0.2857 (28.57%)

# Find missing values in a data frame
sample_with_na <- tibble(
  id = 1:6,
  name = c("Alice", "Bob", NA, "Diana", "Edward", "Frank"),
  age = c(25, NA, 28, 35, NA, 32),
  score = c(85.5, 92.3, 78.9, NA, 95.7, 88.2)
)

# Check each column for NAs
colSums(is.na(sample_with_na))

# Or use a cleaner summary
summary(sample_with_na)

# Visualize missing data pattern (useful for larger datasets)
# install.packages("naniar")
library(naniar)
vis_miss(sample_with_na) # Visual representation of missingness

# Different types of "missing" in raw data:
# - NA (R's missing value)
# - Empty strings ""
# - "N/A", "n/a", "NA" as text
# - 999 or -999 as missing indicators
# - Blank cells in Excel

# Section 7: Handling Missing Data -----------------------------------------
# There's no one-size-fits-all approach!
# Strategy depends on: why data is missing, how much is missing, analysis goals

# Strategy 1: Complete case analysis (remove rows with any NA)
complete_data <- na.omit(sample_with_na)
complete_data

# This can dramatically reduce sample size!
nrow(sample_with_na) # 6 rows
nrow(complete_data) # Only 2 rows left!

# Strategy 2: Remove rows where specific column(s) are NA
# More common and less wasteful
data_no_na_age <- sample_with_na %>%
  filter(!is.na(age)) # Keep rows where age is NOT missing

# Or using base R
data_no_na_age_base <- sample_with_na[!is.na(sample_with_na$age), ]

# Strategy 3: Replace NA with a specific value
# Only appropriate in specific contexts!
sample_filled <- sample_with_na %>%
  mutate(score = replace_na(score, 0)) # Replace NA scores with 0

# Be careful! Replacing with 0 might not make sense
# (0 score vs missing score are different)

# Strategy 4: Replace NA with mean/median (simple imputation)
sample_mean_impute <- sample_with_na %>%
  mutate(score = replace_na(score, mean(score, na.rm = TRUE)))

# na.rm = TRUE tells functions to remove NAs before calculating

# Strategy 5: Forward fill or backward fill (for time series)
sample_with_na %>%
  fill(name, .direction = "down") # Carry last observation forward

# Strategy 6: Create indicator variable (flag missing)
sample_with_flag <- sample_with_na %>%
  mutate(
    score_missing = is.na(score),
    score_imputed = replace_na(score, mean(score, na.rm = TRUE))
  )

# Discuss when each strategy is appropriate:
# - Complete case: when data is MCAR (missing completely at random)
# - Mean imputation: quick but can reduce variance
# - Indicator variable: preserves information about missingness
# - Advanced methods: multiple imputation (beyond this course)

# Section 8: Type Conversion and Parsing -----------------------------------
# Common issue - data stored as wrong type

# Character to numeric
numbers_as_char <- c("10", "20", "30", "40")
as.numeric(numbers_as_char)

# What happens with invalid values?
messy_numbers <- c("10", "20", "N/A", "40")
as.numeric(messy_numbers) # Warning! "N/A" becomes NA

# Always check for warnings when converting types!

# Use parse_number() from readr for more robust parsing
parse_number(c("$100", "20%", "30.5 kg")) # Extracts just the number

# Character to date
dates_as_char <- c("2024-01-15", "2024-02-20", "2024-03-10")
as.Date(dates_as_char)

# Specify date format if non-standard
dates_messy <- c("01/15/2024", "02/20/2024", "03/10/2024")
as.Date(dates_messy, format = "%m/%d/%Y")

# Date format codes:
# %Y = 4-digit year, %y = 2-digit year
# %m = month as number, %b = abbreviated month name
# %d = day of month

# Use lubridate for easier date parsing (part of tidyverse)
library(lubridate)
mdy(dates_messy) # Automatically parse month-day-year
ymd("2024-01-15") # Year-month-day
dmy("15-01-2024") # Day-month-year

# Handle parsing failures gracefully
safe_numbers <- c("10", "20", "not a number", "40")
result <- suppressWarnings(as.numeric(safe_numbers))
result # 10 20 NA 40

# Find which ones failed
problems <- is.na(result) & !is.na(safe_numbers)
safe_numbers[problems] # "not a number"

# readr provides parse_*() functions that handle errors better:
parse_number("not a number", na = c("", "NA", "not a number"))


# Section 9: Column Name Cleaning ------------------------------------------
# Good column names make analysis much easier!

# Create data with problematic column names
messy_names <- tibble(
  `Participant ID` = 1:5,
  `Age (years)` = c(25, 30, 28, 35, 27),
  `Test Score (%)` = c(85, 92, 78, 88, 95),
  `Date of Birth` = c(
    "1999-01-15",
    "1994-06-20",
    "1996-03-10",
    "1989-09-05",
    "1997-11-30"
  )
)

# Problems: spaces, parentheses, uppercase, special characters
names(messy_names)

# Solution 1: Use janitor::clean_names()
clean_data <- messy_names %>%
  clean_names()

names(clean_data) # participant_id, age_years, test_score_percent, date_of_birth

# clean_names() converts to snake_case by default
# Options: "snake", "camel", "title", etc.

# Solution 2: Manually rename columns
clean_data_manual <- messy_names %>%
  rename(
    id = `Participant ID`,
    age = `Age (years)`,
    score = `Test Score (%)`,
    dob = `Date of Birth`
  )

# Solution 3: Rename all columns at once
names(messy_names) <- c("id", "age", "score", "dob")

# Good column names are:
# - Short but descriptive
# - No spaces (use _ or camelCase)
# - No special characters
# - Lowercase (easier to type)
# - Consistent style across your project

# Section 10: MAIN EXERCISE -----------------------------------------------
# This is the main activity - a realistic messy dataset
# Walk through this step-by-step, then have students try variations

# Step 1: Create a messy CSV file for practice
# In real life, students would receive this file
# This simulates common data quality issues

messy_data_raw <- tibble(
  `Participant ID` = c(
    "P001",
    "P002",
    "P003",
    "P004",
    "P005",
    "P006",
    "P007",
    "P008",
    "P009",
    "P010"
  ),
  `Age (years)` = c(
    "25",
    "30",
    "N/A",
    "35",
    "28",
    "27",
    "forty-two",
    "29",
    "31",
    "26"
  ),
  Gender = c("F", "M", "F", "m", "F", "Male", "Female", "F", "M", ""),
  `Income ($)` = c(
    "$45,000",
    "$52,000",
    "$48,000",
    "N/A",
    "$51,000",
    "$47,000",
    "$55,000",
    "$49,000",
    "$53,000",
    "$46000"
  ),
  `Test Score` = c("85", "92", "78", "88", "95", "87", "N/A", "91", "84", "89"),
  `Date Enrolled` = c(
    "2024-01-15",
    "2024-01-20",
    "2024/02/01",
    "Jan 25, 2024",
    "2024-02-10",
    "2024-02-15",
    "2024-03-01",
    "3/5/2024",
    "2024-03-10",
    "2024-03-15"
  ),
  Notes = c(
    "Completed all tasks",
    NA,
    "Missed session 2",
    "",
    "Excellent performance",
    NA,
    "Needs follow-up",
    "",
    NA,
    ""
  )
)

# Write to CSV
write_csv(messy_data_raw, here("data", "messy_participant_data.csv"))

# Point out the issues in this dataset:
# 1. Column names have spaces and special characters
# 2. Age has "N/A" text and a word ("forty-two")
# 3. Gender has inconsistent coding (M/Male, F/Female, blank)
# 4. Income has currency symbols and commas
# 5. Test Score has "N/A" as text
# 6. Dates in multiple formats
# 7. Empty strings vs NA for missing data

# Step 2: Import the messy data
raw_data <- read_csv(here("data", "messy_participant_data.csv"))

# read_csv() will show warnings about parsing problems
# This is good! It alerts us to issues.

# Step 3: Examine the data
raw_data
glimpse(raw_data)
summary(raw_data)

# Always start by looking at your data!
# Use View(raw_data) interactively to inspect

# Check for issues in each column
table(raw_data$Gender) # Inconsistent coding
table(raw_data$`Age (years)`) # Text values
table(raw_data$`Test Score`) # "N/A" as text


# Step 4: Clean column names
clean_data <- raw_data %>%
  clean_names()

names(clean_data) # Much better!


# Step 5: Fix data types and handle missing values
clean_data <- clean_data %>%
  mutate(
    # Clean age: convert to numeric, handle "N/A" and text
    age_years = parse_number(age_years), # Handles "N/A", turns text into NA

    # Standardize gender coding
    gender = case_when(
      gender %in% c("F", "Female") ~ "Female",
      gender %in% c("M", "m", "Male") ~ "Male",
      gender == "" ~ NA_character_,
      TRUE ~ gender # Keep anything else as-is
    ),

    # Clean income: remove $ and commas, convert to numeric
    income = parse_number(income),

    # Clean test score: convert to numeric (handles "N/A")
    test_score = parse_number(test_score),

    # Parse dates (try multiple formats)
    date_enrolled = case_when(
      str_detect(date_enrolled, "^\\d{4}-\\d{2}-\\d{2}$") ~ ymd(date_enrolled),
      str_detect(date_enrolled, "^\\d{4}/\\d{2}/\\d{2}$") ~ ymd(date_enrolled),
      str_detect(date_enrolled, "^\\d{1,2}/\\d{1,2}/\\d{4}$") ~ mdy(
        date_enrolled
      ),
      TRUE ~ mdy(date_enrolled) # Try month-day-year for remaining
    ),

    # Clean notes: convert empty strings to NA
    notes = na_if(notes, "")
  )

# Walk through each transformation step-by-step
# Explain parse_number(), case_when(), and date parsing

# Step 6: Verify the cleaning
glimpse(clean_data)
summary(clean_data)

# Check for remaining issues
problems(clean_data) # If read_csv had parsing problems

# Summary of missing values
clean_data %>%
  summarise(across(everything(), ~ sum(is.na(.))))


# Step 7: Create calculated columns if needed
clean_data <- clean_data %>%
  mutate(
    # Age group
    age_group = case_when(
      age_years < 30 ~ "Under 30",
      age_years >= 30 ~ "30 and over",
      TRUE ~ NA_character_
    ),

    # Income category
    income_category = case_when(
      income < 48000 ~ "Lower",
      income >= 48000 & income < 52000 ~ "Middle",
      income >= 52000 ~ "Higher",
      TRUE ~ NA_character_
    ),

    # Pass/fail based on test score
    passed = test_score >= 80
  )


# Step 8: Save the cleaned dataset
# Use descriptive filenames with dates!
# Format: YYYY-MM-DD_description.csv

output_filename <- paste0(
  Sys.Date(),
  "_participant_data_cleaned.csv"
)

write_csv(clean_data, here("data", output_filename))

# Also show that you can save intermediate versions:
# write_csv(raw_data, here("data", "01_raw_data.csv"))
# write_csv(clean_data, here("data", "02_cleaned_data.csv"))

# Save as RDS (R native format, preserves types)
saveRDS(clean_data, here("data", "participant_data_cleaned.rds"))

# Read back RDS
clean_data_rds <- readRDS(here("data", "participant_data_cleaned.rds"))

# RDS vs CSV:
# - RDS preserves data types perfectly (factors, dates, etc.)
# - RDS is R-specific (can't open in Excel)
# - CSV is universal but types need re-specification
# - Use RDS for intermediate R-only files, CSV for sharing

# BONUS: Advanced Import Techniques ----------------------------------------

# Read only specific columns
partial_data <- read_csv(
  here("data", "messy_participant_data.csv"),
  col_select = c(`Participant ID`, `Age (years)`, Gender)
)

# Specify column types to avoid parsing issues
typed_data <- read_csv(
  here("data", "messy_participant_data.csv"),
  col_types = cols(
    `Participant ID` = col_character(),
    `Age (years)` = col_character(), # Keep as character, clean later
    Gender = col_character(),
    `Income ($)` = col_character(),
    `Test Score` = col_character(),
    `Date Enrolled` = col_character(),
    Notes = col_character()
  )
)

# Read with different delimiters
# read_delim(file, delim = ";")    # Semicolon-separated
# read_tsv(file)                    # Tab-separated

# Skip rows and custom NA values
data_custom_na <- read_csv(
  here("data", "messy_participant_data.csv"),
  na = c("", "NA", "N/A", "n/a", ".") # Treat all these as missing
)

# Import multiple files and combine
# Very common when you have data in multiple files!

# Create multiple sample files
sample_data_1 <- clean_data %>% slice(1:5)
sample_data_2 <- clean_data %>% slice(6:10)

write_csv(sample_data_1, here("data", "data_part1.csv"))
write_csv(sample_data_2, here("data", "data_part2.csv"))

# Method 1: Read and bind manually
part1 <- read_csv(here("data", "data_part1.csv"))
part2 <- read_csv(here("data", "data_part2.csv"))
combined <- bind_rows(part1, part2)

# Method 2: Read all files matching a pattern
all_files <- list.files(
  path = here("data"),
  pattern = "data_part.*\\.csv$",
  full.names = TRUE
)

# Read and combine in one step
combined_auto <- all_files %>%
  map_df(read_csv) # map_df applies read_csv to each file and combines

# This is incredibly useful for:
# - Data collected over multiple days/months
# - Multiple participants/sites
# - Data exported in chunks

# =============================================================================
# END OF SESSION 3
# =============================================================================

# TEACHING NOTES FOR NEXT TIME:
# - Emphasize that data cleaning is iterative, not one-and-done
# - Always save your cleaning code (reproducibility!)
# - Document your decisions (why did you remove/impute?)
# - Next session: Data transformation and manipulation with dplyr

# COMMON STUDENT MISTAKES TO WATCH FOR:
# 1. Not checking data after import (always inspect!)
# 2. Using absolute file paths instead of here()
# 3. Not handling different representations of missing (NA, "N/A", "", etc.)
# 4. Overwriting original data (always keep raw data separate)
# 5. Not documenting cleaning decisions
# 6. Assuming data types are correct without checking

# KEY CONCEPTS TO REINFORCE:
# - Reproducible file paths with here()
# - read_csv() vs read.csv() differences
# - Multiple strategies for missing data (no single "right" answer)
# - Type conversion and parsing issues
# - Descriptive file naming conventions
# - Always keep raw data, save cleaned data separately

# ASSESSMENT IDEAS:
# - Give students a new messy dataset to clean
# - Ask them to document each cleaning step and justify decisions
# - Have them create a "data dictionary" describing cleaned variables
# - Compare base R and tidyverse approaches to same task
# - Debugging exercise: fix broken import/cleaning code
