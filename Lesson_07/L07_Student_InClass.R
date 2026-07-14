###########################################
# Session 7: Visualization with ggplot2   #
#            (In-Class Version)           #
###########################################

# Live capture. This was the most engaged session yet - people light up
# when the data turns into pictures. The |> vs + thing tripped half the
# room repeatedly (as expected). Got through faceting; themes and the main
# exercise are homework. Plenty of good detours.

# Section 1: Setup ---------------------------------------------------------

library(tidyverse)
library(here)

# Project root is C:\RStuff, so the path carries the "R-Course" prefix.
survey <- read_csv(here("R-Course", "data", "employee_survey.csv"))
glimpse(survey)

# Section 2: The Grammar of Graphics ---------------------------------------
# Whiteboarded the three pieces: DATA, AESTHETICS (mappings), GEOMETRIES.
# "Every plot is: take data, map columns to visual properties, draw shapes."
# Then immediately into code so it wasn't abstract for long.

# Section 3: Your First Plot -----------------------------------------------

# Ran the empty canvas first. Someone said "it's broken, there's no points."
# Perfect - that's the lesson. aes() reserved the space, no geom = nothing
# drawn. aes and geom are separate jobs.
ggplot(survey, aes(x = tenure_years, y = salary))

# Then added points:
ggplot(survey, aes(x = tenure_years, y = salary)) +
  geom_point()

# Then the house style - pipe the data in:
survey |>
  ggplot(aes(x = tenure_years, y = salary)) +
  geom_point()

# HERE is where it started: two people wrote |> geom_point() and got an
# error. Wrote it big on the board: PIPE DATA IN, PLUS TO BUILD LAYERS.
# ggplot is older than the pipe, it uses +. Came back to this all session.

# Section 4: Aesthetics ----------------------------------------------------

# color mapped to department - automatic legend
survey |>
  ggplot(aes(x = tenure_years, y = salary, color = department)) +
  geom_point()

# color as a fixed value - OUTSIDE aes
survey |>
  ggplot(aes(x = tenure_years, y = salary)) +
  geom_point(color = "steelblue")

# Demoed THE classic bug live - constant inside aes:
survey |>
  ggplot(aes(x = tenure_years, y = salary, color = "steelblue")) +
  geom_point()
# Points came out RED with a legend labeled "steelblue". Big laugh, good
# learning. Rule: column -> inside aes. Fixed value -> outside aes.

survey |>
  ggplot(aes(x = tenure_years, y = salary,
             color = department, shape = remote)) +
  geom_point(size = 3)

# Section 5: Regression Line -----------------------------------------------

survey |>
  ggplot(aes(x = tenure_years, y = salary)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm")

# Q: "what's the gray band?" - the 95% confidence interval for the fit.
# Showed se = FALSE to turn it off.

# Per-department fit lines by moving color up into the shared aes:
survey |>
  ggplot(aes(x = tenure_years, y = salary, color = department)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE)
# Good moment: both geoms inherit the top-level aes, so color flows to both.

# Section 6: Distributions -------------------------------------------------

survey |>
  ggplot(aes(x = salary)) +
  geom_histogram()
# The "using bins = 30" warning came up - explained it's a nudge, not an
# error, and set a binwidth:

survey |>
  ggplot(aes(x = salary)) +
  geom_histogram(binwidth = 5000, fill = "steelblue", color = "white")

# fill vs color question came up here - fill = inside, color = border.
# Worth its own callout. They mixed these up a few times.

# Section 7: Comparing Groups ----------------------------------------------

survey |>
  ggplot(aes(x = department, y = satisfaction)) +
  geom_boxplot()

# boxplot + jitter (the rich version)
survey |>
  ggplot(aes(x = department, y = satisfaction, fill = department)) +
  geom_boxplot(alpha = 0.5, outliers = FALSE) +
  geom_jitter(width = 0.2, alpha = 0.5)
# Note for myself: outliers = FALSE needs ggplot2 3.5+. Everyone's on
# current tidyverse so fine, but flag it if anyone's on an old laptop.

# geom_bar (counts) vs geom_col (plots values) - the big distinction:
survey |>
  ggplot(aes(x = department)) +
  geom_bar() # counts rows

# tied straight back to Session 5 - wrangle then plot:
survey |>
  group_by(department) |>
  summarize(mean_sat = mean(satisfaction)) |>
  ggplot(aes(x = department, y = mean_sat)) +
  geom_col(fill = "steelblue")
# "geom_bar counts, geom_col plots what you give it." This clicked once
# they saw the dplyr summary feed directly into the plot.

# Section 8: Faceting ------------------------------------------------------

survey |>
  ggplot(aes(x = tenure_years, y = salary)) +
  geom_point() +
  facet_wrap(~ department)
# "Read the tilde as 'by' - one panel by department." Landed well.

survey |>
  ggplot(aes(x = tenure_years, y = salary)) +
  geom_point() +
  facet_grid(remote ~ department)

# ---- ran out of time around here ----

# Section 9: Labels, Scales, Themes ----------------------------------------
# Showed ONE polished example quickly so they'd seen labs() + theme_minimal,
# then said the rest is in the instructor notes for homework.
survey |>
  ggplot(aes(x = tenure_years, y = salary, color = department)) +
  geom_point(alpha = 0.7) +
  labs(title = "Salary by Tenure", x = "Tenure (years)", y = "Salary (USD)") +
  theme_minimal()

# Section 10: Saving Plots -------------------------------------------------
# Mentioned ggsave() verbally - width/height in inches, dpi 300 for print.
# Will demo properly next time. Code is in the instructor file.

# Section 11: MAIN EXERCISE ------------------------------------------------
# HOMEWORK - all four plots in the Student file. Did #1 together as a start,
# including the jitter point about Likert data overlapping:
survey |>
  ggplot(aes(x = engagement, y = satisfaction)) +
  geom_jitter(alpha = 0.5, width = 0.1, height = 0.1) +
  geom_smooth(method = "lm") +
  labs(x = "Engagement (1-5)", y = "Satisfaction (1-5)") +
  theme_minimal()
# Rest (#2-4) are yours. Next session is text analysis - a change of pace.
