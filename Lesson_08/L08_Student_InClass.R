###########################################
# Session 8: Text Analysis with tidytext  #
#            (In-Class Version)           #
###########################################

# Live capture. Good energy - the "text becomes tidy data" framing landed
# fast because they already know dplyr cold. The stopword before/after got
# an actual reaction. Got through sentiment by department (the payoff);
# AFINN and the main exercise are homework. Notes inline.

# Section 1: Setup ---------------------------------------------------------

library(tidyverse)
library(tidytext)
library(here)

# Project root is C:\RStuff, so the path carries the "R-Course" prefix.
comments <- read_csv(here("R-Course", "data", "employee_comments.csv"))
glimpse(comments)

# Dropped the blank comments first - someone asked "why are some empty?"
# Real surveys, real non-responders. Session 3 habit: handle missing first.
comments <- comments |> filter(!is.na(comment), comment != "")
nrow(comments)

# Section 2: Tokenization --------------------------------------------------

# This is the whole trick. One word per row.
tokens <- comments |>
  unnest_tokens(word, comment)

tokens |> select(employee_id, department, word) |> head(15)

# "Wait, one employee is now twenty rows?" Yes - that's the point. Once
# every word is a row, it's tidy data and ALL your dplyr works on it.
# Pointed out unnest_tokens already lowercased and stripped punctuation.

nrow(tokens)

# Section 3: Word Frequencies ----------------------------------------------

tokens |>
  count(word, sort = TRUE) |>
  head(20)
# Top words: the, and, i, to, is, my... Asked the room "is this useful?"
# No. These are stopwords. Set up the next section.

# Section 4: Removing Stopwords - the satisfying part ----------------------

data(stop_words)

tokens_clean <- tokens |>
  anti_join(stop_words, by = "word")

tokens_clean |>
  count(word, sort = TRUE) |>
  head(20)
# team, feel, work, manager, growth... Audible difference from the room
# when the junk dropped out. "anti_join = keep words NOT in the list."
# Ran the before and after back to back on screen. Best demo of the day.

# Section 5: Visualizing Word Frequencies ----------------------------------

tokens_clean |>
  count(word, sort = TRUE) |>
  slice_max(n, n = 15) |>
  mutate(word = reorder(word, n)) |>
  ggplot(aes(x = n, y = word)) +
  geom_col(fill = "steelblue") +
  labs(title = "Most Common Words in Comments", x = "Count", y = NULL) +
  theme_minimal()
# Reused the reorder trick from Session 7. They recognized it - nice
# continuity moment.

# Section 6: Sentiment with Bing -------------------------------------------

# Used Bing - it's built in, no download, just works.
bing <- get_sentiments("bing")
bing |> count(sentiment)

sentiment_words <- tokens_clean |>
  inner_join(bing, by = "word")

sentiment_words |>
  count(word, sentiment, sort = TRUE) |>
  head(20)
# "anti_join removed stopwords, inner_join KEEPS only words with sentiment."
# The remove-vs-keep contrast between the two joins clicked here.

# Section 7: Aggregating Sentiment - the payoff ----------------------------

dept_sentiment <- sentiment_words |>
  count(department, sentiment) |>
  pivot_wider(names_from = sentiment, values_from = n, values_fill = 0) |>
  mutate(net_sentiment = positive - negative) |>
  arrange(net_sentiment)
dept_sentiment
# Sales most negative, Engineering most positive. Then I pulled up the
# Session 5 satisfaction-by-department numbers next to it - SAME ordering.
# This was the intellectual high point. "Two completely different measures,
# Likert numbers and free text, telling the same story. That agreement is
# what gives you confidence the finding is real." Worth the whole session.

# Section 8: Visualizing Sentiment -----------------------------------------

dept_sentiment |>
  mutate(department = reorder(department, net_sentiment)) |>
  ggplot(aes(x = net_sentiment, y = department, fill = net_sentiment > 0)) +
  geom_col() +
  scale_fill_manual(values = c("firebrick", "forestgreen")) +
  labs(title = "Net Sentiment by Department", x = "Net sentiment", y = NULL) +
  theme_minimal() +
  theme(legend.position = "none")

# ---- ran out of time here ----

# Section 9: AFINN ---------------------------------------------------------
# Did NOT do live - explained verbally that AFINN scores -5 to +5 but needs
# the textdata download with an interactive prompt, so it's a homework /
# console thing, not something to run blind in a script. Warned them the
# prompt will hang a script if they're not expecting it.

# Section 10: MAIN EXERCISE ------------------------------------------------
# HOMEWORK - all six steps in the Student file. Did #1-2 together:
comment_tokens <- comments |> unnest_tokens(word, comment)
comment_tokens |>
  anti_join(stop_words, by = "word") |>
  count(word, sort = TRUE) |>
  slice_max(n, n = 10)
# The big one (#5) is sentiment by department compared to Session 5 - they
# already saw the answer above, so the homework is reproducing it themselves.
# Next session: TF-IDF and n-grams (which words are DISTINCTIVE, not just frequent).
