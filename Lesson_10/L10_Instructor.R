###########################################
# Session 10: Correlation & Regression    #
###########################################

# This starts the MODELING arc of the course. The last two sessions were
# text; now we're back to numbers, and we move from DESCRIBING data to
# MODELING relationships in it. Correlation measures how two variables move
# together; regression goes further and lets us PREDICT one from others.
#
# This is also where statistical literacy matters as much as R syntax. The
# code for lm() is three characters. Interpreting it correctly - what a
# coefficient means, what a p-value does and doesn't tell you, why
# correlation isn't causation - is the real lesson. Budget time for the
# concepts, not just the functions.
#
# Pacing note: correlation and the correlation matrix are quick. Simple
# regression with lm() and reading its output is the core. broom and
# multiple predictors are the second half. Diagnostics can be a lighter
# touch if time runs short.

# Section 1: Setup ---------------------------------------------------------

library(tidyverse)
library(here)

# New packages this session:
# install.packages(c("corrplot", "broom"))
library(corrplot) # correlation matrix visualization
library(broom) # tidy model outputs (turns model objects into data frames)

survey <- read_csv(here("data", "employee_survey.csv"))
glimpse(survey)

# We'll work with the numeric columns: satisfaction, engagement, autonomy,
# tenure_years, salary. The organizational question driving this session:
# what predicts job satisfaction?

# Section 2: Correlation - The Concept -------------------------------------
# Correlation measures the strength and direction of a LINEAR relationship
# between two numeric variables. It ranges from -1 to +1:
#
#   +1 = perfect positive (as one goes up, the other goes up proportionally)
#    0 = no linear relationship
#   -1 = perfect negative (as one goes up, the other goes down)
#
# The sign is direction; the magnitude is strength. Rough field conventions
# (these are guidelines, not laws):
#   |r| < 0.1   negligible
#   0.1 - 0.3   weak
#   0.3 - 0.5   moderate
#   0.5 - 0.7   strong
#   > 0.7       very strong
#
# THE CARDINAL WARNING, say it early and often: correlation is NOT
# causation. Two things moving together doesn't mean one causes the other.
# Ice cream sales and drownings correlate (both rise in summer); neither
# causes the other. Keep this in front of students all session.

# Section 3: Computing Correlation -----------------------------------------
# cor() computes the correlation between two vectors.

# Pearson correlation (the default) - measures LINEAR association
cor(survey$satisfaction, survey$engagement)
# A single number. Positive and moderate: more engaged employees tend to
# report higher satisfaction.

# Watch for NAs! salary has missing values (Session 3 callback).
cor(survey$satisfaction, survey$salary)
# Returns NA, because cor() can't handle missing values by default.
# use = "complete.obs" drops rows where either value is missing:
cor(survey$satisfaction, survey$salary, use = "complete.obs")

# cor.test() adds a significance test and confidence interval
cor.test(survey$satisfaction, survey$engagement)
# The output gives:
#   - the correlation estimate (cor)
#   - a p-value (is it significantly different from zero?)
#   - a 95% confidence interval for the true correlation
# A small p-value (< 0.05 conventionally) suggests the relationship is
# unlikely to be zero in the population. But p-values are widely
# misunderstood - a small p does NOT mean a large or important effect, just
# a detectable one. With enough data, trivial correlations become
# "significant". Always look at the effect SIZE (the r), not just the p.

# Section 4: Pearson vs Spearman -------------------------------------------
# Pearson measures LINEAR relationships and assumes roughly continuous data.
# Spearman measures MONOTONIC relationships (consistent direction, not
# necessarily a straight line) and works on ranks, so it's more robust to
# outliers and suits ordinal data like Likert scales.

# Pearson (linear)
cor(survey$satisfaction, survey$autonomy, method = "pearson")

# Spearman (rank-based, monotonic)
cor(survey$satisfaction, survey$autonomy, method = "spearman")

# When they differ a lot, it's a clue: maybe the relationship is monotonic
# but not linear, or outliers are distorting Pearson. For our Likert items
# (1-5 integers), Spearman is arguably the more honest choice, though
# Pearson is reported far more often by convention. Mention this; the
# "correct" method depends on your data and field norms.

# Section 5: The Correlation Matrix ----------------------------------------
# Computing correlations one pair at a time is tedious. A correlation matrix
# gives you all pairwise correlations at once.

# Select just the numeric columns (Session 6 where() callback)
survey_num <- survey |>
  select(satisfaction, engagement, autonomy, tenure_years, salary)

# cor() on a data frame gives the full matrix
cor_matrix <- cor(survey_num, use = "complete.obs")
round(cor_matrix, 2) # round for readability
# Read it: the diagonal is all 1 (every variable correlates perfectly with
# itself). The matrix is symmetric (r of A,B equals r of B,A). Scan the
# satisfaction row to see what relates to satisfaction: engagement, autonomy,
# and salary are the moderate-to-strong ones; tenure barely moves with it.

# Section 6: Visualizing the Correlation Matrix ----------------------------
# A matrix of numbers is hard to scan. corrplot turns it into a picture.

# Basic corrplot - circles sized and colored by correlation
corrplot(cor_matrix, method = "circle")

# A cleaner version: upper triangle only, with the numbers shown
corrplot(cor_matrix,
         method = "color",
         type = "upper", # only the upper triangle (matrix is symmetric)
         addCoef.col = "black", # print the correlation values
         tl.col = "black", # text label color
         tl.srt = 45) # rotate labels 45 degrees
# Blue = positive, red = negative, intensity = strength (corrplot's default
# palette). The picture makes the satisfaction relationships pop instantly.
# This is the figure you'd put in a report to show the relationship landscape.

# Section 7: Simple Linear Regression --------------------------------------
# Correlation says two variables move together. Regression fits a LINE that
# lets you predict one (the outcome/response) from another (the predictor).
#
# The model: satisfaction = intercept + slope * engagement + error
# lm() ("linear model") fits it. The formula syntax is: outcome ~ predictor
# Read ~ as "explained by" or "as a function of".

model1 <- lm(satisfaction ~ engagement, data = survey)
model1
# Bare printing shows just the coefficients. Use summary() for the full picture.

summary(model1)
# Walk through the output piece by piece - this is the heart of the session:
#
#   Coefficients table:
#     (Intercept) = predicted satisfaction when engagement = 0
#                   (often not meaningful on its own; engagement is never 0
#                    on a 1-5 scale, so the intercept is an extrapolation)
#     engagement  = the SLOPE. For each 1-point increase in engagement,
#                   predicted satisfaction changes by this much. THIS is the
#                   number you interpret and report.
#     Std. Error  = uncertainty in each estimate
#     t value & Pr(>|t|) = is the coefficient significantly different from 0?
#                   The stars (*, **, ***) flag significance levels.
#
#   R-squared = the proportion of variance in satisfaction explained by the
#               model (0 to 1). 0.27 means engagement explains about 27% of
#               the variation in satisfaction. The rest is other factors and
#               noise. Adjusted R-squared penalizes for extra predictors.
#
#   F-statistic & p-value = is the model as a whole better than nothing?

# THE INTERPRETATION SENTENCE students should be able to write:
# "Each one-point increase in engagement is associated with about a [slope]
#  increase in satisfaction, and engagement explains about [R2*100]% of the
#  variation in satisfaction." Note "associated with", NOT "causes".

# Section 8: Tidy Model Output with broom ----------------------------------
# summary() prints nicely but the output is a messy object that's hard to
# use programmatically. broom converts model output into tidy data frames
# you can filter, plot, and combine - everything from Sessions 5-7 applies.

# tidy() - the coefficient table as a data frame
tidy(model1)
# Columns: term, estimate, std.error, statistic (t), p.value. Now you can
# pipe it, round it, filter it, put it in a report table.

# glance() - one-row model summary (R2, AIC, etc.)
glance(model1)
# R-squared, adjusted R-squared, p-value, AIC, BIC, df - all in one tidy row.
# Great for comparing several models side by side.

# augment() - adds fitted values and residuals back onto the data
augment(model1) |> head()
# .fitted = the model's prediction for each row
# .resid  = the residual (actual minus predicted) - the model's error
# This is what you need for diagnostic plots (Section 10).

# Why broom matters: tidy output means a model is just another data frame.
# You can rbind several models' tidy() results, plot coefficients, build
# summary tables - the whole tidyverse toolkit now works on model output.

# Section 9: Multiple Predictors -------------------------------------------
# Real outcomes have many drivers. Add predictors with + in the formula.
# (Full treatment of multiple regression and interactions is Session 16;
# here we just show that lm scales to more than one predictor.)

model2 <- lm(satisfaction ~ engagement + autonomy, data = survey)
summary(model2)
# Now each slope is the effect of that predictor HOLDING THE OTHER CONSTANT.
# "Controlling for autonomy, each point of engagement adds [b_eng] to
#  satisfaction." The R-squared should rise versus model1 because autonomy
# adds explanatory power. Compare the two:
glance(model1)$r.squared
glance(model2)$r.squared
# The jump shows autonomy contributes beyond engagement alone.

# Add salary too (drops NA-salary rows automatically, with a note)
model3 <- lm(satisfaction ~ engagement + autonomy + salary, data = survey)
summary(model3)
# lm() silently drops rows with NA in any model variable. Check the
# "observations deleted due to missingness" note - know your N changed.

# Compare all three models' fit at a glance
bind_rows(
  glance(model1) |> mutate(model = "engagement"),
  glance(model2) |> mutate(model = "+ autonomy"),
  glance(model3) |> mutate(model = "+ salary")
) |>
  select(model, r.squared, adj.r.squared, AIC, nobs)
# This is broom's real power: three models, one comparison table, built with
# the same dplyr you already know. Lower AIC and higher adjusted R-squared
# generally indicate better fit, but more predictors aren't always better -
# that tension is the heart of Session 16.

# Section 10: Checking the Model -------------------------------------------
# A regression can be fit to anything; that doesn't make it appropriate.
# Linear regression assumes, among other things, that residuals are roughly
# random (no pattern) and roughly normally distributed. A quick visual check:

# Residuals vs fitted - look for random scatter (good) vs a pattern (bad)
augment(model2) |>
  ggplot(aes(x = .fitted, y = .resid)) +
  geom_point(alpha = 0.6) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "firebrick") +
  labs(title = "Residuals vs Fitted",
       x = "Fitted satisfaction", y = "Residual") +
  theme_minimal()
# Want: a formless cloud centered on zero. A funnel shape, a curve, or
# clustering signals a problem (non-constant variance, nonlinearity, etc.).
# Note: with 1-5 integer outcomes the residuals come in bands - a real
# limitation of treating Likert data as continuous, worth saying out loud.

# Base R gives four diagnostic plots at once:
# plot(model2)   # run interactively; press Enter to cycle through the four
# These are the standard residual diagnostics. We keep it light here; the
# point is that you ALWAYS look, you don't just trust the R-squared.

# Section 11: MAIN EXERCISE ------------------------------------------------
# Build a correlation matrix and fit regressions on the survey data.
# Walk through 1-2 together, then let them work.

# 1. Compute a correlation matrix for the numeric variables
ex_num <- survey |>
  select(satisfaction, engagement, autonomy, tenure_years, salary)
ex_cor <- cor(ex_num, use = "complete.obs")
round(ex_cor, 2)

# 2. Visualize it with corrplot
corrplot(ex_cor, method = "color", type = "upper",
         addCoef.col = "black", tl.col = "black", tl.srt = 45)

# 3. Fit a simple regression predicting satisfaction from engagement
ex_model <- lm(satisfaction ~ engagement, data = survey)
summary(ex_model)

# 4. Extract the tidy coefficients with broom
tidy(ex_model)

# 5. Write the interpretation sentence for the engagement slope
#    (discussion: "each one-point increase in engagement is associated
#     with about a ___ increase in satisfaction")

# 6. Fit a multiple regression adding autonomy, compare R-squared to #3
ex_model2 <- lm(satisfaction ~ engagement + autonomy, data = survey)
glance(ex_model)$r.squared
glance(ex_model2)$r.squared

# 7. Plot residuals vs fitted for the multiple model and comment
augment(ex_model2) |>
  ggplot(aes(x = .fitted, y = .resid)) +
  geom_point(alpha = 0.6) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "firebrick") +
  theme_minimal()

# BONUS: Going Further -----------------------------------------------------

# Plot the regression line over the data (Session 7 callback)
survey |>
  ggplot(aes(x = engagement, y = satisfaction)) +
  geom_jitter(alpha = 0.5, width = 0.1, height = 0.1) + # Likert overlap
  geom_smooth(method = "lm") +
  labs(title = "Satisfaction vs Engagement with Fitted Line") +
  theme_minimal()
# geom_smooth(method = "lm") draws the SAME line lm() fits. The visual and
# the model agree - a good moment to connect Session 7 to this session.

# Predict satisfaction for new hypothetical employees
new_data <- tibble(engagement = c(2, 4, 5), autonomy = c(3, 4, 5))
predict(model2, newdata = new_data)
# predict() applies the fitted model to new predictor values. This is the
# whole point of a predictive model - estimate the outcome for cases you
# haven't seen. (Confidence/prediction intervals available via interval=.)

# Standardized coefficients (compare predictors on the same scale)
# Fit on scaled predictors so coefficients are directly comparable in size
survey |>
  mutate(across(c(engagement, autonomy), \(x) scale(x)[, 1])) |>
  lm(satisfaction ~ engagement + autonomy, data = _) |> # _ is the pipe placeholder
  tidy()
# scale() z-scores a variable (Session 6 callback). With predictors on the
# same scale, the larger coefficient is the stronger predictor. Note the _
# placeholder: the native pipe uses _ to send the piped value to a NAMED
# argument (data = _) instead of the first. A handy native-pipe trick.

# =============================================================================
# END OF SESSION 10
# =============================================================================

# A NOTE ON SCOPE: This session teaches the MECHANICS and INTERPRETATION of
# correlation and regression in R. It is not a statistics course. Whether a
# given model is appropriate, which method to use, and how to interpret
# results for real decisions are judgment calls that depend on your data,
# your field, and your question. When the stakes are real, consult someone
# with statistical training. R makes the computation easy; it does not make
# the reasoning automatic.

# TEACHING NOTES FOR NEXT TIME:
# - "Correlation is not causation" cannot be said too many times. Use the
#   ice-cream-and-drownings example; it sticks.
# - The summary(lm) output is dense. Walk it line by line the first time.
#   The two numbers that matter most: the slope (effect) and R-squared (fit).
# - p-values are the most misunderstood thing in statistics. Hammer that a
#   small p means "detectable", not "large" or "important". Effect size first.
# - broom's value isn't obvious until they need to compare models. The
#   three-model glance() table is the moment it clicks - show it deliberately.
# - The Likert-as-continuous issue (banded residuals) is an honest
#   limitation. Naming it builds credibility and previews better methods.
# - Next session: data reshaping and joins (pivot_longer/wider, the join
#   family) - the tools for getting data into modeling shape.

# COMMON STUDENT MISTAKES TO WATCH FOR:
# 1. Forgetting use = "complete.obs" with NAs (cor returns NA silently)
# 2. Interpreting the intercept when predictor = 0 is meaningless
# 3. Reading a small p-value as a large/important effect
# 4. Saying "causes" instead of "is associated with"
# 5. Trusting R-squared without looking at residuals
# 6. Not noticing lm() dropped NA rows (N changed silently)
# 7. Confusing the correlation r with the regression slope (related, not equal)

# KEY CONCEPTS TO REINFORCE:
# - Correlation: -1 to +1, sign = direction, magnitude = strength
# - Correlation is NOT causation (say it every session)
# - lm(outcome ~ predictor): slope = effect, R-squared = fit
# - Interpret the SLOPE and EFFECT SIZE, not just the p-value
# - broom (tidy/glance/augment) makes models into tidy data frames
# - Multiple predictors: each effect is "holding the others constant"
# - Always check residuals; never trust a number you haven't plotted

# ASSESSMENT IDEAS:
# - Give a correlation matrix, have them identify the key relationships
# - Have them fit a regression and write the interpretation sentence
# - Ask them to explain why a significant p-value isn't the whole story
# - Compare two models with broom and justify which fits better
# - Spot the error: a "causes" interpretation of a correlational result
