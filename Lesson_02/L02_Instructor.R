###################################
# Session 2: Core Data Structures #
###################################

# This is one of the most important sessions. Students need
# to understand these structures deeply as they form the foundation of all
# data analysis in R. Use lots of examples and check for understanding.

# Section 1: Atomic Vectors and Type Coercion ----------------------------
# Atomic vectors contain elements of the SAME type
# This is different from lists, which we'll see later

# The main atomic vector types:
# - numeric (double): decimal numbers
# - integer: whole numbers (use L suffix)
# - character: text strings
# - logical: TRUE/FALSE

# Create different types of atomic vectors
numeric_vec <- c(1.5, 2.7, 3.9, 4.2, 5.0)
character_vec <- c("Alice", "Bob", "Charlie")
logical_vec <- c(TRUE, FALSE, TRUE, TRUE)
integer_vec <- c(1L, 2L, 3L, 4L, 5L) # L makes it explicitly integer
# What is the value of explicitly integer?

# Check the type of each vector
typeof(numeric_vec) # "double"
typeof(character_vec) # "character"
typeof(logical_vec) # "logical"
typeof(integer_vec) # "integer"

# Also show class() - often same as typeof() for vectors
# class(numeric_vec)    # "numeric"

# Type coercion: what happens when we mix types?
# R will coerce to the most flexible type
# Hierarchy: character > numeric > logical

# Mixing numbers and characters -> everything becomes character
mixed1 <- c(1, 2, "three", 4)
typeof(mixed1) # "character"
mixed1 # "1" "2" "three" "4" (note the quotes!)

# Mixing numbers and logical -> logical becomes numeric (TRUE=1, FALSE=0)
mixed2 <- c(1, 2, TRUE, FALSE, 5)
typeof(mixed2) # "double"
mixed2 # 1 2 1 0 5

# This can cause silent bugs! Always check your data types
# sum(c(TRUE, FALSE, TRUE))  # Works! = 2 (because TRUE=1, FALSE=0)

# Explicit coercion functions
as.numeric(c("1", "2", "3")) # Convert character to numeric
as.character(c(1, 2, 3)) # Convert numeric to character
as.logical(c(0, 1, 0)) # Convert numeric to logical (0=FALSE, other=TRUE)

# Show what happens with invalid coercion
# as.numeric(c("1", "two", "3"))    # Returns: 1 NA 3 (with warning)

# Section 2: Lists --------------------------------------------------------
# Lists are the most flexible data structure in R
# Unlike atomic vectors, lists can contain DIFFERENT types
# Lists can even contain other lists (nested structures)

# Create a simple list with different types
my_list <- list(42, "hello", TRUE, c(1, 2, 3))
my_list

# Create a named list (much more useful!)
person <- list(
  name = "Scott",
  age = 42,
  is_student = FALSE,
  grades = c(85, 92, 88)
)
person

# Lists are incredibly powerful because they can hold anything
# You can have a list where each element is a data frame, for example

# Nested lists (lists containing lists)
nested_list <- list(
  participant_1 = list(id = "P001", age = 25, scores = c(78, 82, 85)),
  participant_2 = list(id = "P002", age = 30, scores = c(88, 90, 92)),
  participant_3 = list(id = "P003", age = 27, scores = c(75, 80, 83))
)
nested_list

# Lists are often used for:
# - Storing heterogeneous data
# - Function outputs (many functions return lists)
# - Complex nested data structures (like JSON)

# Section 3: Matrices -----------------------------------------------------
# Matrices are 2D structures where ALL elements must be the SAME type
# Think of them as a vector arranged in rows and columns

# Create a matrix using matrix()
# Data fills by COLUMN by default
mat1 <- matrix(1:12, nrow = 3, ncol = 4)
mat1

# Fill by row instead
mat2 <- matrix(1:12, nrow = 3, ncol = 4, byrow = TRUE)
mat2

# Show the difference between byrow=TRUE and byrow=FALSE

# Create a matrix by binding columns
col1 <- c(1, 2, 3)
col2 <- c(4, 5, 6)
col3 <- c(7, 8, 9)
mat3 <- cbind(col1, col2, col3)
mat3

# Create a matrix by binding rows
row1 <- c(1, 2, 3)
row2 <- c(4, 5, 6)
row3 <- c(7, 8, 9)
mat4 <- rbind(row1, row2, row3)
mat4

# Add row and column names
rownames(mat1) <- c("Row1", "Row2", "Row3")
colnames(mat1) <- c("Col1", "Col2", "Col3", "Col4")
mat1

# Indexing matrices: [row, column]
mat1[2, 3] # Element at row 2, column 3
mat1[2, ] # Entire row 2 (returns a vector)
mat1[, 3] # Entire column 3 (returns a vector)
mat1[1:2, 2:4] # Submatrix: rows 1-2, columns 2-4

# Matrices are less common in data analysis than data frames
# but are important for:
# - Mathematical operations
# - Image data
# - Some statistical methods (e.g., correlation matrices)

# Section 4: Data Frames --------------------------------------------------
# Data frames are THE most important data structure for data analysis!
# Think of them as a spreadsheet or a table
# - Each column is a vector (can be different types)
# - Each column must have the same length
# - Columns have names

# Create a data frame
students_df <- data.frame(
  name = c("Alice", "Bob", "Charlie", "Diana", "Edward"),
  age = c(20, 22, 21, 23, 20),
  score = c(85, 92, 78, 88, 95),
  passed = c(TRUE, TRUE, TRUE, TRUE, TRUE)
)
students_df

# Walk through the structure
# - Each column is a variable
# - Each row is an observation/case
# - This is "tidy data" format

# View the structure
str(students_df) # Shows data types and first few values

# View dimensions
nrow(students_df) # Number of rows (observations)
ncol(students_df) # Number of columns (variables)
dim(students_df) # Dimensions: rows and columns

# View column names
names(students_df)
colnames(students_df) # Same thing

# View in data exporer tab
view(students_df)

# Access a column using $
students_df$name # Returns the name column as a vector
students_df$score # Returns the score column as a vector

# Access a column using []
students_df[, "name"] # Returns as a vector
students_df["name"] # Returns as a data frame (single column)
students_df[, 1] # Access by position (first column)

# Explain the subtle difference:
# students_df["name"]    vs    students_df[, "name"]
# The first returns a data frame, the second returns a vector

# Access multiple columns
students_df[, c("name", "score")]
students_df[, c(1, 3)]

# Access rows
students_df[1, ] # First row
students_df[1:3, ] # First three rows

# Access specific cells
students_df[2, 3] # Row 2, column 3
students_df[2, "score"] # Row 2, score column

# Add a new column
students_df$grade <- c("B", "A", "C", "B", "A")
students_df

# Add a calculated column
students_df$score_doubled <- students_df$score * 2
students_df

# Show that you can reference existing columns when creating new ones
students_df$score_pct <- students_df$score / 100
students_df


# Section 5: Tibbles ------------------------------------------------------
# Tibbles are "modern data frames" from the tidyverse
# They have some improved behaviors compared to base data frames

# Load tidyverse (or just tibble)
library(tidyverse) # Loads tibble along with other packages

# Create a tibble
students_tbl <- tibble(
  name = c("Alice", "Bob", "Charlie", "Diana", "Edward"),
  age = c(20, 22, 21, 23, 20),
  score = c(85, 92, 78, 88, 95),
  passed = c(TRUE, TRUE, TRUE, TRUE, TRUE)
)
students_tbl

# Point out the differences in printing:
# - Shows first 10 rows by default
# - Shows column types under names
# - Doesn't show row names
# - More informative display

# Convert data frame to tibble
students_tbl2 <- as_tibble(students_df)
students_tbl2

# Convert tibble to data frame
students_df2 <- as.data.frame(students_tbl)
students_df2

# Key differences to demonstrate:
# 1. Printing behavior
tibble(rbind(
  students_tbl2,
  students_tbl2,
  students_tbl2,
  students_tbl2,
  students_tbl2
))
data.frame(rbind(
  students_tbl2,
  students_tbl2,
  students_tbl2,
  students_tbl2,
  students_tbl2
))

# 2. Subsetting behavior
students_df[, "name"] # Returns a vector (drops to 1D)
students_tbl[, "name"] # Returns a tibble (stays 2D)

# Tibbles never:
# - Automatically convert strings to factors
# - Drop dimensions when subsetting
# - Use row names (controversial!)
# Tibbles are stricter and more predictable

# Section 6: Indexing Methods ---------------------------------------------
# Understanding [ ], [[ ]], and $ is crucial!
# These work differently for different data structures

# Create a sample list for demonstration
my_list <- list(
  numbers = c(1, 2, 3),
  letters = c("a", "b", "c"),
  logicals = c(TRUE, FALSE, TRUE)
)

# [ ] - Returns a list (keeps the structure)
my_list[1] # Returns a list with one element
class(my_list[1]) # "list"

# [[ ]] - Returns the element itself (extracts the contents)
my_list[[1]] # Returns the vector c(1, 2, 3)
class(my_list[[1]]) # "numeric"

# $ - Returns the element by name (extracts the contents)
my_list$numbers # Returns the vector c(1, 2, 3)
class(my_list$numbers) # "numeric"

# TEACHING ANALOGY: [ ] is like grabbing a box, [[ ]] is like opening the box
# Think of it this way:
# my_list[1]    -> gives you a box containing numbers
# my_list[[1]]  -> gives you the numbers themselves

# For data frames, this matters too!
students_df["name"] # Returns a data frame (1 column)
students_df[["name"]] # Returns a vector
students_df$name # Returns a vector

# Multiple indexing with [[ ]]
my_list[[1]][2] # Second element of first list item


# Section 7: Logical Subsetting -------------------------------------------
# This is one of the most powerful features in R!
# Logical subsetting lets you filter data based on conditions

# Create a sample vector
test_scores <- c(65, 78, 82, 55, 91, 88, 73, 95, 60, 85)

# Create a logical vector based on a condition
passed <- test_scores > 70
passed # TRUE/FALSE for each element

# Use the logical vector to subset
test_scores[passed] # Returns only scores > 70

# Combine in one step (most common approach)
test_scores[test_scores > 70]
test_scores[test_scores >= 80]
test_scores[test_scores < 60]

# Multiple conditions using logical operators
# & (AND): both conditions must be TRUE
test_scores[test_scores > 70 & test_scores < 90]

# | (OR): at least one condition must be TRUE
test_scores[test_scores < 60 | test_scores > 90]

# Logical subsetting with data frames
# This is where it gets really powerful!

# Filter rows based on a condition
students_df[students_df$score > 85, ]
students_df[students_df$age >= 22, ]


# Multiple conditions
students_df[students_df$score > 85 & students_df$age < 22, ]

# Select specific columns from filtered rows
students_df[students_df$score > 85, c("name", "score")]

# Explain that the first dimension is rows, second is columns
# data_frame[rows, columns]
# data_frame[logical_vector, ]    # filter rows
# data_frame[, c("col1", "col2")] # select columns

# Section 8: Factors ------------------------------------------------------
# Factors are R's way of storing categorical data
# They look like character vectors but are stored as integers with labels
# This is memory-efficient and useful for statistical modeling

# Create a character vector of categories
colors <- c("red", "blue", "red", "green", "blue", "red", "green")
colors

# Convert to a factor
colors_factor <- factor(colors)
colors_factor

# Check the levels (unique categories)
levels(colors_factor) # "blue" "green" "red" (alphabetical by default)

# Under the hood, factors are stored as integers
# with labels. This is efficient for repeated categories.
as.numeric(colors_factor) # Shows the underlying integer codes

# Create an ordered factor (for ordinal data)
satisfaction <- c("low", "high", "medium", "low", "high", "medium", "high")
satisfaction_factor <- factor(
  satisfaction,
  levels = c("low", "medium", "high"),
  ordered = TRUE
)
satisfaction_factor

# Ordered factors preserve the ordering
# This matters for plotting and statistical analyses
satisfaction_factor[1] < satisfaction_factor[2] # Can compare ordered factors

# Reorder factor levels
colors_factor2 <- factor(colors, levels = c("red", "green", "blue"))
levels(colors_factor2)

# Common issues with factors:
# 1. Accidentally converting numbers to factors
# 2. Factor levels that don't match your data
# 3. Unwanted factor behavior when reading data (R used to do this by default)

# Converting factors back to characters
as.character(colors_factor)

# In modern R (tidyverse), factors are less automatic
# but still important for:
# - Statistical modeling (sets reference levels)
# - Plotting (controls order of categories)
# - Data validation (only allows specified levels)

# Section 9: MAIN EXERCISE ------------------------------------------------
# This exercise ties everything together
# Create a realistic research dataset and practice subsetting

# Create vectors for participant data
id <- paste0("P", sprintf("%03d", 1:20)) # P001, P002, ..., P020
age <- c(
  28,
  34,
  25,
  42,
  31,
  27,
  38,
  29,
  45,
  33,
  26,
  37,
  30,
  41,
  28,
  35,
  27,
  39,
  32,
  44
)
gender <- rep(c("Female", "Male", "Non-binary", "Female"), length.out = 20)
condition <- rep(c("control", "treatment"), each = 10)
score_pre <- c(
  72,
  68,
  75,
  70,
  73,
  71,
  69,
  74,
  67,
  76,
  71,
  70,
  72,
  69,
  74,
  68,
  73,
  70,
  75,
  67
)
score_post <- c(
  74,
  71,
  76,
  72,
  75,
  73,
  70,
  75,
  69,
  77,
  78,
  82,
  85,
  81,
  87,
  80,
  84,
  83,
  86,
  79
)

# Combine into a data frame
participants_df <- data.frame(
  id,
  age,
  gender,
  condition,
  score_pre,
  score_post
)

# View the data frame
head(participants_df)
str(participants_df)

# Convert to a tibble
participants_tbl <- as_tibble(participants_df)

# Display both and compare
print(participants_df)
print(participants_tbl)

# Point out the differences:
# - Tibble shows column types
# - Tibble shows only first 10 rows
# - Tibble output is more compact and informative

# Subsetting Exercises ----------------------------------------------------

# 1. Select all participants over age 30
participants_df[participants_df$age > 30, ]

# Break down what's happening:
# participants_df$age > 30    # Creates logical vector
# participants_df[logical_vector, ]  # Filters rows

# 2. Select just the id, age, and score_post columns
participants_df[, c("id", "age", "score_post")]

# Alternative using subset() function
subset(participants_df, select = c(id, age, score_post))

# 3. Select participants in the treatment condition
participants_df[participants_df$condition == "treatment", ]

# 4. Select participants with score_post > score_pre
participants_df[participants_df$score_post > participants_df$score_pre, ]

# We can also create a new variable for this
participants_df$improved <- participants_df$score_post >
  participants_df$score_pre
participants_df[participants_df$improved, ]

# 5. Select participants over 35 in the treatment condition
participants_df[
  participants_df$age > 35 & participants_df$condition == "treatment",
]

# Show what happens with each part:
# participants_df$age > 35                    # First condition
# participants_df$condition == "treatment"    # Second condition
# & combines them                             # Both must be TRUE

# 6. Calculate mean post-test score for each condition
# This previews grouping operations (covered more in later sessions)

# For control group
mean(participants_df[participants_df$condition == "control", "score_post"])

# For treatment group
mean(participants_df[participants_df$condition == "treatment", "score_post"])

# More elegant approach using tapply() or aggregate()
tapply(participants_df$score_post, participants_df$condition, mean)

aggregate(score_post ~ condition, data = participants_df, FUN = mean)

# Explain that dplyr will make this much easier!
# In tidyverse: participants_tbl %>% group_by(condition) %>% summarize(mean = mean(score_post))

# BONUS: Advanced Subsetting ----------------------------------------------

# Use subset() function (base R)
subset(participants_df, condition == "treatment" & age > 30)

# subset() is convenient but has some quirks
# It's often recommended to use [ ] for programming, subset() for interactive use

# Use which() to find row numbers
which(participants_df$score_post > 80)

# which() returns indices, not logical vector
# Useful for finding positions or avoiding NAs
high_scorers_idx <- which(participants_df$score_post > 80)
participants_df[high_scorers_idx, ]

# Order participants by age
participants_df[order(participants_df$age), ]

# Order by multiple columns (age, then score_post)
participants_df[order(participants_df$age, participants_df$score_post), ]

# Order descending
participants_df[order(-participants_df$age), ]

# Create a new variable for score improvement
participants_df$improvement <- participants_df$score_post -
  participants_df$score_pre
participants_df

# Calculate mean improvement by condition
aggregate(improvement ~ condition, data = participants_df, FUN = mean)

# This shows the treatment effect!
# Treatment group improved more than control group

# TEACHING NOTES FOR NEXT TIME:
# - Review the differences between data structures
# - Emphasize that data frames/tibbles are most common for data analysis
# - Preview that tidyverse will make many of these operations easier
# - Next session: data import/export and introduction to tidyverse

# COMMON STUDENT MISTAKES TO WATCH FOR:
# 1. Confusing [ ] and [[ ]] for lists
# 2. Forgetting the comma in data frame subsetting: df[df$x > 5, ]
# 3. Using = instead of == in logical conditions
# 4. Not understanding type coercion in vectors
# 5. Expecting data frames to behave like matrices (they're special!)
# 6. Factor surprises (especially with older R code/data)

# KEY CONCEPTS TO REINFORCE:
# - Vectors must have same type, lists can mix types
# - Data frames are lists of vectors (each column is a vector)
# - [ ] returns same structure, [[ ]] and $ extract contents
# - Logical subsetting is incredibly powerful
# - Tibbles are stricter, more predictable data frames

# ASSESSMENT:
# - Give students a data frame and ask them to:
#   * Extract specific columns
#   * Filter rows based on multiple conditions
#   * Create new calculated columns
#   * Explain the difference between df$col and df["col"]
# - Debugging exercise: fix code with common indexing errors
# - Create a data structure that matches specified requirements
