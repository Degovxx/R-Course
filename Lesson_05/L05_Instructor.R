########################################
# Session 5: Data Wrangling with dplyr #
########################################

# This is the session where R starts to feel powerful. Everything up to
# now has been foundations: data structures, importing, debugging. Now
# students learn the verbs they'll use every single day. dplyr is the
# heart of the tidyverse for data manipulation.
#
# Pacing note: this is a BIG session. The six core verbs plus the pipe
# plus grouping is a lot. Prioritize filter, select, mutate, and the pipe
# in the first half. group_by + summarize is the payoff in the second half.
# If you run short on time, count() and tidy data can become homework.

# Section 1: Setup ---------------------------------------------------------

# Load the tidyverse (dplyr comes with it)
library(tidyverse)

# We'll work with employee survey data throughout this session.
# This connects to the organizational-research theme of the course.
# The file was created for this course; in real life it would be an
# export from a survey platform (Qualtrics, SurveyMonkey, etc.)

library(here)
survey <- read_csv(here("data", "employee_survey.csv"))

# Always look first (lesson from Session 4: inspect before you operate)
glimpse(survey)
summary(survey)

# Columns:
# - employee_id: unique identifier
# - department: Sales, Engineering, HR, Marketing, Operations
# - satisfaction: job satisfaction, 1-5 Likert
# - engagement: engagement score, 1-5 Likert
# - autonomy: perceived autonomy, 1-5 Likert
# - tenure_years: years at the company
# - salary: annual salary in dollars
# - remote: TRUE/FALSE, works remotely

# Section 2: The Pipe Operator ---------------------------------------------
# Before the verbs, teach the pipe. It's what makes dplyr readable.
# Spend real time here. The pipe is the single biggest readability win
# in modern R, and students who don't "get" it will write nested mush.

# The problem the pipe solves: nested function calls read inside-out.
# Without the pipe, to filter then summarize you nest:
summarize(
  filter(survey, department == "Sales"),
  mean_sat = mean(satisfaction)
)
# To read that, your eye has to start in the MIDDLE (filter) and work out.

# The pipe takes the thing on the LEFT and feeds it as the FIRST argument
# to the function on the RIGHT. Read it as the word "then".

# Same operation with the pipe, reads top-to-bottom:
survey |>
  filter(department == "Sales") |>
  summarize(mean_sat = mean(satisfaction))

# Read aloud: "take survey, THEN filter to Sales, THEN summarize the mean."

# Two pipes exist, and students will see both. Explain the difference.
# |> is the NATIVE pipe, built into R itself since version 4.1 (2021).
#    No package needed. This is what we use in this course.
# %>% is the magrittr pipe, the older tidyverse pipe. It requires a package
#    (loaded automatically with the tidyverse). You'll see it constantly in
#    existing code, tutorials, and Stack Overflow, so RECOGNIZE it, but
#    write |> in your own code.

# For almost everything in this course the two behave identically:
survey |> filter(department == "Sales") |> nrow()
survey %>% filter(department == "Sales") %>% nrow() # same result, older style

# Why we standardize on |>:
# - It's built into R, so it works with zero dependencies
# - It's the direction R core is heading
# - It's what new R documentation increasingly uses
# The one syntax quirk: |> requires the parentheses on the function.
# Write `x |> sum()`, not `x |> sum`. (%>% was lenient about this.)

# Keyboard shortcut for the pipe: Ctrl+Shift+M (Cmd+Shift+M on Mac)
# Make that shortcut insert |> by checking this box once:
# Tools > Global Options > Code > "Use native pipe operator"
# Do this now so every Ctrl+Shift+M gives you the native pipe.

# Section 3: filter() - Keep Rows ------------------------------------------
# filter() keeps rows that match a condition. Think of it as the row-picker.

# Single condition
survey |> filter(department == "Engineering")

# Numeric comparison
survey |> filter(satisfaction >= 4)

# Multiple conditions with comma (comma means AND)
survey |> filter(department == "Sales", satisfaction >= 4)

# Same thing with explicit & (identical result)
survey |> filter(department == "Sales" & satisfaction >= 4)

# OR conditions with |
survey |> filter(department == "Sales" | department == "Marketing")

# Better way to write that OR: %in%
# (callback to Session 4 gotchas: %in% beats chained | for multiple values)
survey |> filter(department %in% c("Sales", "Marketing"))

# Logical columns filter directly (no == TRUE needed)
survey |> filter(remote)
survey |> filter(!remote) # the not-remote employees

# Filtering out missing values
# (callback to Session 3: real data has NAs)
survey |> filter(!is.na(salary))

# Common mistake to flag: = vs ==
# survey |> filter(department = "Sales")
# Error: We detected a named argument... did you mean ==?
# dplyr actually catches this one with a helpful message. Show it.

# Section 4: select() - Keep Columns ---------------------------------------
# select() picks columns. Think of it as the column-picker.

# Select specific columns by name (no quotes needed in dplyr!)
survey |> select(employee_id, department, satisfaction)

# Select a range of columns with :
survey |> select(satisfaction:autonomy)

# Drop columns with - (minus)
survey |> select(-employee_id)
survey |> select(-c(salary, remote))

# Reorder columns: select() keeps the order you list them in
survey |> select(department, employee_id, satisfaction)

# everything() helper: "the column I name, then all the rest"
# Useful for moving one column to the front
survey |> select(department, everything())

# rename() is select's cousin: rename without dropping anything
survey |> rename(dept = department)
# Syntax is new_name = old_name (the new name goes on the LEFT)

# Tidy-select helpers get a full treatment next session (Session 6).
# Just preview that select() can match patterns:
survey |> select(starts_with("s")) # satisfaction, salary

# Section 5: mutate() - Create or Change Columns ---------------------------
# mutate() adds new columns or modifies existing ones.
# The new column appears at the far right by default.

# Create a new column from a calculation
survey |>
  mutate(salary_k = salary / 1000)

# Create multiple columns in one mutate (comma-separated)
survey |>
  mutate(
    salary_k = salary / 1000,
    high_engagement = engagement >= 4
  )

# New columns can reference columns created earlier in the SAME mutate
survey |>
  mutate(
    total_score = satisfaction + engagement + autonomy,
    avg_score = total_score / 3
  )

# Modify an existing column by reassigning its name
survey |>
  mutate(department = toupper(department))

# Conditional columns with if_else() (two outcomes)
# Note: if_else() is the dplyr version. It's stricter than base ifelse()
# about types, which catches bugs. Use if_else() in tidyverse code.
survey |>
  mutate(satisfied = if_else(satisfaction >= 4, "Yes", "No"))

# Multiple conditions with case_when() (more than two outcomes)
# (callback to Session 3, where we used case_when for cleaning)
survey |>
  mutate(
    tenure_band = case_when(
      tenure_years < 2 ~ "New",
      tenure_years < 5 ~ "Established",
      tenure_years < 10 ~ "Senior",
      TRUE ~ "Veteran" # TRUE is the catch-all "else"
    )
  )

# .default replaces the TRUE ~ idiom in newer dplyr and reads better:
survey |>
  mutate(
    tenure_band = case_when(
      tenure_years < 2 ~ "New",
      tenure_years < 5 ~ "Established",
      tenure_years < 10 ~ "Senior",
      .default = "Veteran"
    )
  )

# Section 6: arrange() - Sort Rows -----------------------------------------
# arrange() sorts the rows. Ascending by default.

# Sort by one column, ascending
survey |> arrange(salary)

# Sort descending with desc()
survey |> arrange(desc(salary))

# Sort by multiple columns (department first, then salary within department)
survey |> arrange(department, desc(salary))

# arrange() pushes NA to the end regardless of direction. Worth knowing.

# Section 7: summarize() - Collapse to a Summary ---------------------------
# summarize() (or summarise(), both spellings work) collapses many rows
# into a single summary row. On its own it's mildly useful; combined with
# group_by() in the next section it becomes the workhorse of analysis.

# Summarize the whole dataset to one row
survey |>
  summarize(
    mean_sat = mean(satisfaction),
    mean_eng = mean(engagement),
    n = n() # n() counts the rows. Very common inside summarize.
  )

# Watch out for NAs! If any value is NA, the result is NA.
# (Session 3 + Session 4 callback. This bites everyone.)
survey |> summarize(mean_salary = mean(salary))
# If salary has NAs, this returns NA. Fix with na.rm = TRUE:
survey |> summarize(mean_salary = mean(salary, na.rm = TRUE))

# Common summary functions: mean, median, sd, min, max, sum, n()
survey |>
  summarize(
    n = n(),
    mean_sat = mean(satisfaction),
    median_sat = median(satisfaction),
    sd_sat = sd(satisfaction),
    min_sat = min(satisfaction),
    max_sat = max(satisfaction)
  )

# Section 8: group_by() + summarize() - The Payoff -------------------------
# This is the most important pattern in the whole session.
# group_by() splits the data into groups; summarize() then computes
# a summary FOR EACH GROUP instead of for the whole dataset.

# Mean satisfaction by department
survey |>
  group_by(department) |>
  summarize(mean_sat = mean(satisfaction))

# One row per group. This is "split-apply-combine."
# Split by department, apply mean, combine into a result table.

# Multiple summaries per group, plus a count
survey |>
  group_by(department) |>
  summarize(
    n = n(),
    mean_sat = mean(satisfaction),
    mean_eng = mean(engagement),
    mean_salary = mean(salary, na.rm = TRUE)
  )

# Group by multiple variables
survey |>
  group_by(department, remote) |>
  summarize(
    n = n(),
    mean_sat = mean(satisfaction),
    .groups = "drop" # drop grouping after summarizing
  )

# THE UNGROUP GOTCHA (callback to Session 4 bonus #5):
# After summarize(), the result is STILL grouped by any remaining
# grouping variables. If you keep piping, that lingering grouping can
# cause surprising results. Two ways to handle it:
#   1. .groups = "drop" inside summarize() (shown above)
#   2. ungroup() as an explicit step
# Demonstrate the difference so they SEE the grouping persist:
survey |>
  group_by(department, remote) |>
  summarize(mean_sat = mean(satisfaction)) # message warns about grouping
# Notice the message: "summarise() has grouped output by 'department'."
# That message is dplyr telling you the result is still grouped by department.

# Section 9: count() - Quick Frequency Tables ------------------------------
# count() is a shortcut for the extremely common "how many in each group"
# It's group_by() + summarize(n = n()) in one verb.

# How many employees in each department?
survey |> count(department)

# Equivalent longhand (show the connection):
survey |> group_by(department) |> summarize(n = n())

# Count by two variables
survey |> count(department, remote)

# Sort the counts with sort = TRUE (most common first)
survey |> count(department, sort = TRUE)

# count() can weight by a column with wt = (sums instead of counts)
survey |> count(department, wt = salary, name = "total_salary")

# Section 10: Putting It Together - A Real Pipeline ------------------------
# The verbs are designed to chain. This is where it clicks.
# Walk through this slowly, one pipe step at a time (Session 4 habit:
# highlight from the top through each step and run incrementally).

# Question: For non-remote employees, what is the average satisfaction
# and engagement by department, for departments averaging 3+ satisfaction,
# sorted by satisfaction?
survey |>
  filter(!remote) |> # only on-site employees
  group_by(department) |> # split by department
  summarize(
    n = n(),
    mean_sat = mean(satisfaction),
    mean_eng = mean(engagement),
    .groups = "drop"
  ) |>
  filter(mean_sat >= 3) |> # keep higher-satisfaction departments
  arrange(desc(mean_sat)) # best first

# Point out: filter appears TWICE and does different jobs each time.
# The first filters individual employees (rows of raw data).
# The second filters department summaries (rows of the summary table).
# Same verb, different stage of the pipeline. This is the mental model
# students most need to build.

# Section 11: Tidy Data (Concept) ------------------------------------------
# Brief conceptual intro. Reshaping tools come in Session 11.
# Tidy data has three rules:
#   1. Each variable is a column
#   2. Each observation is a row
#   3. Each value is a cell
#
# Our survey data is already tidy: one row per employee, one column per
# measured variable. dplyr is DESIGNED for tidy data. When data is tidy,
# the verbs just work. When it isn't, you reshape it first (Session 11).
#
# Show a NON-tidy example so the contrast lands:
# A wide table where each Likert item is its own column AND department
# means are stored as separate columns would fight the dplyr verbs.
# Keep this conceptual; do not go down the pivot rabbit hole today.

# Section 12: MAIN EXERCISE ------------------------------------------------
# Students work with the employee survey data.
# Walk through 1-2 together, then let them work the rest.

# 1. Calculate mean satisfaction score by department
survey |>
  group_by(department) |>
  summarize(mean_sat = mean(satisfaction))

# 2. Find the average engagement and satisfaction for each department,
#    sorted by engagement (highest first)
survey |>
  group_by(department) |>
  summarize(
    mean_eng = mean(engagement),
    mean_sat = mean(satisfaction),
    .groups = "drop"
  ) |>
  arrange(desc(mean_eng))

# 3. Filter for high-performing departments (engagement >= 3.5)
#    and sort by satisfaction
survey |>
  group_by(department) |>
  summarize(mean_eng = mean(engagement), mean_sat = mean(satisfaction),
            .groups = "drop") |>
  filter(mean_eng >= 3.5) |>
  arrange(desc(mean_sat))

# 4. Create a tenure category variable (New / Established / Senior / Veteran)
survey |>
  mutate(
    tenure_band = case_when(
      tenure_years < 2 ~ "New",
      tenure_years < 5 ~ "Established",
      tenure_years < 10 ~ "Senior",
      .default = "Veteran"
    )
  ) |>
  count(tenure_band)

# 5. How many remote vs on-site employees are in each department?
survey |> count(department, remote)

# 6. For each department, what proportion of employees are remote?
survey |>
  group_by(department) |>
  summarize(
    n = n(),
    n_remote = sum(remote),
    pct_remote = mean(remote) # mean of a logical = proportion TRUE
  )
# Teaching point (Session 2 callback): mean() of a logical vector gives
# the proportion of TRUEs, because TRUE = 1 and FALSE = 0. Elegant.

# 7. Create a salary_band column and find mean satisfaction per band
survey |>
  filter(!is.na(salary)) |>
  mutate(
    salary_band = case_when(
      salary < 55000 ~ "Lower",
      salary < 70000 ~ "Middle",
      .default = "Upper"
    )
  ) |>
  group_by(salary_band) |>
  summarize(mean_sat = mean(satisfaction), n = n())

# BONUS: Advanced Patterns -------------------------------------------------

# slice_max() and slice_min(): top/bottom N rows
# The 3 highest-paid employees
survey |> slice_max(salary, n = 3)

# Top earner WITHIN each department
survey |>
  group_by(department) |>
  slice_max(salary, n = 1)

# distinct(): unique rows or unique combinations
survey |> distinct(department)
survey |> distinct(department, remote)

# Combining mutate with group_by (mutate respects groups!)
# Add each employee's deviation from their DEPARTMENT mean satisfaction
survey |>
  group_by(department) |>
  mutate(dept_mean_sat = mean(satisfaction),
         sat_vs_dept = satisfaction - dept_mean_sat) |>
  ungroup() |>
  select(employee_id, department, satisfaction, dept_mean_sat, sat_vs_dept)
# This is a powerful pattern: group_by + mutate keeps every row but adds
# group-level context. Different from group_by + summarize, which collapses.

# across(): apply one function to many columns (full treatment Session 6)
survey |>
  group_by(department) |>
  summarize(across(c(satisfaction, engagement, autonomy), mean))

# =============================================================================
# END OF SESSION 5
# =============================================================================

# TEACHING NOTES FOR NEXT TIME:
# - The pipe is the make-or-break concept. If students leave understanding
#   filter/select/mutate/the pipe, the session succeeded even if you didn't
#   reach count() or tidy data.
# - Live-code the pipelines one step at a time. Run filter alone, see the
#   result, THEN add the next pipe. Don't paste a finished 5-step pipeline.
# - The "filter appears twice" pipeline (Section 10) is the conceptual peak.
#   Make sure they see that the verbs operate on whatever table is current.
# - Next session: tidy-select helpers and across() for column-wise ops.

# COMMON STUDENT MISTAKES TO WATCH FOR:
# 1. Using = instead of == in filter (dplyr catches this with a good message)
# 2. Forgetting na.rm = TRUE in summarize, getting NA results
# 3. Quoting column names in select/filter (dplyr uses bare names)
# 4. Forgetting the pipe between steps (Session 4 bug script callback)
# 5. Expecting summarize to keep all columns (it only keeps groups + summaries)
# 6. Not realizing data stays grouped after summarize (the ungroup gotcha)
# 7. Confusing filter (rows) with select (columns)

# KEY CONCEPTS TO REINFORCE:
# - The pipe reads left-to-right, top-to-bottom, as the word "then"
# - filter = rows, select = columns, mutate = new/changed columns
# - group_by + summarize = split-apply-combine
# - The verbs chain; each one operates on the table produced by the last
# - mean() of a logical gives a proportion

# ASSESSMENT IDEAS:
# - Give students a question in plain English, have them build the pipeline
# - Give a broken pipeline (Session 4 style) with wrong verb order to fix
# - Ask them to produce a department summary table from raw data
# - Have them explain, in words, what each step of a given pipeline does
# - Translate a base-R subsetting expression (Session 2) into dplyr verbs
