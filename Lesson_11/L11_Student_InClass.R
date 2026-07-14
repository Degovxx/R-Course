###########################################
# Session 11: Data Reshaping & Joins      #
#            (In-Class Version)           #
###########################################

# Live capture. The wide/long thing took longer to sink in than I expected -
# had to draw it twice. Joins went faster, the Venn diagram helped. The
# silent-NA join failure was the highlight; genuine "oh no" reaction when
# the regions came back NA with no error. Got through Section 9; exercise is
# homework. Notes inline.

# Section 1: Setup ---------------------------------------------------------

library(tidyverse)
library(here)

# Project root is C:\RStuff, so the path carries the "R-Course" prefix.
survey <- read_csv(here("R-Course", "data", "employee_survey.csv"))
dept_info <- read_csv(here("R-Course", "data", "department_info.csv"))
glimpse(survey)
glimpse(dept_info)
# Explained dept_info is a LOOKUP - one row per department, extra attributes.

# Section 2: Wide vs Long --------------------------------------------------
# Drew both shapes on the board with a 2-employee toy example. First pass
# didn't land - someone said "but it's the same data?" YES, exactly, that's
# the point. Same data, two shapes, you move between them. Second drawing
# with the measure/value columns labeled explicitly got there.

# Section 3: pivot_longer --------------------------------------------------

survey_long <- survey |>
  pivot_longer(cols = c(satisfaction, engagement, autonomy),
               names_to = "measure", values_to = "score")
survey_long |> select(employee_id, department, measure, score) |> head(9)
# "See how E001 is now three rows? And department repeats?" That visual of
# the repeating rows is what made long format click.

# The payoff - all three measures in one group_by:
survey_long |>
  group_by(measure) |>
  summarize(mean_score = mean(score), sd_score = sd(score))
# "In wide format that's three separate mean() calls. Here it's one." Sold it.

# Faceted plot for free (Session 7 callback):
survey_long |>
  ggplot(aes(x = score)) +
  geom_bar(fill = "steelblue") +
  facet_wrap(~ measure) +
  theme_minimal()

# Section 4: pivot_wider ---------------------------------------------------

# Reversed it to show the round trip:
survey_long |>
  pivot_wider(names_from = measure, values_from = score) |>
  head()
# "Wide to long to wide, back where we started. Reshaping loses nothing."

# The real pattern - compute long, present wide:
survey_long |>
  group_by(department, measure) |>
  summarize(mean_score = mean(score), .groups = "drop") |>
  pivot_wider(names_from = measure, values_from = mean_score)
# "Compute in long because group_by is easy there, then pivot wide for a
# table a human can read." This is THE workflow. Emphasized it hard.

# Section 5: Joins Concept -------------------------------------------------
# Drew the Venn diagram: two circles, the overlap is the match. left = whole
# left circle, inner = overlap only, full = both whole circles. Pointed out
# dept_info has a Finance row with no employees, which is what makes the
# joins differ. Set up the demo.

# Section 6: left_join -----------------------------------------------------

survey_joined <- survey |>
  left_join(dept_info, by = "department")
nrow(survey)        # 60
nrow(survey_joined) # still 60 - "left_join never drops your left rows"
glimpse(survey_joined)
# "Every employee now has region, head, budget. Finance isn't here because
# no employee belongs to it." The 80%-of-the-time join.

survey_joined |>
  group_by(region) |>
  summarize(n = n(), mean_sat = mean(satisfaction))
# "region didn't exist 30 seconds ago - the join unlocked it." Good moment.

# Section 7: inner_join ----------------------------------------------------

# Showed the difference by flipping direction:
dept_info |>
  inner_join(survey, by = "department") |>
  distinct(department)
# Only 5 departments - "Finance vanished, inner_join drops non-matches."
# The contrast with left_join landed because they'd just seen 60 rows stay.

# Section 8: full_join + anti_join -----------------------------------------

dept_info |>
  full_join(survey, by = "department") |>
  filter(department == "Finance") |>
  select(department, region, employee_id)
# Finance present, employee_id NA. "full_join shows gaps on both sides."

dept_info |>
  anti_join(survey, by = "department")
# Just Finance. "anti_join FINDS the unmatched - it's a data-quality tool,
# not just merging." This reframing surprised a few people.

# Section 9: Broken Join Keys - the highlight ------------------------------

dept_messy <- read_csv(here("R-Course", "data", "department_info_messy.csv"))
dept_messy$department
# Pointed out "engineering" lowercase and "Operations " with trailing space.

broken <- survey |>
  left_join(dept_messy, by = "department")
broken |> filter(is.na(region)) |> count(department)
# Engineering and Operations employees got NA region. NO ERROR. The room
# reacted - "wait it just... didn't match? and didn't tell us?" Exactly.
# "This is worse than an error because nothing warns you. ALWAYS check for
# NAs after a join." Best teaching moment of the session.

# The fix:
dept_fixed <- dept_messy |>
  mutate(department = str_trim(department),
         department = str_to_title(department))
survey |>
  left_join(dept_fixed, by = "department") |>
  filter(is.na(region)) |>
  count(department)
# Zero NA rows. "Clean your keys on both sides first. A join is only as good
# as its keys." Session 3 data-hygiene callback landed.

# ---- ran out of time here ----

# Section 10: MAIN EXERCISE ------------------------------------------------
# HOMEWORK - all seven in the Student file. Did #1 and #4 together (the
# pivot_longer and the left_join) since those anchor the two halves. #7 (the
# broken-key debugging) is the one I most want them to work through - feeling
# the silent failure themselves is the lesson.
survey |>
  pivot_longer(cols = c(satisfaction, engagement, autonomy),
               names_to = "measure", values_to = "score") |>
  head(9)
# Next session: cluster analysis with k-means - finding groups in the data
# rather than testing a relationship we specified.

# Note to self: budget more board time for wide/long next round. It's the
# conceptual bottleneck of the whole session and I rushed the first drawing.
