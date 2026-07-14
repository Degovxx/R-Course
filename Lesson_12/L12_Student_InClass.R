###########################################
# Session 12: Cluster Analysis (k-means)  #
#            (In-Class Version)           #
###########################################

# Live capture. The unsupervised-vs-supervised framing landed well - "we're
# not testing anything, we're asking what's there." The scaling demo (broken
# vs fixed) was the moment that stuck. Got through profiling; the bonus and
# exercise are homework. Notes inline.

# Section 1: Setup ---------------------------------------------------------

library(tidyverse)
library(here)
library(factoextra)
library(cluster)

# Project root is C:\RStuff, so the path carries the "R-Course" prefix.
survey <- read_csv(here("R-Course", "data", "employee_survey.csv"))
glimpse(survey)

# Section 2: What Is k-means? ----------------------------------------------
# Walked the algorithm in plain English: pick k, drop k centers, assign each
# point to nearest, move centers to the average, repeat. The "you choose k,
# the algorithm won't tell you" point surprised a few - they expected it to
# just find the number of groups. Good - that's the hard part, set up Sec 5.

# Section 3: Scaling - the demo that stuck ---------------------------------

survey |>
  select(satisfaction, engagement, autonomy, tenure_years) |>
  summary()
# Showed the ranges: Likert 1-5, but tenure 0-20. "If we don't scale, tenure
# will hijack the distance because its numbers are bigger." Promised to PROVE
# it in the bonus (and did - see end). That promise kept them paying attention.

survey_scaled <- survey |>
  select(satisfaction, engagement, autonomy, tenure_years) |>
  scale()
head(survey_scaled)
# "Now everything is on the same footing - mean 0, sd 1. Always scale before
# k-means." Tied it back to the z-scoring from Sessions 6 and 10.

# Section 4: Running k-means -----------------------------------------------

set.seed(2026)
km3 <- kmeans(survey_scaled, centers = 3, nstart = 25)
km3$size
# Three clusters, sizes roughly 20 / 15 / 25. Explained nstart = 25 tries 25
# random starts and keeps the best. "Never use just one start - you might
# land on a bad solution." And set.seed so we all get the same answer.

# Section 5: Elbow Method --------------------------------------------------

fviz_nbclust(survey_scaled, kmeans, method = "wss")
# Steep drop to k=2, another solid drop to k=3, then it flattens. "The bend
# is around 3 - that's the elbow." Was honest that it's SOFT, not a sharp
# corner. "Real elbows usually are. You use judgment, and domain knowledge
# counts too." Someone asked "what if I think there are 4 types of employee?"
# - great question, said that's exactly the kind of domain input that belongs
# alongside the plot.

# Section 6: Visualizing ---------------------------------------------------

fviz_cluster(km3, data = survey_scaled, geom = "point",
             ellipse.type = "convex", ggtheme = theme_minimal())
# Three reasonably separated blobs. Explained the axes are principal
# components (a 2D projection of the 4 variables) without going deep - "it's
# the flattest informative view of the 4D data." Good enough for now.

# Section 7: Profiling - the payoff ----------------------------------------

survey_clustered <- survey |>
  mutate(cluster = factor(km3$cluster))

cluster_profiles <- survey_clustered |>
  group_by(cluster) |>
  summarize(n = n(),
            mean_satisfaction = mean(satisfaction),
            mean_engagement = mean(engagement),
            mean_autonomy = mean(autonomy),
            mean_tenure = mean(tenure_years),
            .groups = "drop")
cluster_profiles
# THIS is where it came together. One cluster high on everything (~4.7 sat,
# ~4.5 autonomy) - "the thriving group." One low (~2.7 sat, ~2.9 engagement)
# - "the at-risk group." One in the middle. Made them name the clusters
# out loud. "The number is nothing; the profile is the insight." Profiled on
# ORIGINAL scale, not z-scores - flagged that z-scores aren't interpretable.

# Grouped bar of the profiles (Sessions 7 + 11 callback):
survey_clustered |>
  group_by(cluster) |>
  summarize(across(c(satisfaction, engagement, autonomy), mean),
            .groups = "drop") |>
  pivot_longer(cols = c(satisfaction, engagement, autonomy),
               names_to = "measure", values_to = "mean_score") |>
  ggplot(aes(x = measure, y = mean_score, fill = cluster)) +
  geom_col(position = "dodge") +
  theme_minimal()
# The grouped bars made the segments obvious at a glance. They used
# pivot_longer without prompting - nice to see Session 11 stick.

# Cross-tab with department:
survey_clustered |>
  count(cluster, department) |>
  pivot_wider(names_from = department, values_from = n, values_fill = 0)
# At-risk cluster skews Sales, thriving skews Engineering - same story as the
# satisfaction patterns from earlier sessions. "The unsupervised result
# agrees with what we already knew - that's a good validity check."

# ---- ran out of time here ----

# Section 8: MAIN EXERCISE -------------------------------------------------
# HOMEWORK - all seven in the Student file. Did #1-3 together (scale, elbow,
# run). #6 (naming the clusters) is the one that matters most - articulating
# a segment in plain English is the deliverable a manager actually uses.

# BONUS done live (because I promised): k-means WITHOUT scaling -------------
set.seed(2026)
km_unscaled <- survey |>
  select(satisfaction, engagement, autonomy, tenure_years) |>
  kmeans(centers = 3, nstart = 25)
survey |>
  mutate(cluster = factor(km_unscaled$cluster)) |>
  group_by(cluster) |>
  summarize(mean_tenure = mean(tenure_years),
            mean_satisfaction = mean(satisfaction), .groups = "drop")
# The unscaled clusters were basically tenure bands - satisfaction barely
# moved across them. "See? Tenure hijacked it. THAT is why we scale." This
# was the demo that made scaling memorable instead of a rule to forget.
# Next session: writing your own functions - we start BUILDING tools, not
# just using them. Beginning of the programming half of the course.
