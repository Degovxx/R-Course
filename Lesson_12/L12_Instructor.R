###########################################
# Session 12: Cluster Analysis (k-means)  #
###########################################

# A shift in goal. Sessions 10-11 tested or combined relationships we
# specified. Clustering is UNSUPERVISED: we don't tell the algorithm what to
# look for, we ask it to FIND structure on its own. "Are there natural
# groups of employees in this survey data?" We don't define the groups in
# advance; k-means discovers them.
#
# The organizational use: employee segmentation. Instead of one-size-fits-
# all, find clusters like "thriving", "at-risk", "disengaged" and tailor
# interventions to each. That's the payoff that makes this concrete.
#
# Pacing note: the INTUITION of k-means and WHY scaling matters are the
# conceptual core - don't rush them. The elbow method and interpreting
# clusters are the practical skills. factoextra makes the visuals easy.

# Section 1: Setup ---------------------------------------------------------

library(tidyverse)
library(here)

# New packages this session:
# install.packages(c("factoextra", "cluster"))
library(factoextra) # clustering visualization (elbow plots, cluster plots)
library(cluster) # clustering algorithms and utilities

survey <- read_csv(here("data", "employee_survey.csv"))
glimpse(survey)

# We'll cluster employees on their survey dimensions: satisfaction,
# engagement, autonomy, and tenure. The question: do employees fall into
# natural groups based on these measures?

# Section 2: What Is k-means? - The Intuition ------------------------------
# k-means partitions observations into k groups so that points within a
# group are as similar as possible and groups are as distinct as possible.
#
# The algorithm, in plain English:
#   1. Pick k (the number of clusters) - YOU choose this up front
#   2. Place k cluster centers randomly
#   3. Assign each point to its NEAREST center
#   4. Move each center to the average of its assigned points
#   5. Repeat 3-4 until centers stop moving
#
# "Nearest" means distance in the variable space. That's the whole idea:
# group points that are close together, where "close" is measured across all
# the variables at once.
#
# TWO THINGS YOU MUST KNOW going in:
#   - You pick k yourself. The algorithm won't tell you how many groups
#     exist; choosing k well is the hard part (Section 5, the elbow method).
#   - The starting centers are RANDOM, so results can vary run to run. Set a
#     seed for reproducibility, and use nstart to try several starts and keep
#     the best (Section 4).

# Section 3: Why Scaling Matters - Do Not Skip -----------------------------
# k-means uses DISTANCE, and distance is dominated by variables on large
# scales. This is the single most important practical point in the session.

# Look at the ranges of our variables:
survey |>
  select(satisfaction, engagement, autonomy, tenure_years) |>
  summary()
# satisfaction/engagement/autonomy run 1-5. tenure runs 0 to ~20. If we
# clustered on the raw numbers, tenure's larger spread would DOMINATE the
# distance calculation - the Likert items would barely matter. The clusters
# would essentially be "tenure groups", ignoring the survey content.

# The fix: SCALE every variable to a common footing (z-score: mean 0, sd 1).
# scale() does this (Session 6/10 callback - same standardization as before).
survey_scaled <- survey |>
  select(satisfaction, engagement, autonomy, tenure_years) |>
  scale() # returns a matrix of z-scores, one column per variable
head(survey_scaled)
# Now every variable contributes equally to distance. No single variable
# dominates because of its units. ALWAYS scale before k-means unless your
# variables are already on the same meaningful scale. This is not optional;
# it changes the answer.

# Section 4: Running k-means -----------------------------------------------
# kmeans() is base R - no package needed. Feed it the scaled data and a k.

set.seed(2026) # random starts -> set a seed so results reproduce
km3 <- kmeans(survey_scaled, centers = 3, nstart = 25)
# centers = 3: ask for 3 clusters (we'll justify this choice in Section 5)
# nstart = 25: try 25 random starts, keep the best. ALWAYS use nstart > 1;
#   a single random start can land on a poor solution. 25 is a safe default.

km3
# The printout shows: cluster sizes, the cluster centers (in scaled units),
# the cluster assignment for each point, and the within-cluster sum of
# squares (a measure of how tight the clusters are - smaller is tighter).

# The pieces you'll actually use:
km3$cluster |> head(20) # which cluster each employee landed in (1, 2, or 3)
km3$size # how many employees per cluster
km3$centers # cluster centers in SCALED units (hard to read - see Section 7)

# Section 5: Choosing k - The Elbow Method ---------------------------------
# We picked 3, but why? k-means makes you choose k, and there's no single
# right answer. The elbow method is the standard heuristic.
#
# The idea: as k increases, within-cluster sum of squares (WSS) always
# decreases (more clusters = tighter fit). But after a point, adding clusters
# barely helps. Plot WSS against k and look for the "elbow" - the bend where
# the improvement levels off. That k is a good balance of fit and simplicity.

# factoextra's fviz_nbclust draws this in one line
fviz_nbclust(survey_scaled, kmeans, method = "wss") +
  labs(title = "Elbow Method for Choosing k")
# Read the plot: steep drop from k=1 to k=2 to k=3, then it flattens. The
# bend around k=3 is the elbow - beyond it, extra clusters add little. So
# k=3 is a defensible choice. The elbow is often SOFT, not a sharp corner;
# pick the region where the curve clearly bends, and use judgment.

# Honesty point for students: the elbow is a heuristic, not a proof. Domain
# knowledge matters too. If you have a business reason to expect 4 employee
# segments, that informs the choice alongside the plot. There are other
# methods (silhouette, gap statistic - see bonus) that can corroborate.

# Section 6: Visualizing the Clusters --------------------------------------
# We have 4 variables, but we can only plot 2 dimensions easily. factoextra's
# fviz_cluster handles this by projecting onto the first two principal
# components (a dimension-reduction technique - it finds the 2D view that
# preserves the most spread). You don't need PCA details now; just know the
# axes are composite directions, not raw variables.

fviz_cluster(km3, data = survey_scaled,
             palette = c("#2E9FDF", "#E7B800", "#FC4E07"),
             geom = "point",
             ellipse.type = "convex", # draw a boundary around each cluster
             ggtheme = theme_minimal()) +
  labs(title = "Employee Clusters (k = 3)")
# Each point is an employee, colored by cluster, with a boundary per group.
# Well-separated, non-overlapping blobs suggest the clustering found real
# structure. Heavy overlap would suggest the groups aren't very distinct.
# The axes (Dim1, Dim2) are principal components; the percentages show how
# much of the total spread each captures.

# Section 7: Profiling the Clusters - The Payoff --------------------------
# A cluster number (1, 2, 3) means nothing until you describe what each group
# IS. Profiling = computing the mean of each variable per cluster, on the
# ORIGINAL (unscaled) scale so it's interpretable. THIS is where clustering
# becomes useful: turning "cluster 2" into "the disengaged group".

# Attach the cluster assignment back to the original (unscaled) data
survey_clustered <- survey |>
  mutate(cluster = factor(km3$cluster)) # factor: cluster is categorical
# IMPORTANT: we scaled a COPY for the algorithm, but profile on the ORIGINAL
# values. The rows are in the same order, so the assignments line up. (This
# alignment assumption is why we didn't reorder the data anywhere.)

# Profile: mean of each measure per cluster
cluster_profiles <- survey_clustered |>
  group_by(cluster) |>
  summarize(
    n = n(),
    mean_satisfaction = mean(satisfaction),
    mean_engagement = mean(engagement),
    mean_autonomy = mean(autonomy),
    mean_tenure = mean(tenure_years),
    .groups = "drop"
  )
cluster_profiles
# NOW read the story. One cluster is high on everything (the thriving group);
# one is low on satisfaction and engagement (the at-risk group); one sits in
# the middle. Give them NAMES based on the numbers - that's the deliverable a
# stakeholder actually uses. The cluster IDs are arbitrary labels; the
# PROFILES are the insight.

# Visualize the profiles (long format + faceting - Sessions 7 & 11 callback)
survey_clustered |>
  group_by(cluster) |>
  summarize(across(c(satisfaction, engagement, autonomy), mean),
            .groups = "drop") |>
  pivot_longer(cols = c(satisfaction, engagement, autonomy),
               names_to = "measure", values_to = "mean_score") |>
  ggplot(aes(x = measure, y = mean_score, fill = cluster)) +
  geom_col(position = "dodge") +
  labs(title = "Cluster Profiles Across Survey Measures",
       x = NULL, y = "Mean score (1-5)") +
  theme_minimal()
# Grouped bars make the profiles pop: you can SEE which cluster is high or
# low on each measure. This is the figure that communicates the segmentation.

# Cross-tabulate clusters with department for extra context
survey_clustered |>
  count(cluster, department) |>
  pivot_wider(names_from = department, values_from = n, values_fill = 0)
# Do certain departments concentrate in certain clusters? Here the at-risk
# cluster skews toward Sales, the thriving cluster toward Engineering -
# matching the satisfaction patterns from earlier sessions. Connecting the
# unsupervised result back to known structure is a good validity check.

# Section 8: MAIN EXERCISE -------------------------------------------------
# Cluster employees on engagement dimensions, choose k, profile the result.
# Walk through 1-2 together, then let them work.

# 1. Select and SCALE the clustering variables
ex_scaled <- survey |>
  select(satisfaction, engagement, autonomy, tenure_years) |>
  scale()

# 2. Use the elbow method to choose k
fviz_nbclust(ex_scaled, kmeans, method = "wss")

# 3. Run k-means with your chosen k (set a seed, use nstart)
set.seed(2026)
ex_km <- kmeans(ex_scaled, centers = 3, nstart = 25)

# 4. Visualize the clusters
fviz_cluster(ex_km, data = ex_scaled, geom = "point",
             ellipse.type = "convex", ggtheme = theme_minimal())

# 5. Profile each cluster (mean of each measure, original scale)
survey |>
  mutate(cluster = factor(ex_km$cluster)) |>
  group_by(cluster) |>
  summarize(n = n(),
            across(c(satisfaction, engagement, autonomy, tenure_years), mean),
            .groups = "drop")

# 6. Give each cluster a descriptive NAME based on its profile
#    (discussion: e.g. "thriving", "at-risk", "steady middle")

# 7. Cross-tabulate clusters with department - any patterns?
survey |>
  mutate(cluster = factor(ex_km$cluster)) |>
  count(cluster, department) |>
  pivot_wider(names_from = department, values_from = n, values_fill = 0)

# BONUS: Going Further -----------------------------------------------------

# The silhouette method: another way to choose k (and assess cluster quality)
fviz_nbclust(survey_scaled, kmeans, method = "silhouette") +
  labs(title = "Silhouette Method for Choosing k")
# Silhouette measures how well each point fits its cluster vs the next-
# nearest one. The k with the highest average silhouette is suggested. When
# elbow and silhouette agree, you can be more confident. When they disagree,
# that's information too - the structure may be ambiguous.

# Compare two values of k side by side
set.seed(2026)
km2 <- kmeans(survey_scaled, centers = 2, nstart = 25)
km4 <- kmeans(survey_scaled, centers = 4, nstart = 25)
# Profile each and ask: which gives the most INTERPRETABLE, actionable
# groups? Sometimes the statistically-suggested k isn't the most useful one.
# Interpretability is a legitimate tie-breaker.

# What happens WITHOUT scaling (the cautionary demo)
set.seed(2026)
km_unscaled <- survey |>
  select(satisfaction, engagement, autonomy, tenure_years) |>
  kmeans(centers = 3, nstart = 25)
survey |>
  mutate(cluster = factor(km_unscaled$cluster)) |>
  group_by(cluster) |>
  summarize(mean_tenure = mean(tenure_years),
            mean_satisfaction = mean(satisfaction), .groups = "drop")
# Compare these clusters to the scaled ones. The unscaled clusters are
# basically tenure bands - satisfaction barely varies across them because
# tenure's larger range hijacked the distance. This is WHY we scale. Showing
# the broken version makes the lesson stick.

# k-means assigns EVERY point to a cluster, even outliers or points between
# groups. It assumes roughly spherical, similar-sized clusters. It's a tool,
# not truth - the "clusters" are always there because you asked for k of
# them. Whether they're MEANINGFUL is your judgment call, informed by the
# profiles and domain knowledge, not the algorithm.

# =============================================================================
# END OF SESSION 12
# =============================================================================

# TEACHING NOTES FOR NEXT TIME:
# - Scaling is the make-or-break practical point. The unscaled-vs-scaled
#   contrast (bonus) is worth doing live - seeing tenure hijack the clusters
#   makes "always scale" memorable instead of a rule they forget.
# - The elbow is soft here (bend around k=3 but not a sharp corner). Use that
#   honestly: real elbows are usually soft, and judgment + domain knowledge
#   matter. Don't pretend the data points to one obvious k.
# - Profiling is the payoff. A cluster number is meaningless; the PROFILE
#   ("high satisfaction, high autonomy = thriving") is the deliverable.
#   Make them name the clusters - that's the skill stakeholders care about.
# - Emphasize unsupervised vs supervised: we're FINDING structure, not
#   testing a hypothesis. This reframes the goal versus Sessions 10-11.
# - Honesty: k-means always returns k clusters. Their meaningfulness is not
#   guaranteed by the algorithm. Teach healthy skepticism.
# - Next session: writing custom functions - the start of the programming
#   half, moving from using tools to building them.

# COMMON STUDENT MISTAKES TO WATCH FOR:
# 1. Forgetting to scale (clusters get dominated by the widest-range variable)
# 2. Forgetting set.seed (results change every run, confusion ensues)
# 3. Using nstart = 1 or omitting it (unstable solutions)
# 4. Profiling on scaled data (z-scores aren't interpretable - use originals)
# 5. Treating the cluster numbers as meaningful labels (they're arbitrary)
# 6. Picking k from the elbow alone, ignoring interpretability
# 7. Believing the clusters are "real" just because the algorithm returned them

# KEY CONCEPTS TO REINFORCE:
# - Clustering is UNSUPERVISED: find structure, don't test a hypothesis
# - You choose k; the algorithm won't tell you how many groups exist
# - ALWAYS scale variables before k-means (distance is scale-sensitive)
# - set.seed + nstart for reproducible, stable results
# - Elbow method to choose k (and it's a soft heuristic, not a proof)
# - Profile clusters on the ORIGINAL scale and give them names
# - k-means always returns k clusters; meaningfulness is your judgment

# ASSESSMENT IDEAS:
# - Give unscaled data, have them cluster, then scale and re-cluster, and
#   explain why the results differ
# - Have them choose k with the elbow method and justify the choice
# - Profile a clustering solution and name the segments
# - Ask why a cluster number alone is not an insight
# - Discuss when interpretability should override the statistically-suggested k
