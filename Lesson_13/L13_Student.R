###########################################
# Session 13: Writing Custom Functions    #
###########################################

# Section 1: Setup ---------------------------------------------------------

# Load the tidyverse and here

# Read in the employee survey data (data/employee_survey.csv)

# glimpse the data

# Section 2: Why Write Functions? - The DRY Principle ----------------------

# Write the copy-paste version first: z-score satisfaction, engagement, and
# autonomy in a single mutate(), one hand-written line each. Feel the
# repetition - what would happen with a typo in one line?

# Now write a z_score() function once, and apply it to all three columns
# with across(). Same result, no repetition.

# Section 3: Anatomy of a Function -----------------------------------------

# Write add_ten(x) that adds 10 to its input. Test it on a single number
# and on a vector.

# Write rectangle_area(width, height) that multiplies its two arguments.
# Call it with positional arguments, then with named arguments.

# Section 4: Return Values - Implicit vs Explicit --------------------------

# Write double_it(x) using an implicit return (last expression)

# Write the same function using an explicit return()

# Write classify_score(x) that returns "A" for >= 90, "B" for >= 80,
# else "C". Use early return() for the A and B cases.

# Write min_max(x) that returns BOTH the min and the max in a named list.
# Access each piece of the result with $.

# Section 5: Default Arguments ---------------------------------------------

# Write safe_mean(x, na.rm = TRUE) that defaults to dropping NAs.
# Test it with the default, then override na.rm = FALSE.

# Write summarize_scores(x, digits = 2, na.rm = TRUE) returning a rounded
# mean and sd. Call it with defaults, then override digits.

# Section 6: The ... Argument (Dots) ---------------------------------------

# Write my_paste(...) that pastes any number of inputs with " | " between them

# Write trimmed_report(x, ...) that computes mean(x, ...) and returns a
# label string. Test it with trim = 0.25 and with na.rm = TRUE passed via ...

# Section 7: Scope - Local vs Global ---------------------------------------

# Write scope_demo() that creates a local variable and returns it.
# Then try to access that variable outside the function - what happens?

# Write count_high_good(x, threshold) that counts values >= threshold,
# taking threshold as an ARGUMENT (not a global). Test it.

# Demonstrate that assigning to x inside a function does NOT change a
# global x of the same name.

# Section 8: Input Validation ----------------------------------------------

# Write z_score_safe(x) that:
#   - stops with a clear message if x is not numeric
#   - stops with a clear message if x has fewer than 2 values
#   - otherwise returns the z-scores (handle NAs)
# Test it with good input, then with bad input to see your error messages.

# Rewrite the validation using stopifnot() instead of if/stop.

# Section 9: Documenting Your Functions ------------------------------------

# Write a comment block above a function stating its purpose, its
# arguments, and its return value. (You'll document cohens_d below.)

# Section 10: MAIN EXERCISE ------------------------------------------------

# 1. Write a documented, validated cohens_d(group1, group2, na.rm = TRUE)
#    that returns the standardized mean difference using the POOLED sd:
#      pooled_sd = sqrt(((n1-1)*var(g1) + (n2-1)*var(g2)) / (n1 + n2 - 2))
#      d = (mean(g1) - mean(g2)) / pooled_sd
#    Test it on remote vs on-site satisfaction, and on Engineering vs Sales
#    satisfaction. Which comparison shows a large effect?

# 2. Write summarize_numeric(df) that takes a data frame and returns a tidy
#    tibble with mean, sd, n, and n_missing for each NUMERIC column.
#    (Hint: across(where(is.numeric), ...) with a named list of functions,
#     then pivot to one row per variable - Sessions 6 and 11.)
#    Run it on the survey.

# 3. Add input validation to BOTH functions (numeric checks, data-frame
#    check, length checks). Write a call that deliberately triggers each
#    error so you can read the message.

# BONUS: Going Further -----------------------------------------------------

# Write make_multiplier(factor) that RETURNS a function multiplying by
# factor. Use it to build double() and triple().

# Write group_mean(df, group_col, value_col) using {{ }} so it accepts BARE
# column names: group_mean(survey, department, satisfaction).
# (This previews Session 14 - tidy evaluation.)

# Compose two of your own functions into a single pipeline function.
