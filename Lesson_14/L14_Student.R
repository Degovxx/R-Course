###########################################
# Session 14: Tidy Evaluation &           #
#             Programming with dplyr      #
###########################################

# Section 1: Setup ---------------------------------------------------------

# Load the tidyverse and here

# Read in the employee survey data (data/employee_survey.csv)

# glimpse the data

# Section 2: The Problem - Why Functions Break with dplyr ------------------

# Write the working version directly: group_by(department) then summarize
# mean(satisfaction). Confirm it works.

# Now try to wrap it in a function that takes group_col and value_col as
# plain arguments (no special syntax). Call it with bare names. What error
# do you get, and WHY? (Think back to Session 13 scope.)

# Section 3: Two Worlds - Data Masking vs Tidy Selection -------------------

# (Concept - no code. Be ready to state the difference:
#  DATA MASKING = compute with columns (filter, mutate, summarize, group_by).
#  TIDY SELECTION = pick columns (select, rename, the .cols of across).
#  The tool you reach for depends on which world the verb is in.)

# Section 4: Embracing with {{ }} - The Core Tool --------------------------

# Fix the broken function from Section 2 using {{ }} around the bare-name
# arguments. Test it with several different grouping and value columns.

# Write add_deviation(df, value_col) that adds each row's distance from the
# mean of value_col, using {{ }} (note: you'll embrace value_col twice).

# Section 5: Naming Outputs with the Walrus := -----------------------------

# Rewrite the grouped-mean function so the OUTPUT column is named after the
# input column (e.g. mean_satisfaction), using "mean_{{ value_col }}" := ...

# Section 6: The .data Pronoun - When the Column Is a String ---------------

# Write group_mean_string(df, group_col, value_col) where the arguments are
# CHARACTER STRINGS. Use .data[[ ]] to look them up. Call it with quoted names.

# Compare: the {{ }} version takes bare names, the .data version takes
# strings. When would each be the right choice?

# Section 7: Tidy Selection in Functions - all_of() and any_of() -----------

# Write select_two(df, col_a, col_b) that selects two BARE-name columns
# using {{ }}.

# Write select_cols(df, cols) that selects from a CHARACTER VECTOR of names
# using all_of(). Then write a version using any_of() and pass it a list
# containing a name that doesn't exist - what's the difference?

# Write select_matching(df, pattern_cols) that passes a tidy-select HELPER
# expression through with {{ }}. Test it with starts_with() and where().

# Section 8: Passing Many Columns with ... ---------------------------------

# Write count_by(df, ...) that groups by ANY number of columns (forward the
# dots to group_by) and counts rows. Test with one, two, and three columns.

# Write summarize_groups(df, group_var, ...) that groups by one column and
# lets the caller supply any number of named summary expressions via ...

# Section 9: Putting It Together - across() in a Function ------------------

# Write standardize_by_group(df, group_var, cols) that z-scores the selected
# cols WITHIN each group. Use {{ group_var }} for the grouping (data masking)
# and {{ cols }} inside across() (tidy selection). Add a _z suffix, ungroup
# at the end. Test it, including with a where() helper for cols.

# Section 10: MAIN EXERCISE ------------------------------------------------

# 1. Write group_summary(df, group_var, value_var) using {{ }} that returns
#    n, mean, and sd of value_var per group (bare names).

# 2. Write zscore_cols(df, cols) using tidy-select that z-scores any chosen
#    columns, keeping the originals (add a _z suffix). Make it work with a
#    bare list of columns AND with a helper like where(is.numeric).

# 3. Write filter_above(df, col_name, threshold) using the .data pronoun,
#    where col_name is a STRING. Keep rows where that column exceeds threshold.

# 4. Write summarize_across_by(df, group_var, cols, fns) that groups by
#    group_var, then applies a named list of functions across the selected
#    cols. Combine {{ group_var }}, across({{ cols }}, ...), and a default
#    fns list of mean and sd. Test it.

# BONUS: Going Further -----------------------------------------------------

# Rewrite a {{ }} function using the older enquo() + !! machinery, so you can
# recognize "bang-bang" in other people's code.

# Write named_mean(df, value_col, prefix) that builds a dynamic output name
# mixing a plain string and an embraced column name, e.g. "avg_satisfaction".

# Add input validation to your string-based filter function: check the
# column exists before using it, with a clear error listing valid columns
# (Session 13 callback).
