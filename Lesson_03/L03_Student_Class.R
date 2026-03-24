########################################
# Session 3: Importing & Cleaning Data #
########################################

# Section 1: Setup and Required Packages ----------------------------------

# Load required packages (tidyverse includes readr)
# install.packages("tidyverse")
library(tidyverse)

# Install and load readxl
library(readxl)

# Install and load here
library(here)

# Install and load haven (for SPSS files). Also includes SAS and STATA and MATLAB
library(haven)

# Easy cleaning and stats helpers
library(janitor)

# Section 2: Working Directories and File Paths ---------------------------

# READING: Look into file paths. Specifically network (//) SAMBA, "standard" windows paths ("C:\"), UNIX paths "/mnt/location". As well as relative paths using "..", "." nomenclature.

# Check your current working directory
getwd()

# List files in your working directory
list.files()
list.files(pattern = "\\.csv")

list.files("C:/RStuff/R-Course/data")



# Section 3: Reading CSV Files ---------------------------------------------

# Read a CSV file using read_csv()
read_csv(file = "C:/RStuff/R-Course/data/sample_data.csv") -> sample_data
# "C:/Users/Sarah/Documents/MyProject/data/file.csv"

# Use here() to show your project root
here("R-Course/data", "sample_data.csv")
read_csv(here("R-Course/data", "sample_data.csv"))

# View the first few rows
head(sample_data)

# Check the structure and data types
str(sample_data)
glimpse(sample_data)

# Compare read_csv() vs read.csv() behavior
read_csv(here("R-Course/data", "sample_data.csv"))
read.csv(here("R-Course/data", "sample_data.csv"))

# Save some stuff!
dir.exists(here("R-Course/Test Export/"))
dir.create(here("R-Course/Test Export/"), showWarnings = FALSE)

write_csv(sample_data, file = here("R-Course/Test Export/", "sample_data.csv"))

# Section 4: Reading Excel Files -------------------------------------------

# Read an Excel file using read_excel()
read_excel(here("R-Course/data", "sample_data.xlsx"))

# Read a specific sheet by name
read_excel(here("R-Course/data", "multi_sheet.xlsx"), sheet = 2)

# Read a specific range of cells
read_excel(here("R-Course/data", "multi_sheet.xlsx"), sheet = 1, range = "A1:C2")

# Skip header rows if needed
read_excel(here("R-Course/data", "multi_sheet.xlsx"), sheet = 1, skip = 1)


# RData Files -------------------------------------------------------------
# ?saveRDS
# readRDS()

?read_rds()
?write_rds()

# ?save
# save(list = ls(all.names = TRUE))

# Section 5: Reading SPSS Files --------------------------------------------

# If you need this it's in the Instructor file!

# Section 6: Identifying Missing Data --------------------------------------

# Create a vector with NA values
test_scores <- c(85, 92, NA, 78, NA, 95, 88)
test_scores

# NA, _NA_Real, _NA_Character
# Missing, Missing at Random, Missing with Purpose

# Use is.na() to identify missing values

# Count missing values in a vector

# Find missing values in a data frame

# Section 7: Handling Missing Data -----------------------------------------

# Remove rows with any NA using na.omit()

# Remove rows where a specific column is NA

# Replace NA with a specific value

# Fill NA with mean of the column

# Section 8: Type Conversion and Parsing -----------------------------------

# Convert character to numeric

# Convert character to date

# Parse numbers with currency symbols

# Handle parsing failures gracefully

# Section 9: Column Name Cleaning ------------------------------------------

# View problematic column names

# Use clean_names() from janitor package

# Manually rename columns

# Section 10: MAIN EXERCISE -----------------------------------------------
# Import and clean a messy dataset

# Step 1: Create a messy CSV file for practice
# Run this code to create a sample messy file

# Step 2: Import the messy data
# Read the messy CSV file

# Step 3: Examine the data
# View structure and identify issues

# Step 4: Clean column names
# Make column names clean and consistent

# Step 5: Fix data types
# Convert columns to appropriate types

# Step 6: Handle missing values
# Decide on strategy for each column with NAs

# Step 7: Create calculated columns if needed
# Add any derived variables

# Step 8: Save the cleaned dataset
# Write the cleaned data to a new CSV file with descriptive name

# BONUS: Advanced Import Techniques ----------------------------------------

# Read only specific columns from a file

# Read with custom column types specified

# Skip rows and handle different delimiters

# Import multiple files and combine them
