###############################################
# Session 6: Tidy-Select & Column Operations  #
###############################################

# Last session gave students the dplyr verbs. This session is about
# SCALE: how to name, select, and transform many columns at once without
# writing the same code over and over. This is where students stop
# copy-pasting mutate lines and start writing code that scales.
#
# The throughline: "I want to do the same thing to a bunch of columns."
# Tidy-select helpers FIND the columns; across() APPLIES a function to them.
#
# Pacing note: starts_with/ends_with/contains are quick and intuitive.
# where() and across() are the conceptual core and deserve the most time.
# rowwise() is the hardest idea; if you run short, it can be homework.

# Section 1: Setup ---------------------------------------------------------

library(tidyverse)
library(here)

# Same employee survey from Session 5. Familiar data lets us focus on the
# new skills instead of relearning the columns.
survey <- read_csv(here("data", "employee_survey.csv"))

glimpse(survey)

# To make the tidy-select helpers shine, we need columns with shared naming
# patterns. The survey has satisfaction/engagement/autonomy as our Likert
# items, but their names don't share a prefix. Let's build a richer example
# with several Q-items, which is what real survey data looks like.
survey_items <- survey |>
  mutate(
    Q1_workload = satisfaction,
    Q2_support = engagement,
    Q3_growth = autonomy,
    Q4_balance = pmin(5, satisfaction + 0), # placeholder extra item
    Q5_recognition = pmax(1, engagement - 0)
  ) |>
  select(employee_id, department, tenure_years, salary, remote,
         starts_with("Q"))

glimpse(survey_items)
# Now we have Q1_workload through Q5_recognition: a realistic Likert block
# with a shared "Q" prefix, plus the demographic/metadata columns.
# (These five items are derived from the original three for teaching
# convenience; we care about the column-operation MECHANICS here, not the
# values. In a real survey these would be five independently measured items.)

# Section 2: Why Tidy-Select Exists ----------------------------------------
# Motivate the problem before the solution.

# Suppose you want the mean of all five Q items. The naive way:
survey_items |>
  summarize(
    Q1 = mean(Q1_workload),
    Q2 = mean(Q2_support),
    Q3 = mean(Q3_growth),
    Q4 = mean(Q4_balance),
    Q5 = mean(Q5_recognition)
  )

# This works, but it's tedious and error-prone. Five items is annoying;
# fifty items is unthinkable. And if a column is renamed or added, you
# have to hand-edit every line. We want to say "all the Q columns" once.

# Section 3: Pattern-Matching Helpers --------------------------------------
# These select columns by NAME PATTERN. They work inside select(), and
# (with across) inside mutate/summarize. Show each one.

# --- starts_with() ---
survey_items |> select(starts_with("Q"))
survey_items |> select(starts_with("Q1")) # just Q1_workload

# --- ends_with() ---
survey_items |> select(ends_with("_workload"))
survey_items |> select(ends_with("s")) # any column ending in s

# --- contains() ---
# Matches a literal substring anywhere in the name
survey_items |> select(contains("_"))
survey_items |> select(contains("growth"))

# --- matches() ---
# The power tool: matches a REGULAR EXPRESSION, not a literal string
# (callback to the regex we touched in Session 3 date cleaning)
survey_items |> select(matches("^Q[1-3]")) # Q1, Q2, Q3 items only
survey_items |> select(matches("workload|balance")) # OR pattern

# When to use which:
# - starts_with / ends_with / contains: literal text, easy to read
# - matches: when you need real pattern logic (digits, alternatives, anchors)

# --- num_range() ---
# For numbered columns with a common stem. Less common but handy.
# (Our columns are Q1_workload not Q1, so this doesn't match here, but
#  show the idea: num_range("Q", 1:3) would match Q1, Q2, Q3 exactly.)

# Combining helpers
survey_items |> select(department, starts_with("Q"))
survey_items |> select(starts_with("Q"), -Q5_recognition) # all Q but Q5

# Section 4: where() - Select by Property, Not Name ------------------------
# where() is different and powerful. Instead of matching the NAME, it
# tests a PROPERTY of each column using a function that returns TRUE/FALSE.

# Select all numeric columns
survey_items |> select(where(is.numeric))

# Select all character columns
survey_items |> select(where(is.character))

# Select all logical columns
survey_items |> select(where(is.logical))

# This is enormously useful because it doesn't depend on naming. "Give me
# every numeric column" works no matter what the columns are called.

# You can write your own predicate. Select columns whose mean exceeds 3:
survey_items |> select(where(\(x) is.numeric(x) && mean(x, na.rm = TRUE) > 3))
# Read \(x) as "function of x". It's R's shorthand for function(x).
# The column is passed in as x; return TRUE to keep it.

# Section 5: across() - Apply a Function to Many Columns --------------------
# This is the heart of the session. across() lets you run the SAME function
# on MULTIPLE columns inside mutate() or summarize(). It pairs a tidy-select
# specification (which columns) with a function (what to do).

# Recall the tedious summarize from Section 2. Here it is with across():
survey_items |>
  summarize(across(starts_with("Q"), mean))

# One line. Read it as: "summarize, applying mean across all Q columns."
# Compare to the five-line version - same result, scales to any number.

# across() with where()
survey_items |>
  summarize(across(where(is.numeric), mean, .names = "mean_{.col}"))
# .names controls the output column names. {.col} is the original name.
# So Q1_workload becomes mean_Q1_workload. Without .names, the output
# columns keep the original names (fine when you replace, awkward when
# you summarize and want to keep the originals distinct).

# across() inside mutate() - transform columns in place
# Round every Q item (silly here since they're integers, but shows syntax)
survey_items |>
  mutate(across(starts_with("Q"), \(x) x * 10)) |>
  select(employee_id, starts_with("Q"))

# A real transformation: z-score (standardize) every numeric Likert item.
# z-score = (value - mean) / sd. Puts everything on a common scale.
survey_items |>
  mutate(across(starts_with("Q"),
                \(x) (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE),
                .names = "{.col}_z")) |>
  select(employee_id, starts_with("Q"))
# .names = "{.col}_z" keeps the originals AND adds standardized versions.

# Multiple functions at once: pass a NAMED LIST of functions
survey_items |>
  summarize(across(starts_with("Q"),
                   list(mean = mean, sd = sd),
                   .names = "{.col}_{.fn}"))
# {.fn} is the function name from the list. So you get Q1_workload_mean,
# Q1_workload_sd, and so on. This is the pattern for a full summary table.

# Section 6: The Anonymous Function Syntax ---------------------------------
# A short detour, because across() leans on it heavily.
# When you need to pass arguments (like na.rm) or do a calculation, you
# wrap it in an anonymous (unnamed) function. R gives you two ways:

# The modern native way: \(x)
survey_items |> summarize(across(starts_with("Q"), \(x) mean(x, na.rm = TRUE)))

# The tidyverse formula way: ~ with .x as the placeholder
survey_items |> summarize(across(starts_with("Q"), ~ mean(.x, na.rm = TRUE)))

# Both are identical in effect. We use \(x) in this course (it's base R and
# matches our native-pipe choice), but ~ .x is EVERYWHERE in existing
# tidyverse code, so recognize it. In the ~ form, .x is the column.

# When you DON'T need arguments, just name the function bare (no wrapper):
survey_items |> summarize(across(starts_with("Q"), mean)) # mean, not \(x)...

# Section 7: pick() - Select Columns Inside a Verb -------------------------
# pick() grabs a subset of columns as a mini data frame, for use INSIDE a
# data-masking verb. It replaced the old across(...)-without-a-function
# idiom (deprecated in dplyr 1.1, 2023). Use pick() now.

# Row-wise total across the Q items using pick() + rowSums()
survey_items |>
  mutate(q_total = rowSums(pick(starts_with("Q")))) |>
  select(employee_id, starts_with("Q"), q_total)

# pick() is also useful for sorting or grouping by a selection:
survey_items |> arrange(pick(starts_with("Q1")))

# Mental model: across() applies a function PER COLUMN; pick() hands you
# the SELECTED COLUMNS as a unit to feed to something like rowSums().

# Section 8: rowwise() - Operate One Row at a Time -------------------------
# Most dplyr is column-wise (vectorized). Sometimes you need to compute
# something ACROSS columns, separately for each row. rowwise() switches
# mutate into per-row mode.

# The mean of the Q items FOR EACH employee (a row-wise average)
survey_items |>
  rowwise() |>
  mutate(q_mean = mean(c_across(starts_with("Q")))) |>
  ungroup() |> # always ungroup after rowwise (Session 5 grouping gotcha)
  select(employee_id, starts_with("Q"), q_mean)

# c_across() is the rowwise companion to across(): it gathers the selected
# columns for the CURRENT row into a vector you can feed to mean(), sum(), etc.

# IMPORTANT performance note: rowwise() is convenient but SLOW on big data
# because it processes one row at a time. For simple row sums/means, the
# vectorized tools are much faster:
survey_items |>
  mutate(q_mean = rowMeans(pick(starts_with("Q")))) |> # vectorized, fast
  select(employee_id, q_mean)
# Rule of thumb: reach for rowMeans/rowSums first. Use rowwise() only when
# the per-row operation has no vectorized equivalent.

# Section 9: MAIN EXERCISE -------------------------------------------------
# Students apply tidy-select and across to the survey items.
# Walk through 1-2 together, then let them work.

# 1. Select all the Q items plus employee_id
survey_items |> select(employee_id, starts_with("Q"))

# 2. Select every numeric column using where()
survey_items |> select(where(is.numeric))

# 3. Calculate the mean of every Q item in one summarize()
survey_items |> summarize(across(starts_with("Q"), mean))

# 4. Calculate mean AND sd of every Q item, named clearly
survey_items |>
  summarize(across(starts_with("Q"),
                   list(mean = mean, sd = sd),
                   .names = "{.col}_{.fn}"))

# 5. Z-score every Q item, keeping the originals (add a _z suffix)
survey_items |>
  mutate(across(starts_with("Q"),
                \(x) (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE),
                .names = "{.col}_z"))

# 6. Create each employee's total score across the five Q items
survey_items |>
  mutate(q_total = rowSums(pick(starts_with("Q")))) |>
  select(employee_id, q_total)

# 7. By department, compute the mean of every Q item (across + group_by)
survey_items |>
  group_by(department) |>
  summarize(across(starts_with("Q"), mean), .groups = "drop")

# 8. Compare two approaches for the same task: get the mean of all numeric
#    columns. Do it with where(is.numeric), then discuss when each fits.
survey_items |>
  summarize(across(where(is.numeric), \(x) mean(x, na.rm = TRUE)))
# Discussion: starts_with("Q") targets a KNOWN named block; where(is.numeric)
# targets a TYPE regardless of name. where() also grabbed tenure_years and
# salary here - which may or may not be what you wanted. Selecting by type
# is convenient but can sweep in columns you didn't intend. Selecting by
# name pattern is explicit. Choose based on which guarantee you want.

# BONUS: Advanced Patterns -------------------------------------------------

# across() in filter() via if_any() / if_all()
# Keep rows where ANY Q item equals 5 (a top-box response on something)
survey_items |> filter(if_any(starts_with("Q"), \(x) x == 5))

# Keep rows where ALL Q items are 3 or higher
survey_items |> filter(if_all(starts_with("Q"), \(x) x >= 3))
# if_any/if_all are the filter-side counterparts to across(). They reduce
# a row's many column-tests down to a single TRUE/FALSE for that row.

# Renaming a whole block with across-style naming via rename_with()
survey_items |>
  rename_with(\(name) str_replace(name, "^Q[0-9]+_", ""),
              .cols = starts_with("Q")) |>
  glimpse()
# rename_with() applies a function to selected column NAMES. Here we strip
# the "Q1_" prefix so Q1_workload becomes workload. .cols picks the targets.

# Conditional transform: only standardize columns with sd > 0
survey_items |>
  mutate(across(where(\(x) is.numeric(x) && sd(x, na.rm = TRUE) > 0),
                \(x) (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE)))

# =============================================================================
# END OF SESSION 6
# =============================================================================

# TEACHING NOTES FOR NEXT TIME:
# - across() is the concept that matters most. If students leave able to
#   write summarize(across(where(is.numeric), mean)), the session worked.
# - Build the survey_items frame on screen so they see WHERE the Q columns
#   come from; otherwise the helpers feel like magic on mystery data.
# - The \(x) syntax trips people up. Say it out loud as "function of x"
#   every time until it sticks. Show the ~ .x form so they recognize it
#   online, but write \(x) in class.
# - rowwise() vs vectorized rowMeans is a real-world performance lesson.
#   Worth the time even if you have to cut a bonus item.
# - Next session: ggplot2 and the grammar of graphics (the fun payoff).

# COMMON STUDENT MISTAKES TO WATCH FOR:
# 1. Forgetting the function in across() (across(starts_with("Q")) alone
#    used to "work" by selecting; now use pick() for that)
# 2. Quoting inside tidy-select where it isn't needed (bare names mostly,
#    but starts_with("Q") DOES quote the pattern string - explain the split)
# 3. Confusing across() (per-column) with pick()/rowSums (across a row)
# 4. Forgetting na.rm inside the across function (Session 5 callback)
# 5. Forgetting to ungroup() after rowwise()
# 6. Using rowwise() for simple sums where rowMeans/rowSums is far faster
# 7. where(is.numeric) sweeping in ID or metadata columns unintentionally

# KEY CONCEPTS TO REINFORCE:
# - Helpers FIND columns (starts_with, ends_with, contains, matches, where)
# - across() APPLIES a function to the found columns, per column
# - where() selects by a column's PROPERTY, not its name
# - \(x) is "function of x"; the tidyverse ~ .x form means the same thing
# - pick() + rowSums/rowMeans for across-a-row math; rowwise() only when needed
# - Selecting by name = explicit; selecting by type = convenient but broad

# ASSESSMENT IDEAS:
# - Give a wide dataset, ask for a one-line summary of all numeric columns
# - Have them standardize a block of Likert items keeping originals
# - Translate a repetitive five-line mutate into one across() call
# - Ask when where(is.numeric) would grab a column they didn't want
# - Pair task: one writes a slow rowwise() version, the other vectorizes it
