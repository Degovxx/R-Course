###########################################
# Session 15: Iteration with purrr        #
#            (In-Class Version)           #
###########################################

# Live capture. Lighter and more fun than last week's tidy-eval slog - people
# were relieved. The for-loop-then-map contrast in Section 2 sold it fast.
# The "map() returns a LIST, typed variants return a VECTOR" point needed two
# passes but landed. The model-per-department payoff was the high point - real
# "oh, THAT'S why" energy. Got through the map-vs-across comparison; exercise
# is homework. Notes inline.

# Section 1: Setup ---------------------------------------------------------

library(tidyverse)
library(here)
library(broom)

# Project root is C:\RStuff, so the path carries the "R-Course" prefix.
survey <- read_csv(here("R-Course", "data", "employee_survey.csv"))
glimpse(survey)

# Section 2: Why Iterate - the for-loop contrast ---------------------------

# Did the copy-paste version first:
mean(survey$satisfaction)
mean(survey$engagement)
mean(survey$autonomy)
# "Three lines. Add a column, add a line." Then the for-loop:
cols <- c("satisfaction", "engagement", "autonomy")
results <- numeric(length(cols))
for (i in seq_along(cols)) {
  results[i] <- mean(survey[[cols[i]]])
}
names(results) <- cols
results
# A few people relaxed seeing the loop - "oh I know this from other languages."
# Then: "count the things you have to get right - the index, the pre-allocated
# vector, the names. Four bookkeeping steps. map() does all four for you."
# Didn't bash loops, just framed map() as less to get wrong. Good setup.

# Section 3: map() returns a LIST ------------------------------------------

score_cols <- list(
  satisfaction = survey$satisfaction,
  engagement = survey$engagement,
  autonomy = survey$autonomy
)
map(score_cols, mean)
# "For each element, call mean()." The output being a LIST (not a vector) was
# the first speed bump - someone expected three plain numbers. "Hold that
# thought - map() ALWAYS gives a list. Next we fix the shape." Deliberately
# left it slightly unsatisfying to motivate the typed variants.

# Section 4: Typed variants - the fix --------------------------------------

map_dbl(score_cols, mean)
# "map_dbl = map, but give me a DOUBLE vector." The clean named numeric vector
# vs the list got the "oh that's better" reaction I wanted. Put the menu up:
#   map() -> list   map_dbl() -> numbers   map_chr() -> text   map_lgl() -> T/F
map_chr(score_cols, \(x) class(x)[1])
map_lgl(score_cols, \(x) any(x > 4))

# Showed the enforcement by breaking it on purpose:
# map_dbl(score_cols, \(x) class(x))
# Error: Can't coerce ... character to a double
# "It REFUSES to give you the wrong type. That's a feature." Tied back to the
# Session 4 / 13 'fail early and clearly' theme - they recognized it. The idea
# that the type is checked FOR you clicked here.

# Section 5: Anonymous functions (Session 6/14 callback) -------------------

map_dbl(score_cols, median)                       # bare name
map_dbl(score_cols, \(x) mean(x, na.rm = TRUE))   # \(x) when you need an arg
map_dbl(score_cols, ~ mean(.x, na.rm = TRUE))     # ~ .x form to recognize
# "Same three ways to pass a function as across() in Session 6. We write
# \(x), we read ~ .x." Quick because they'd seen it - nice continuity.

# The string-as-extractor surprised people in a good way:
people <- list(list(name = "Alice", age = 30),
               list(name = "Bob", age = 25),
               list(name = "Carol", age = 41))
map_chr(people, "name")
map_dbl(people, "age")
# "A bare string plucks that field from each record." Connected to Session 2
# lists / JSON. Someone asked if this is how you'd handle API data - yes,
# exactly. Good real-world hook.

# Section 6: map() |> list_rbind() -----------------------------------------

dept_names <- unique(survey$department)
dept_names |>
  map(\(dep) {
    sub <- filter(survey, department == dep)
    tibble(department = dep, n = nrow(sub),
           mean_sat = mean(sub$satisfaction))
  }) |>
  list_rbind()
# "map() gives a list of one-row tibbles; list_rbind() stacks them." Flagged
# the deprecation directly: "you'll see map_dfr() doing this in one step in
# older code - it still runs, but it's superseded. Write map() |> list_rbind()."
# Same move as %>% vs |> in Session 5 - recognize the old, write the new.
# Nobody had seen map_dfr yet so it was painless to set the convention early.

# Section 7: map2() --------------------------------------------------------

map2_dbl(c(10, 20, 30), c(2, 3, 4), \(b, m) b * m)   # 20 60 120
# "map walks one list, map2 walks two in lockstep - .x and .y." Kept it short,
# one clean example. Mentioned pmap() exists for 3+ inputs, didn't run it.
# "map -> map2 -> pmap, one, two, many." That progression was enough.

# ---- running a little ahead of time here for once ----

# Section 8: map() vs across() ---------------------------------------------

survey |>
  summarize(across(c(satisfaction, engagement, autonomy),
                   \(x) mean(x, na.rm = TRUE)))
survey |>
  select(satisfaction, engagement, autonomy) |>
  map_dbl(\(x) mean(x, na.rm = TRUE))
# Ran both. "Same numbers, different SHAPE - a tibble vs a vector." The rule
# that landed: "across() for COLUMNS of one data frame; map() for everything
# else - subsets, files, MODELS." Set up the exercise: "next we do the thing
# across() literally cannot do." Pointed out a data frame IS a list of columns
# so map() over a selected frame walks the columns (Session 2 callback) - one
# person found that genuinely cool.

# Section 9: MAIN EXERCISE -------------------------------------------------
# HOMEWORK - all four in the Student file. Did #1 and #2 together because the
# split() idea is the unlock and the model payoff is the whole point:
survey |>
  split(survey$department) |>
  map_dbl(\(d) cor(d$satisfaction, d$engagement))
# "split() turns one frame into a LIST of frames, one per department - exactly
# what map() wants." The per-department correlations as a named vector got
# nods. Then the models:
dept_models <- survey |>
  split(survey$department) |>
  map(\(d) lm(satisfaction ~ engagement, data = d))
dept_models$Engineering
# "Five models, one line, no copy-paste. across() can't hold a list of models
# - this is map()'s territory." THIS was the high point - the reason-to-care
# moment. Then teased #3: map(tidy) |> list_rbind(names_to = "department")
# to get every model's coefficients into one labeled table.

# #3 (tidy + list_rbind into one coefficient table) and #4 (map vs across,
# confirm same numbers / different shapes) are homework. Told them #3 is the
# Session 10 broom callback - "you tidied one model by hand then; now you tidy
# five at once by iteration."

# Next session: multiple regression and interactions - back to modeling. "We
# just fit a model per group with map(); next we put several predictors in ONE
# model and ask what happens when they interact."

# Note to self: this one paced well - the for-loop contrast and the model
# payoff are the two anchors, keep both. The map()-returns-a-list speed bump
# is worth leaving in; the dissatisfaction is what makes map_dbl land. Could
# give the nest()/list-column bonus more air next time if the room's fresh.
