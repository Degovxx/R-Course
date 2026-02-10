###################################
# Session 2: Core Data Structures #
###################################

# Section 1: Atomic Vectors and Type Coercion ----------------------------

# Create a numeric vector with 5 numbers
numeric_vec <- c(1.5, 2.7, 3.9, 4.2, 5.0)

# Create a character vector with 3 names
character_vec <- c("Alice", "Bob", "Charlie")

# Create a logical vector with 4 TRUE/FALSE values
logical_vec <- c(TRUE, FALSE, TRUE, TRUE)

# Integer Vector
integer_vec <- c(1L, 2L, 3L, 4L, 5L)

# Check the type of each vector using typeof()
typeof(integer_vec)
typeof(numeric_vec)

# Floating point rounding issues
a <- 0.1
b <- 0.2
a + b == 0.3

0.1 + 0.2 == 0.3
0.1 + 0.2

print(0.1 + 0.2, digits = 20)

all.equal(0.1 + 0.2, 0.3)

# Type coercion - what happens when we mix types?
# Create a vector mixing numbers and characters
mixed1 <- c(1, 2, "three", 4)
mixed1
# Check its type - what happened?
typeof(mixed1)

# Create a vector mixing numbers and logical values
mixed2 <- c(1, 2, TRUE, FALSE, 5)
typeof(mixed2)
mixed2

# everything
mixed3 <- c(1, 2, TRUE, FALSE, "Five", "5")
mixed3

# Logical Math
sum(c(TRUE, TRUE, FALSE)) >= 2

# Explicit Coercion
as.numeric(mixed3)
as.character(mixed3)
as.logical(mixed3)

# Section 2: Lists --------------------------------------------------------

# Create a list with different types (number, character, and logical)
my_list <- list(42, "Hello", TRUE, c(1, 2, 3))
my_list

# Create a list with names for each element
person <- list(
  name = "Scott",
  age = 42,
  is_student = FALSE,
  grade = c(85, 92, 88)
)
person

# Create a nested list (a list containing another list)
nested_list <- list(
  participant_1 = list(id = "P001", age = 35, scores = c(78, 82, 85)),
  participant_2 = list(id = "P002", age = 30, scores = c(88, 90, 92, 88)),
  participant_3 = list(id = "P003", age = 27, scores = c(75, 80, 83))
)
nested_list

# Section 3: Matrices -----------------------------------------------------

# Create a matrix with 3 rows and 4 columns using matrix()
mat1 <- matrix(1:12, nrow = 3, ncol = 4)
mat1

mat2 <- matrix(1:12, nrow = 3, ncol = 4, byrow = TRUE)
mat2

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

# Much like lists you can name elements!
mat1
rownames(mat1) <- c("Row1", "Row2", "Row3")
colnames(mat1) <- c("Col1", "Col2", "Col3", "Col4")

# Access the element in row 2, column 3
mat1[2, 4]
mat1["Row2", "Col4"]

mat1[1, ]
mat1[, 3]

mat1[1:2, 2:4]

mat1[upper.tri(mat1)]

# Section 4: Data Frames --------------------------------------------------

# Create a data frame with 3 columns: name, age, score
students_df <- data.frame(
  name = c("Alice", "Bob", "Charlie", "Diana", "Edward"),
  age = c(20, 22, 21, 23, 20),
  score = c(85, 92, 78, 88, 95),
  passed = c(TRUE, TRUE, TRUE, TRUE, TRUE)
)

# View the structure of your data frame
str(students_df)

# Access a column using $
help("$")
students_df$score
str(students_df$score)
typeof(students_df$score)
students_df$score <- students_df$score - 2

# Access a column using []
students_df[, 3]
students_df[, "score"]
students_df[, c(FALSE, FALSE, TRUE, FALSE)]

# Helper functions
nrow(students_df)
ncol(students_df)
dim(students_df)

names(students_df)

View(students_df)

# Confusing Selection
str(students_df$score)
str(students_df[, "score"])
str(students_df["score"])

(students_df$score - 2)[3]
(students_df[, "score"] - 2)[3]
(students_df["score"] - 2)[3, ]

# Add a new column to the data frame
students_df$grade <- c("B", "A", "C", "B", "A")
students_df$score_pct <- students_df$score / 100

# Section 5: Tibbles ------------------------------------------------------

# Load the tidyverse (or tibble) package
install.packages("tibble")
library(tidyverse)

# Create a tibble with the same data as your data frame
students_tbl <- tibble(
  name = c("Alice", "Bob", "Charlie", "Diana", "Edward"),
  age = c(20, 22, 21, 23, 20),
  age_2 = age * 2,
  score = c(85, 92, 78, 88, 95),
  passed = c(TRUE, TRUE, TRUE, TRUE, TRUE)
)

# Convert your data frame to a tibble
tibble(students_df)
as.data.frame(students_tbl)

# Print both - notice the differences

# Subsetting Differences
students_df[, "name"] # Returns a vector (drops to 1D)
students_tbl[, "name"] # Returns a tibble (stays 2D)

students_df["name"] # Returns a data frame (stays 2D)
students_tbl["name"] # Returns a tibble (stays 2D)

# Section 6: Indexing Methods ---------------------------------------------

# Create a sample list for practicing indexing
my_list <- list(
  numbers = c(1, 2, 3),
  letters = c("a", "b", "c"),
  logicals = c(TRUE, FALSE, TRUE)
)

# Use [ ] to extract an element (returns a list)
my_list[2]
class(my_list[2])

# Use [[ ]] to extract an element (returns the value)
my_list[[2]]
class(my_list[[2]])

# Use $ to extract by name
my_list$numbers
class(my_list$numbers)

# DATA FRAMES TOO
students_df["name"] # Returns a data frame (1 column)
students_df[["name"]] # Returns a vector
students_df$name # Returns a vector

# Multi Indexing


# Section 7: Logical Subsetting -------------------------------------------

# Create a sample vector

# Create a logical vector for values > 75

# Use the logical vector to subset the original

# Combine in one step with a logical condition

# Section 8: Factors ------------------------------------------------------

# Create a character vector of categories

# Convert to a factor

# Check the levels

# Create an ordered factor (e.g., low, medium, high)

# Section 9: MAIN EXERCISE ------------------------------------------------
# Create and manipulate a participant dataset

# Create vectors for participant data
# - id: participant IDs (P001, P002, etc.)
# - age: ages (ranging from 25 to 45)
# - gender: gender categories
# - condition: experimental condition (control or treatment)
# - score_pre: pre-test scores
# - score_post: post-test scores
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

# QUESTIONS TO PONDER:
# Investigate how I created these data:
# - Used paste0() and sprintf() to create formatted IDs. What do these commands do?
# - Used rep() to repeat patterns. Figure out how to use rep()!

# Combine into a data frame called participants_df

# Convert to a tibble called participants_tbl

# Display both and compare

# Subsetting exercises:
# Select all participants over age 30

# Select just the id, age, and score_post columns

# Select participants in the treatment condition

# Select participants with score_post > score_pre

# Select participants over 35 in the treatment condition

# Calculate mean post-test score for each condition

# BONUS: Advanced Subsetting ----------------------------------------------

# Use subset() function to select treatment participants over 30

# Use which() to find row numbers where score_post > 80

# Order participants by age using order()

# Create a new variable for score improvement (post - pre)

# INDEPENDENT LEARNING ----------------------------------------------------
# Compare and contrast as.numeric() and as.integer()
# Run this and think about the output 0.1 + 0.2 == 0.3
# print(0.1 + 0.2, digits = 20)
# Why does this matter? Computer precision errors can be costly if you don't know to avoid them...
# x <- seq(0, 1, by = 0.1)
# x[x == 0.3]
# versus
# x[abs(x - 0.3) < 1e-10]
# Going back to the first example, R gives us tools to deal with the way computers work. all.equal(0.1 + 0.2, 0.3)
