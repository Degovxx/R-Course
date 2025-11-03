###################################
# Session 2: Core Data Structures #
###################################

# Section 1: Atomic Vectors and Type Coercion ----------------------------

# Create a numeric vector with 5 numbers

# Create a character vector with 3 names

# Create a logical vector with 4 TRUE/FALSE values

# Check the type of each vector using typeof()

# Type coercion - what happens when we mix types?
# Create a vector mixing numbers and characters

# Check its type - what happened?

# Create a vector mixing numbers and logical values

# Section 2: Lists --------------------------------------------------------

# Create a list with different types (number, character, and logical)

# Create a list with names for each element

# Create a nested list (a list containing another list)

# Section 3: Matrices -----------------------------------------------------

# Create a matrix with 3 rows and 4 columns using matrix()

# Create a matrix by combining vectors with cbind()

# Create a matrix by combining vectors with rbind()

# Access the element in row 2, column 3

# Section 4: Data Frames --------------------------------------------------

# Create a data frame with 3 columns: name, age, score

# View the structure of your data frame

# Access a column using $

# Access a column using []

# Add a new column to the data frame

# Section 5: Tibbles ------------------------------------------------------

# Load the tidyverse (or tibble) package

# Create a tibble with the same data as your data frame

# Convert your data frame to a tibble

# Print both - notice the differences

# Section 6: Indexing Methods ---------------------------------------------

# Create a sample list for practicing indexing

# Use [ ] to extract an element (returns a list)

# Use [[ ]] to extract an element (returns the value)

# Use $ to extract by name

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
