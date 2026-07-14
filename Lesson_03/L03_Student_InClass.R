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
read_excel(
  here("R-Course/data", "multi_sheet.xlsx"),
  sheet = 1,
  range = "A1:C2"
)

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
test_scores <- c(85, 92, NA, 78, NA, 95, 88, NULL)
test_scores

# Importing with NA
read_csv(na = c("", "NA", "NULL", "-1", "999"))

# NA, _NA_Real, _NA_Character
# Missing, Missing at Random, Missing with Purpose

# Use is.na() to identify missing values
is.na(test_scores)
is.null(test_scores)

# Count missing values in a vector
sum(is.na(test_scores)) <= 2

# Find the index
test_scores[which(!is.na(test_scores))]

# Proportion missing
round(mean(is.na(test_scores)) * 100, 2)

# Find missing values in a data frame / tibble
sample_with_na <- tibble(
  id = 1:6,
  name = c("Alice", "Bob", NA, "Diana", "Edward", "Frank"),
  age = c(25, NA, 28, 35, NA, 32),
  score = c(85.5, 92.3, 78.9, NA, 95.7, 88.2)
)

is.na(sample_with_na)
colSums(is.na(sample_with_na))
summary(sample_with_na)

install.packages("naniar")
library("naniar")
vis_miss(sample_with_na)

# Section 7: Handling Missing Data -----------------------------------------

# Remove rows with any NA using na.omit()
rowSums(is.na(sample_with_na)) > 2
na.omit(sample_with_na)

# Remove rows where a specific column is NA
filter(sample_with_na, !is.na(name), !is.na(score))

# Replace NA with a specific value
sample_with_na$score[is.na(sample_with_na$score)] <- 10
mutate(sample_with_na, age = replace_na(age, 0))

# Fill NA with mean of the column
mutate(sample_with_na, age = replace_na(age, mean(age, na.rm = TRUE)))
mutate(sample_with_na, age = impute_mean(sample_with_na$age))

# fill down
fill(sample_with_na, name, .direction = "down")

# Flagging
mutate(
  sample_with_na,
  score_missing = is.na(score),
  age_missing = is.na(age),
  age = replace_na(age, mean(age, na.rm = TRUE))
)

# Section 8: Type Conversion and Parsing -----------------------------------

# Convert character to numeric
numbers_as_char <- c(10, 20, 30, 40, "N/A")
as.numeric(numbers_as_char)

c("$100", "20%", "30.5 kg") |>
  parse_number()

# Convert character to date
dates_as_char <- c("2024-01-15", "2024-02-20", "2024-03-10")
# US MM-DD-YYYY. DD-MM-YYYY. YYYY-DD-MM. Numeric dates (Search how Excel handles dates and find Excel's "Origin")
as.Date(dates_as_char) -> dates_as_date
str(dates_as_char)
class(dates_as_char)
str(dates_as_date)
class(dates_as_date)

# HOMEWORK: POSIX compliant Dates
?POSIXct

dates_messy <- c("01/15/2024", "02/20/2024", "03/10/2024")
as.Date(dates_messy, format = "%m/%d/%Y")

library(lubridate)

mdy(dates_messy)

# Parse numbers with currency symbols

# Handle parsing failures gracefully

# Section 9: Column Name Cleaning ------------------------------------------

# View problematic column names

# Use clean_names() from janitor package

# Manually rename columns

# Section 10: MAIN EXERCISE -----------------------------------------------
# Import and clean a messy dataset
library(tidyverse)
library(here)
read_csv(here("R-Course", "data", "messy_participant_data.csv")) -> messy_data

messy_data$`Date Enrolled`

messy_data[grepl(messy_data$`Date Enrolled`, pattern = "^(0-9)"), ]

messy_data$Gender

str_trunc(messy_data$Gender, width = 1, side = "left", ellipsis = ".")

filter(messy_data, str_detect(`Date Enrolled`, "-")) |>
  mutate(ymd(`Date Enrolled`)) |>
  glimpse()

messy_data$`Date Enrolled`[c(3, 4, 8)] <- c("2024-02-01", "2024-01-25", "2024-03-05")
messy_data$`Date Enrolled`
?lubridate
?as.Date

as.Date(messy_data$`Date Enrolled`) -> date_test
str(date_test)
class(date_test)

ymd(messy_data$`Date Enrolled`) -> date_test
str(date_test)
class(date_test)

messy_data$`Date Enrolled` <- ymd(messy_data$`Date Enrolled`)

year(messy_data$`Date Enrolled`)
month(messy_data$`Date Enrolled`)
day(messy_data$`Date Enrolled`)

paste0(month(messy_data$`Date Enrolled`), "-", day(messy_data$`Date Enrolled`), "-", year(messy_data$`Date Enrolled`))
mdy(paste0(month(messy_data$`Date Enrolled`), "-", day(messy_data$`Date Enrolled`), "-", year(messy_data$`Date Enrolled`)))

# as.data.frame# Step 1: Create a messy CSV file for practice
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
