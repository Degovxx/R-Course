###############################################
# Session 6: Tidy-Select & Column Operations  #
#            (In-Class Version)               #
###############################################

# Live capture. Spent the front half motivating WHY (the tedious version),
# which paid off when across() landed. Got through across() and pick().
# rowwise() covered briefly at the end; main exercise is homework.

# Section 1: Setup ---------------------------------------------------------

library(tidyverse)
library(here)

# Project root is C:\RStuff, so path is prefixed with "R-Course".
survey <- read_csv(here("R-Course", "data", "employee_survey.csv"))

glimpse(survey)

# Built the wider Q-item frame on screen so the helpers had something to
# match. Explained these five items are derived from the original three
# just for teaching - it's the mechanics we care about, not the values.
survey_items <- survey |>
  mutate(
    Q1_workload = satisfaction,
    Q2_support = engagement,
    Q3_growth = autonomy,
    Q4_balance = pmin(5, satisfaction + 0),
    Q5_recognition = pmax(1, engagement - 0)
  ) |>
  select(employee_id, department, tenure_years, salary, remote,
         starts_with("Q"))

glimpse(survey_items)

# Section 2: Why Tidy-Select Exists ----------------------------------------

# Did the painful version first. Everyone agreed it was awful.
survey_items |>
  summarize(
    Q1 = mean(Q1_workload),
    Q2 = mean(Q2_support),
    Q3 = mean(Q3_growth),
    Q4 = mean(Q4_balance),
    Q5 = mean(Q5_recognition)
  )
# "Now imagine fifty items." Good setup for across().

# Section 3: Pattern-Matching Helpers --------------------------------------

survey_items |> select(starts_with("Q"))
survey_items |> select(ends_with("_workload"))
survey_items |> select(contains("growth"))

# matches() with regex - tied back to the date regex from Session 3
survey_items |> select(matches("^Q[1-3]"))

# Q from class: "why does starts_with need quotes but the column names in
# select don't?" Good question. The PATTERN is a string you're matching
# against, so it's quoted. A bare column name IS the column. Different things.

survey_items |> select(department, starts_with("Q"))

# Section 4: where() -------------------------------------------------------

survey_items |> select(where(is.numeric))
survey_items |> select(where(is.character))

# This got an audible "oh nice" - selecting by type instead of name.

# custom predicate
survey_items |> select(where(\(x) is.numeric(x) && mean(x, na.rm = TRUE) > 3))
# Read \(x) as "function of x" - had to say this several times.

# Section 5: across() - the main event -------------------------------------

# The payoff for Section 2's pain:
survey_items |> summarize(across(starts_with("Q"), mean))
# One line vs five. This is the moment the session is built around.

survey_items |>
  summarize(across(where(is.numeric), mean, .names = "mean_{.col}"))

# z-score every Q item, keep originals
survey_items |>
  mutate(across(starts_with("Q"),
                \(x) (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE),
                .names = "{.col}_z")) |>
  select(employee_id, starts_with("Q"))

# mean AND sd in one shot with a named list
survey_items |>
  summarize(across(starts_with("Q"),
                   list(mean = mean, sd = sd),
                   .names = "{.col}_{.fn}"))

# Section 6: Anonymous Function Syntax -------------------------------------

# Both forms, side by side. We write \(x); recognize ~ .x online.
survey_items |> summarize(across(starts_with("Q"), \(x) mean(x, na.rm = TRUE)))
survey_items |> summarize(across(starts_with("Q"), ~ mean(.x, na.rm = TRUE)))

# Section 7: pick() --------------------------------------------------------

survey_items |>
  mutate(q_total = rowSums(pick(starts_with("Q")))) |>
  select(employee_id, starts_with("Q"), q_total)

# Mental model that worked: "across() does something to EACH column;
# pick() hands you the columns as a bundle to feed rowSums()."

# ---- this is about where time ran out ----

# Section 8: rowwise() -----------------------------------------------------
# Showed quickly. Emphasized it's the SLOW option and rowMeans is better.
survey_items |>
  rowwise() |>
  mutate(q_mean = mean(c_across(starts_with("Q")))) |>
  ungroup() |>
  select(employee_id, q_mean)

# The fast way - this is what they should actually use:
survey_items |>
  mutate(q_mean = rowMeans(pick(starts_with("Q")))) |>
  select(employee_id, q_mean)

# Section 9: MAIN EXERCISE -------------------------------------------------
# HOMEWORK. All 8 in the Student file. Did #3 together as the anchor:
survey_items |> summarize(across(starts_with("Q"), mean))
# The rest are yours for next session.

# BONUS: if there's interest, look at if_any/if_all for row filtering.
survey_items |> filter(if_any(starts_with("Q"), \(x) x == 5))
