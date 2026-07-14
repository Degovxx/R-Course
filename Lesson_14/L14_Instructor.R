###########################################
# Session 14: Tidy Evaluation &           #
#             Programming with dplyr      #
###########################################

# Last session we wrote functions, and the bonus ended on a cliffhanger:
# group_mean(survey, department, satisfaction) worked, with BARE column names
# and no quotes, thanks to a mysterious {{ }}. This session is the whole
# explanation. It's the bridge between "writing functions" (Session 13) and
# "writing functions that speak fluent tidyverse".
#
# THE PROBLEM this solves: the tidyverse's great convenience - typing bare
# column names like filter(satisfaction > 3) instead of df[df$satisfaction >
# 3, ] - becomes a HEADACHE the moment you try to wrap it in a function. The
# function receives the NAME satisfaction, tries to find a variable called
# satisfaction in its own scope (Session 13: scope!), and fails. Tidy
# evaluation is the machinery that makes bare column names work inside your
# own functions.
#
# Pacing note: this is the most ABSTRACT session in the course. Go slow.
# The single most important idea is the distinction between DATA MASKING and
# TIDY SELECTION - everything else hangs off it. {{ }} is the workhorse;
# .data[[ ]] is the string-based alternative. Lean hard on "show the broken
# version first, then fix it" - the contrast is what makes it click.

# Section 1: Setup ---------------------------------------------------------

library(tidyverse)
library(here)

# Same employee survey since Session 5. By now the columns are second nature,
# which is exactly what we want - the NEW thing here is hard enough on its own.
survey <- read_csv(here("data", "employee_survey.csv"))
glimpse(survey)

# Section 2: The Problem - Why Functions Break with dplyr ------------------
# Start with the failure. Students need to FEEL why this is hard before the
# solution means anything.

# This works fine, typed directly:
survey |>
  group_by(department) |>
  summarize(mean_sat = mean(satisfaction))

# Now try to wrap it in a function so you can reuse it for any group/column.
# The OBVIOUS attempt - just pass the names like normal arguments:
group_mean_broken <- function(df, group_col, value_col) {
  df |>
    group_by(group_col) |>
    summarize(mean = mean(value_col))
}
# group_mean_broken(survey, department, satisfaction)
# Error: object 'department' not found

# WHY it fails (this is the heart of the session): when you call the function
# with `department`, R tries to evaluate `department` as a normal value in
# the function's scope (Session 13). There IS no variable called department
# there - department is a COLUMN inside df, not an object in the environment.
# dplyr's verbs do a special trick to find columns; a plain function argument
# does not get that trick automatically. We have to hand it over explicitly.

# Section 3: Two Worlds - Data Masking vs Tidy Selection -------------------
# THE conceptual core. Every tidyverse verb uses ONE of two evaluation styles,
# and which tool you reach for depends on which style the verb uses.
#
# DATA MASKING: the verb lets you use column names as if they were variables
# in a computation. You can do MATH and LOGIC with them.
#   - filter(satisfaction > 3)      - compare
#   - mutate(total = a + b)         - compute
#   - summarize(m = mean(x))        - aggregate
#   - group_by(department)          - reference
#   Verbs: filter, mutate, summarize, group_by, arrange, count, ...
#
# TIDY SELECTION: the verb lets you PICK columns by name, position, or helper.
# You're choosing WHICH columns, not computing with their values.
#   - select(satisfaction, engagement)
#   - select(starts_with("Q"))      - Session 6 helpers live here
#   - across(where(is.numeric), ...) - the SELECTION part of across()
#   Verbs/contexts: select, rename, the .cols of across, pivot_longer cols, ...
#
# The tool you need DIFFERS by world:
#   - Data masking  -> embrace with {{ }}   (Sections 4-5)
#   - Tidy selection -> ALSO {{ }} in modern dplyr, but the mental model and
#     the string-based escape hatch (.data / all_of) differ (Sections 6-7)
#
# Keep this two-column map on the board all session. When a student's
# function breaks, the first question is always: "which world are you in?"

# Section 4: Embracing with {{ }} - The Core Tool --------------------------
# {{ }} ("curly-curly" or "embrace") is the fix for data-masking arguments.
# It tells dplyr: "don't evaluate this argument in the function's scope -
# pass the column name THROUGH to the verb and let dplyr resolve it as a
# column." It hands dplyr's special trick down into your function.

# The broken function from Section 2, now fixed:
group_mean <- function(df, group_col, value_col) {
  df |>
    group_by({{ group_col }}) |>
    summarize(mean = mean({{ value_col }}, na.rm = TRUE), .groups = "drop")
}
group_mean(survey, department, satisfaction)   # works! bare names, no quotes
group_mean(survey, department, engagement)     # reusable for any column
group_mean(survey, remote, salary)             # any grouping, any value

# Read {{ value_col }} as: "take whatever column the caller named and drop it
# in right here." The braces are the hand-off. Without them, group_col is just
# an unfound variable; with them, it becomes the column the caller meant.

# {{ }} works anywhere inside a data-masking verb - in computations too:
add_deviation <- function(df, value_col) {
  df |>
    mutate(deviation = {{ value_col }} - mean({{ value_col }}, na.rm = TRUE))
}
add_deviation(survey, satisfaction) |>
  select(employee_id, satisfaction, deviation)
# Each employee's distance from the mean satisfaction. {{ }} used twice in
# one expression - it's just "insert the column here", as many times as needed.

# Section 5: Naming Outputs with the Walrus := -----------------------------
# A natural next want: name the OUTPUT column after the INPUT column, instead
# of a hard-coded "mean". But you can't put {{ }} on the left of a normal =.
# The := operator (the "walrus") lets the left-hand side be dynamic.

group_mean_named <- function(df, group_col, value_col) {
  df |>
    group_by({{ group_col }}) |>
    summarize(
      "mean_{{ value_col }}" := mean({{ value_col }}, na.rm = TRUE),
      .groups = "drop"
    )
}
group_mean_named(survey, department, satisfaction)
# The output column is now mean_satisfaction, not "mean". Note the two pieces:
#   - the name is a STRING with {{ }} interpolated inside it (glue-style)
#   - := replaces = because the left side is computed, not literal
group_mean_named(survey, department, engagement)   # -> mean_engagement

# The "{ }" glue syntax in names is worth a beat: inside a quoted name,
# "{{ value_col }}" is replaced by the column's name as text. This is the
# same {.col} idea from across()'s .names (Session 6), generalized.

# Section 6: The .data Pronoun - When the Column Is a String ---------------
# {{ }} is for when the caller passes a BARE name (satisfaction). But
# sometimes the column name arrives as a STRING - read from a config, built
# in a loop, chosen from a dropdown. For that, use the .data pronoun with
# [[ ]] (Session 2 callback: [[ ]] extracts by name).

# .data is a special object meaning "the data frame currently being processed
# inside the verb". .data[[var]] looks up the column NAMED by the string var.
group_mean_string <- function(df, group_col, value_col) {
  # here group_col and value_col are CHARACTER STRINGS, e.g. "department"
  df |>
    group_by(.data[[group_col]]) |>
    summarize(mean = mean(.data[[value_col]], na.rm = TRUE), .groups = "drop")
}
group_mean_string(survey, "department", "satisfaction")   # note the QUOTES
group_mean_string(survey, "remote", "salary")

# The contrast that defines the section:
#   group_mean(survey, department, satisfaction)        # {{ }}: BARE name
#   group_mean_string(survey, "department", "satisfaction")  # .data: STRING
#
# Same result, different input style. Use {{ }} for interactive convenience
# (bare names), .data[[ ]] when the name is programmatic (a string). They are
# the two answers to "how did the column name reach my function?".

# .data also prevents a subtle bug: ambiguity between a column and a local
# variable of the same name. .data[["x"]] ALWAYS means the column x, never a
# stray local x. It's the unambiguous, explicit choice.

# Section 7: Tidy Selection in Functions - all_of() and any_of() -----------
# The OTHER world (Section 3). When your function needs to SELECT columns
# (not compute with them), the tools differ.

# Bare-name selection passes through with {{ }} just like data masking:
select_two <- function(df, col_a, col_b) {
  df |> select({{ col_a }}, {{ col_b }})
}
select_two(survey, department, salary)

# But selection's STRING escape hatch is all_of() / any_of(), NOT .data.
# (.data is a data-masking tool; in selection you use these instead.)
select_cols <- function(df, cols) {
  # cols is a CHARACTER VECTOR of column names
  df |> select(all_of(cols))
}
select_cols(survey, c("department", "satisfaction", "salary"))

# all_of() vs any_of():
#   all_of(cols)  - every name MUST exist, errors if one is missing (strict)
#   any_of(cols)  - takes the ones that exist, silently skips the rest (lenient)
select_cols_safe <- function(df, cols) {
  df |> select(any_of(cols))
}
select_cols_safe(survey, c("department", "nonexistent", "salary"))
# any_of() returns department and salary, ignoring "nonexistent". Handy for
# "drop these columns if present" or selecting from a maybe-incomplete list.

# Tidy-select HELPERS (Session 6) also work inside functions and can be
# parameterized. Pass a helper expression through with {{ }}:
select_matching <- function(df, pattern_cols) {
  df |> select({{ pattern_cols }})
}
select_matching(survey, starts_with("s"))     # satisfaction, salary
select_matching(survey, where(is.numeric))    # all numeric columns
# The whole tidy-select expression (starts_with("s"), where(is.numeric)) is
# handed through intact. This is how you write flexible column-picking tools.

# Section 8: Passing Many Columns with ... ---------------------------------
# Often you want a function to accept ANY number of grouping or summary
# columns. Combine ... (Session 13) with the tidy-eval rules: dots carry
# data-masking expressions through to the verb automatically.

# Group by any number of columns, count rows:
count_by <- function(df, ...) {
  df |>
    group_by(...) |>     # the dots forward all grouping columns to group_by
    summarize(n = n(), .groups = "drop")
}
count_by(survey, department)
count_by(survey, department, remote)           # two grouping columns
count_by(survey, department, remote, salary)   # as many as you like

# ... also carries named expressions. A flexible summarizer:
summarize_groups <- function(df, group_var, ...) {
  df |>
    group_by({{ group_var }}) |>
    summarize(..., .groups = "drop")   # caller supplies the summary exprs
}
summarize_groups(survey, department,
                 mean_sat = mean(satisfaction),
                 mean_eng = mean(engagement),
                 n = n())
# The caller writes the summaries; the function provides the grouping
# skeleton. This is genuinely powerful - a reusable analysis template.

# Section 9: Putting It Together - across() in a Function ------------------
# across() (Session 6) spans BOTH worlds: its .cols argument is tidy SELECTION,
# its function argument is the operation. Parameterizing both inside a custom
# function is the capstone pattern of the session.

# A flexible z-score function: standardize any selected columns, by group.
standardize_by_group <- function(df, group_var, cols) {
  df |>
    group_by({{ group_var }}) |>
    mutate(across({{ cols }},
                  \(x) (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE),
                  .names = "{.col}_z")) |>
    ungroup()
}
standardize_by_group(survey, department, c(satisfaction, engagement)) |>
  select(employee_id, department, satisfaction, satisfaction_z,
         engagement, engagement_z)
# Within each department, satisfaction and engagement are z-scored against
# THAT department's mean and sd. {{ group_var }} (data masking) and
# {{ cols }} (tidy selection inside across) working side by side - the two
# worlds in one function. This is the real-world payoff of the session.

# Works with helpers too, since {{ cols }} carries any tidy-select expression:
standardize_by_group(survey, remote, where(is.numeric)) |>
  select(employee_id, remote, ends_with("_z")) |>
  head()

# Section 10: MAIN EXERCISE ------------------------------------------------
# Write flexible, reusable analysis functions. Walk through 1-2 together,
# then let them work. Each targets one tidy-eval tool.

# 1. A grouped summary function using {{ }}: takes a grouping column and a
#    value column (BARE names), returns mean and sd per group.
group_summary <- function(df, group_var, value_var) {
  df |>
    group_by({{ group_var }}) |>
    summarize(
      n = n(),
      mean = mean({{ value_var }}, na.rm = TRUE),
      sd = sd({{ value_var }}, na.rm = TRUE),
      .groups = "drop"
    )
}
group_summary(survey, department, satisfaction)
group_summary(survey, remote, salary)

# 2. A z-score function using tidy-select: standardize any chosen columns,
#    keeping the originals (add a _z suffix).
zscore_cols <- function(df, cols) {
  df |>
    mutate(across({{ cols }},
                  \(x) (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE),
                  .names = "{.col}_z"))
}
zscore_cols(survey, c(satisfaction, engagement, autonomy)) |>
  select(employee_id, ends_with("_z"))
zscore_cols(survey, where(is.numeric)) |>   # works with a helper too
  select(employee_id, ends_with("_z")) |>
  head()

# 3. A filtering function using the .data pronoun: take a column name as a
#    STRING and a threshold, keep rows above it.
filter_above <- function(df, col_name, threshold) {
  df |>
    filter(.data[[col_name]] > threshold)
}
filter_above(survey, "satisfaction", 3)
filter_above(survey, "salary", 70000)
# .data[[col_name]] because the column arrives as a string. The threshold is
# an ordinary value, so it needs no special treatment.

# 4. Combine tidy evaluation with across() for a powerful abstraction:
#    summarize any selected columns with any named list of functions, by group.
summarize_across_by <- function(df, group_var, cols,
                                 fns = list(mean = \(x) mean(x, na.rm = TRUE),
                                            sd = \(x) sd(x, na.rm = TRUE))) {
  df |>
    group_by({{ group_var }}) |>
    summarize(across({{ cols }}, fns, .names = "{.col}_{.fn}"),
              .groups = "drop")
}
summarize_across_by(survey, department, c(satisfaction, engagement))
# One function that groups, selects, and applies multiple summaries - the
# whole tidyverse toolkit, parameterized. {{ group_var }} is data masking,
# {{ cols }} is tidy selection, fns is the operation. All three sessions'
# worth of ideas (6, 13, 14) in one tool.

# BONUS: Going Further -----------------------------------------------------

# enquo() and !! - the OLDER, lower-level machinery {{ }} is built on.
# {{ x }} is exactly shorthand for !!enquo(x). You'll see !! ("bang-bang")
# and enquo() in older code and Stack Overflow answers, so recognize them:
group_mean_old <- function(df, group_col, value_col) {
  group_col <- enquo(group_col)   # "quote" the argument (capture the name)
  value_col <- enquo(value_col)
  df |>
    group_by(!!group_col) |>      # "unquote" it (drop the name back in)
    summarize(mean = mean(!!value_col, na.rm = TRUE), .groups = "drop")
}
group_mean_old(survey, department, satisfaction)
# This does exactly what the {{ }} version does. {{ }} (introduced 2019) bundled
# enquo + !! into one readable operator. WRITE {{ }}; just RECOGNIZE !!.

# The englue() / glue trick for fully dynamic names from strings:
named_mean <- function(df, value_col, prefix) {
  df |>
    summarize("{prefix}_{{ value_col }}" := mean({{ value_col }}, na.rm = TRUE))
}
named_mean(survey, satisfaction, "avg")   # column: avg_satisfaction
# Mixes a plain string ({prefix}) and an embraced name ({{ value_col }}) in
# one glued output name. Both interpolate inside the quoted := left side.

# Defensive check: confirm a string column actually exists before using it.
filter_above_safe <- function(df, col_name, threshold) {
  if (!col_name %in% names(df)) {
    stop("Column '", col_name, "' not found. Available: ",
         paste(names(df), collapse = ", "))   # Session 13 validation callback
  }
  df |> filter(.data[[col_name]] > threshold)
}
# filter_above_safe(survey, "satisfction", 3)   # typo -> clear, helpful error
# Pairs the string-based .data approach with Session 13's input validation:
# string column names are exactly where a typo slips through silently, so a
# membership check earns its keep.

# =============================================================================
# END OF SESSION 14
# =============================================================================

# TEACHING NOTES:
# - This is the abstraction peak of the course. Expect glazed looks; that's
#   normal. The "broken first, then fixed" structure (Sections 2 -> 4) is the
#   single most effective move. Let them sit in the error before the fix.
# - The data-masking vs tidy-selection split (Section 3) is THE idea. Put the
#   two-column map on the board and keep pointing back to it: "which world?"
#   Every other decision in the session follows from that answer.
# - {{ }} for bare names, .data[[ ]] for strings (Sections 4 vs 6) is the
#   practical takeaway most will actually use. Drill the bare-vs-quoted
#   contrast: group_mean(df, dept, sat) vs group_mean_string(df, "dept", "sat").
# - WHY it breaks (Section 2) ties straight back to Session 13 scope: the
#   argument gets evaluated in the function's environment, where the column
#   name isn't a variable. Make that connection explicit - it demystifies it.
# - := and glue names (Section 5) are a nice-to-have; don't let them eat the
#   time the core needs. Same for the enquo/!! bonus - recognition only.
# - Next session: iteration with purrr - map() over lists and vectors, the
#   other half of "programming with the tidyverse".

# COMMON STUDENT MISTAKES TO WATCH FOR:
# 1. Passing a bare name and forgetting {{ }} (object 'department' not found)
# 2. Using {{ }} on a STRING argument (use .data[[ ]] / all_of() instead)
# 3. Using .data[[ ]] in a SELECT context (that's masking; use all_of() there)
# 4. Forgetting := when the output name is dynamic (a plain = won't take {{ }})
# 5. Mixing up the two worlds: which verb is masking vs selection
# 6. all_of() on a name that doesn't exist (use any_of() for the lenient case)
# 7. Quoting column names when passing bare to a {{ }} function (or vice versa)
# 8. Expecting ... to need {{ }} (it doesn't - dots forward expressions as-is)

# KEY CONCEPTS TO REINFORCE:
# - The tidyverse has TWO evaluation worlds: data masking and tidy selection
# - Data masking = compute with columns (filter/mutate/summarize/group_by)
# - Tidy selection = pick columns (select/rename/across's .cols)
# - {{ }} ("embrace") passes a BARE column name through to a verb
# - .data[[var]] uses a STRING column name in a masking context
# - all_of()/any_of() use STRING names in a selection context
# - := plus "{{ col }}" glue names build dynamic output column names
# - ... forwards any number of column expressions with no extra syntax
# - {{ }} is modern shorthand for the older !!enquo() pattern

# ASSESSMENT IDEAS:
# - Give a broken dplyr-wrapping function, have them diagnose and fix with {{ }}
# - Have them write the SAME function two ways: bare-name ({{ }}) and string (.data)
# - Ask which "world" a given verb uses and why it matters for the tool choice
# - Write a flexible group-summary function accepting any group and value column
# - Combine {{ group }} + across({{ cols }}) into one standardization tool
# - Explain why the naive (no {{ }}) version fails, in terms of scope (Session 13)
