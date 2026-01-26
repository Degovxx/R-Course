#####################################
# Session 1: Orientation & R Basics #
#####################################

# Section 1: Variables and Assignment --------------------------------------

# Create a variable called 'my_age' and assign your age to it
my_age <- 42

# Alt + - shortcut

# Create a variable called 'my_name' and assign your name (in quotes)
my_name <- "Scott"
# Print both variables to the console
my_age
my_name

print(my_name)
cat(my_name, my_age)
# =concat(my_name, my_age)

# Section 2: Data Types ----------------------------------------------------

# Create a numeric variable
height_cm <- 177
num_students <- 4

# Create a character variable
city <- "Seattle"
favorite_color <- "Blue"

# Create a logical variable
# =if()
is_raining <- FALSE
is_sunny <- T

# Check the class of each variable using class()
class(height_cm) # Returns "numeric"
class(city) # Returns "character"
class(is_raining) # Returns "logical"

typeof(height_cm)

# Section 3: Basic Operators -----------------------------------------------

# Arithmetic operators
# Add two numbers
10 + 5 # Addition: 15
10 - 5 # Subtraction: 5
10 * 5 # Multiplication: 50
10 / 5 # Division: 2
10^2 # Exponentiation: 100
10 / 3
10 %% 3 # Modulo (remainder): 1
10 %/% 3 # Integer division: 3
10 %/% 3.3

sum_results <- 10 + 5
square_results <- 10^2

sum_results + square_results

# Divide two numbers

# Use the exponent operator (^)

# Comparison operators
# Test if 10 is greater than 5
10 > 5
10 < 5
10 >= 10
10 == 1
10 == 10
10 != 10
# =(10 <> 10)
10 != 5

# Test if "apple" equals "orange"
"Apple" == "Orange"
"Apple" == "Apple"

# Combinatorics
"Apple" == "Apple" & "Apple" == "Orange"
"Apple" == "Apple" | "Apple" == "Orange"

TRUE & FALSE & TRUE & T & T & T
TRUE | FALSE | T | F
!TRUE


# Section 4: Vectors -------------------------------------------------------

# Create a numeric vector of 5 numbers using c()
ages <- c(25, 30, 35, 40, 45)
temperatures <- c(72.5, 68.3, 75.1, 70.0, 565)

even_vector <- c(2, 4, 6, 8, 10, 12)
mixed_elements <- c(2, 4, 6, "8", "Ten", 12)
even_vector + c(2, 3, 6)

# =CONCAT()

# Create a character vector of 3 fruit names
fruits <- c("apple", "banana", "cherry")
cities <- c("New York", "Los Angeles", "Chicago")
fruits[1]


# Perform arithmetic on your numeric vector (multiply by 2)
ages * 2
ages[c(1, 3, 5)] * 2
ages[c(1, 3, 5)] * ages[c(2, 4, 2)]

ages[ages > 32] + 3


# Section 5: Getting Help --------------------------------------------------

mean(as.numeric(mixed_elements), na.rm = TRUE, trim = 0)
help(mean)
?mean

??mean
help.search()


example(mean)
# Get help for the mean function

as.numeric(mixed_elements)
mixed_elements[5] <- 10
as.numeric(mixed_elements)


# Search for functions related to "standard deviation"

# Section 6: Installing and Loading Packages ------------------------------

# Install the 'praise' package (run in console, not script!)

# Load the praise package
library("praise")
# Use the praise() function

# Section 7: MAIN EXERCISE -------------------------------------------------
# Compute mean, median, and standard deviation for a numeric vector

# Create a vector of at least 10 numeric values

# Calculate the mean

# Calculate the median

# Calculate the standard deviation

# Print a summary message with all three statistics

# BONUS: Work with built-in data -------------------------------------------

# Load the mtcars dataset (built into R)

# Look at the first few rows using head()

# Calculate mean of the mpg column

# Calculate median of the hp column
