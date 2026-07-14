###########################################
# Session 14: Tidy Evaluation &           #
#             Programming with dplyr      #
#            (In-Class Version)           #
###########################################

# Live capture. This was the hardest session to teach so far and I felt it -
# the abstraction is real. The "broken first, then fix it" structure saved me;
# the error in Section 2 did more teaching than any explanation could. The
# two-worlds map stayed on the whiteboard the whole time and I pointed at it
# constantly. Got through across()-in-a-function; exercise is homework. The
# {{ }} payoff from last week's cliffhanger landed well as an opener.

# Section 1: Setup ---------------------------------------------------------

library(tidyverse)
library(here)

# Project root is C:\RStuff, so the path carries the "R-Course" prefix.
survey <- read_csv(here("R-Course", "data", "employee_survey.csv"))
glimpse(survey)

# Opened by calling back to last week's cliffhanger: "Remember group_mean
# with the bare column names and the mysterious {{ }}? Today is the why."
# Good buy-in - a couple people said they'd been wondering about it.

# Section 2: The Problem - start with the break ----------------------------

# Works typed directly:
survey |>
  group_by(department) |>
  summarize(mean_sat = mean(satisfaction))

# The naive wrap - ran it live KNOWING it would fail:
group_mean_broken <- function(df, group_col, value_col) {
  df |>
    group_by(group_col) |>
    summarize(mean = mean(value_col))
}
# group_mean_broken(survey, department, satisfaction)
# Error: object 'department' not found
# Let the error sit on screen. "Why does typing department work but passing
# it to a function doesn't?" Tied it straight to Session 13 scope: the
# function looks for a VARIABLE called department in its own environment,
# finds nothing, because department is a COLUMN, not an object. That
# connection ("this is a scope problem") was the moment it started to make
# sense for the room. Worth the buildup.

# Section 3: Two Worlds ----------------------------------------------------
# Whiteboarded the two-column map and left it up all session:
#
#   DATA MASKING            |  TIDY SELECTION
#   compute WITH columns    |  PICK columns
#   filter, mutate,         |  select, rename,
#   summarize, group_by     |  across()'s .cols
#   tool: {{ }} / .data[[]] |  tool: {{ }} / all_of()
#
# "Every time a function breaks today, first question: which world are you
# in?" Repeated this maybe ten times. The map was the single most useful
# thing on the board - kept pointing at it instead of re-explaining.

# Section 4: {{ }} - the fix -----------------------------------------------

group_mean <- function(df, group_col, value_col) {
  df |>
    group_by({{ group_col }}) |>
    summarize(mean = mean({{ value_col }}, na.rm = TRUE), .groups = "drop")
}
group_mean(survey, department, satisfaction)
group_mean(survey, remote, salary)
# The fix landing right after the error was the payoff. "{{ }} says: don't
# evaluate this here, hand the NAME down to dplyr and let it find the column."
# Read it aloud as "drop the column in right here". Someone asked if it's two
# braces or one - TWO, the curly-curly. Wrote {{ }} big on the board.

# Used twice in one expression to show it's just "insert here":
add_deviation <- function(df, value_col) {
  df |>
    mutate(deviation = {{ value_col }} - mean({{ value_col }}, na.rm = TRUE))
}
add_deviation(survey, satisfaction) |>
  select(employee_id, satisfaction, deviation) |> head()
# "Embrace it as many times as you need. It's not magic, it's a hand-off."

# Section 5: := for dynamic names ------------------------------------------

group_mean_named <- function(df, group_col, value_col) {
  df |>
    group_by({{ group_col }}) |>
    summarize("mean_{{ value_col }}" := mean({{ value_col }}, na.rm = TRUE),
              .groups = "drop")
}
group_mean_named(survey, department, satisfaction)   # -> mean_satisfaction
# The output column being named mean_satisfaction instead of "mean" got a
# small "nice". Explained the two pieces: the name is a STRING with {{ }}
# glued in, and := replaces = because the left side is computed. Connected
# the glue to the {.col} from across() .names in Session 6 - they remembered it.
# Kept this brief; it's a nice-to-have, not the core.

# Section 6: .data for strings ---------------------------------------------

group_mean_string <- function(df, group_col, value_col) {
  df |>
    group_by(.data[[group_col]]) |>
    summarize(mean = mean(.data[[value_col]], na.rm = TRUE), .groups = "drop")
}
group_mean_string(survey, "department", "satisfaction")   # QUOTES now
# Ran the two side by side - this was the clarifying contrast of the day:
#   group_mean(survey, department, satisfaction)              # bare
#   group_mean_string(survey, "department", "satisfaction")   # string
# "{{ }} for bare names you type. .data[[ ]] for names that show up as
# strings - from a config, a loop, a dropdown." The "[[ ]] extracts by name"
# callback to Session 2 indexing helped - they'd seen [[ ]] before.
# Q: "which one should I use?" - depends how the name reaches you. If you're
# typing it, {{ }}. If it's already a string, .data[[ ]]. Don't quote a bare
# name or unquote a string. That's the whole rule.

# Section 7: Selection - all_of / any_of -----------------------------------

# Bare-name selection is just {{ }} again:
select_two <- function(df, col_a, col_b) {
  df |> select({{ col_a }}, {{ col_b }})
}
select_two(survey, department, salary)

# String selection uses all_of(), NOT .data - this is the easy thing to mix up:
select_cols <- function(df, cols) {
  df |> select(all_of(cols))
}
select_cols(survey, c("department", "satisfaction", "salary"))

# all_of vs any_of:
select_cols_safe <- function(df, cols) df |> select(any_of(cols))
select_cols_safe(survey, c("department", "nonexistent", "salary"))
# any_of skipped "nonexistent" silently; all_of would have errored. "all_of =
# strict, every name must exist. any_of = lenient, takes what's there." Flagged
# that .data is a MASKING tool and all_of is a SELECTION tool - pointed at the
# board map again. This is the crossing-the-streams mistake to watch for.

# Helpers pass through with {{ }} too:
select_matching <- function(df, pattern_cols) df |> select({{ pattern_cols }})
select_matching(survey, starts_with("s"))
select_matching(survey, where(is.numeric))
# "The whole starts_with(...) expression rides through intact." Session 6
# callback - they liked that the helpers they already knew just work here.

# Section 8: ... for many columns ------------------------------------------

count_by <- function(df, ...) {
  df |> group_by(...) |> summarize(n = n(), .groups = "drop")
}
count_by(survey, department)
count_by(survey, department, remote)
# The pleasant surprise: ... needs NO {{ }}. "The dots forward the column
# expressions as-is - dplyr unpacks them." A couple people expected to need
# {{ }} inside and were glad they didn't. Session 13 ... callback landed.

summarize_groups <- function(df, group_var, ...) {
  df |> group_by({{ group_var }}) |> summarize(..., .groups = "drop")
}
summarize_groups(survey, department,
                 mean_sat = mean(satisfaction),
                 mean_eng = mean(engagement), n = n())
# "The caller writes the summaries, the function provides the grouping
# skeleton." Called it an analysis template. Good reaction - this is the kind
# of reusable thing they can picture using at work.

# ---- ran out of time about here ----

# Section 9: across() in a function ----------------------------------------
# Showed this one but didn't have them type it - flagged it as the capstone
# and the model for exercise #4.
standardize_by_group <- function(df, group_var, cols) {
  df |>
    group_by({{ group_var }}) |>
    mutate(across({{ cols }},
                  \(x) (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE),
                  .names = "{.col}_z")) |>
    ungroup()
}
standardize_by_group(survey, department, c(satisfaction, engagement)) |>
  select(employee_id, department, satisfaction, satisfaction_z) |> head()
# "{{ group_var }} is masking, {{ cols }} inside across is selection - both
# worlds in one function." Pointed at the board map one last time. This is
# where the whole session pays off, but it was rushed for time - flag for
# next round to protect these minutes by trimming Section 5.

# Section 10: MAIN EXERCISE ------------------------------------------------
# HOMEWORK - all four in the Student file. Did #1 together as the anchor:
group_summary <- function(df, group_var, value_var) {
  df |>
    group_by({{ group_var }}) |>
    summarize(n = n(),
              mean = mean({{ value_var }}, na.rm = TRUE),
              sd = sd({{ value_var }}, na.rm = TRUE),
              .groups = "drop")
}
group_summary(survey, department, satisfaction)
# #2 (zscore_cols, tidy-select) and #3 (filter_above, .data string) drill the
# two tools separately - good, because the #1 risk is mixing them up. #4
# (summarize_across_by) is the capstone that combines everything; told them
# it's the hard one and to lean on the Section 9 model.

# Next session: iteration with purrr - map() over lists and vectors. "We've
# learned to write flexible functions; next we learn to RUN them across many
# things at once." The other half of programming with the tidyverse.

# Note to self: this session needs the most patience. The two-worlds map and
# the broken-then-fixed structure are what carried it - keep both. Trim := and
# the glue-name detour next time to protect Section 9, which is the real payoff
# and got squeezed. Nobody fully internalized masking-vs-selection in one
# sitting and that's fine - the exercise is where it sets.
