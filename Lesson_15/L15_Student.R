###########################################
# Session 15: Iteration with purrr        #
###########################################

# Section 1: Setup ---------------------------------------------------------

# Load the tidyverse and here

# Load broom (we'll iterate over models)

# Read in the employee survey data (data/employee_survey.csv)

# glimpse the data

# Section 2: The Problem Iteration Solves ----------------------------------

# Write the copy-paste version first: mean of satisfaction, engagement, and
# autonomy, one line each. Feel the repetition.

# Now write the same thing as a base R for-loop over a vector of column
# names. Notice how much bookkeeping (index, accumulator, names) it takes.

# Section 3: map() - Apply a Function to Each Element ----------------------

# Build a named list of the three Likert columns

# map() that list through mean() - what type is the result?

# map() over a character vector of column names, pulling each column from
# survey with an anonymous function

# Section 4: Typed map Variants - map_dbl, map_chr, map_lgl ----------------

# Use map_dbl() to get the three means as a numeric VECTOR

# Use map_chr() to get the class of each column

# Use map_lgl() to test whether each column has any value above 4

# What happens if you use map_dbl() but the function returns a character?
# (Try it - the error is the point.)

# Section 5: Anonymous Functions in map - \(x) and ~ -----------------------

# Pass a bare named function (e.g. median) to map_dbl

# Pass a \(x) anonymous function that needs an argument (mean with na.rm)

# Do the same with the ~ .x formula form (so you recognize it in other code)

# Use the string-as-extractor shorthand to pluck a field from a list of
# records (build a small list of list(name=, age=) and pull each name)

# Section 6: Combining Results into a Data Frame ---------------------------

# For each department, build a one-row summary tibble (department, n,
# mean_sat, mean_eng), then stack them with map() |> list_rbind()

# (Recognize the older map_dfr() form too - but write the list_rbind() form.)

# Section 7: map2() - Iterating Over Two Inputs ----------------------------

# Use map2_dbl() to multiply two parallel vectors element by element

# Build a labeled string per department by pairing each department name with
# its data subset using map2_chr()

# Section 8: map() vs across() - When to Use Which -------------------------

# Compute the mean of the three Likert columns with across() inside summarize

# Compute the same means with map_dbl() over a selected data frame

# (Concept: which iterates over COLUMNS in a verb, which over ANY list?
#  When would you HAVE to use map() instead of across()?)

# Section 9: MAIN EXERCISE ------------------------------------------------

# 1. Use split() + map_dbl() to compute the correlation between satisfaction
#    and engagement WITHIN each department.

# 2. Use split() + map() to fit lm(satisfaction ~ engagement) to each
#    department subset. (Why can't across() do this?)

# 3. map() each model through broom::tidy() and list_rbind() them into one
#    table, using names_to to label which department each row came from.
#    Then pull just the engagement slopes.

# 4. Compute the mean of the three Likert columns BOTH ways (across() and
#    map_dbl()). Confirm the numbers agree and describe how the OUTPUT shapes
#    differ.

# BONUS: Going Further -----------------------------------------------------

# Use walk() to PRINT a line per department (a side effect, no return value)

# Use imap_chr() to build a "name = value" string using each element's name

# Build a fit-comparison table: split by department, fit a model to each,
# glance() each, list_rbind() into one table of R-squared values

# Try the nest() + mutate(map(...)) list-column version of the same
# many-models workflow
