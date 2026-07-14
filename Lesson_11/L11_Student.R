###########################################
# Session 11: Data Reshaping & Joins      #
###########################################

# Section 1: Setup ---------------------------------------------------------

# Load the tidyverse and here

# Read in the employee survey data

# Read in the department info lookup (data/department_info.csv)

# glimpse both

# Section 2: Wide vs Long - The Concept ------------------------------------

# (Concept - no code. Be ready to describe wide format, long format, and
#  why each is useful. Same data, two shapes.)

# Section 3: pivot_longer - Wide to Long -----------------------------------

# Pivot satisfaction, engagement, and autonomy into long format
# (names_to = "measure", values_to = "score")

# Look at the first 9 rows - notice how employee_id and department repeat

# Using the long data, get mean and sd of each measure with group_by

# Make a faceted bar plot of each measure's distribution

# Section 4: pivot_wider - Long to Wide ------------------------------------

# Reverse the pivot back to wide format

# Build a summary table: mean score per department per measure
# (group_by in long form, then pivot_wider)

# Section 5: Joins - The Concept -------------------------------------------

# (Concept - no code. Know the join family: left, inner, full, anti, semi,
#  and which unmatched rows each keeps.)

# Section 6: left_join - Keep All Left Rows --------------------------------

# left_join the survey with dept_info on "department"

# Check the row count - did it change?

# Summarize satisfaction by region (a column the join added)

# Section 7: inner_join - Keep Only Matches --------------------------------

# inner_join survey with dept_info

# Now inner_join dept_info (left) with survey - how many departments remain?
# What happened to Finance?

# Section 8: full_join and the Others --------------------------------------

# full_join dept_info with survey, then look at the Finance row

# Use anti_join to find departments with no employees

# Use semi_join to find departments that DO have employees

# Section 9: When Join Keys Don't Match ------------------------------------

# Read the messy lookup (data/department_info_messy.csv) and look at its keys

# left_join it and find which employees got NA region

# Fix the keys (str_trim + str_to_title) and rejoin - confirm NAs disappear

# Section 10: MAIN EXERCISE ------------------------------------------------

# 1. Pivot the three Likert columns into long format

# 2. Get mean and sd of each measure from the long data

# 3. Pivot back to wide: mean score per department per measure

# 4. left_join the survey with department info

# 5. Summarize satisfaction by region

# 6. Use anti_join to find departments with no employees

# 7. Join the messy lookup, find the NA rows, fix the keys, rejoin

# BONUS: Going Further -----------------------------------------------------

# Join, then plot satisfaction by region

# Try pivot_longer with names_sep and the .value token on pre/post data

# Chain a join, a reshape, and a summary in one pipeline
