########################################
# Session 5: Data Wrangling with dplyr #
########################################

# Section 1: Setup ---------------------------------------------------------

# Load the tidyverse

# Load the here package and read in the employee survey data
# (the file is at data/employee_survey.csv)

# Inspect the data before doing anything (glimpse and summary)

# Section 2: The Pipe Operator ---------------------------------------------

# Write a nested expression that filters survey to the Sales department
# and then summarizes mean satisfaction (no pipe)

# Now rewrite that same operation using the native pipe |>

# Recognize the older %>% pipe too: rewrite it once with %>% so you can
# tell them apart (then use |> for the rest of the course)

# Section 3: filter() - Keep Rows ------------------------------------------

# Filter to one department

# Filter where satisfaction is 4 or higher

# Filter with two conditions (department AND satisfaction)

# Filter with an OR condition

# Rewrite that OR using %in%

# Filter to only remote employees (logical column)

# Filter out rows where salary is missing

# Section 4: select() - Keep Columns ---------------------------------------

# Select employee_id, department, and satisfaction

# Select a range of columns using :

# Drop the employee_id column

# Reorder so department comes first, then everything else

# Rename department to dept

# Section 5: mutate() - Create or Change Columns ---------------------------

# Create a salary_k column (salary divided by 1000)

# Create two columns at once in a single mutate

# Create a total_score column, then an avg_score that uses it

# Create a satisfied column ("Yes"/"No") using if_else()

# Create a tenure_band column using case_when()

# Section 6: arrange() - Sort Rows -----------------------------------------

# Sort by salary ascending

# Sort by salary descending

# Sort by department, then salary descending within department

# Section 7: summarize() - Collapse to a Summary ---------------------------

# Summarize the whole dataset: mean satisfaction, mean engagement, and n()

# Summarize mean salary (watch out for NAs - use na.rm if needed)

# Section 8: group_by() + summarize() --------------------------------------

# Mean satisfaction by department

# Multiple summaries by department, including a count

# Group by department AND remote, summarize, and drop grouping

# Section 9: count() -------------------------------------------------------

# Count employees per department

# Count by department and remote together

# Count departments, sorted most-common first

# Section 10: Putting It Together ------------------------------------------

# Build a pipeline: for non-remote employees, find mean satisfaction and
# engagement by department, keep departments averaging 3+ satisfaction,
# sorted by satisfaction (highest first)

# Section 11: Tidy Data ----------------------------------------------------

# (Conceptual - no code. Be ready to state the three rules of tidy data.)

# Section 12: MAIN EXERCISE ------------------------------------------------

# 1. Calculate mean satisfaction score by department

# 2. Average engagement and satisfaction per department, sorted by engagement

# 3. Filter for departments with engagement >= 3.5, sort by satisfaction

# 4. Create a tenure category (New/Established/Senior/Veteran) and count each

# 5. How many remote vs on-site employees are in each department?

# 6. For each department, what proportion of employees are remote?

# 7. Create a salary_band column and find mean satisfaction per band

# BONUS: Advanced Patterns -------------------------------------------------

# Find the 3 highest-paid employees using slice_max()

# Find the top earner within each department

# Get the distinct combinations of department and remote

# Use group_by + mutate to add each employee's deviation from their
# department's mean satisfaction (keep all rows)
