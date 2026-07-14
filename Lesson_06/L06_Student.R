###############################################
# Session 6: Tidy-Select & Column Operations  #
###############################################

# Section 1: Setup ---------------------------------------------------------

# Load the tidyverse and here

# Read in the employee survey data (data/employee_survey.csv)

# Build a richer frame with five Q-items so the helpers have a naming
# pattern to match. Run this block as given:
# survey_items <- survey |>
#   mutate(
#     Q1_workload = satisfaction,
#     Q2_support = engagement,
#     Q3_growth = autonomy,
#     Q4_balance = pmin(5, satisfaction + 0),
#     Q5_recognition = pmax(1, engagement - 0)
#   ) |>
#   select(employee_id, department, tenure_years, salary, remote,
#          starts_with("Q"))

# glimpse the result

# Section 2: Why Tidy-Select Exists ----------------------------------------

# Write the tedious version first: mean of all five Q items, one line each
# inside a single summarize(). Feel the pain so the next sections land.

# Section 3: Pattern-Matching Helpers --------------------------------------

# Use starts_with() to select all Q columns

# Use ends_with() to select the column ending in "_workload"

# Use contains() to select columns containing "growth"

# Use matches() with a regex to select Q1 through Q3 only

# Combine: select department plus all Q columns

# Section 4: where() -------------------------------------------------------

# Select all numeric columns

# Select all character columns

# Select all logical columns

# Write a custom predicate: numeric columns whose mean is above 3

# Section 5: across() ------------------------------------------------------

# Rewrite Section 2's tedious summarize using across()

# Summarize the mean of every numeric column, named with a mean_ prefix

# Use across() inside mutate() to z-score every Q item (add a _z suffix)

# Summarize mean AND sd of every Q item using a named list of functions

# Section 6: Anonymous Function Syntax -------------------------------------

# Use across() with \(x) to take a mean with na.rm = TRUE

# Do the same with the ~ .x formula form (so you recognize it)

# Section 7: pick() --------------------------------------------------------

# Use pick() with rowSums() to make a q_total column

# Section 8: rowwise() -----------------------------------------------------

# Use rowwise() + c_across() to compute each employee's mean Q score

# Then do the same thing the fast vectorized way with rowMeans() + pick()

# Section 9: MAIN EXERCISE -------------------------------------------------

# 1. Select all Q items plus employee_id

# 2. Select every numeric column using where()

# 3. Mean of every Q item in one summarize()

# 4. Mean AND sd of every Q item, clearly named

# 5. Z-score every Q item, keeping the originals

# 6. Each employee's total score across the five Q items

# 7. By department, mean of every Q item

# 8. Mean of all numeric columns with where(is.numeric); then note when
#    name-based vs type-based selection is the right choice

# BONUS: Advanced Patterns -------------------------------------------------

# Use if_any() to keep rows where any Q item equals 5

# Use if_all() to keep rows where all Q items are 3 or higher

# Use rename_with() to strip the "Q1_" style prefix from the Q columns
