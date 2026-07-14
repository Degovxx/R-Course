###########################################
# Session 7: Visualization with ggplot2   #
###########################################

# This is the fun one. After six sessions of structures, cleaning, verbs,
# and column ops, students finally get to SEE their data. ggplot2 is the
# best plotting system in any language, and the grammar of graphics is a
# genuinely beautiful idea once it clicks.
#
# The core mental model to install: a plot is built in LAYERS. You start
# with data, map columns to visual properties (aesthetics), and add
# geometric layers (points, bars, lines). Each layer is added with +.
#
# THE #1 THING STUDENTS GET WRONG: they use |> between ggplot layers.
# ggplot predates the pipe and uses +. We pipe data INTO ggplot, then
# switch to + for the layers. Hammer this early and often.
#
# Pacing note: aesthetics + geom_point + geom_histogram are the must-haves.
# Faceting and themes are the second half. ggsave is a 2-minute closer.

# Section 1: Setup ---------------------------------------------------------

library(tidyverse) # ggplot2 loads with the tidyverse
library(here)

survey <- read_csv(here("data", "employee_survey.csv"))
glimpse(survey)

# Section 2: The Grammar of Graphics ---------------------------------------
# Teach the concept before the code. Three core components:
#
#   1. DATA      - the data frame you're plotting
#   2. AESTHETICS - mappings from columns to visual properties
#                   (x position, y position, color, size, shape, ...)
#   3. GEOMETRIES - the geometric objects that represent the data
#                   (points, bars, lines, boxes, ...)
#
# Every ggplot is: take DATA, map columns to AESTHETICS, draw GEOMETRIES.
# More layers (labels, scales, themes) refine it, but those three are the
# skeleton of every plot you'll ever make.

# The anatomy of a ggplot call:
#   ggplot(data, aes(x = ..., y = ...)) +
#     geom_something() +
#     more_layers()
#
# Note the + at the end of each line EXCEPT the last. The + must go at the
# END of a line, not the start of the next one. R needs to know the
# expression continues.

# Section 3: Your First Plot - Scatterplot ---------------------------------
# geom_point() draws one point per row. Best for two continuous variables.

# Build it up in stages so students see each piece add something.

# Stage 1: just the canvas (data + aesthetics, no geometry yet)
ggplot(survey, aes(x = tenure_years, y = salary))
# Run this alone: you get axes and a grid but NO points. The aesthetics
# reserved the space; without a geom there's nothing to draw. This is a
# great teaching moment - it shows aes() and geom are separate jobs.

# Stage 2: add the points
ggplot(survey, aes(x = tenure_years, y = salary)) +
  geom_point()

# Stage 3: pipe the data in first (our house style, connects to L5/L6)
survey |>
  ggplot(aes(x = tenure_years, y = salary)) +
  geom_point()
# Read it: "take survey, THEN start a plot mapping tenure to x and salary
# to y, AND add points." Note the switch from |> to + at the ggplot line.
# THIS is the spot students mix up. Say it out loud: pipe in, plus to build.

# Section 4: Aesthetics - Mapping Columns to Visuals -----------------------
# Aesthetics inside aes() are MAPPED to data. Set OUTSIDE aes() they're
# FIXED constants. This distinction causes endless confusion - teach it now.

# Map color to a column (color VARIES with department)
survey |>
  ggplot(aes(x = tenure_years, y = salary, color = department)) +
  geom_point()
# Each department gets its own color, and a legend appears automatically.

# Set color to a constant (ALL points are blue) - note: OUTSIDE aes()
survey |>
  ggplot(aes(x = tenure_years, y = salary)) +
  geom_point(color = "steelblue")
# No legend, because nothing is mapped - it's just a fixed property.

# THE CLASSIC MISTAKE: putting a constant inside aes()
# ggplot(survey, aes(x = tenure_years, y = salary, color = "steelblue")) +
#   geom_point()
# This makes ggplot treat "steelblue" as a one-level category, colors the
# points red (its first default), and adds a useless legend labeled
# "steelblue". Show this live - it's the single most confusing ggplot bug.
# RULE: mapping to a column -> inside aes(). Fixed value -> outside aes().

# Other aesthetics to demo
survey |>
  ggplot(aes(x = tenure_years, y = salary,
             color = department, shape = remote)) +
  geom_point(size = 3)
# color from department, shape from remote, size fixed at 3 (outside aes).

# alpha (transparency) helps with overlapping points
survey |>
  ggplot(aes(x = tenure_years, y = salary)) +
  geom_point(alpha = 0.5, size = 2)

# Section 5: Adding a Regression Line --------------------------------------
# geom_smooth() adds a trend line. method = "lm" gives a straight (linear)
# fit; the default method = "loess" gives a wiggly local-regression curve.

# Linear fit with confidence band
survey |>
  ggplot(aes(x = tenure_years, y = salary)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm")
# The shaded band is the 95% confidence interval for the fit. Turn it off
# with se = FALSE if you just want the line.

survey |>
  ggplot(aes(x = tenure_years, y = salary)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE, color = "firebrick")

# Layer ORDER matters: later layers draw ON TOP. Points then line means the
# line sits over the points. Flip them and the points cover the line.

# A fit line PER GROUP, by mapping color (the mapping flows to both geoms)
survey |>
  ggplot(aes(x = tenure_years, y = salary, color = department)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE)
# Because color is in the top-level aes(), BOTH geom_point and geom_smooth
# inherit it, so you get one line per department.

# Section 6: Distributions - Histograms and Density ------------------------
# For a single continuous variable, show its distribution.

# Histogram: bins the data and counts. Only needs an x aesthetic.
survey |>
  ggplot(aes(x = salary)) +
  geom_histogram()
# ggplot will warn "stat_bin() using bins = 30. Pick better value with
# binwidth." That warning is normal - it's nudging you to choose binning.

# Control the bins
survey |>
  ggplot(aes(x = salary)) +
  geom_histogram(binwidth = 5000, fill = "steelblue", color = "white")
# binwidth sets the width of each bar in DATA units ($5000 here).
# fill = bar color, color = bar OUTLINE. (Common mix-up: fill vs color.
# For shapes with area, fill is the inside, color is the border.)

# Density: a smoothed version of the histogram
survey |>
  ggplot(aes(x = salary)) +
  geom_density(fill = "steelblue", alpha = 0.4)

# Section 7: Comparing Groups - Boxplots and Bars --------------------------

# Boxplot: distribution of a continuous variable ACROSS categories
survey |>
  ggplot(aes(x = department, y = satisfaction)) +
  geom_boxplot()
# The box = middle 50% (IQR), the line = median, whiskers = range (roughly),
# dots = outliers. Great for comparing distributions side by side.

# Add color and jittered raw points on top for richness
survey |>
  ggplot(aes(x = department, y = satisfaction, fill = department)) +
  geom_boxplot(alpha = 0.5, outliers = FALSE) +
  geom_jitter(width = 0.2, alpha = 0.5)
# geom_jitter adds the actual data points with a little horizontal noise so
# they don't stack. outliers = FALSE on the boxplot avoids drawing outlier
# dots twice (once by the box, once by the jitter).
# Version note: outliers = FALSE needs ggplot2 3.5.0+ (2024). On older
# versions use outlier.shape = NA instead. Check with packageVersion("ggplot2").

# Bar chart of COUNTS: geom_bar() counts rows per category automatically
survey |>
  ggplot(aes(x = department)) +
  geom_bar()
# geom_bar does the counting for you - only needs x. This is the same job
# as count() from Session 5, but visual.

# Bar chart of VALUES you computed: geom_col()
# When you already have the numbers (e.g., a summary from Session 5), use
# geom_col(), which plots y as-is instead of counting.
survey |>
  group_by(department) |>
  summarize(mean_sat = mean(satisfaction)) |>
  ggplot(aes(x = department, y = mean_sat)) +
  geom_col(fill = "steelblue")
# THIS is the Session 5 + Session 7 combo: wrangle to a summary with dplyr,
# pipe straight into ggplot. geom_bar COUNTS, geom_col PLOTS given values.
# Mixing these up ("why is my bar chart counting instead of showing means?")
# is a top-five beginner error. geom_col when you have y already.

# Section 8: Faceting - Small Multiples ------------------------------------
# Faceting splits one plot into a grid of sub-plots, one per group. It's
# the visual equivalent of group_by: same plot, repeated per category.

# facet_wrap(): wraps sub-plots into a grid. One variable.
survey |>
  ggplot(aes(x = tenure_years, y = salary)) +
  geom_point() +
  facet_wrap(~ department)
# The ~ department means "make one panel per department". Read ~ as "by".
# Now you can compare the tenure-salary relationship across departments.

# Control the layout
survey |>
  ggplot(aes(x = salary)) +
  geom_histogram(binwidth = 5000) +
  facet_wrap(~ department, ncol = 2)

# facet_grid(): a 2D grid crossing TWO variables (rows by columns)
survey |>
  ggplot(aes(x = tenure_years, y = salary)) +
  geom_point() +
  facet_grid(remote ~ department)
# Rows = remote (TRUE/FALSE), columns = department. Every combination gets
# its own panel. facet_wrap for one variable, facet_grid for crossing two.

# Section 9: Labels, Scales, and Themes ------------------------------------
# Make it presentable. This is what separates a quick exploration plot from
# something you'd put in front of stakeholders.

# Labels with labs()
survey |>
  ggplot(aes(x = tenure_years, y = salary, color = department)) +
  geom_point(alpha = 0.7) +
  labs(
    title = "Salary by Tenure Across Departments",
    subtitle = "Employee survey, 2026",
    x = "Tenure (years)",
    y = "Annual salary (USD)",
    color = "Department",
    caption = "Source: internal engagement survey"
  )
# Note: the legend title is set by the AESTHETIC name (color = "Department").

# Themes change the overall look. ggplot's default is theme_gray().
# theme_minimal() and theme_bw() are clean, professional choices.
survey |>
  ggplot(aes(x = tenure_years, y = salary, color = department)) +
  geom_point(alpha = 0.7) +
  labs(title = "Salary by Tenure", x = "Tenure (years)", y = "Salary (USD)") +
  theme_minimal()

# Scales control how data maps to the axes/colors. Format the salary axis
# as dollars using the scales package (loads with tidyverse but call
# scales:: explicitly to be safe).
survey |>
  ggplot(aes(x = tenure_years, y = salary, color = department)) +
  geom_point(alpha = 0.7) +
  scale_y_continuous(labels = scales::dollar) +
  labs(title = "Salary by Tenure", x = "Tenure (years)", y = "Salary") +
  theme_minimal()

# A polished, stakeholder-ready version pulling it together
survey |>
  ggplot(aes(x = department, y = satisfaction, fill = department)) +
  geom_boxplot(alpha = 0.7, outliers = FALSE) +
  geom_jitter(width = 0.2, alpha = 0.4) +
  labs(
    title = "Job Satisfaction by Department",
    x = NULL, # NULL drops the axis label entirely (department is obvious)
    y = "Satisfaction (1-5)"
  ) +
  theme_minimal() +
  theme(legend.position = "none") # the fill legend is redundant with the x axis

# Section 10: Saving Plots -------------------------------------------------
# ggsave() writes the LAST plot (or a named plot object) to a file.

# Save a plot object for reuse
sat_plot <- survey |>
  ggplot(aes(x = department, y = satisfaction, fill = department)) +
  geom_boxplot(alpha = 0.7) +
  labs(title = "Satisfaction by Department", x = NULL, y = "Satisfaction") +
  theme_minimal() +
  theme(legend.position = "none")

# Display it by typing the object name
sat_plot

# Save to a file (path via here() - Session 3 habit)
# ggsave(here("output", "satisfaction_by_dept.png"),
#        plot = sat_plot,
#        width = 8, height = 5, dpi = 300)
# width/height are in INCHES by default. dpi = 300 is print/publication
# quality (use 150 for screen, 300 for documents). File format is inferred
# from the extension: .png, .pdf, .jpg, .svg all work. PDF and SVG are
# vector formats - they scale without pixelation, ideal for reports.

# Section 11: MAIN EXERCISE ------------------------------------------------
# Build the four plots from the syllabus, then polish one for export.
# Walk through #1 together, then let them work.

# 1. Scatterplot of two continuous variables with a regression line
survey |>
  ggplot(aes(x = engagement, y = satisfaction)) +
  geom_jitter(alpha = 0.5, width = 0.1, height = 0.1) + # jitter: Likert overlaps
  geom_smooth(method = "lm") +
  labs(title = "Satisfaction vs Engagement",
       x = "Engagement (1-5)", y = "Satisfaction (1-5)") +
  theme_minimal()
# Teaching note: satisfaction and engagement are 1-5 integers, so plain
# points stack right on top of each other. geom_jitter spreads them so you
# can see density. This is a real data-literacy point: know your variable
# types before choosing a geom.

# 2. Distributions by group (boxplots or violins)
survey |>
  ggplot(aes(x = department, y = engagement, fill = department)) +
  geom_boxplot(alpha = 0.7, outliers = FALSE) +
  geom_jitter(width = 0.2, alpha = 0.4) +
  labs(title = "Engagement by Department", x = NULL, y = "Engagement (1-5)") +
  theme_minimal() +
  theme(legend.position = "none")

# 3. A faceted plot showing a trend across departments
survey |>
  ggplot(aes(x = tenure_years, y = salary)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE) +
  facet_wrap(~ department) +
  labs(title = "Salary vs Tenure by Department",
       x = "Tenure (years)", y = "Salary (USD)") +
  scale_y_continuous(labels = scales::dollar) +
  theme_minimal()

# 4. Apply a professional theme + export at publication resolution
final_plot <- survey |>
  group_by(department) |>
  summarize(mean_sat = mean(satisfaction), .groups = "drop") |>
  ggplot(aes(x = reorder(department, mean_sat), y = mean_sat,
             fill = mean_sat)) +
  geom_col() +
  coord_flip() + # horizontal bars read more easily with category labels
  labs(title = "Mean Satisfaction by Department",
       x = NULL, y = "Mean satisfaction (1-5)") +
  theme_minimal() +
  theme(legend.position = "none")
final_plot
# reorder(department, mean_sat) sorts the bars by value - a small touch that
# makes ranked bar charts far more readable than alphabetical order.

# ggsave(here("output", "mean_satisfaction.png"),
#        plot = final_plot, width = 8, height = 5, dpi = 300)

# BONUS: Going Further -----------------------------------------------------

# Violin plots: like boxplots but show the full distribution shape
survey |>
  ggplot(aes(x = department, y = satisfaction, fill = department)) +
  geom_violin(alpha = 0.6) +
  theme_minimal() +
  theme(legend.position = "none")

# Color scales: use a named palette instead of defaults
survey |>
  ggplot(aes(x = tenure_years, y = salary, color = department)) +
  geom_point(size = 2) +
  scale_color_brewer(palette = "Set2") + # colorblind-friendlier than default
  theme_minimal()

# Combine dplyr + ggplot in one flow: filter, then plot
survey |>
  filter(!remote) |>
  ggplot(aes(x = engagement, y = satisfaction)) +
  geom_jitter(alpha = 0.5) +
  geom_smooth(method = "lm") +
  labs(title = "On-site employees only") +
  theme_minimal()

# Saving the dplyr result AND plotting it are two different things - the
# pipe flows data into ggplot but the plot is not a data frame. You can't
# pipe a ggplot into a dplyr verb. (A reliable source of confused errors.)

# =============================================================================
# END OF SESSION 7
# =============================================================================

# TEACHING NOTES FOR NEXT TIME:
# - The |> vs + confusion is THE thing to drill. Pipe data in, plus to build
#   layers. Expect to correct this a dozen times; that's normal.
# - Build the first scatterplot in stages (canvas, then points) so they see
#   that aes() and geom are separate. The empty-canvas stage is worth it.
# - The inside-aes vs outside-aes distinction (mapped vs fixed) is the
#   second big concept. Demo the "color = 'steelblue' inside aes" bug live.
# - geom_bar (counts) vs geom_col (plots given values) trips everyone.
#   Tie geom_col back to Session 5 summaries - wrangle then plot.
# - Jittering Likert data is a genuine data-literacy lesson, not a trick.
# - Next session: text analysis with tidytext (a change of pace).

# COMMON STUDENT MISTAKES TO WATCH FOR:
# 1. Using |> instead of + between ggplot layers (the #1 error)
# 2. Putting + at the START of a line instead of the END
# 3. Constants inside aes() (color = "blue" in aes makes a fake legend)
# 4. fill vs color confusion (fill = interior, color = border/points)
# 5. geom_bar when they meant geom_col (counting vs plotting values)
# 6. Plotting raw Likert points without jitter (everything overlaps)
# 7. Trying to pipe a ggplot object into a dplyr verb

# KEY CONCEPTS TO REINFORCE:
# - Data + aesthetics + geometries = every plot
# - Pipe data IN with |>, build layers with +
# - aes() = mapped to a column; outside aes() = fixed constant
# - Layer order = draw order (later layers on top)
# - facet_wrap (one variable) vs facet_grid (cross two)
# - geom_bar counts rows; geom_col plots values you already have
# - theme_minimal/theme_bw for professional looks; ggsave to export

# ASSESSMENT IDEAS:
# - Give a plain English description, have them build the plot
# - Show a broken plot (constant in aes, |> instead of +) to fix
# - Have them wrangle a summary with dplyr and plot it with geom_col
# - Ask them to explain mapped vs fixed aesthetics with an example
# - Export a publication-ready figure and justify the dpi/size choices
