###########################################
# Session 11: Data Reshaping & Joins      #
###########################################

# Two big skills this session, both about getting data into the SHAPE your
# analysis needs:
#
#   1. RESHAPING: converting between wide and long formats (pivot_longer /
#      pivot_wider). Different tools want different shapes; you need to move
#      between them fluently.
#   2. JOINING: combining two tables on a shared key (the join family).
#      Real data lives in multiple tables; joins are how you bring it together.
#
# We've already used pivot_wider (Session 8 sentiment) and anti_join
# (Session 8 stopwords) informally. Now we treat them properly.
#
# Pacing note: pivoting is the trickier of the two to internalize - the
# wide/long mental model takes repetition. Joins are more intuitive once you
# see the picture. Spend the first half on pivots, second half on joins.

# Section 1: Setup ---------------------------------------------------------

library(tidyverse) # tidyr (pivots) and dplyr (joins) both load here
library(here)

survey <- read_csv(here("data", "employee_survey.csv"))
dept_info <- read_csv(here("data", "department_info.csv"))

glimpse(survey)
glimpse(dept_info)
# dept_info is a LOOKUP table: one row per department, with region, the
# department head, and a budget. We'll join it to the per-employee survey.

# Section 2: Wide vs Long - The Concept ------------------------------------
# This is the mental model the whole reshaping half depends on.
#
# WIDE format: one row per subject, each measurement in its own COLUMN.
#   employee_id | satisfaction | engagement | autonomy
#   E001        | 4            | 3          | 4
#   Humans read this easily. It's how survey exports usually look.
#
# LONG format: one row per measurement, with a column naming the measure and
#   a column holding the value.
#   employee_id | measure      | value
#   E001        | satisfaction | 4
#   E001        | engagement   | 3
#   E001        | autonomy     | 4
#   Machines (and ggplot, and dplyr's group_by) love this. It's "tidy" when
#   each measure is a variable and each row an observation.
#
# Neither is "right" - you move between them depending on the task. The key
# realization: the SAME data, two shapes. Reshaping loses nothing.

# Section 3: pivot_longer - Wide to Long -----------------------------------
# pivot_longer takes several columns and stacks them into two: a "names"
# column (which measure) and a "values" column (the number). Use it when you
# have measurements spread across columns that you want to treat uniformly.

# Take the three Likert columns and stack them
survey_long <- survey |>
  pivot_longer(
    cols = c(satisfaction, engagement, autonomy), # columns to stack
    names_to = "measure", # new column holding the old column NAMES
    values_to = "score" # new column holding the VALUES
  )
survey_long |> select(employee_id, department, measure, score) |> head(9)
# Each employee now spans three rows, one per measure. Notice employee_id
# and department REPEAT down the rows - they weren't pivoted, so they ride
# along. The data tripled in rows and shrank in columns. Same information.

# Why bother? Because now ALL three measures can be handled at once:
survey_long |>
  group_by(measure) |>
  summarize(mean_score = mean(score), sd_score = sd(score))
# One group_by gives you all three measures' stats. In wide format you'd
# need three separate mean() calls (or across(), Session 6). Long format +
# group_by is often the cleaner path.

# And it makes faceted plotting trivial (Session 7 callback)
survey_long |>
  ggplot(aes(x = score)) +
  geom_bar(fill = "steelblue") +
  facet_wrap(~ measure) +
  labs(title = "Distribution of Each Likert Measure", x = "Score (1-5)") +
  theme_minimal()
# One plot, all three measures, because they're stacked in long form. This
# is why long format is the workhorse for analysis and visualization.

# You can also select columns to pivot with tidy-select helpers (Session 6)
survey |>
  pivot_longer(cols = where(is.numeric) & !c(tenure_years, salary),
               names_to = "measure", values_to = "score") |>
  head()
# "every numeric column EXCEPT tenure and salary" - the Likert items.
# tidy-select inside pivot_longer is a clean way to grab a block of columns.

# Section 4: pivot_wider - Long to Wide ------------------------------------
# pivot_wider is the inverse: it spreads a names column and a values column
# back out into multiple columns. Use it to build summary tables for humans,
# or to reverse a pivot_longer.

# Reverse the pivot we just did
survey_wide <- survey_long |>
  pivot_wider(
    names_from = measure, # column whose VALUES become new column names
    values_from = score # column whose values fill the new columns
  )
survey_wide |> head()
# Back to one row per employee, measures as columns. We've made a round trip:
# wide -> long -> wide, landing where we started. Reshaping is reversible.

# The more common real use: build a summary table. Compute mean score per
# department per measure (long), then spread measures across columns (wide).
dept_measure_means <- survey_long |>
  group_by(department, measure) |>
  summarize(mean_score = mean(score), .groups = "drop") |>
  pivot_wider(names_from = measure, values_from = mean_score)
dept_measure_means
# This is the classic analysis pattern: compute in LONG form (group_by is
# easy there), then pivot WIDE for a readable report table. One row per
# department, one column per measure. This is the table you'd hand a manager.

# values_fill handles gaps (Session 8 callback): when a name/value combo is
# missing, pivot_wider puts NA unless you tell it otherwise.
# pivot_wider(..., values_fill = 0) fills missing cells with 0 instead of NA.

# Section 5: Joins - The Concept -------------------------------------------
# Joins combine two tables by matching rows on a shared KEY column. Our key
# is "department": the survey has it per employee, dept_info has it per
# department. Joining attaches each department's region, head, and budget to
# every employee in that department.
#
# The join family differs ONLY in which unmatched rows they keep:
#
#   left_join(x, y)  : keep ALL rows of x; attach y where it matches
#   inner_join(x, y) : keep ONLY rows that match in BOTH
#   full_join(x, y)  : keep ALL rows of both; NA where no match
#   right_join(x, y) : keep all rows of y (rarely used; just flip a left_join)
#   anti_join(x, y)  : keep rows of x with NO match in y (a filter, adds no cols)
#   semi_join(x, y)  : keep rows of x that DO match in y (also a filter)
#
# Our setup, by design: every employee's department exists in dept_info, but
# dept_info also has "Finance", which has NO employees. That mismatch is what
# makes the different joins produce visibly different results below.

# Section 6: left_join - Keep All Left Rows --------------------------------
# The workhorse. "Keep all my employees, attach department info to each."

survey_joined <- survey |>
  left_join(dept_info, by = "department")
glimpse(survey_joined)
# Every employee now carries region, dept_head, budget_k. The row count is
# UNCHANGED (still 60) - left_join never drops left rows. Finance is NOT
# here, because no employee belongs to it and left_join only adds columns to
# existing left rows. This is the join you reach for 80% of the time:
# enriching your main table with lookup info.

nrow(survey)        # 60
nrow(survey_joined) # still 60 - left_join preserved every employee

# Now department-level attributes are usable per employee
survey_joined |>
  group_by(region) |>
  summarize(n = n(), mean_sat = mean(satisfaction))
# We can suddenly summarize by region, a column that didn't exist until the
# join. That's the point: joins unlock analysis you couldn't do on one table.

# Section 7: inner_join - Keep Only Matches --------------------------------
inner <- survey |>
  inner_join(dept_info, by = "department")
nrow(inner) # 60 here too - every employee matched a real department
# inner_join keeps only rows matching in BOTH tables. Here it's identical to
# the left_join because all employees matched. The DIFFERENCE shows when we
# join the OTHER direction (dept_info on the left):
dept_info |>
  inner_join(survey, by = "department") |>
  distinct(department)
# Only 5 departments - Finance vanished, because it had no matching employee.
# inner_join dropped the unmatched Finance row. left_join would have kept it.

# Section 8: full_join and the Others --------------------------------------

# full_join keeps everything from both sides
full <- dept_info |>
  full_join(survey, by = "department")
full |> filter(department == "Finance") |> select(department, region, employee_id)
# Finance appears with its region but employee_id is NA - it's in dept_info
# but has no employees. full_join surfaces gaps on EITHER side. Use it when
# you need to see the complete picture including non-matches.

# anti_join: which departments have NO employees? (a diagnostic filter)
dept_info |>
  anti_join(survey, by = "department")
# Returns just Finance. anti_join is how you FIND unmatched records - perfect
# for data-quality checks: "which lookup entries are unused?" or "which
# records reference a key that doesn't exist?" Adds no columns, just filters.

# semi_join: which departments DO have employees? (the complement)
dept_info |>
  semi_join(survey, by = "department")
# Returns the 5 active departments. Like inner_join but keeps only dept_info's
# columns (no employee data attached). A filter, not a merge.

# Section 9: When Join Keys Don't Match ------------------------------------
# The #1 real-world join problem: keys that LOOK the same but aren't.
# Trailing spaces, case differences, "St" vs "Street" - these silently fail
# to match and you get NAs or dropped rows with no error. (Session 3 + 4
# data-hygiene callback.)

# Load a deliberately messy version of the lookup
dept_messy <- read_csv(here("data", "department_info_messy.csv"))
dept_messy$department
# Notice: "engineering" is lowercase, "Operations " has a trailing space.

# Join it and watch the failure
broken <- survey |>
  left_join(dept_messy, by = "department")
broken |>
  filter(is.na(region)) |>
  count(department)
# Engineering and Operations employees got NA region! Their department
# strings didn't match ("Engineering" != "engineering"). left_join didn't
# error - it just couldn't match, so it filled NA. SILENT failure is the
# danger. Always check for unexpected NAs after a join.

# The fix: clean the keys on BOTH sides before joining (Session 3 habit)
dept_fixed <- dept_messy |>
  mutate(department = str_trim(department), # remove leading/trailing spaces
         department = str_to_title(department)) # standardize case
survey |>
  left_join(dept_fixed, by = "department") |>
  filter(is.na(region)) |>
  count(department)
# Zero rows now - every employee matched. str_trim() and str_to_title() are
# string-cleaning tools (more in later text work). The lesson: a join is
# only as good as its keys. Inspect and standardize them first.

# Joining on differently-named key columns
# If the key is "department" in one table and "dept" in the other, use:
# left_join(x, y, by = c("department" = "dept"))
# The named vector maps left key to right key.

# Section 10: MAIN EXERCISE ------------------------------------------------
# Reshape the survey, then join employee data with department info.
# Walk through 1-2 together, then let them work.

# 1. Pivot the three Likert columns into long format
ex_long <- survey |>
  pivot_longer(cols = c(satisfaction, engagement, autonomy),
               names_to = "measure", values_to = "score")
ex_long |> head(9)

# 2. Using the long data, get mean and sd of each measure
ex_long |>
  group_by(measure) |>
  summarize(mean = mean(score), sd = sd(score))

# 3. Pivot back to wide: mean score per department per measure
ex_long |>
  group_by(department, measure) |>
  summarize(mean_score = mean(score), .groups = "drop") |>
  pivot_wider(names_from = measure, values_from = mean_score)

# 4. left_join the survey with department info
ex_joined <- survey |>
  left_join(dept_info, by = "department")
glimpse(ex_joined)

# 5. Summarize satisfaction by region (a column only the join provides)
ex_joined |>
  group_by(region) |>
  summarize(n = n(), mean_sat = mean(satisfaction))

# 6. Use anti_join to find departments with no employees
dept_info |>
  anti_join(survey, by = "department")

# 7. Join the MESSY lookup, find the NA rows, then fix the keys and rejoin
survey |>
  left_join(read_csv(here("data", "department_info_messy.csv")),
            by = "department") |>
  filter(is.na(region)) |>
  count(department)
# (then apply str_trim + str_to_title and confirm the NAs disappear)

# BONUS: Going Further -----------------------------------------------------

# Joining and then plotting: satisfaction by region
survey |>
  left_join(dept_info, by = "department") |>
  ggplot(aes(x = region, y = satisfaction, fill = region)) +
  geom_boxplot(alpha = 0.7) +
  labs(title = "Satisfaction by Region", x = NULL, y = "Satisfaction") +
  theme_minimal() +
  theme(legend.position = "none")

# pivot_longer with multiple sets of columns and names_sep
# If columns were named like "Q1_pre", "Q1_post", names_sep splits them into
# two new columns. Powerful for repeated-measures survey data:
example <- tibble(
  id = 1:3,
  score_pre = c(70, 65, 80),
  score_post = c(78, 72, 85)
)
example |>
  pivot_longer(cols = starts_with("score"),
               names_to = c(".value", "time"), # .value keeps "score" as a column
               names_sep = "_")
# .value is a special token: the part before the _ becomes the value column
# name (score), the part after (_pre/_post) becomes the "time" column. This
# reshapes pre/post data into one score column with a time indicator - the
# shape you'd want for a before/after analysis. Advanced but very common.

# Chaining a reshape, a join, and a summary in one pipeline
survey |>
  left_join(dept_info, by = "department") |>
  pivot_longer(cols = c(satisfaction, engagement, autonomy),
               names_to = "measure", values_to = "score") |>
  group_by(region, measure) |>
  summarize(mean_score = mean(score), .groups = "drop") |>
  pivot_wider(names_from = measure, values_from = mean_score)
# Join to get region, pivot long to handle all measures, summarize by
# region, pivot wide for the report. Every tool from this session in one
# flow. This is what real data work looks like.

# =============================================================================
# END OF SESSION 11
# =============================================================================

# TEACHING NOTES FOR NEXT TIME:
# - The wide/long mental model is the hard part. Draw both shapes on the
#   board with the SAME tiny dataset. The "same data, two shapes, reshaping
#   loses nothing" point needs to land before any code.
# - The compute-in-long-pivot-wide-for-humans pattern (Section 4) is the
#   single most useful real-world workflow here. Show it deliberately.
# - For joins, draw the Venn diagram: left/inner/full as overlapping circles.
#   The only difference between joins is which unmatched rows survive.
# - The silent-NA join failure (Section 9) is the highest-value practical
#   lesson. Real joins fail on dirty keys constantly. Make them feel the
#   "no error but wrong answer" danger - it's worse than an error.
# - anti_join as a data-quality tool (find the unmatched) often surprises
#   people who think of joins only as "merging". Emphasize it.
# - Next session: cluster analysis (k-means) - the start of finding
#   structure rather than testing a specified relationship.

# COMMON STUDENT MISTAKES TO WATCH FOR:
# 1. Confusing names_to/values_to (longer) with names_from/values_from (wider)
# 2. Forgetting that pivoted-away columns repeat down the rows (long form)
# 3. Reaching for inner_join when left_join is what they want (dropped rows)
# 4. Not checking for NAs after a join (silent key-mismatch failures)
# 5. Dirty join keys: case, trailing spaces, inconsistent spelling
# 6. Forgetting by = when joining (R guesses, which may surprise you)
# 7. Mixing up left vs right table in the join direction

# KEY CONCEPTS TO REINFORCE:
# - Wide and long are the same data in two shapes; reshaping is reversible
# - pivot_longer: names_to / values_to. pivot_wider: names_from / values_from
# - Compute in long form, pivot wide for human-readable report tables
# - Joins combine tables on a shared key
# - left (keep all left), inner (matches only), full (keep all), anti (find
#   unmatched), semi (keep matched, no new columns)
# - A join is only as good as its keys: clean and inspect them first
# - Always check for unexpected NAs after a join

# ASSESSMENT IDEAS:
# - Give wide data, have them pivot long, summarize, and pivot back wide
# - Provide two tables, have them choose and justify the right join type
# - Plant a dirty key, have them diagnose why a join produced NAs
# - Have them use anti_join to find a data-quality problem
# - Explain the difference between inner_join and left_join with an example
