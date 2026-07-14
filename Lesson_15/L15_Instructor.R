###########################################
# Session 15: Iteration with purrr        #
###########################################

# The other half of "programming with the tidyverse". Last session we wrote
# flexible FUNCTIONS (Session 13) that speak tidyverse (Session 14). This
# session is about RUNNING a function across many things at once - many list
# elements, many columns, many data subsets, many models. That's ITERATION.
#
# THE BIG IDEA: instead of copy-pasting a block five times (DRY again,
# Session 13) or writing a for-loop with an accumulator, you say "apply this
# function to each element of this list" in one line. map() is that line.
#
# Why purrr's map() over base R's for-loops and apply()? Three reasons:
#   1. It returns a PREDICTABLE type (map_dbl always gives a double vector;
#      a for-loop's result depends on how you set up the accumulator).
#   2. It composes in a pipe, so iteration becomes one more step in a flow.
#   3. The typed variants document intent and catch type bugs early.
#
# Pacing note: map() and the typed variants (map_dbl/chr/lgl) are the core -
# get those solid. map() returning a list, and how the typed variants
# simplify, is the key mental model. map2() and the model-fitting payoff are
# the second half. The map()-vs-across() comparison ties it to Session 6.

# Section 1: Setup ---------------------------------------------------------

library(tidyverse)   # purrr loads with the tidyverse
library(here)
library(broom)       # tidy model outputs (Session 10) - we iterate over models

survey <- read_csv(here("data", "employee_survey.csv"))
glimpse(survey)

# Section 2: The Problem Iteration Solves ----------------------------------
# Motivate before the syntax. Show the repetition map() eliminates.

# Suppose you want the mean of three columns. The copy-paste way (Session 13's
# nemesis):
mean(survey$satisfaction)
mean(survey$engagement)
mean(survey$autonomy)
# Three lines, and if you add a column you add a line. We want to say "take
# the mean of EACH of these" once.

# The base R for-loop way - works, but verbose and easy to get wrong:
cols <- c("satisfaction", "engagement", "autonomy")
results <- numeric(length(cols))      # pre-allocate the output (easy to forget)
for (i in seq_along(cols)) {
  results[i] <- mean(survey[[cols[i]]])
}
names(results) <- cols
results
# You manage the index, the accumulator, the pre-allocation, the names. Four
# chances to introduce a bug. map() handles all the bookkeeping for you.

# Section 3: map() - Apply a Function to Each Element ----------------------
# map(x, f) applies function f to EACH element of x and returns a LIST,
# one result per element. The list is the safe default: it can hold any
# result, of any type or size.

# A list of three numeric vectors to iterate over:
score_cols <- list(
  satisfaction = survey$satisfaction,
  engagement = survey$engagement,
  autonomy = survey$autonomy
)

# map() each through mean(). Returns a LIST of three numbers.
map(score_cols, mean)
# Read it: "for each element of score_cols, call mean() on it." The result is
# a named list (names carried from the input) with one mean per element.

# map() works over any vector, not just lists. Over a character vector of
# column names, pulling each column from survey:
map(cols, \(col) mean(survey[[col]]))
# \(col) is the anonymous function (Session 6 / 13): "for each col name,
# compute the mean of that column." Here the result is an UNnamed list
# because a plain character vector carries no names.

# The output of map() is ALWAYS a list. That's predictable but often not what
# you want - three means should be a numeric VECTOR, not a list of three
# one-element pieces. That's what the typed variants are for (Section 4).

# Section 4: Typed map Variants - map_dbl, map_chr, map_lgl ----------------
# The typed variants return an ATOMIC VECTOR of a specific type instead of a
# list, AND they enforce that type - a built-in correctness check.
#
#   map()      -> list (any type, any length per element)
#   map_dbl()  -> double (numeric) vector
#   map_int()  -> integer vector
#   map_chr()  -> character vector
#   map_lgl()  -> logical vector
#
# Use the typed variant when you KNOW each call returns a single value of
# that type. It both simplifies the result and catches bugs.

# Means as a clean numeric vector (not a list):
map_dbl(score_cols, mean)
# satisfaction engagement autonomy  -  a named numeric vector. Compare to the
# map() version above: same computation, tidier and correctly typed output.

# Character output - the class of each column:
map_chr(score_cols, \(x) class(x)[1])

# Logical output - does each column contain any value above 4?
map_lgl(score_cols, \(x) any(x > 4))

# THE ENFORCEMENT is the hidden value. If a function returns the wrong type,
# the typed variant ERRORS immediately instead of silently producing junk:
# map_dbl(score_cols, \(x) class(x))
# Error: Can't coerce element 1 from a character to a double
# That early, clear failure (Session 4 + 13 theme) is a feature: map_dbl is a
# promise that every result is one double, checked for you.

# map_int vs map_dbl: use map_int only when results are truly integers
# (counts, lengths). When in doubt, map_dbl - it accepts whole numbers too.
map_int(score_cols, length)   # each column's length (all 60)

# Section 5: Anonymous Functions in map - \(x) and ~ -----------------------
# map() takes a function. Three ways to supply one - all common, recognize all.

# Way 1: a NAMED function, bare (no arguments to add)
map_dbl(score_cols, mean)          # just the function name
map_dbl(score_cols, median)
map_dbl(score_cols, sd)

# Way 2: the native anonymous function \(x) - what we write in this course
map_dbl(score_cols, \(x) mean(x, na.rm = TRUE))   # when you need an argument
map_dbl(score_cols, \(x) max(x) - min(x))         # the range of each column

# Way 3: purrr's formula shorthand ~ with .x as the placeholder
# (the SAME idea as Session 6's across formula form). Recognize it; it's
# everywhere in existing purrr code.
map_dbl(score_cols, ~ mean(.x, na.rm = TRUE))
map_dbl(score_cols, ~ max(.x) - min(.x))
# In the ~ form, .x is each element. \(x) ... and ~ ... .x are interchangeable.
# We WRITE \(x) (base R, matches our native-pipe house style); we READ both.

# A purrr-specific shorthand worth knowing: a STRING extracts that element
# from each item. Great for pulling one field out of a list of records.
people <- list(
  list(name = "Alice", age = 30),
  list(name = "Bob", age = 25),
  list(name = "Carol", age = 41)
)
map_chr(people, "name")    # "Alice" "Bob" "Carol" - pluck the name field
map_dbl(people, "age")     # 30 25 41 - pluck the age field
# The string-as-extractor is shorthand for \(p) p[["name"]]. Handy for the
# nested lists that come back from APIs and JSON (Session 2 list callback).

# Section 6: Combining Results into a Data Frame ---------------------------
# When each iteration returns a one-row tibble (or a row of results), you
# usually want them STACKED into a single data frame. The modern purrr idiom
# is map() to a list of tibbles, then list_rbind() to bind the rows.

# Per department, build a one-row summary tibble, then stack them:
dept_names <- unique(survey$department)

dept_summaries <- dept_names |>
  map(\(dep) {
    sub <- survey |> filter(department == dep)
    tibble(
      department = dep,
      n = nrow(sub),
      mean_sat = mean(sub$satisfaction),
      mean_eng = mean(sub$engagement)
    )
  }) |>
  list_rbind()    # stack the list of one-row tibbles into one data frame
dept_summaries
# map() produces a LIST of tibbles; list_rbind() row-binds them into one. The
# result is a tidy summary, one row per department.

# NOTE on map_dfr(): older code uses map_dfr(x, f) to do map + row-bind in one
# call. As of purrr 1.0 (2022) map_dfr() is SUPERSEDED - it still works, but
# the docs now steer you to map() |> list_rbind(). You'll SEE map_dfr() in
# existing code and tutorials, so recognize it:
#   dept_names |> map_dfr(\(dep) { ... })        # old, superseded
#   dept_names |> map(\(dep) { ... }) |> list_rbind()   # current, preferred
# Same result. Write the list_rbind() form; recognize map_dfr(). (Likewise
# map_dfc() -> map() |> list_cbind() for binding columns.)

# This map() + list_rbind() pattern is the workhorse for "do something to each
# group/file/model and collect the results into one table". We use it for
# models in Section 9.

# Section 7: map2() - Iterating Over Two Inputs ----------------------------
# map() walks one input. map2(x, y, f) walks TWO in parallel, calling
# f(x[[i]], y[[i]]) for each i. The two inputs must be the same length.
# In the function, the two elements are .x and .y (formula form) or named
# args (in \(x, y)).

# Two parallel vectors: a base value and a multiplier per element.
bases <- c(10, 20, 30)
mults <- c(2, 3, 4)
map2_dbl(bases, mults, \(b, m) b * m)    # 20 60 120
# Typed variants exist for map2 too (map2_dbl, map2_chr, ...).

# A practical example: build a labeled summary string per department, pairing
# each department name with its subset.
map2_chr(
  dept_names,
  map(dept_names, \(dep) filter(survey, department == dep)),
  \(name, sub) paste0(name, ": mean satisfaction = ", round(mean(sub$satisfaction), 2))
)
# .x = the name, .y = the data subset, walked in lockstep.

# pmap() generalizes to ANY number of inputs (a list of arguments). Mention it
# exists for when two isn't enough; we won't drill it. The progression is
# map (one) -> map2 (two) -> pmap (many).

# Section 8: map() vs across() - When to Use Which -------------------------
# Both apply a function to many things. The difference is WHAT they iterate
# over, and it determines which tool fits (Session 6 callback).
#
#   across()  iterates over COLUMNS of a data frame, INSIDE a dplyr verb
#             (mutate/summarize). Stays in the data frame. Same operation to
#             each column, results land as columns.
#
#   map()     iterates over ELEMENTS of ANY list or vector, ANYWHERE. More
#             general: list elements, files, models, data subsets, API
#             results - things that aren't columns of one data frame.
#
# Rule of thumb: transforming/summarizing COLUMNS of one data frame -> across().
# Iterating over anything else (or producing non-column results like fitted
# models) -> map().

# The SAME task two ways - mean of three columns:

# across() way - stays in the data frame, natural for column summaries:
survey |>
  summarize(across(c(satisfaction, engagement, autonomy),
                   \(x) mean(x, na.rm = TRUE)))

# map() way - pull the columns into a list first, then iterate:
survey |>
  select(satisfaction, engagement, autonomy) |>
  map_dbl(\(x) mean(x, na.rm = TRUE))
# (A data frame IS a list of columns, so map() over a selected data frame
# walks its columns - a neat connection to Session 2.)
#
# For this column-summary task, across() is cleaner - it's purpose-built for
# it. map() earns its place when you leave the single-data-frame world:
# iterating over data SUBSETS, fitting MODELS, reading many FILES. The next
# section is exactly that case, where across() simply can't go.

# Section 9: MAIN EXERCISE ------------------------------------------------
# The payoff: iterate over data subsets and MODELS - things across() can't do.
# Walk through 1-2 together, then let them work. This ties together purrr,
# broom (Session 10), and custom functions (Session 13).

# 1. Use map() to compute a correlation for each department.
#    Split the survey by department, then correlate satisfaction with
#    engagement within each.
dept_corrs <- survey |>
  split(survey$department) |>     # a named LIST of per-department data frames
  map_dbl(\(d) cor(d$satisfaction, d$engagement))
dept_corrs
# split() turns one data frame into a list of sub-data-frames, one per
# department - exactly the list shape map() loves. map_dbl gives one
# correlation per department as a named numeric vector.

# 2. Fit the SAME regression model to each department subset with map().
#    (across() cannot do this - a model is not a column.)
dept_models <- survey |>
  split(survey$department) |>
  map(\(d) lm(satisfaction ~ engagement, data = d))
# dept_models is a LIST of fitted lm objects, one per department. map()
# returns a list because models are arbitrary objects, not atomic values.
dept_models$Engineering   # inspect one of them

# 3. Extract the coefficients from every model into one tidy table.
#    map() each model through broom::tidy(), then stack with list_rbind().
dept_coefs <- dept_models |>
  map(tidy) |>                          # each model -> a tidy coefficient tibble
  list_rbind(names_to = "department")   # stack, adding the list names as a column
dept_coefs
# names_to = "department" turns the list names (department names) into a
# column, so you know which row came from which model. This is the
# map() |> list_rbind() pattern from Section 6, applied to models. Pull just
# the engagement slopes to compare departments:
dept_coefs |> filter(term == "engagement")

# 4. Compare map() vs across() for a column operation. Compute the mean of the
#    three Likert columns BOTH ways and confirm they agree.
across_way <- survey |>
  summarize(across(c(satisfaction, engagement, autonomy),
                   \(x) mean(x, na.rm = TRUE)))
map_way <- survey |>
  select(satisfaction, engagement, autonomy) |>
  map_dbl(\(x) mean(x, na.rm = TRUE))
across_way    # a one-row tibble (stays in the data frame)
map_way       # a named numeric vector (left the data frame)
# Same numbers, different shapes. Discussion: across() keeps you in the data
# frame (great for building summary tables); map() returns a plain vector and
# generalizes beyond columns (great for the model-fitting in #1-3). Pick the
# tool that matches what you're iterating over.

# BONUS: Going Further -----------------------------------------------------

# walk() - like map() but for SIDE EFFECTS (printing, saving files), where you
# don't care about the return value. Returns its input invisibly.
walk(dept_names, \(dep) cat("Department:", dep, "\n"))
# Use walk() (not map()) when iterating to PRINT or SAVE - it signals "I'm
# doing this for the effect, not the result" and avoids a list of NULLs.
# e.g. walk2(plots, filenames, \(p, f) ggsave(f, p)) to save many plots.

# imap() - map with an INDEX or NAME. The function gets .x (the element) and
# .y (its name or position). Handy when the name matters.
imap_chr(score_cols, \(x, name) paste0(name, " mean = ", round(mean(x), 2)))

# map() returning models, then glance() for a fit-comparison table
# (Session 10's three-model table, now built by iteration instead of by hand):
survey |>
  split(survey$department) |>
  map(\(d) lm(satisfaction ~ engagement, data = d)) |>
  map(glance) |>
  list_rbind(names_to = "department") |>
  select(department, r.squared, nobs)
# One pipeline: split into departments, fit a model to each, glance each,
# stack into a table. This is the iteration version of what we did by hand in
# Session 10 - and it scales to 5 departments or 500 with no extra code.

# nest() + map() inside a tibble (list-columns) - the tidyverse-native version
# of split + map. A column where each cell holds a whole data frame.
survey |>
  nest(.by = department) |>                       # one row per dept, data nested
  mutate(model = map(data, \(d) lm(satisfaction ~ engagement, data = d)),
         r2 = map_dbl(model, \(m) glance(m)$r.squared)) |>
  select(department, r2)
# nest() packs each department's rows into a list-column called data; map()
# fits a model per row; map_dbl pulls each R-squared. List-columns keep the
# models, data, and results together in one tidy frame. This is the modern
# "many models" workflow - powerful, and worth a taste even if it's advanced.

# =============================================================================
# END OF SESSION 15
# =============================================================================

# TEACHING NOTES:
# - The core arc is map() returns a LIST -> typed variants return a VECTOR and
#   check the type. Get that contrast solid before anything else. Show the
#   map() list result and the map_dbl() vector result side by side.
# - Motivate with the for-loop (Section 2). Most will have seen loops; showing
#   that map() removes the index/accumulator/pre-allocation bookkeeping sells
#   it. Don't bash loops - just show map() is less to get wrong.
# - The typed-variant ENFORCEMENT (map_dbl errors on wrong type) is a feature,
#   not an annoyance. Tie it to the Session 4 + 13 "fail early and clearly"
#   theme. Demo the error.
# - map_dfr is superseded - teach map() |> list_rbind() as the real answer,
#   name map_dfr only for recognition. Same treatment as %>% in Session 5.
# - The model-fitting exercise (#2-3) is THE payoff: across() can't return a
#   list of models, so this is where map() is irreplaceable. Make that
#   explicit - it answers "why not just always use across()?".
# - split() + map() is the approachable mental model; nest() + list-columns is
#   the powerful modern version. Teach split() in the core, show nest() as a
#   bonus taste. Don't force list-columns on a tired room.
# - Next session: multiple regression and interactions - back to modeling,
#   building on the lm() and broom work this session iterated over.

# COMMON STUDENT MISTAKES TO WATCH FOR:
# 1. Expecting map() to return a vector (it returns a LIST; use map_dbl etc.)
# 2. Using map_dbl when the function returns non-numeric (errors - which is good)
# 3. Forgetting the data subset is a LIST after split() (that's why map() fits)
# 4. Reaching for map() to summarize columns when across() is cleaner
# 5. Using map_dfr in new code (superseded; use map() |> list_rbind())
# 6. Mixing up .x (map) with the bare column names of dplyr (different worlds)
# 7. map2() inputs of different lengths (must match)
# 8. Using map() for side effects (printing/saving) instead of walk()

# KEY CONCEPTS TO REINFORCE:
# - map(x, f) applies f to each element of x and returns a LIST
# - Typed variants (map_dbl/chr/lgl/int) return an atomic vector AND check type
# - Three ways to pass a function: bare name, \(x) ..., or ~ ... .x
# - map() |> list_rbind() stacks per-iteration tibbles (replaces map_dfr)
# - map2() walks two inputs in parallel; pmap() walks many
# - across() iterates over COLUMNS in a verb; map() iterates over ANY list
# - Use map() when results aren't columns (models, files, subsets)
# - walk() for side effects; imap() when the name/index matters

# ASSESSMENT IDEAS:
# - Give a copy-pasted block or a for-loop, have them rewrite it with map()
# - Ask which map variant returns what, and have them pick the right one
# - Fit one model per group with split() + map(), tidy into one table
# - Explain why a model-per-group needs map() and can't use across()
# - Translate a map_dfr() call into the modern map() |> list_rbind() form
# - Decide map() vs across() for a given task and justify the choice
