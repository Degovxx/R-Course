###########################################
# Session 10: Correlation & Regression    #
#            (In-Class Version)           #
###########################################

# Live capture. Spent more time on interpretation than syntax, which was
# right - lm() is easy, reading it is the skill. The correlation-isn't-
# causation point came up about five times. Got through multiple regression
# and broom's model-comparison table; diagnostics and the exercise are
# homework. Notes inline.

# Section 1: Setup ---------------------------------------------------------

library(tidyverse)
library(here)
library(corrplot)
library(broom)

# Project root is C:\RStuff, so the path carries the "R-Course" prefix.
survey <- read_csv(here("R-Course", "data", "employee_survey.csv"))
glimpse(survey)

# Section 2: Correlation Concept -------------------------------------------
# Whiteboarded the -1 to +1 scale. Then the ice cream / drownings example
# for correlation-not-causation. Someone offered "umbrellas and rain" as
# another - good, they got it. Came back to this point all session.

# Section 3: Computing Correlation -----------------------------------------

cor(survey$satisfaction, survey$engagement)
# ~0.54. Moderate positive. "More engaged people tend to report higher
# satisfaction" - note the careful wording, no causal claim.

# The NA gotcha with salary (Session 3 callback):
cor(survey$satisfaction, survey$salary) # NA!
cor(survey$satisfaction, survey$salary, use = "complete.obs") # ~0.48

cor.test(survey$satisfaction, survey$engagement)
# Walked through the p-value and CI. Big point that landed: "a small p means
# DETECTABLE, not BIG. Look at the r for how big." Repeated this twice.

# Section 4: Pearson vs Spearman -------------------------------------------

cor(survey$satisfaction, survey$autonomy, method = "pearson")
cor(survey$satisfaction, survey$autonomy, method = "spearman")
# Close here, so didn't dwell. Noted Spearman is arguably better for Likert
# (it's ordinal) but Pearson is what everyone reports. Field convention.

# Section 5: Correlation Matrix --------------------------------------------

survey_num <- survey |>
  select(satisfaction, engagement, autonomy, tenure_years, salary)

cor_matrix <- cor(survey_num, use = "complete.obs")
round(cor_matrix, 2)
# Scanned the satisfaction row together: engagement, autonomy, salary all
# moderate; tenure basically flat (~0.06). "Tenure doesn't move with
# satisfaction here" - useful negative result.

# Section 6: Visualizing It ------------------------------------------------

corrplot(cor_matrix, method = "color", type = "upper",
         addCoef.col = "black", tl.col = "black", tl.srt = 45)
# The picture got an "oh that's much easier to read." Blue positive, red
# negative. This is the report figure.

# Section 7: Simple Regression - the core ----------------------------------

model1 <- lm(satisfaction ~ engagement, data = survey)
summary(model1)
# Walked the output line by line. Slope ~0.58: "each one-point bump in
# engagement is ASSOCIATED WITH about a 0.58 bump in satisfaction." Made
# them say "associated with" not "causes". R-squared ~0.27: "engagement
# explains about 27% of the variation, the rest is other stuff and noise."
# The intercept-at-zero-engagement point confused one person - explained
# it's an extrapolation since engagement is never 0 on a 1-5 scale.

# Section 8: broom ---------------------------------------------------------

tidy(model1) # coefficients as a tidy data frame
glance(model1) # one-row fit summary
augment(model1) |> head() # fitted + residuals
# "Why bother when summary() prints fine?" Good question - showed the payoff
# in the next section (comparing models). Parked it for 2 minutes.

# Section 9: Multiple Predictors - broom pays off --------------------------

model2 <- lm(satisfaction ~ engagement + autonomy, data = survey)
summary(model2)
# R-squared jumped to ~0.51 from 0.27. "Autonomy adds real explanatory power
# beyond engagement." Each slope now "holding the other constant."

glance(model1)$r.squared
glance(model2)$r.squared

model3 <- lm(satisfaction ~ engagement + autonomy + salary, data = survey)
# Flagged the "observations deleted due to missingness" note - salary NAs
# dropped some rows. "Your N changed, know that."

# THE broom moment - three models, one comparison table:
bind_rows(
  glance(model1) |> mutate(model = "engagement"),
  glance(model2) |> mutate(model = "+ autonomy"),
  glance(model3) |> mutate(model = "+ salary")
) |>
  select(model, r.squared, adj.r.squared, AIC, nobs)
# THIS is when broom clicked. "Models are just data frames now, so dplyr
# works on them." The R-squared climbing across the table told the story
# cleanly. Good setup for Session 16 (when more isn't always better).

# ---- ran out of time about here ----

# Section 10: Checking the Model -------------------------------------------
# Showed ONE residuals-vs-fitted plot quickly so they'd seen the idea:
augment(model2) |>
  ggplot(aes(x = .fitted, y = .resid)) +
  geom_point(alpha = 0.6) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "firebrick") +
  theme_minimal()
# Pointed out the residuals come in BANDS because satisfaction is 1-5
# integers - an honest limitation of treating Likert as continuous. Said
# we'll meet better tools later. "Always look at residuals, never just trust
# R-squared." Full diagnostics (plot(model2)) is in the instructor file.

# Section 11: MAIN EXERCISE ------------------------------------------------
# HOMEWORK - all seven in the Student file. Did #1-3 together (matrix,
# corrplot, simple regression). The written interpretation sentence (#5) is
# the one I most want them to nail - articulating a slope in plain English
# without saying "causes".
ex_model <- lm(satisfaction ~ engagement, data = survey)
tidy(ex_model)
# Next session: reshaping and joins - getting messy real-world data into the
# shape modeling needs.

# Reminder to self for next time: the p-value-vs-effect-size point needs
# even more air. Half the room still defaults to "is it significant?" as the
# only question. Effect size first, every time.
