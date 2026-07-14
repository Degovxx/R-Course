########################################
# Session 5: Data Wrangling with dplyr #
#          (In-Class Version)          #
########################################

# Live capture of what we actually ran in class. Ran long on the pipe
# (worth it) and grouping. Got through the integrated pipeline in
# Section 10; main exercise is homework. Notes from class are inline.

# Section 1: Setup ---------------------------------------------------------

library(tidyverse)
library(here)

# Note: project root is C:\RStuff, so the path is "R-Course/data/..."
survey <- read_csv(here("R-Course", "data", "employee_survey.csv"))

glimpse(survey)
summary(survey)

# Someone asked why salary showed up with NAs in the summary - good catch,
# three employees have missing salary. We come back to this in summarize.

# Section 2: The Pipe Operator ---------------------------------------------

# Started with the nested version to show why it's painful to read:
summarize(
  filter(survey, department == "Sales"),
  mean_sat = mean(satisfaction)
)

# Then the pipe version. Much better.
survey |>
  filter(department == "Sales") |>
  summarize(mean_sat = mean(satisfaction))

# Set everyone's RStudio to insert the native pipe:
# Tools > Global Options > Code > check "Use native pipe operator"
# Then Ctrl+Shift+M inserts |>

# Showed %>% so they recognize it online, but we're writing |>.
survey %>% filter(department == "Sales") %>% nrow()
survey |> filter(department == "Sales") |> nrow()

# Q from class: "what if the data isn't the first argument?" Told them
# that's where |> gets fussy and %>% has the . placeholder, but it almost
# never comes up with dplyr because data is always first. Parked it.

# Section 3: filter() - Keep Rows ------------------------------------------

survey |> filter(department == "Engineering")

survey |> filter(satisfaction >= 4)

# comma = AND
survey |> filter(department == "Sales", satisfaction >= 4)

# OR with |
survey |> filter(department == "Sales" | department == "Marketing")

# better: %in%
survey |> filter(department %in% c("Sales", "Marketing"))

# logical column filters directly
survey |> filter(remote)
survey |> filter(!remote)

# drop missing
survey |> filter(!is.na(salary))

# Demoed the = vs == mistake live - dplyr's error message is genuinely
# helpful here, it literally asks "did you mean ==?"
# survey |> filter(department = "Sales")

# Section 4: select() - Keep Columns ---------------------------------------

survey |> select(employee_id, department, satisfaction)

survey |> select(satisfaction:autonomy)

survey |> select(-employee_id)

survey |> select(department, everything())

survey |> rename(dept = department)

# Section 5: mutate() - Create or Change Columns ---------------------------

survey |> mutate(salary_k = salary / 1000)

survey |>
  mutate(
    total_score = satisfaction + engagement + autonomy,
    avg_score = total_score / 3
  )

# if_else for two outcomes
survey |> mutate(satisfied = if_else(satisfaction >= 4, "Yes", "No"))

# case_when for more than two
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

survey |> arrange(salary)
survey |> arrange(desc(salary))
survey |> arrange(department, desc(salary))

# Section 7: summarize() - Collapse to a Summary ---------------------------

survey |>
  summarize(
    mean_sat = mean(satisfaction),
    mean_eng = mean(engagement),
    n = n()
  )

# Here's the NA from Section 1 biting us:
survey |> summarize(mean_salary = mean(salary)) # NA!
survey |> summarize(mean_salary = mean(salary, na.rm = TRUE)) # fixed

# Section 8: group_by() + summarize() --------------------------------------

# The payoff. Mean satisfaction by department:
survey |>
  group_by(department) |>
  summarize(mean_sat = mean(satisfaction))

# Engineering came out highest, Sales lowest. Class found this interesting.

survey |>
  group_by(department) |>
  summarize(
    n = n(),
    mean_sat = mean(satisfaction),
    mean_eng = mean(engagement),
    mean_salary = mean(salary, na.rm = TRUE)
  )

# Pointed out the grouping message when we don't drop groups:
survey |>
  group_by(department, remote) |>
  summarize(mean_sat = mean(satisfaction))
# "summarise() has grouped output by 'department'" - that's the lingering
# grouping we warned about. Use .groups = "drop":

survey |>
  group_by(department, remote) |>
  summarize(mean_sat = mean(satisfaction), .groups = "drop")

# Section 9: count() -------------------------------------------------------

survey |> count(department)

# showed it's the same as the longhand:
survey |> group_by(department) |> summarize(n = n())

survey |> count(department, remote)
survey |> count(department, sort = TRUE)

# Section 10: Putting It Together ------------------------------------------

# The big one. Built it ONE PIPE AT A TIME on screen.
survey |>
  filter(!remote) |>
  group_by(department) |>
  summarize(
    n = n(),
    mean_sat = mean(satisfaction),
    mean_eng = mean(engagement),
    .groups = "drop"
  ) |>
  filter(mean_sat >= 3) |>
  arrange(desc(mean_sat))

# The "filter shows up twice doing different jobs" point landed well once
# we ran it step by step. First filter = employees, second filter = the
# department summary rows. That's the whole mental model for the session.

# ---- ran out of time here ----

# Section 11: Tidy Data ----------------------------------------------------
# Stated the three rules verbally (variable=column, observation=row,
# value=cell). Full reshaping is Session 11. No code in class.

# Section 12: MAIN EXERCISE ------------------------------------------------
# HOMEWORK. Work through all 7 in the Student file. We did #1 together
# below as a starting point; the rest are yours.

# 1. Mean satisfaction by department (did together)
survey |>
  group_by(department) |>
  summarize(mean_sat = mean(satisfaction))

# 2-7: see Student file, complete for next session.

# BONUS: covered slice_max briefly if there's time, otherwise skip.
survey |> slice_max(salary, n = 3)
