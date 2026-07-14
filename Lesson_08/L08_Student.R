###########################################
# Session 8: Text Analysis with tidytext  #
###########################################

# Section 1: Setup ---------------------------------------------------------

# Load the tidyverse, tidytext, and here

# Read in the employee comments (data/employee_comments.csv)

# glimpse the data

# Drop blank / NA comments

# Section 2: Tokenization --------------------------------------------------

# Use unnest_tokens() to break comments into one word per row
# (remember: output column name first, then the input text column)

# glimpse the result and look at the first 15 rows

# How many tokens total?

# Section 3: Word Frequencies ----------------------------------------------

# Count the most common words overall (sort = TRUE)
# What problem do you notice with the top words?

# Section 4: Removing Stopwords --------------------------------------------

# Load the built-in stop_words table

# Use anti_join to remove stopwords

# Count the most common words again - much better now

# Section 5: Visualizing Word Frequencies ----------------------------------

# Bar chart of the top 15 content words
# (use slice_max for the top words and reorder to sort the bars)

# Section 6: Sentiment with the Bing Lexicon -------------------------------

# Get the Bing lexicon with get_sentiments("bing")

# inner_join your cleaned words to the lexicon

# Look at the most common positive and negative words

# Section 7: Aggregating Sentiment -----------------------------------------

# Count positive vs negative words overall

# Compute net sentiment per employee
# (count by employee and sentiment, pivot_wider, then positive - negative)

# Compute net sentiment per department, sorted

# Section 8: Visualizing Sentiment -----------------------------------------

# Bar plot of net sentiment by department (color bars by sign)

# Faceted plot of the top words driving each sentiment

# Section 9: AFINN (Optional) ----------------------------------------------

# (Optional - requires the textdata package and an interactive download.
#  If you've accepted the AFINN license once, try get_sentiments("afinn")
#  and compute a mean score by department.)

# Section 10: MAIN EXERCISE ------------------------------------------------

# 1. Tokenize the comments into one word per row

# 2. Remove stopwords and find the 10 most frequent content words

# 3. Make a bar plot of the most common words

# 4. Join to the Bing lexicon and count positive vs negative words

# 5. Compute net sentiment by department; compare to the Session 5
#    satisfaction pattern - do they tell the same story?

# 6. Plot net sentiment by department

# BONUS: Going Further -----------------------------------------------------

# Add a few custom stopwords with a second anti_join

# Compare the top words in two departments
