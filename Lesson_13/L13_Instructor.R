###########################################
# Session 13: Writing Custom Functions    #
###########################################

# The turning point of the course. For twelve sessions students have USED
# functions other people wrote - mean(), filter(), lm(), kmeans(). Now they
# WRITE them. This is the start of the programming half: moving from
# operating tools to building them.
#
# The motivating principle is DRY: Don't Repeat Yourself. The moment you
# copy-paste a block of code and change one value, you should have written
# a function. Copy-paste is how bugs multiply - fix the original, forget the
# three copies. A function is one definition, one place to fix, used everywhere.
#
# Pacing note: function SYNTAX (arguments, body, return) is quick and they'll
# grasp it fast. The conceptual core that deserves real time is SCOPE (local
# vs global) and INPUT VALIDATION - those are what separate a script snippet
# from a reusable tool. The exercise (Cohen's d, a summary function) is where
# it all comes together.

# Section 1: Setup ---------------------------------------------------------

library(tidyverse)
library(here)

# Same employee survey we've used since Session 5. Familiar data means we
# focus on the new skill - writing functions - not relearning columns.
survey <- read_csv(here("data", "employee_survey.csv"))
glimpse(survey)

# Section 2: Why Write Functions? - The DRY Principle ----------------------
# Motivate the problem before the syntax. Show the pain of repetition.

# Suppose you want to standardize (z-score) three columns. The copy-paste way:
survey_zpain <- survey |>
  mutate(
    satisfaction_z = (satisfaction - mean(satisfaction)) / sd(satisfaction),
    engagement_z = (engagement - mean(engagement)) / sd(engagement),
    autonomy_z = (autonomy - mean(autonomy)) / sd(autonomy)
  )
# Three nearly-identical lines. Now imagine a typo in one: you write
# mean(satisfaction) where you meant mean(engagement). The code RUNS, gives
# a wrong answer, and nothing warns you. Copy-paste is a bug factory.
#
# (We already know across() solves THIS specific case from Session 6. But
# across() only helps when the operation fits its mold. Functions are the
# general tool: ANY repeated logic, not just column-wise operations.)

# The fix: define the operation ONCE, give it a name, reuse it.
z_score <- function(x) {
  (x - mean(x)) / sd(x)
}

# Now the same work, with no repetition and one place to fix bugs:
survey |>
  mutate(across(c(satisfaction, engagement, autonomy), z_score)) |>
  select(employee_id, satisfaction, engagement, autonomy)
# z_score is now a verb in YOUR vocabulary. This is the whole point: build
# tools once, use them everywhere, fix them in one place.

# Section 3: Anatomy of a Function -----------------------------------------
# Every function has three parts. Walk through each explicitly.

# function(arguments) { body, ending in a return value }
#
#   1. ARGUMENTS  - the inputs, named in the parentheses
#   2. BODY       - the code that runs, inside the braces
#   3. RETURN     - the value the function hands back

# A minimal example, fully labeled:
add_ten <- function(x) {   # x is the ARGUMENT (the input)
  result <- x + 10         # BODY (the computation)
  result                   # RETURN value (last expression)
}
add_ten(5)   # 15
add_ten(c(1, 2, 3))   # 11 12 13 - vectorized for free, because + is

# Assigning the function to a name (add_ten <- ...) is how you CREATE it.
# Calling it (add_ten(5)) is how you USE it. Same as any object in R.

# Multiple arguments, separated by commas:
rectangle_area <- function(width, height) {
  width * height
}
rectangle_area(4, 5)   # 20
rectangle_area(width = 4, height = 5)   # same, named arguments

# Naming arguments at the call site (width = 4) is clearer and order-proof.
# Encourage this for any function with more than one or two arguments.

# Section 4: Return Values - Implicit vs Explicit --------------------------
# A function returns the value of its LAST evaluated expression. You usually
# don't need return() at all - the last line IS the return.

# Implicit return (idiomatic R - the last expression is returned)
double_it <- function(x) {
  x * 2
}
double_it(21)   # 42

# Explicit return() does the same thing. It's optional here:
double_it_explicit <- function(x) {
  return(x * 2)
}
double_it_explicit(21)   # 42

# When IS return() useful? For EARLY exits - bailing out before the end.
# (We use this heavily for input validation in Section 8.)
classify_score <- function(x) {
  if (x >= 90) {
    return("A")   # exits here if true, never reaching the lines below
  }
  if (x >= 80) {
    return("B")
  }
  "C"   # the implicit return for everything else
}
classify_score(95)   # "A"
classify_score(85)   # "B"
classify_score(70)   # "C"

# STYLE NOTE: many R style guides say skip return() for the final value and
# reserve it for early exits. Others use it everywhere for clarity. We'll use
# implicit returns for the final value and return() for early exits, which is
# the common tidyverse convention. Consistency matters more than the choice.

# A common confusion: a function only returns ONE object. To return several
# things, bundle them in a list (Session 2 callback - lists hold anything):
min_max <- function(x) {
  list(minimum = min(x), maximum = max(x))
}
result <- min_max(c(3, 7, 1, 9, 4))
result$minimum   # 1
result$maximum   # 9
# Returning a one-row tibble is also a tidy-friendly pattern (Section 9).

# Section 5: Default Arguments ---------------------------------------------
# Arguments can have DEFAULT values, used when the caller doesn't supply one.
# This is how mean(x, na.rm = FALSE) works - na.rm defaults to FALSE.

# Default na.rm = TRUE so our function handles missing data out of the box
# (Session 3/5 callback: real data has NAs, and forgetting na.rm bites everyone)
safe_mean <- function(x, na.rm = TRUE) {
  mean(x, na.rm = na.rm)
}
safe_mean(c(1, 2, NA, 4))   # 2.333 - uses the default na.rm = TRUE
safe_mean(c(1, 2, NA, 4), na.rm = FALSE)   # NA - caller overrode the default

# Defaults make functions convenient for the common case while still flexible.
# Rule of thumb: put REQUIRED arguments first (no default), OPTIONAL ones
# (with defaults) after. Callers then supply only what they need.

# A practical example with several defaults:
summarize_scores <- function(x, digits = 2, na.rm = TRUE) {
  list(
    mean = round(mean(x, na.rm = na.rm), digits),
    sd = round(sd(x, na.rm = na.rm), digits)
  )
}
summarize_scores(survey$salary)   # uses both defaults
summarize_scores(survey$salary, digits = 0)   # override one, keep the other

# Section 6: The ... Argument (Dots) ---------------------------------------
# ... ("dots") lets a function accept an arbitrary number of arguments, or
# pass extra arguments through to ANOTHER function. It's how functions like
# c(), paste(), and many tidyverse verbs accept "as many as you give them".

# Use 1: accept any number of inputs
my_paste <- function(...) {
  paste(..., sep = " | ")
}
my_paste("a", "b", "c")   # "a | b | c"
my_paste("only one")      # "only one"

# Use 2 (the more common one): pass extra arguments THROUGH to an inner
# function without naming them all yourself. Here we forward ... to mean():
trimmed_report <- function(x, ...) {
  # ... captures anything extra (like trim = or na.rm =) and hands it to mean
  the_mean <- mean(x, ...)
  paste("Mean:", round(the_mean, 2))
}
trimmed_report(c(1, 2, 3, 100))                 # ordinary mean
trimmed_report(c(1, 2, 3, 100), trim = 0.25)    # trimmed mean, via ...
trimmed_report(c(1, 2, NA, 4), na.rm = TRUE)    # na.rm forwarded to mean()

# ... is powerful but can hide bugs: a misspelled argument name silently
# disappears into the dots instead of erroring. Use it deliberately, not
# as a catch-all to avoid thinking about your arguments.

# Section 7: Scope - Local vs Global ---------------------------------------
# THE conceptual core of the session. Where do a function's variables live?
#
# A function has its OWN local environment. Variables created INSIDE a
# function exist only WHILE it runs and vanish when it returns. They do NOT
# leak into your global workspace. This is a feature - it keeps functions
# self-contained and prevents them from clobbering your variables.

scope_demo <- function() {
  local_var <- "I only exist inside the function"
  local_var
}
scope_demo()   # returns the string
# local_var     # Error: object 'local_var' not found - it's gone

# Functions CAN SEE global variables (they look outward if a name isn't
# local), but this is a TRAP. Relying on a global makes a function depend on
# hidden state - it breaks the moment that global changes or is missing.

threshold <- 4   # a global
# BAD: this function secretly depends on the global 'threshold'
count_high_bad <- function(x) {
  sum(x >= threshold)   # where did threshold come from? Hidden dependency!
}
count_high_bad(survey$satisfaction)   # works... until threshold changes

# GOOD: pass everything the function needs as an ARGUMENT. Self-contained.
count_high_good <- function(x, threshold) {
  sum(x >= threshold)   # threshold is explicit, no hidden dependency
}
count_high_good(survey$satisfaction, threshold = 4)
# The good version is reproducible: its output depends only on its inputs.
# Hammer this: a function should take what it needs as arguments and return
# a result, touching nothing outside itself. Inputs in, value out.

# Assignment inside a function does NOT change the global of the same name:
x <- 10
clobber_test <- function() {
  x <- 999   # this x is LOCAL - a brand new variable, not the global x
  x
}
clobber_test()   # 999
x                # still 10 - the global was untouched
# (There IS a <<- operator that writes to the global. Mention it exists,
#  then tell them to avoid it - it reintroduces exactly the hidden-state
#  problem we're trying to escape. Almost always the wrong tool.)

# Section 8: Input Validation ----------------------------------------------
# A reusable function will eventually be called with input you didn't expect:
# a character where you wanted a number, an empty vector, the wrong length.
# VALIDATION catches bad input early with a CLEAR message, instead of letting
# it fail deep inside with a cryptic error (Session 4 debugging callback).

# Unvalidated: fails confusingly on bad input
z_score_naive <- function(x) {
  (x - mean(x)) / sd(x)
}
z_score_naive(c("a", "b", "c"))
# Error in x - mean(x) : non-numeric argument to binary operator
# Technically correct, but the error points at the internals, not the cause.

# Validated: checks the input and explains the problem in plain language
z_score_safe <- function(x) {
  if (!is.numeric(x)) {
    stop("`x` must be numeric, but you supplied a ", class(x)[1], " vector.")
  }
  if (length(x) < 2) {
    stop("`x` must have at least 2 values to compute a standard deviation.")
  }
  (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE)
}
z_score_safe(c(10, 20, 30, 40))      # works
# z_score_safe(c("a", "b"))          # clear error: must be numeric
# z_score_safe(5)                    # clear error: needs at least 2 values

# The validation toolkit:
#   stop()    - halt with an error (input is wrong, can't continue)
#   warning() - flag a problem but keep going (Session 4: warnings vs errors)
#   message() - informational note, not a problem
demo_signals <- function(x) {
  if (length(x) == 0) stop("x is empty - nothing to do.")
  if (any(is.na(x))) warning("x contains NAs; they will be removed.")
  message("Processing a vector of length ", length(x), ".")
  mean(x, na.rm = TRUE)
}
demo_signals(c(1, 2, NA, 4))   # prints a message, raises a warning, returns 2.333

# stopifnot() is a compact way to assert several conditions at once:
validated <- function(x) {
  stopifnot(
    is.numeric(x),
    length(x) >= 2
  )
  (x - mean(x)) / sd(x)
}
# stopifnot() errors if any condition is FALSE, naming the failed one. Terser
# than a stack of if/stop, though the custom messages above are friendlier.
# The {checkmate} and {assertthat} packages offer richer validation if you
# write functions for others - overkill for now, worth knowing they exist.

# Section 9: Documenting Your Functions ------------------------------------
# A function you can't understand in six months is barely better than no
# function. Document WHAT it does, WHAT goes in, and WHAT comes out.

# The lightweight convention: a comment block above the definition stating
# purpose, arguments, and return value.

# Compute Cohen's d, a standardized effect size for the difference between
# two groups' means (how many pooled SDs apart the groups are).
#   group1, group2 : numeric vectors, one per group
#   na.rm          : drop NAs before computing? (default TRUE)
# Returns: a single number (the effect size). Positive => group1 mean higher.
cohens_d <- function(group1, group2, na.rm = TRUE) {
  if (!is.numeric(group1) || !is.numeric(group2)) {
    stop("Both `group1` and `group2` must be numeric vectors.")
  }
  if (na.rm) {
    group1 <- group1[!is.na(group1)]
    group2 <- group2[!is.na(group2)]
  }
  n1 <- length(group1)
  n2 <- length(group2)
  # pooled standard deviation (the standardizer)
  pooled_sd <- sqrt(
    ((n1 - 1) * var(group1) + (n2 - 1) * var(group2)) / (n1 + n2 - 2)
  )
  (mean(group1) - mean(group2)) / pooled_sd
}

# The professional standard is roxygen2 (#' comments that generate help
# pages and power packages). We won't write packages here, but show the
# shape so they recognize it - it's the same information, formalized:
#
#' Compute Cohen's d effect size
#' @param group1 Numeric vector for the first group
#' @param group2 Numeric vector for the second group
#' @param na.rm Logical; remove NAs before computing? Default TRUE
#' @return A single numeric effect size
#' @examples
#' cohens_d(c(85, 90, 88), c(78, 82, 80))
#
# When you eventually build a package (Session 22 touches version control),
# roxygen2 turns these into real ?help pages. For now, plain comments are fine.

# Section 10: MAIN EXERCISE ------------------------------------------------
# Build real, validated, documented functions. Walk through 1-2 together,
# then let them work. These tie together every piece of the session.

# 1. Write and test a Cohen's d function (effect size)
#    (defined above; here we USE it on real data)
remote_sat <- survey$satisfaction[survey$remote]
onsite_sat <- survey$satisfaction[!survey$remote]
cohens_d(remote_sat, onsite_sat)
# This comes out near zero - remote and on-site satisfaction barely differ.
# An honest, useful negative result: not every comparison has a big effect.
# Contrast with a comparison that DOES (Engineering vs Sales, ~3.0 - huge):
eng_sat <- survey$satisfaction[survey$department == "Engineering"]
sales_sat <- survey$satisfaction[survey$department == "Sales"]
cohens_d(eng_sat, sales_sat)
# A large positive d: Engineering's satisfaction is ~3 pooled SDs above
# Sales. Matches the by-department story from Sessions 5, 8, 12.

# 2. Write a summary function for the numeric columns of a data frame.
#    It should take a data frame, compute mean/sd/n/n_missing for each
#    numeric column, and return a tidy tibble.
summarize_numeric <- function(df) {
  if (!is.data.frame(df)) {
    stop("`df` must be a data frame or tibble, not a ", class(df)[1], ".")
  }
  df |>
    summarize(across(
      where(is.numeric),
      list(
        mean = \(x) mean(x, na.rm = TRUE),
        sd = \(x) sd(x, na.rm = TRUE),
        n = \(x) sum(!is.na(x)),
        n_missing = \(x) sum(is.na(x))
      ),
      .names = "{.col}__{.fn}"
    )) |>
    # reshape to one row per column (Session 11 callback: pivot + separate)
    pivot_longer(everything(), names_to = "stat", values_to = "value") |>
    separate(stat, into = c("variable", "statistic"), sep = "__") |>
    pivot_wider(names_from = statistic, values_from = value)
}
summarize_numeric(survey)
# Returns one row per numeric column with mean, sd, n, n_missing. This is the
# Session 6 (across) + Session 11 (pivot) toolkit packaged into a reusable
# tool. salary's n_missing will be > 0 - the function surfaces it automatically.

# 3. Add input validation to both functions (done above - is.numeric checks,
#    is.data.frame check, length checks). Demonstrate the clear errors:
# cohens_d("a", "b")            # errors: must be numeric
# summarize_numeric(c(1, 2, 3)) # errors: must be a data frame

# BONUS: Going Further -----------------------------------------------------

# A function that returns a function (a "function factory"). Advanced, but it
# shows scope in action: the inner function REMEMBERS the factory's argument.
make_multiplier <- function(factor) {
  function(x) x * factor   # the inner function captures `factor` from scope
}
double <- make_multiplier(2)
triple <- make_multiplier(3)
double(10)   # 20
triple(10)   # 30
# double and triple each "remember" their own factor. This captured
# environment is called a CLOSURE. You don't need it often, but it's the same
# scope mechanism from Section 7, used on purpose.

# A function that takes a tidyverse column name. This is a PREVIEW of Session
# 14 (tidy evaluation). Passing a bare column name like `satisfaction` needs
# the {{ }} ("embrace") operator - regular functions can't do it directly:
group_mean <- function(df, group_col, value_col) {
  df |>
    group_by({{ group_col }}) |>
    summarize(mean = mean({{ value_col }}, na.rm = TRUE), .groups = "drop")
}
group_mean(survey, department, satisfaction)
# Note the bare column names - no quotes. {{ }} makes this work. WHY it's
# needed and how it works is the entire subject of Session 14. Here it's a
# teaser: "this is possible, and next session explains the magic."

# Composing your own functions into a pipeline:
clean_and_score <- function(x) {
  x |> (\(v) v[!is.na(v)])() |> z_score()
}
clean_and_score(c(10, 20, NA, 40, 50))
# Small functions combine into bigger ones. That's the payoff of DRY: a
# vocabulary of reliable verbs you assemble like building blocks.

# =============================================================================
# END OF SESSION 13
# =============================================================================

# TEACHING NOTES FOR NEXT TIME:
# - DRY is the "why". Open with the copy-paste z-score pain (Section 2) so
#   they FEEL the problem before seeing the function as the fix. The bug-
#   multiplies-on-copy-paste point lands hard if you show a planted typo.
# - Scope (Section 7) is the conceptual make-or-break. The "inputs in, value
#   out, touch nothing outside" rule is the whole lesson in one sentence.
#   Demo the clobber_test - that the local x doesn't change the global x
#   genuinely surprises people and makes scope concrete.
# - Validation (Section 8) is what turns a snippet into a TOOL. Tie it back
#   to Session 4: a good error message is a gift to your future self. Show
#   the naive-vs-safe z_score side by side - the clearer error sells it.
# - return() confusion: be explicit that the LAST line is the return, and
#   return() is mainly for early exits. Students coming from Python expect
#   return() everywhere.
# - The {{ }} bonus is a deliberate cliffhanger for Session 14. Don't explain
#   it deeply - just show it works and promise the why next time.
# - Next session: tidy evaluation - writing functions that speak tidyverse
#   (the {{ }} magic explained).

# COMMON STUDENT MISTAKES TO WATCH FOR:
# 1. Expecting return() to be required (the last expression is the return)
# 2. Trying to return multiple values without a list (a function returns one
#    object - bundle several in a list or tibble)
# 3. Relying on global variables instead of passing them as arguments
# 4. Forgetting that a function call needs () even with no arguments
# 5. Putting required arguments AFTER ones with defaults (defaults go last)
# 6. Assuming a local variable persists after the function returns (it doesn't)
# 7. No validation, then a cryptic error deep in the body on bad input
# 8. Passing a bare column name to a normal function (needs {{ }}, Session 14)

# KEY CONCEPTS TO REINFORCE:
# - DRY: if you copy-paste-and-tweak, write a function instead
# - Three parts: arguments (in), body (work), return (out - the last line)
# - Default arguments make the common case easy; required args go first
# - SCOPE: local variables stay local; pass inputs, return outputs, no globals
# - Validate inputs early with stop()/stopifnot() and clear messages
# - Document purpose, arguments, and return value (comments now, roxygen later)
# - A function returns ONE object; use a list/tibble for several results

# ASSESSMENT IDEAS:
# - Give a repetitive copy-paste block, have them refactor it into a function
# - Have them write a validated function and a test call that triggers the error
# - Ask why relying on a global variable makes a function fragile
# - Give a function with a scope bug (reads a global) and have them fix it
# - Write Cohen's d from the formula and verify against a known example
# - Explain the difference between an implicit and explicit return
