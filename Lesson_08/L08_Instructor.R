###########################################
# Session 8: Text Analysis with tidytext  #
###########################################

# A change of pace. Up to now everything has been numbers. This session is
# about UNSTRUCTURED TEXT - the open-ended comments people write on surveys,
# the stuff that usually gets ignored because it's hard to quantify.
#
# The big idea: tidytext lets us treat text as TIDY DATA. One row per word
# (a "token"), and suddenly all the dplyr skills from Sessions 5-6 apply
# directly. count words, group by department, summarize sentiment. The text
# becomes just another data frame.
#
# Pacing note: tokenizing and word frequencies are the core and are very
# satisfying. Sentiment is the second half. The TF-IDF preview is optional.
#
# IMPORTANT setup reality (read before class): the Bing sentiment lexicon
# ships INSIDE tidytext and works offline with no prompts. AFINN and NRC
# live in the separate textdata package and require an interactive
# license-acceptance download the FIRST time you use them. That interactive
# prompt will hang a script and confuse students. So we teach with Bing as
# the default and show AFINN as an optional richer alternative. Have AFINN
# pre-downloaded on your machine if you want to demo it live.

# Section 1: Setup ---------------------------------------------------------

library(tidyverse)
library(tidytext) # the new package this session
library(here)

# install.packages("tidytext") if needed.
# For the optional AFINN section you also need:
# install.packages("textdata")

# Read the open-ended comments. Same employees and departments as the
# Session 5 survey, so the by-department results connect to what we saw then.
comments <- read_csv(here("data", "employee_comments.csv"))
glimpse(comments)

# Note the blank comments - real surveys always have non-responders.
# Drop them up front (Session 3 missing-data habit).
comments <- comments |> filter(!is.na(comment), comment != "")
nrow(comments) # fewer rows after dropping blanks

# Section 2: What Is Tokenization? -----------------------------------------
# Text analysis starts by breaking text into TOKENS - usually individual
# words. "I love my team" becomes four tokens: "i", "love", "my", "team".
#
# The tidytext approach: one token per ROW. This is the whole trick. Once
# every word is its own row, the data is tidy and dplyr just works.

# unnest_tokens() does the tokenizing. It takes a column of text and
# explodes it into one-word-per-row, keeping the other columns alongside.
tokens <- comments |>
  unnest_tokens(word, comment)
# Arguments: unnest_tokens(output_column, input_column)
# "word" is the NEW column name we want; "comment" is the text we're splitting.

glimpse(tokens)
tokens |> select(employee_id, department, word) |> head(15)
# Notice: one employee now spans MANY rows, one per word. department came
# along for the ride. unnest_tokens also lowercased everything and stripped
# punctuation automatically - sensible defaults for word analysis.

# How many tokens total?
nrow(tokens)

# Section 3: Word Frequencies ----------------------------------------------
# Now it's just dplyr. count() the words (Session 5 callback).

# Most common words overall
tokens |>
  count(word, sort = TRUE) |>
  head(20)
# Problem: the top words are "the", "and", "i", "to", "is"... These are
# STOPWORDS - grammatical glue with no content. They drown out the signal.

# Section 4: Removing Stopwords --------------------------------------------
# tidytext ships a stopwords table called stop_words. We remove them with
# an anti_join (Session 11 will cover joins formally; here it's intuitive:
# "keep the words that are NOT in the stopword list").

data(stop_words) # load the built-in stopword lexicon
glimpse(stop_words)
# It has a 'word' column and a 'lexicon' column (the source of each stopword).

# anti_join drops any row whose word appears in stop_words
tokens_clean <- tokens |>
  anti_join(stop_words, by = "word")

# Now the frequencies are meaningful
tokens_clean |>
  count(word, sort = TRUE) |>
  head(20)
# "team", "feel", "work", "manager", "growth"... real content words now.
# This before/after is the single most satisfying moment of the session.
# Show the top-20 WITH stopwords, then WITHOUT, side by side.

# Section 5: Visualizing Word Frequencies ----------------------------------
# Bar chart of the most common content words (Session 7 callback).

tokens_clean |>
  count(word, sort = TRUE) |>
  slice_max(n, n = 15) |> # top 15 by count
  mutate(word = reorder(word, n)) |> # sort bars by frequency
  ggplot(aes(x = n, y = word)) +
  geom_col(fill = "steelblue") +
  labs(title = "Most Common Words in Employee Comments",
       x = "Count", y = NULL) +
  theme_minimal()
# reorder(word, n) makes the bars sort by count instead of alphabetically
# (the ranked-bar trick from Session 7). Horizontal bars (word on y) keep
# the labels readable.

# Section 6: Sentiment Analysis - The Bing Lexicon -------------------------
# Sentiment analysis assigns emotional valence to words. A LEXICON is just
# a lookup table mapping words to sentiment. The simplest is Bing: each word
# is labeled "positive" or "negative".

# get_sentiments() retrieves a lexicon. Bing is built into tidytext - no
# download, no prompt, works offline. This is why we start here.
bing <- get_sentiments("bing")
glimpse(bing)
bing |> count(sentiment) # how many positive vs negative words it knows

# Join our words to the lexicon. inner_join keeps ONLY words that appear in
# the lexicon (words with no sentiment are dropped - that's what we want).
sentiment_words <- tokens_clean |>
  inner_join(bing, by = "word")

sentiment_words |>
  select(employee_id, department, word, sentiment) |>
  head(15)
# Each remaining word now carries a positive/negative label.

# Most common positive and negative words
sentiment_words |>
  count(word, sentiment, sort = TRUE) |>
  head(20)

# Section 7: Aggregating Sentiment -----------------------------------------
# Now collapse word-level sentiment up to something meaningful.

# Overall: how many positive vs negative words?
sentiment_words |> count(sentiment)

# Per employee: a net sentiment score (positives minus negatives)
employee_sentiment <- sentiment_words |>
  count(employee_id, department, sentiment) |>
  pivot_wider(names_from = sentiment, # one column for pos, one for neg
              values_from = n,
              values_fill = 0) |> # employees with no neg words get 0, not NA
  mutate(net_sentiment = positive - negative)
# pivot_wider reshapes long -> wide (full treatment in Session 11; here it's
# just "turn the sentiment rows into positive and negative columns").
employee_sentiment |> head()

# Per department: average net sentiment. THIS is the payoff - it should line
# up with the satisfaction-by-department pattern from Session 5.
dept_sentiment <- sentiment_words |>
  count(department, sentiment) |>
  pivot_wider(names_from = sentiment, values_from = n, values_fill = 0) |>
  mutate(net_sentiment = positive - negative) |>
  arrange(net_sentiment)
dept_sentiment
# Sales should land most negative, Engineering most positive - matching the
# satisfaction scores we computed back in Session 5. Make that connection
# explicit: two totally different measures (Likert numbers vs free text)
# telling the same story is a real analytics insight.

# Section 8: Visualizing Sentiment -----------------------------------------

# Net sentiment by department
dept_sentiment |>
  mutate(department = reorder(department, net_sentiment)) |>
  ggplot(aes(x = net_sentiment, y = department, fill = net_sentiment > 0)) +
  geom_col() +
  scale_fill_manual(values = c("firebrick", "forestgreen")) +
  labs(title = "Net Sentiment by Department",
       subtitle = "Positive minus negative words in open-ended comments",
       x = "Net sentiment (words)", y = NULL) +
  theme_minimal() +
  theme(legend.position = "none")
# fill = net_sentiment > 0 colors bars by sign (green positive, red negative).

# Top contributing words to each sentiment
sentiment_words |>
  count(word, sentiment, sort = TRUE) |>
  group_by(sentiment) |>
  slice_max(n, n = 8) |>
  ungroup() |>
  mutate(word = reorder(word, n)) |>
  ggplot(aes(x = n, y = word, fill = sentiment)) +
  geom_col() +
  facet_wrap(~ sentiment, scales = "free_y") + # each facet its own words
  scale_fill_manual(values = c(negative = "firebrick",
                               positive = "forestgreen")) +
  labs(title = "Top Words Driving Sentiment", x = "Count", y = NULL) +
  theme_minimal() +
  theme(legend.position = "none")
# scales = "free_y" lets each facet show its OWN words instead of forcing a
# shared axis (different words drive positive vs negative).

# Section 9: The AFINN Lexicon (Optional, Requires Download) ----------------
# Bing labels words positive/negative. AFINN goes further: it scores each
# word from -5 (very negative) to +5 (very positive). That lets you weight
# intensity, not just direction.
#
# CATCH: AFINN lives in the textdata package and the FIRST call triggers an
# interactive license prompt and download. That prompt will HANG a
# non-interactive script. Run this in the console once, accept, and then it
# caches. Do NOT put a fresh AFINN download in a script students run blind.

# Uncomment to use (after installing textdata and accepting the prompt once):
# afinn <- get_sentiments("afinn")
# glimpse(afinn) # has 'word' and 'value' (the -5 to +5 score)
#
# afinn_scores <- tokens_clean |>
#   inner_join(afinn, by = "word") |>
#   group_by(department) |>
#   summarize(mean_score = mean(value), total_score = sum(value),
#             .groups = "drop") |>
#   arrange(mean_score)
# afinn_scores
#
# The intensity weighting can change the ranking versus Bing - "love" (+3)
# counts more than "like" (+2). Worth comparing the two lexicons' results
# and discussing why they might disagree. No lexicon is ground truth; they
# encode different judgments.

# Section 10: MAIN EXERCISE ------------------------------------------------
# Tokenize the comments, find frequent words, compute sentiment by group.
# Walk through 1-2 together, then let them work.

# 1. Tokenize the comments into one word per row
comment_tokens <- comments |>
  unnest_tokens(word, comment)
comment_tokens |> head()

# 2. Remove stopwords and find the 10 most frequent content words
comment_tokens |>
  anti_join(stop_words, by = "word") |>
  count(word, sort = TRUE) |>
  slice_max(n, n = 10)

# 3. Make a bar plot of the most common words
comment_tokens |>
  anti_join(stop_words, by = "word") |>
  count(word, sort = TRUE) |>
  slice_max(n, n = 12) |>
  mutate(word = reorder(word, n)) |>
  ggplot(aes(x = n, y = word)) +
  geom_col(fill = "steelblue") +
  labs(title = "Most Common Words", x = "Count", y = NULL) +
  theme_minimal()

# 4. Join to the Bing lexicon and count positive vs negative words
comment_tokens |>
  anti_join(stop_words, by = "word") |>
  inner_join(get_sentiments("bing"), by = "word") |>
  count(sentiment)

# 5. Compute net sentiment by department and compare to the Session 5
#    satisfaction pattern
comment_tokens |>
  anti_join(stop_words, by = "word") |>
  inner_join(get_sentiments("bing"), by = "word") |>
  count(department, sentiment) |>
  pivot_wider(names_from = sentiment, values_from = n, values_fill = 0) |>
  mutate(net_sentiment = positive - negative) |>
  arrange(net_sentiment)

# 6. Plot net sentiment by department
comment_tokens |>
  anti_join(stop_words, by = "word") |>
  inner_join(get_sentiments("bing"), by = "word") |>
  count(department, sentiment) |>
  pivot_wider(names_from = sentiment, values_from = n, values_fill = 0) |>
  mutate(net_sentiment = positive - negative,
         department = reorder(department, net_sentiment)) |>
  ggplot(aes(x = net_sentiment, y = department, fill = net_sentiment > 0)) +
  geom_col() +
  scale_fill_manual(values = c("firebrick", "forestgreen")) +
  labs(title = "Net Sentiment by Department", x = "Net sentiment", y = NULL) +
  theme_minimal() +
  theme(legend.position = "none")

# BONUS: Going Further -----------------------------------------------------

# Word clouds (a different way to show frequency - size = count)
# install.packages("wordcloud")
# library(wordcloud)
# word_counts <- tokens_clean |> count(word, sort = TRUE)
# wordcloud(word_counts$word, word_counts$n, max.words = 50)
# Note: word clouds look impressive but are hard to read precisely. A bar
# chart almost always communicates frequency better. Show one, then say so.

# Custom stopwords: add domain-specific words to ignore
# Sometimes generic stopwords aren't enough. Maybe "work" and "job" appear
# constantly and add no signal for your question. Add your own:
custom_stop <- tibble(word = c("work", "job", "feel", "company"))
tokens |>
  anti_join(stop_words, by = "word") |>
  anti_join(custom_stop, by = "word") |>
  count(word, sort = TRUE) |>
  head(15)
# Stacking anti_joins is the clean way to layer custom stopwords on top of
# the standard list.

# Comparing word frequency across two departments
tokens_clean |>
  filter(department %in% c("Sales", "Engineering")) |>
  count(department, word) |>
  group_by(department) |>
  slice_max(n, n = 8) |>
  ungroup()
# This previews Session 9's TF-IDF question: which words are DISTINCTIVE to
# each group, not just frequent everywhere?

# =============================================================================
# END OF SESSION 8
# =============================================================================

# TEACHING NOTES FOR NEXT TIME:
# - The core "aha" is that one-word-per-row makes text into tidy data, so
#   all the dplyr they already know just works. Lean on that continuity.
# - The stopword before/after (Section 4) is the most satisfying demo. Show
#   the junk-filled top-20 first, then the cleaned one. Let it land.
# - The department-sentiment result connecting back to Session 5
#   satisfaction is the intellectual payoff. Make that link explicit: two
#   independent measures agreeing is what real analysis feels like.
# - Bing works offline; AFINN needs the interactive download. Do NOT let
#   students hit the AFINN prompt mid-script in class - it hangs and panics
#   everyone. Demo AFINN yourself if at all, pre-downloaded.
# - Next session: advanced text - TF-IDF and n-grams (which words are
#   DISTINCTIVE, and how words pair up).

# COMMON STUDENT MISTAKES TO WATCH FOR:
# 1. Forgetting to remove stopwords (top words are all "the", "and", "i")
# 2. unnest_tokens argument order (output name first, then input column)
# 3. Using inner_join vs anti_join backwards (anti to REMOVE stopwords,
#    inner to KEEP sentiment matches)
# 4. Hitting the AFINN download prompt in a script and not knowing why it hung
# 5. Forgetting values_fill = 0 in pivot_wider (gives NA, breaks the math)
# 6. Treating word clouds as analysis (they're decoration; bars are clearer)
# 7. Not dropping blank/NA comments before tokenizing

# KEY CONCEPTS TO REINFORCE:
# - Tokenization = one word per row = text becomes tidy data
# - anti_join REMOVES (stopwords); inner_join KEEPS (sentiment matches)
# - A lexicon is just a lookup table of words to sentiment
# - Bing = positive/negative; AFINN = scored -5 to +5 (needs download)
# - Aggregate word-level sentiment up to employee or department level
# - No lexicon is ground truth - they encode different human judgments

# ASSESSMENT IDEAS:
# - Give raw text, have them tokenize, clean, and find top words
# - Have them compute and plot sentiment by some grouping variable
# - Ask them to explain why stopword removal matters with a before/after
# - Compare Bing vs AFINN results and explain a disagreement
# - Add three sensible custom stopwords for a given research question
