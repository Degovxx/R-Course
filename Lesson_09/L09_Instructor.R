###########################################
# Session 9: Advanced Text Analysis       #
###########################################

# Last session we counted words and scored sentiment. The limitation: raw
# frequency tells you what's COMMON, not what's DISTINCTIVE. "work" and
# "team" are everywhere, so they're useless for telling departments apart.
# This session answers two sharper questions:
#
#   1. Which words are DISTINCTIVE to each group? -> TF-IDF
#   2. How do words PAIR UP into phrases and networks? -> n-grams, co-occurrence
#
# Same comments data as Session 8. The throughline: frequency finds the
# obvious; TF-IDF and n-grams find the interesting.
#
# Pacing note: TF-IDF is the conceptual core and deserves real time -
# students need the INTUITION, not the formula. Bigrams are intuitive and
# fast. The word network is the visual payoff but also the fussiest setup
# (extra packages); if time is short it can be a demo rather than hands-on.

# Section 1: Setup ---------------------------------------------------------

library(tidyverse)
library(tidytext)
library(here)

# New packages for the network section (Section 7):
# install.packages(c("igraph", "ggraph"))
library(igraph) # graph data structures
library(ggraph) # ggplot-style graph visualization

comments <- read_csv(here("data", "employee_comments.csv")) |>
  filter(!is.na(comment), comment != "") # drop blanks (Session 8 habit)
glimpse(comments)

# Section 2: The Limitation of Raw Frequency -------------------------------
# Motivate TF-IDF by showing why plain counts fall short.

# Most frequent content words per department (Session 8 approach)
comments |>
  unnest_tokens(word, comment) |>
  anti_join(stop_words, by = "word") |>
  count(department, word, sort = TRUE) |>
  group_by(department) |>
  slice_max(n, n = 5) |>
  ungroup() |>
  arrange(department, desc(n))
# The problem: the top words look SIMILAR across departments - "team",
# "work", "feel", "manager" show up everywhere. Frequency tells us what
# people talk about in general, not what makes each department DIFFERENT.
# We need a measure that rewards words distinctive to one group.

# Section 3: TF-IDF - The Intuition ----------------------------------------
# TF-IDF = Term Frequency x Inverse Document Frequency.
# Don't lead with the formula. Lead with the idea:
#
#   - A word matters to a document if it appears OFTEN there (high TF)...
#   - ...but ONLY if it's RARE across the whole corpus (high IDF).
#
# A word that's frequent everywhere (like "the" or "work") gets a low score
# because it's not distinctive. A word that's frequent in ONE department but
# rare elsewhere gets a high score - that's the signal we want.
#
# The pieces:
#   TF  = how often a word appears in a document (here: a department)
#   IDF = log(total documents / documents containing the word)
#         A word in ALL documents has IDF = log(1) = 0, killing its score.
#   TF-IDF = TF x IDF
#
# A "document" is whatever unit you choose to compare. Here each DEPARTMENT
# is a document, and we ask which words distinguish each department.
#
# KEY POINT: TF-IDF handles common-word downweighting AUTOMATICALLY. You
# generally do NOT remove stopwords first - the IDF term already crushes
# ubiquitous words to near zero. This surprises students who just learned
# anti_join. Tell them: stopword removal was for frequency; TF-IDF self-cleans.

# Section 4: Computing TF-IDF ----------------------------------------------
# tidytext's bind_tf_idf() does the whole calculation in one verb.

# Step 1: get word counts per department (no stopword removal - see above)
word_counts <- comments |>
  unnest_tokens(word, comment) |>
  count(department, word, sort = TRUE)
word_counts

# Step 2: bind_tf_idf adds tf, idf, and tf_idf columns
# Arguments: bind_tf_idf(term_column, document_column, count_column)
dept_tf_idf <- word_counts |>
  bind_tf_idf(word, department, n)
dept_tf_idf |> arrange(desc(tf_idf)) |> head(15)
# The high-tf_idf words are the DISTINCTIVE ones. Note words appearing in
# all five departments have idf = 0 and thus tf_idf = 0 - automatically
# filtered out without us lifting a finger.

# Step 3: top distinctive words per department
dept_tf_idf |>
  group_by(department) |>
  slice_max(tf_idf, n = 5) |>
  ungroup() |>
  arrange(department, desc(tf_idf)) |>
  select(department, word, n, tf_idf)
# NOW the departments look different. Engineering's distinctive words skew
# positive (enjoy, supported, love); Sales skews negative (disorganized,
# exhausting). This is the SAME story as the Session 8 sentiment, but TF-IDF
# surfaced it from the words themselves without a sentiment lexicon.

# A note on a quirk: with short comments and only five documents, an
# occasional stopword can sneak into the top list if it happens to be
# distinctive to one department's phrasing. That's TF-IDF being honest about
# THIS small corpus, not a bug. On larger corpora it's rarely an issue. If
# it bothers you, you can anti_join stopwords first - just know it's optional.

# Section 5: Visualizing TF-IDF --------------------------------------------

dept_tf_idf |>
  group_by(department) |>
  slice_max(tf_idf, n = 6) |>
  ungroup() |>
  mutate(word = reorder_within(word, tf_idf, department)) |>
  ggplot(aes(x = tf_idf, y = word, fill = department)) +
  geom_col() +
  facet_wrap(~ department, scales = "free_y") +
  scale_y_reordered() + # undoes the reorder_within suffix on the labels
  labs(title = "Most Distinctive Words by Department",
       subtitle = "Highest TF-IDF scores",
       x = "TF-IDF", y = NULL) +
  theme_minimal() +
  theme(legend.position = "none")
# NEW helpers: reorder_within() and scale_y_reordered() are a tidytext pair
# for sorting bars WITHIN each facet independently. Plain reorder() (Session
# 7) sorts globally and looks wrong inside facets; this pair fixes that.
# It's the one faceted-bar gotcha worth memorizing for text work.

# Section 6: N-grams - Words in Sequence -----------------------------------
# Single words lose context: "not good" tokenizes to "not" and "good", and
# "good" might even score positive. N-grams keep word ORDER by tokenizing
# into sequences. A bigram is two consecutive words; a trigram is three.

# Tokenize into bigrams with token = "ngrams", n = 2
bigrams <- comments |>
  unnest_tokens(bigram, comment, token = "ngrams", n = 2)
bigrams |> select(department, bigram) |> head(10)

# Most common bigrams - but they're full of stopwords ("and the", "i am")
bigrams |> count(bigram, sort = TRUE) |> head(10)
# Same stopword problem as Session 8, but now we can't just anti_join the
# whole bigram - we need to remove rows where EITHER word is a stopword.

# Step 1: split the bigram into two columns with separate()
bigrams_separated <- bigrams |>
  separate(bigram, into = c("word1", "word2"), sep = " ")
# separate() splits one column into several on a delimiter (Session 3-style
# parsing). Now we have word1 and word2 as their own columns.

# Step 2: filter out any bigram where either word is a stopword
bigrams_filtered <- bigrams_separated |>
  filter(!word1 %in% stop_words$word,
         !word2 %in% stop_words$word)

# Step 3: count the meaningful bigrams
bigrams_filtered |>
  count(word1, word2, sort = TRUE) |>
  head(15)
# Now real phrases surface: "poor communication", "unclear priorities",
# "collaborative environment". These carry far more meaning than single
# words. Run the before (stopword junk) and after (real phrases) back to
# back - same satisfying contrast as the Session 8 stopword demo.

# Recombine into a single column if you want the phrase back
bigrams_counts <- bigrams_filtered |>
  count(word1, word2, sort = TRUE) |>
  unite(bigram, word1, word2, sep = " ") # unite is the inverse of separate
bigrams_counts |> head(10)

# Section 7: Word Co-occurrence Networks -----------------------------------
# Bigrams are pairs; a NETWORK shows the whole web of which words connect to
# which. Each word is a node; an edge links words that appear together,
# weighted by how often. This reveals clusters of related language.

# Build a graph from the bigram counts. graph_from_data_frame expects
# columns: from, to, and (optionally) edge attributes like weight.
bigram_graph <- bigrams_filtered |>
  count(word1, word2, sort = TRUE) |>
  filter(n >= 2) |> # only keep pairs occurring 2+ times, or it's a hairball
  graph_from_data_frame()
bigram_graph # an igraph object - prints a summary, not a data frame

# Visualize with ggraph (ggplot grammar, but for graphs)
set.seed(2026) # layout is randomized; seed makes it reproducible
ggraph(bigram_graph, layout = "fr") + # "fr" = force-directed layout
  geom_edge_link(aes(alpha = n), show.legend = FALSE) +
  geom_node_point(color = "steelblue", size = 4) +
  geom_node_text(aes(label = name), vjust = 1, hjust = 1, size = 3) +
  labs(title = "Word Co-occurrence Network") +
  theme_void() # graphs want no axes or grid - theme_void strips everything
# Read it: connected words tend to appear together. Chains like
# "poor -> communication -> from -> leadership" trace common phrasings.
# Clusters reveal themes. It's exploratory, not precise - a map of the
# language, good for spotting structure you'd then investigate with counts.
#
# SETUP CAUTION: ggraph/igraph are heavier dependencies. If a student's
# install fails, don't let it derail the session - the TF-IDF and bigram
# sections are the core learning. Have this ready as a demo on your machine
# so everyone sees it even if not everyone can run it.

# Section 8: MAIN EXERCISE -------------------------------------------------
# Compute TF-IDF, extract bigrams, build a small network.
# Walk through 1-2 together, then let them work.

# 1. Compute TF-IDF for words by department
ex_tf_idf <- comments |>
  unnest_tokens(word, comment) |>
  count(department, word) |>
  bind_tf_idf(word, department, n)
ex_tf_idf |> arrange(desc(tf_idf)) |> head(10)

# 2. Show the top 5 distinctive words per department
ex_tf_idf |>
  group_by(department) |>
  slice_max(tf_idf, n = 5) |>
  ungroup() |>
  select(department, word, tf_idf) |>
  arrange(department, desc(tf_idf))

# 3. Plot the distinctive words (faceted, using reorder_within)
ex_tf_idf |>
  group_by(department) |>
  slice_max(tf_idf, n = 5) |>
  ungroup() |>
  mutate(word = reorder_within(word, tf_idf, department)) |>
  ggplot(aes(x = tf_idf, y = word, fill = department)) +
  geom_col() +
  facet_wrap(~ department, scales = "free_y") +
  scale_y_reordered() +
  theme_minimal() +
  theme(legend.position = "none")

# 4. Extract bigrams and find the most common meaningful pairs
comments |>
  unnest_tokens(bigram, comment, token = "ngrams", n = 2) |>
  separate(bigram, into = c("word1", "word2"), sep = " ") |>
  filter(!word1 %in% stop_words$word, !word2 %in% stop_words$word) |>
  count(word1, word2, sort = TRUE) |>
  head(10)

# 5. Build and plot a word co-occurrence network
ex_graph <- comments |>
  unnest_tokens(bigram, comment, token = "ngrams", n = 2) |>
  separate(bigram, into = c("word1", "word2"), sep = " ") |>
  filter(!word1 %in% stop_words$word, !word2 %in% stop_words$word) |>
  count(word1, word2, sort = TRUE) |>
  filter(n >= 2) |>
  graph_from_data_frame()

set.seed(2026)
ggraph(ex_graph, layout = "fr") +
  geom_edge_link(aes(alpha = n), show.legend = FALSE) +
  geom_node_point(color = "steelblue", size = 4) +
  geom_node_text(aes(label = name), size = 3, vjust = 1, hjust = 1) +
  theme_void()

# 6. Compare insights: pick one department. What did raw frequency say
#    versus TF-IDF? Write 2-3 sentences. (Discussion, not code.)

# BONUS: Going Further -----------------------------------------------------

# Trigrams (three-word sequences) for longer phrases
comments |>
  unnest_tokens(trigram, comment, token = "ngrams", n = 3) |>
  separate(trigram, into = c("w1", "w2", "w3"), sep = " ") |>
  filter(!w1 %in% stop_words$word,
         !w2 %in% stop_words$word,
         !w3 %in% stop_words$word) |>
  count(w1, w2, w3, sort = TRUE) |>
  head(10)
# Trigrams need more data to be useful - on a small corpus most occur once.
# Show this so students see the data-hunger of higher n-grams firsthand.

# What words follow "not"? (negation - the thing single tokens miss)
comments |>
  unnest_tokens(bigram, comment, token = "ngrams", n = 2) |>
  separate(bigram, into = c("word1", "word2"), sep = " ") |>
  filter(word1 == "not") |>
  count(word2, sort = TRUE)
# This is WHY n-grams matter for sentiment. "not good", "not enough" - the
# single-word sentiment from Session 8 would score "good" as positive and
# miss the negation entirely. N-grams are how you'd start to fix that.

# TF-IDF at the employee level instead of department
comments |>
  unnest_tokens(word, comment) |>
  count(employee_id, word) |>
  bind_tf_idf(word, employee_id, n) |>
  arrange(desc(tf_idf)) |>
  head(10)
# Changing the "document" unit changes the question entirely. Department
# documents ask "what distinguishes departments"; employee documents ask
# "what's unique to each person's comment". Same tool, different lens.

# =============================================================================
# END OF SESSION 9
# =============================================================================

# TEACHING NOTES FOR NEXT TIME:
# - TF-IDF intuition over formula. "Frequent here AND rare elsewhere." If
#   they leave understanding that one sentence, the session worked. The
#   math is secondary; bind_tf_idf does it for them.
# - The "frequency looks the same across departments, TF-IDF looks
#   different" contrast (Sections 2 vs 4) is the whole motivation. Run both
#   and let them SEE the difference before explaining why.
# - Stopwords: this is the confusing reversal. They JUST learned to remove
#   stopwords; now TF-IDF says don't bother (IDF handles it) but bigrams say
#   do (different reason). Be explicit about which technique wants which.
# - reorder_within + scale_y_reordered is a memorize-it pair for faceted
#   text bars. Plain reorder looks broken in facets.
# - The network is the prettiest output but the fussiest setup. Have it
#   pre-running as a demo so a failed install doesn't sink the room.
# - Next session: correlation and regression - back to numbers, the start
#   of the modeling arc.

# COMMON STUDENT MISTAKES TO WATCH FOR:
# 1. Removing stopwords before TF-IDF (unnecessary; IDF already handles it)
# 2. anti_join on the whole bigram (you must separate() first, then filter)
# 3. Plain reorder() inside facets (use reorder_within + scale_y_reordered)
# 4. bind_tf_idf argument order (term, document, count)
# 5. Forgetting set.seed() before a network plot (layout changes every run)
# 6. Expecting trigrams to be rich on a tiny corpus (they need volume)
# 7. ggraph/igraph install failures derailing the whole session

# KEY CONCEPTS TO REINFORCE:
# - Frequency finds COMMON words; TF-IDF finds DISTINCTIVE words
# - TF-IDF = frequent in this document AND rare across the corpus
# - The "document" unit defines the question (department vs employee)
# - N-grams preserve word order and context that single tokens lose
# - For bigrams: separate(), filter both words, then count
# - Networks map word relationships - exploratory, not precise
# - Different techniques want different stopword handling

# ASSESSMENT IDEAS:
# - Give grouped text, have them find each group's distinctive words
# - Ask them to explain TF-IDF in one sentence without the formula
# - Have them extract and interpret the top bigrams for a group
# - Ask why "not good" is a problem for Session 8's single-word sentiment
# - Change the document unit and have them describe how the question shifts
