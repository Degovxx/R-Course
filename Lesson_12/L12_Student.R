###########################################
# Session 12: Cluster Analysis (k-means)  #
###########################################

# Section 1: Setup ---------------------------------------------------------

# Load the tidyverse and here

# Install and load factoextra and cluster

# Read in the employee survey data

# Section 2: What Is k-means? ----------------------------------------------

# (Concept - no code. Be ready to describe the algorithm in plain English
#  and the two things you must know: you pick k, and starts are random.)

# Section 3: Why Scaling Matters -------------------------------------------

# Look at the ranges of satisfaction, engagement, autonomy, tenure_years
# Why would clustering on raw values be a problem?

# Select those four columns and scale() them to z-scores

# Section 4: Running k-means -----------------------------------------------

# Set a seed, then run kmeans() on the scaled data with centers = 3
# and nstart = 25

# Look at the result: cluster sizes, assignments

# Section 5: Choosing k - The Elbow Method ---------------------------------

# Use fviz_nbclust(..., method = "wss") to draw the elbow plot
# Where is the bend?

# Section 6: Visualizing the Clusters --------------------------------------

# Use fviz_cluster() to plot the clusters in 2D

# Section 7: Profiling the Clusters ----------------------------------------

# Attach the cluster assignment to the ORIGINAL (unscaled) survey

# Compute the mean of each measure per cluster

# Make a grouped bar plot of the cluster profiles
# (summarize, pivot_longer, geom_col with position = "dodge")

# Cross-tabulate cluster with department

# Section 8: MAIN EXERCISE -------------------------------------------------

# 1. Select and scale the clustering variables

# 2. Use the elbow method to choose k

# 3. Run k-means with your chosen k (set a seed, use nstart)

# 4. Visualize the clusters

# 5. Profile each cluster (mean of each measure, original scale)

# 6. Give each cluster a descriptive NAME based on its profile

# 7. Cross-tabulate clusters with department - any patterns?

# BONUS: Going Further -----------------------------------------------------

# Try the silhouette method (fviz_nbclust method = "silhouette")

# Compare k = 2 and k = 4 - which gives the most interpretable groups?

# Run k-means WITHOUT scaling and compare - what got hijacked, and why?
