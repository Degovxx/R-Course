###########################################
# Session 13: Writing Custom Functions    #
#            (In-Class Version)           #
###########################################

# Live capture. The "you've been USING functions for twelve weeks, now you
# BUILD them" framing landed - felt like a graduation moment for the room.
# DRY clicked fast once I planted a copy-paste typo live. Scope was the part
# that needed the most air (as expected). Got through documenting; the
# exercise is homework. Notes inline.

# Section 1: Setup ---------------------------------------------------------

library(tidyverse)
library(here)

# Project root is C:\RStuff, so the path carries the "R-Course" prefix.
survey <- read_csv(here("R-Course", "data", "employee_survey.csv"))
glimpse(survey)

# Section 2: Why Functions? - DRY ------------------------------------------

# Did the copy-paste version first and PLANTED a typo live - wrote
# mean(satisfaction) in the engagement line on purpose:
survey |>
  mutate(
    satisfaction_z = (satisfaction - mean(satisfaction)) / sd(satisfaction),
    engagement_z = (engagement - mean(satisfaction)) / sd(engagement),  # BUG
    autonomy_z = (autonomy - mean(autonomy)) / sd(autonomy)
  ) |>
  select(employee_id, satisfaction_z, engagement_z) |>
  head()
# Asked "is this right?" Nobody spotted it for a minute. THEN someone caught
# the mean(satisfaction) in the engagement line. "It RAN. It gave numbers. It
# was wrong. Nothing warned you. THAT is why copy-paste is dangerous." Best
# possible motivation - they felt the danger instead of being told about it.

z_score <- function(x) {
  (x - mean(x)) / sd(x)
}

survey |>
  mutate(across(c(satisfaction, engagement, autonomy), z_score)) |>
  select(employee_id, satisfaction, engagement, autonomy) |>
  head()
# "One definition. One place for the bug to live. Used everywhere." Tied it
# back to across() from Session 6 - they recognized it, good continuity.

# Section 3: Anatomy -------------------------------------------------------

add_ten <- function(x) {
  result <- x + 10
  result
}
add_ten(5)
add_ten(c(1, 2, 3))
# Wrote ARGUMENTS / BODY / RETURN on the board next to the three parts.
# "Vectorized for free" got a question - explained it's because + is already
# vectorized, the function inherits that. Didn't go deep.

rectangle_area <- function(width, height) {
  width * height
}
rectangle_area(4, 5)
rectangle_area(height = 5, width = 4)   # named args, order doesn't matter
# The named-args-are-order-proof point was new to a couple of people.

# Section 4: Return Values -------------------------------------------------

# The implicit return is the thing the Python people kept tripping on.
double_it <- function(x) x * 2   # one-liner, no braces needed
double_it(21)

# "Where's the return statement?" - exactly the question I wanted. "The last
# line IS the return. R doesn't need the word." Two people visibly relieved,
# two visibly suspicious. Showed return() works too so nobody felt forced:
double_it_explicit <- function(x) {
  return(x * 2)
}

# Early return as the REAL use for return():
classify_score <- function(x) {
  if (x >= 90) return("A")
  if (x >= 80) return("B")
  "C"
}
classify_score(95); classify_score(85); classify_score(70)
# "Use return() to bail out early, skip it for the final value." That framing
# settled the suspicious faces.

# Returning two things needs a list (Session 2 callback):
min_max <- function(x) {
  list(minimum = min(x), maximum = max(x))
}
mm <- min_max(c(3, 7, 1, 9, 4))
mm$minimum; mm$maximum
# "A function hands back ONE object. Want several? Put them in a list." The
# list callback to Session 2 landed - they remembered lists hold anything.

# Section 5: Default Arguments ---------------------------------------------

safe_mean <- function(x, na.rm = TRUE) {
  mean(x, na.rm = na.rm)
}
safe_mean(c(1, 2, NA, 4))                # default drops NA
safe_mean(c(1, 2, NA, 4), na.rm = FALSE) # overridden -> NA
# "This is literally how mean()'s own na.rm works - you're building the same
# convenience into your own tools." Connected it to the na.rm pain from
# Sessions 3 and 5. Required-args-first, defaults-last rule went on the board.

# Section 6: ... (Dots) ----------------------------------------------------

# Kept this light - showed the pass-through use, which is the one that matters.
trimmed_report <- function(x, ...) {
  paste("Mean:", round(mean(x, ...), 2))
}
trimmed_report(c(1, 2, 3, 100))
trimmed_report(c(1, 2, 3, 100), trim = 0.25)   # forwarded to mean() via ...
# "... is a conveyor belt: anything extra rides through to mean()." Flagged
# the gotcha - a misspelled arg vanishes into ... silently - but didn't dwell.
# This is the one section I'd compress further next time; it's the least
# essential and ate a few minutes.

# Section 7: Scope - the part that needed the most time --------------------

scope_demo <- function() {
  local_var <- "only exists inside"
  local_var
}
scope_demo()
# local_var   # ran this live -> Error: object not found. "It's GONE. Born
# when the function ran, died when it returned." The room went quiet in a
# good way - this is the mental model shift.

# The clobber demo was the highlight:
x <- 10
clobber_test <- function() {
  x <- 999     # LOCAL x, brand new
  x
}
clobber_test()   # 999
x                # still 10
# Genuine surprise. "Wait, the 999 didn't stick?" No - the inside x is a
# different x. "Functions don't reach out and change your stuff. Inputs in,
# value out, touch nothing else." Wrote that sentence on the board and
# circled it. If they remember one thing from today, that's it.

# The hidden-global trap:
threshold <- 4
count_high_bad <- function(vec) sum(vec >= threshold)  # reads a global - BAD
count_high_good <- function(vec, threshold) sum(vec >= threshold)  # GOOD
count_high_good(survey$satisfaction, threshold = 4)
# "The bad one works until someone changes threshold somewhere else, then it
# silently does something different. Pass what you need." Mentioned <<- exists
# and said "don't" in the same breath. Nobody pushed on it, good.

# Section 8: Input Validation ----------------------------------------------

# Showed the naive failure first (Session 4 debugging callback):
z_score_naive <- function(x) (x - mean(x)) / sd(x)
# z_score_naive(c("a","b","c"))
# Error: non-numeric argument to binary operator
# "Correct, but it blames the internals. Where's the actual problem?"

z_score_safe <- function(x) {
  if (!is.numeric(x)) {
    stop("`x` must be numeric, but you gave a ", class(x)[1], " vector.")
  }
  if (length(x) < 2) {
    stop("`x` must have at least 2 values for an sd.")
  }
  (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE)
}
z_score_safe(c(10, 20, 30, 40))
# z_score_safe(c("a","b"))   # clear message naming the real problem
# "A good error message is a gift to future-you." That line got nods - they
# remember being lost in cryptic errors back in Session 4.

# stopifnot for the terse version:
validated <- function(x) {
  stopifnot(is.numeric(x), length(x) >= 2)
  (x - mean(x)) / sd(x)
}
# Showed it, said the custom-message version reads friendlier for tools you
# hand to other people. Mentioned checkmate/assertthat exist, moved on.

# ---- ran out of time about here ----

# Section 9: Documenting ---------------------------------------------------
# Showed the comment-block convention quickly on cohens_d (purpose / args /
# return) and flashed the roxygen #' shape so they'd recognize it, noting
# it becomes real help pages when you build a package (Session 22 hook).
# Didn't have them write one - it's in the homework.

# Section 10: MAIN EXERCISE ------------------------------------------------
# HOMEWORK - all three in the Student file. Did #1 (cohens_d) together as the
# anchor since it's the one with real math:
cohens_d <- function(group1, group2, na.rm = TRUE) {
  if (!is.numeric(group1) || !is.numeric(group2)) {
    stop("Both groups must be numeric.")
  }
  if (na.rm) {
    group1 <- group1[!is.na(group1)]
    group2 <- group2[!is.na(group2)]
  }
  n1 <- length(group1); n2 <- length(group2)
  pooled_sd <- sqrt(((n1 - 1) * var(group1) + (n2 - 1) * var(group2)) /
                      (n1 + n2 - 2))
  (mean(group1) - mean(group2)) / pooled_sd
}

# Tested on two comparisons live:
cohens_d(survey$satisfaction[survey$remote],
         survey$satisfaction[!survey$remote])
# Near zero - "remote vs on-site satisfaction is basically a tie." Good
# teaching moment: not every comparison has an effect, and a small d is a
# real finding, not a failure.

cohens_d(survey$satisfaction[survey$department == "Engineering"],
         survey$satisfaction[survey$department == "Sales"])
# Big positive d (~3). "Engineering sits about three pooled SDs above Sales."
# Same story as the satisfaction split we've seen since Session 5 - the
# effect size just puts a number on how big it is. They liked that it tied
# back to a result they already trusted.

# #2 (summarize_numeric, the across + pivot one) is the meatier homework -
# it's Session 6 and Session 11 packaged into one reusable tool. #3 is adding
# validation to both. Told them the validation is the part that turns these
# from snippets into TOOLS.

# Next session: tidy evaluation - how to write functions that take bare
# tidyverse column names. Teased it: this works, and next week is the why.
group_mean <- function(df, group_col, value_col) {
  df |>
    group_by({{ group_col }}) |>
    summarize(mean = mean({{ value_col }}, na.rm = TRUE), .groups = "drop")
}
group_mean(survey, department, satisfaction)
# Wrote {{ }} on the board, called it "the embrace", said "that's all I'm
# telling you - next week is the whole story." Good cliffhanger, a couple
# people groaned (the good kind).

# Note to self: compress the ... section next round and give those minutes to
# validation - that's the part with lasting payoff. Scope timing was right.
