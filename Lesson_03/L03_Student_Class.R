########################################
# Session 3: Importing & Cleaning Data #
########################################

# Section 1: Setup and Required Packages ----------------------------------

# Load required packages (tidyverse includes readr)

# Install and load readxl

# Install and load here

# Install and load haven (for SPSS files)

# Section 2: Working Directories and File Paths ---------------------------

# Check your current working directory

# List files in your working directory

# Use here() to show your project root

# Section 3: Reading CSV Files ---------------------------------------------

# Read a CSV file using read_csv()

# View the first few rows

# Check the structure and data types

# Compare read_csv() vs read.csv() behavior

# Section 4: Reading Excel Files -------------------------------------------

# Read an Excel file using read_excel()

# Read a specific sheet by name

# Read a specific range of cells

# Skip header rows if needed

# Section 5: Reading SPSS Files --------------------------------------------

# Read an SPSS file using read_sav()

# View the structure and labels

# Section 6: Identifying Missing Data --------------------------------------

# Create a vector with NA values

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
