###########################################
# Session 9: Advanced Text Analysis       #
###########################################

# Section 1: Setup ---------------------------------------------------------

# Load the tidyverse, tidytext, and here

# Install and load igraph and ggraph (for the network section)

# Read in the comments and drop blanks (same as Session 8)

# Section 2: The Limitation of Raw Frequency ------------------------------

# Find the top 5 most frequent content words per department
# (tokenize, remove stopwords, count by department, slice_max per group)
# What do you notice - do the departments look different or similar?

# Section 3: TF-IDF - The Intuition ----------------------------------------

# (Concept - no code. Be ready to explain TF-IDF in one sentence:
#  a word that is frequent HERE but rare ELSEWHERE is distinctive.)

# Section 4: Computing TF-IDF ----------------------------------------------

# Step 1: count words per department (do NOT remove stopwords - why not?)

# Step 2: use bind_tf_idf(word, department, n) to add tf, idf, tf_idf

# Step 3: show the top 5 distinctive words per department

# Section 5: Visualizing TF-IDF --------------------------------------------

# Faceted bar plot of the top distinctive words per department
# (use reorder_within() and scale_y_reordered() to sort within facets)

# Section 6: N-grams -------------------------------------------------------

# Tokenize into bigrams (token = "ngrams", n = 2)

# Count the raw bigrams - what's the problem?

# separate() the bigram into word1 and word2

# Filter out rows where either word is a stopword

# Count the meaningful bigrams

# Section 7: Word Co-occurrence Networks -----------------------------------

# Build a graph from bigram counts (keep pairs with n >= 2)
# using graph_from_data_frame()

# Plot it with ggraph (set.seed first, use layout = "fr", theme_void)

# Section 8: MAIN EXERCISE -------------------------------------------------

# 1. Compute TF-IDF for words by department

# 2. Show the top 5 distinctive words per department

# 3. Plot the distinctive words (faceted, reorder_within)

# 4. Extract bigrams and find the most common meaningful pairs

# 5. Build and plot a word co-occurrence network

# 6. Pick one department. What did raw frequency say vs TF-IDF?
#    Write 2-3 sentences.

# BONUS: Going Further -----------------------------------------------------

# Extract trigrams (n = 3) - why are they sparse on this data?

# Find what words follow "not" (negation that single tokens miss)

# Compute TF-IDF at the employee level instead of department
# - how does changing the document unit change the question?
