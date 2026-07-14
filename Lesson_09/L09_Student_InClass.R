###########################################
# Session 9: Advanced Text Analysis       #
#            (In-Class Version)           #
###########################################

# Live capture. TF-IDF took a while to land but the "frequent here, rare
# elsewhere" line eventually clicked. Bigrams were quick. Did the network
# as a demo on my screen (two people had ggraph install trouble - glad I
# didn't make it hands-on). Main exercise is homework. Notes inline.

# Section 1: Setup ---------------------------------------------------------

library(tidyverse)
library(tidytext)
library(here)
library(igraph)
library(ggraph)

# Project root is C:\RStuff, so the path carries the "R-Course" prefix.
comments <- read_csv(here("R-Course", "data", "employee_comments.csv")) |>
  filter(!is.na(comment), comment != "")
glimpse(comments)

# Section 2: The Limitation of Raw Frequency ------------------------------

# Started by showing why last week's frequency isn't enough.
comments |>
  unnest_tokens(word, comment) |>
  anti_join(stop_words, by = "word") |>
  count(department, word, sort = TRUE) |>
  group_by(department) |>
  slice_max(n, n = 5) |>
  ungroup() |>
  arrange(department, desc(n))
# Asked: "do these departments look different?" Not really - team, work,
# feel everywhere. "So how do we find what makes them DIFFERENT?" Setup done.

# Section 3: TF-IDF Intuition ----------------------------------------------
# Whiteboarded it. Took a couple tries. What finally landed:
# "A word is distinctive if it shows up a lot HERE but rarely ELSEWHERE."
# The formula (TF x log(N/df)) I showed but de-emphasized. The sentence is
# what they need. Also flagged the stopword reversal early so it wasn't a
# surprise: "you do NOT remove stopwords for TF-IDF - the math handles it."

# Section 4: Computing TF-IDF ----------------------------------------------

word_counts <- comments |>
  unnest_tokens(word, comment) |>
  count(department, word, sort = TRUE)

dept_tf_idf <- word_counts |>
  bind_tf_idf(word, department, n)

dept_tf_idf |>
  group_by(department) |>
  slice_max(tf_idf, n = 5) |>
  ungroup() |>
  arrange(department, desc(tf_idf)) |>
  select(department, word, n, tf_idf)
# THIS is where it paid off. Engineering's distinctive words are positive
# (enjoy, supported, love), Sales' are negative (disorganized, exhausting).
# Connected it back: "same story as last week's sentiment, but TF-IDF found
# it from the words alone, no lexicon." Good continuity moment.

# Someone noticed a stopword-ish word in HR's list. Used it as a teaching
# point: small corpus, only 5 documents, so an occasional function word can
# be genuinely distinctive. TF-IDF being honest, not broken.

# Section 5: Visualizing TF-IDF --------------------------------------------

dept_tf_idf |>
  group_by(department) |>
  slice_max(tf_idf, n = 6) |>
  ungroup() |>
  mutate(word = reorder_within(word, tf_idf, department)) |>
  ggplot(aes(x = tf_idf, y = word, fill = department)) +
  geom_col() +
  facet_wrap(~ department, scales = "free_y") +
  scale_y_reordered() +
  labs(title = "Most Distinctive Words by Department", x = "TF-IDF", y = NULL) +
  theme_minimal() +
  theme(legend.position = "none")
# Flagged reorder_within + scale_y_reordered as the faceted-text-bar pair.
# "Plain reorder looks broken in facets - use these two together." Wrote it
# on the board because it's the kind of thing nobody remembers cold.

# Section 6: N-grams -------------------------------------------------------

# Bigrams. Showed the raw version first - all stopword junk:
comments |>
  unnest_tokens(bigram, comment, token = "ngrams", n = 2) |>
  count(bigram, sort = TRUE) |>
  head(10)
# "and the", "i am"... same junk problem. But can't anti_join the whole
# bigram. So: separate, filter both words, recount.

comments |>
  unnest_tokens(bigram, comment, token = "ngrams", n = 2) |>
  separate(bigram, into = c("word1", "word2"), sep = " ") |>
  filter(!word1 %in% stop_words$word, !word2 %in% stop_words$word) |>
  count(word1, word2, sort = TRUE) |>
  head(15)
# "poor communication", "unclear priorities", "collaborative environment".
# Real phrases. Same satisfying before/after as last week's stopword demo.

# ---- about here time got tight ----

# Section 7: Word Network (DEMO - did not have everyone run this) -----------
# Built this on my screen. Two folks had ggraph install issues so I made it
# a watch-not-do. Worth seeing even if not running.
bigram_graph <- comments |>
  unnest_tokens(bigram, comment, token = "ngrams", n = 2) |>
  separate(bigram, into = c("word1", "word2"), sep = " ") |>
  filter(!word1 %in% stop_words$word, !word2 %in% stop_words$word) |>
  count(word1, word2, sort = TRUE) |>
  filter(n >= 2) |>
  graph_from_data_frame()

set.seed(2026)
ggraph(bigram_graph, layout = "fr") +
  geom_edge_link(aes(alpha = n), show.legend = FALSE) +
  geom_node_point(color = "steelblue", size = 4) +
  geom_node_text(aes(label = name), vjust = 1, hjust = 1, size = 3) +
  theme_void()
# The "poor -> communication -> from -> leadership" chain was visible and
# people got it immediately. Reminder for those who couldn't run it: install
# igraph and ggraph at home, then this works.

# Section 8: MAIN EXERCISE -------------------------------------------------
# HOMEWORK - all six in the Student file. Did #1 together:
comments |>
  unnest_tokens(word, comment) |>
  count(department, word) |>
  bind_tf_idf(word, department, n) |>
  arrange(desc(tf_idf)) |>
  head(10)
# #6 is the written reflection comparing frequency vs TF-IDF for one
# department - want them to articulate the difference in their own words.
# Next session: correlation and regression. Back to numbers, start of the
# modeling part of the course.

# BONUS mentioned but not run: what follows "not" - the negation problem
# that breaks single-word sentiment. Tied it back to Session 8. Good hook
# for why n-grams matter beyond just "neat phrases".
