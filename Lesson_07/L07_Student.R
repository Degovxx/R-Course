###########################################
# Session 7: Visualization with ggplot2   #
###########################################

# Section 1: Setup ---------------------------------------------------------

# Load the tidyverse and here

# Read in the employee survey data (data/employee_survey.csv)

# glimpse the data

# Section 2: The Grammar of Graphics ---------------------------------------

# (Concept - no code. Be ready to name the three core components:
#  data, aesthetics, geometries.)

# Section 3: Your First Plot - Scatterplot ---------------------------------

# Make just the canvas: ggplot with x = tenure_years, y = salary, no geom

# Add geom_point()

# Now pipe the data in first, then build the plot with +

# Section 4: Aesthetics ----------------------------------------------------

# Map color to department (inside aes)

# Set color to a fixed value for all points (outside aes)

# Map color to department AND shape to remote, with a fixed point size

# Add alpha transparency to handle overlapping points

# Section 5: Adding a Regression Line --------------------------------------

# Scatterplot of tenure vs salary with a linear smooth (geom_smooth lm)

# Same, but turn off the confidence band and set the line color

# A separate fit line per department (map color in the top-level aes)

# Section 6: Distributions -------------------------------------------------

# Histogram of salary

# Histogram with a chosen binwidth, fill, and outline color

# Density plot of salary

# Section 7: Comparing Groups ----------------------------------------------

# Boxplot of satisfaction by department

# Boxplot with fill and jittered points on top

# Bar chart of employee COUNTS per department (geom_bar)

# Bar chart of MEAN satisfaction per department (dplyr summary + geom_col)

# Section 8: Faceting ------------------------------------------------------

# Scatterplot of tenure vs salary, faceted by department (facet_wrap)

# Histogram of salary faceted by department, 2 columns

# Scatterplot faceted by remote AND department (facet_grid)

# Section 9: Labels, Scales, and Themes ------------------------------------

# Add a title, subtitle, axis labels, and caption with labs()

# Apply theme_minimal()

# Format the salary axis as dollars with scale_y_continuous

# Build one polished, stakeholder-ready plot (labels + theme + clean legend)

# Section 10: Saving Plots -------------------------------------------------

# Save a plot to an object, display it, then export with ggsave()
# (8 x 5 inches, dpi = 300)

# Section 11: MAIN EXERCISE ------------------------------------------------

# 1. Scatterplot of two continuous variables with a regression line
#    (remember: satisfaction/engagement are 1-5, so jitter the points)

# 2. Distributions by group (boxplots or violins)

# 3. A faceted plot showing a trend across departments

# 4. Apply a professional theme and export at publication resolution

# BONUS: Going Further -----------------------------------------------------

# Make a violin plot

# Use scale_color_brewer with a named palette

# Filter with dplyr, then pipe straight into a plot
