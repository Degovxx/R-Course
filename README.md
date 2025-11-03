# R Programming for Data Analysis & Organizational Research
## Course Syllabus

---

## Session 1: Orientation & R Basics

**Learning Objectives:**
- Navigate RStudio and adopt a project-based workflow
- Use base syntax, assignment, and basic operators
- Understand the console vs script distinction

**Topics:**
- RStudio interface and projects
- Scripts vs console: when to use each
- Variables and assignment
- Data types: numeric, character, logical
- Basic operators
- Installing and loading packages
- Getting help: `?function`, `??search`, and documentation

**Readings:**
- [RStudio IDE Cheatsheet](https://rstudio.github.io/cheatsheets/html/rstudio-ide.html)
- [An Introduction to R](https://cran.r-project.org/doc/manuals/r-release/R-intro.html) (Chapters 1-2)
- [R for Data Science: Workflow basics](https://r4ds.hadley.nz/workflow-basics.html)

**Exercise:**
- Set up an RStudio project
- Create a script that computes mean, median, and standard deviation for a numeric vector
- Practice using `?mean` and other help functions

---

## Session 2: Core Data Structures

**Learning Objectives:**
- Identify and manipulate vectors, lists, matrices, data frames, and tibbles
- Subset and index data reliably using logical, positional, and name-based methods
- Understand when to use each data structure

**Topics:**
- Atomic vectors and type coercion
- Lists: nested structures
- Matrices
- Data frames
- Tibbles
- Indexing: `[]`, `[[]]`, `$`
- Logical subsetting and Boolean vectors
- Factors and categorical data

**Readings:**
- [R for Data Science: Vectors](https://r4ds.hadley.nz/vectors.html)
- [Tibble Overview](https://tibble.tidyverse.org/articles/tibble.html)
- [Advanced R: Vectors](https://adv-r.hadley.nz/vectors-chap.html) (optional, for deeper understanding)

**Exercise:**
- Create a dataset with participant IDs, demographics, and test scores
- Practice subsetting: all participants over age 30
- Select specific columns by name
- Use logical conditions to filter data
- Convert between data frames and tibbles
- Observe differences between formats

---

## Session 3: Importing & Cleaning Data

**Learning Objectives:**
- Import common data formats (CSV, Excel, SPSS)
- Handle missing data and perform type conversions
- Apply reproducible file path practices

**Topics:**
- `readr::read_csv()` for CSV files
- `readxl::read_excel()` for Excel files
- Handling NA values: identification and strategies
- Type conversion and parsing issues
- Working directories and relative paths
- The `here` package for project-relative paths
- File naming conventions for reproducibility

**Readings:**
- [readr documentation](https://readr.tidyverse.org/articles/readr.html)
- [readxl: Cell and Column Types](https://readxl.tidyverse.org/articles/cell-and-column-types.html)
- [here package vignette](https://here.r-lib.org/)

**Exercise:**
- Import a provided messy CSV file with mixed types and missing values
- Clean column types
- Address NAs appropriately (remove, impute, or flag)
- Save the cleaned dataset with a descriptive filename

---

## Session 4: Debugging & Troubleshooting

**Learning Objectives:**
- Read and interpret error messages effectively
- Use debugging tools to isolate problems
- Develop systematic troubleshooting strategies

**Topics:**
- Common error types: syntax errors, object not found, type mismatches
- Reading stack traces and error messages
- Using `print()` for inspection
- Using `str()` for structure examination
- Using `View()` for data exploration
- `browser()` and `debug()` functions
- Reproducible examples with `reprex`
- Getting help: Stack Overflow, GitHub issues, documentation

**Readings:**
- [R for Data Science: Workflow scripts and projects](https://r4ds.hadley.nz/workflow-scripts.html)
- [Debugging with RStudio](https://support.posit.co/hc/en-us/articles/205612627-Debugging-with-RStudio)
- [reprex package](https://reprex.tidyverse.org/)

**Exercise:**
- Debug provided broken scripts with common errors
- Create a reproducible example of a problem
- Practice using `browser()` to step through code

---

## Session 5: Data Wrangling with dplyr

**Learning Objectives:**
- Transform and summarize data with core dplyr verbs
- Compose readable pipelines with `|>` or `%>%`
- Understand grouped vs ungrouped operations

**Topics:**
- `filter()` for row filtering
- `select()` for column selection
- `mutate()` for creating new variables
- `arrange()` for sorting
- `summarize()` for aggregation
- `group_by()` and grouped operations
- Pipe operator `|>` for readable workflows
- `count()` and `n()` for frequency tables
- Introduction to tidy data principles

**Readings:**
- [dplyr documentation](https://dplyr.tidyverse.org/)
- [R for Data Science: Data transformation](https://r4ds.hadley.nz/data-transform.html)
- [Data Transformation Cheatsheet](https://rstudio.github.io/cheatsheets/html/data-transformation.html)

**Exercise:**
- Load employee survey data
- Calculate mean satisfaction scores by department
- Filter for high-performing departments and sort by engagement
- Create new variables (e.g., tenure categories)

---

## Session 6: Tidy-Select & Column Operations

**Learning Objectives:**
- Select columns programmatically and at scale
- Apply functions across multiple columns efficiently
- Write maintainable code for repetitive operations

**Topics:**
- `starts_with()` helper
- `ends_with()` helper
- `contains()` helper
- `matches()` helper
- `where()` helper
- `across()` for applying functions to multiple columns
- `pick()` for selecting within data-masking functions
- Row-wise operations with `rowwise()`

**Readings:**
- [dplyr: Select Columns](https://dplyr.tidyverse.org/reference/dplyr_tidy_select.html)
- [dplyr: Column-wise Operations](https://dplyr.tidyverse.org/articles/colwise.html)
- [Tidy Style Guide: Syntax](https://style.tidyverse.org/syntax.html)

**Exercise:**
- Apply z-score transformation to all numeric columns in a dataset
- Calculate means across all Likert scale items (e.g., `starts_with("Q")`)
- Compare using `across()` vs `where(is.numeric)` for different scenarios

---

## Session 7: Visualization with ggplot2

**Learning Objectives:**
- Apply the grammar of graphics framework
- Produce clear, publication-quality plots
- Customize themes and scales for professional output

**Topics:**
- The layered grammar: data, aesthetics, geometries
- `geom_histogram()` for distributions
- `geom_point()` for scatterplots
- `geom_bar()` for bar charts
- `geom_boxplot()` for boxplots
- Aesthetics: color, size, shape, alpha
- Faceting with `facet_wrap()` and `facet_grid()`
- Themes and customization
- Saving plots with `ggsave()`

**Readings:**
- [ggplot2 documentation](https://ggplot2.tidyverse.org/)
- [R for Data Science: Data Visualization](https://r4ds.hadley.nz/data-visualize.html)
- [Data Visualization Cheatsheet](https://rstudio.github.io/cheatsheets/html/data-visualization.html)

**Exercise:**
- Create a scatterplot of two continuous variables with regression line
- Visualize distributions by group using boxplots or violin plots
- Build a faceted plot showing trends across departments
- Apply professional theme
- Export at publication resolution

---

## Session 8: Text Analysis with tidytext

**Learning Objectives:**
- Tokenize and clean unstructured text data
- Analyze word frequencies
- Compute basic sentiment scores

**Topics:**
- Tokenization basics with `unnest_tokens()`
- Removing stopwords
- Word frequency analysis and visualization
- Sentiment analysis using pre-built lexicons (AFINN, Bing)
- Aggregating sentiment scores

**Readings:**
- [tidytext: Tidy Text Mining](https://cran.r-project.org/web/packages/tidytext/vignettes/tidytext.html)
- [Text Mining with R: Chapter 1](https://www.tidytextmining.com/tidytext.html)
- [Text Mining with R: Sentiment Analysis](https://www.tidytextmining.com/sentiment.html)

**Exercise:**
- Tokenize open-ended employee survey comments
- Remove stopwords and identify most frequent words
- Compute sentiment scores using AFINN or Bing lexicon
- Visualize: bar plot of common words and sentiment trends by department

---

## Session 9: Advanced Text Analysis

**Learning Objectives:**
- Understand and apply TF-IDF for document importance
- Analyze n-grams and word relationships
- Examine word co-occurrence patterns

**Topics:**
- Term frequency-inverse document frequency (TF-IDF)
- Bigrams and n-grams: capturing phrases
- Word co-occurrence and correlation
- Visualizing word networks
- When to use TF-IDF vs raw frequency

**Readings:**
- [Text Mining with R: Chapter 3 - Relationships](https://www.tidytextmining.com/ngrams.html)
- [Text Mining with R: Chapter 4 - TF-IDF](https://www.tidytextmining.com/tfidf.html)
- [tidytext: n-grams](https://juliasilge.github.io/tidytext/articles/tidytext.html)

**Exercise:**
- Calculate TF-IDF scores for survey comments across departments
- Extract and analyze bigrams to find common phrases
- Create a word network showing term co-occurrence
- Compare insights from TF-IDF vs simple word counts

---

## Session 10: Correlation & Regression

**Learning Objectives:**
- Compute and interpret correlation coefficients
- Fit and interpret simple and multiple linear models
- Assess model fit and assumptions

**Topics:**
- Pearson correlation
- Spearman correlation
- Correlation matrices and visualization with `corrplot`
- `lm()` basics: formula syntax and interpretation
- Coefficients, standard errors, p-values, R²
- Tidy model outputs with `broom` package

**Readings:**
- [broom documentation](https://broom.tidymodels.org/)
- [R for Data Science: Model basics](https://r4ds.hadley.nz/model-basics.html)
- [Base R lm() documentation](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/lm.html)

**Exercise:**
- Compute correlation matrix for key organizational variables
- Fit simple linear regression predicting job satisfaction from engagement
- Extract tidy coefficients with `broom::tidy()`
- Visualize fitted values and residuals

---

## Session 11: Data Reshaping & Joins

**Learning Objectives:**
- Reshape data between wide and long formats
- Join datasets using relational keys
- Handle mismatched keys and duplicates

**Topics:**
- `pivot_longer()` for wide to long conversion
- `pivot_wider()` for long to wide conversion
- `left_join()` for keeping all left rows
- `inner_join()` for keeping only matching rows
- `full_join()` for keeping all rows
- `anti_join()` for identifying non-matches
- Handling duplicate keys and NA values in joins
- When to use each join type

**Readings:**
- [tidyr: Pivoting](https://tidyr.tidyverse.org/articles/pivot.html)
- [dplyr: Two-table verbs](https://dplyr.tidyverse.org/articles/two-table.html)
- [R for Data Science: Joins](https://r4ds.hadley.nz/joins.html)

**Exercise:**
- Convert wide survey data to long format for analysis
- Join employee performance data with demographic information
- Identify unmatched records using `anti_join()`
- Reshape aggregated results back to wide format for reporting

---

## Session 12: Cluster Analysis

**Learning Objectives:**
- Apply k-means clustering to group similar observations
- Determine optimal number of clusters
- Visualize and interpret cluster solutions

**Topics:**
- K-means algorithm: intuition and parameters
- Scaling and standardization (why it matters)
- Elbow method for choosing k
- Visualizing clusters in 2D
- Interpreting cluster characteristics

**Readings:**
- [UC Business Analytics: K-means Clustering](https://uc-r.github.io/kmeans_clustering)
- [factoextra package](https://rpkgs.datanovia.com/factoextra/)

**Exercise:**
- Cluster employees based on engagement survey dimensions
- Use elbow plot to determine optimal number of clusters
- Visualize clusters with scatter plots
- Profile each cluster: compute mean scores on key variables

---

## Session 13: Writing Custom Functions

**Learning Objectives:**
- Write reusable functions for repeated tasks
- Use proper argument handling and return values
- Apply basic error checking

**Topics:**
- Function syntax: arguments, body, return values
- Default arguments
- Using `...` for flexible arguments
- Scope: global vs local environments
- Simple input validation
- Documenting your functions
- When to write a function (DRY principle)

**Readings:**
- [R for Data Science: Functions](https://r4ds.hadley.nz/functions.html)
- [Advanced R: Functions](https://adv-r.hadley.nz/functions.html) (sections 6.1-6.4)

**Exercise:**
- Write a function to compute Cohen's d effect size
- Create a summary function that takes a data frame and computes mean/SD for numeric columns
- Add input validation to check for appropriate data types

---

## Session 14: Tidy Evaluation & Programming with dplyr

**Learning Objectives:**
- Write functions that accept tidyverse column names
- Use `{{ }}` (curly-curly) for embracing arguments
- Understand `.data` pronoun for programmatic selection

**Topics:**
- Data masking vs tidy selection
- Embracing with `{{ }}` for single column arguments
- `.data[[var]]` for string-based column selection
- Using tidy-select helpers inside custom functions
- Common patterns for flexible data functions

**Readings:**
- [Programming with dplyr](https://dplyr.tidyverse.org/articles/programming.html)
- [rlang: Tidy evaluation](https://rlang.r-lib.org/reference/topic-defuse.html)
- [Data masking programming patterns](https://rlang.r-lib.org/reference/topic-data-mask-programming.html)

**Exercise:**
- Write a summary function that accepts a grouping column with `{{ }}`
- Create a z-score function that works with tidy-select expressions
- Build a flexible filtering function using `.data` pronoun
- Combine tidy evaluation with `across()` for powerful abstractions

---

## Session 15: Iteration with purrr

**Learning Objectives:**
- Use `map()` functions to iterate over lists and vectors
- Apply functions to multiple columns or datasets
- Understand when iteration is better than vectorization

**Topics:**
- `map()` basics: applying a function to each element
- `map_dbl()` for numeric output
- `map_chr()` for character output
- `map_dfr()` for combining results into data frames
- Anonymous functions with `\(x)` or `~`
- `map2()` for iterating over two inputs
- Practical comparison: `map()` vs `across()`

**Readings:**
- [purrr documentation](https://purrr.tidyverse.org/)
- [R for Data Science: Iteration](https://r4ds.hadley.nz/iteration.html)

**Exercise:**
- Use `map()` to calculate correlation between variables across multiple departments
- Fit the same regression model to different subsets using `map()`
- Extract coefficients from multiple models with `map_dfr()`
- Compare performance of `map()` vs `across()` for column operations

---

## Session 16: Multiple Regression & Interactions

**Learning Objectives:**
- Build multiple regression models with several predictors
- Test and interpret interaction effects (moderation)
- Check for multicollinearity

**Topics:**
- Multiple regression: interpreting coefficients with multiple predictors
- Interaction terms: creating and interpreting
- Centering predictors for interpretable interactions
- Variance Inflation Factor (VIF) for multicollinearity
- Comparing nested models with `anova()`

**Readings:**
- [Interaction Effects in R](https://interactions.jacob-long.com/articles/interactions.html)
- [car package documentation](https://cran.r-project.org/web/packages/car/vignettes/embedding.pdf)
- [Understanding Interaction Effects](http://www.understandingdata.net/2017/03/24/creating-and-interpreting-interaction-variables-in-regression-models/)

**Exercise:**
- Predict job satisfaction from engagement, autonomy, and tenure
- Test moderation: Does department type moderate the engagement→satisfaction relationship?
- Calculate and interpret VIF values
- Visualize the interaction effect

---

## Session 17: Introduction to Machine Learning Workflows

**Learning Objectives:**
- Understand the machine learning workflow
- Split data for training and testing
- Create preprocessing recipes

**Topics:**
- ML concepts: training, testing, overfitting
- Train/test splits with `rsample::initial_split()`
- Creating recipes: steps for preprocessing
- Centering numeric variables
- Scaling numeric variables
- Creating dummy variables for categorical data
- The importance of data preprocessing
- Introduction to `workflows` package

**Readings:**
- [tidymodels: Get Started](https://www.tidymodels.org/start/recipes/)
- [rsample documentation](https://rsample.tidymodels.org/reference/initial_split.html)
- [recipes documentation](https://recipes.tidymodels.org/articles/recipes.html)

**Exercise:**
- Split employee turnover data (70/30 split)
- Create a recipe that normalizes numeric predictors and creates dummy variables
- Prep and bake the recipe to see transformed data
- Understand what each preprocessing step does

---

## Session 18: Fitting & Evaluating Classification Models

**Learning Objectives:**
- Fit a classification model using tidymodels
- Make predictions on new data
- Evaluate model performance with key metrics

**Topics:**
- Model specification with `parsnip` (logistic regression)
- Combining recipe and model into a workflow
- Fitting to training data
- Making predictions on test data
- Accuracy metric
- Confusion matrix
- ROC-AUC metric

**Readings:**
- [parsnip documentation](https://parsnip.tidymodels.org/articles/parsnip.html)
- [yardstick documentation](https://yardstick.tidymodels.org/articles/yardstick.html)
- [tidymodels: Build a Model](https://www.tidymodels.org/start/models/)

**Exercise:**
- Specify a logistic regression model to predict employee turnover
- Create and fit a complete workflow
- Generate predictions on test set
- Calculate accuracy
- Create confusion matrix
- Compute ROC-AUC
- Interpret which variables are most important

---

## Session 19: Scale Reliability & Factor Analysis

**Learning Objectives:**
- Assess internal consistency reliability
- Conduct exploratory factor analysis (EFA)
- Interpret factor loadings

**Topics:**
- Cronbach's alpha: calculation and interpretation
- Item-total correlations
- Reverse scoring items
- Exploratory Factor Analysis basics
- Scree plots and choosing number of factors
- Interpreting factor loadings

**Readings:**
- [psych package: Scale Construction](https://personality-project.org/r/psych/HowTo/psych_for_sem.pdf) (pages 1-15)
- [Quick-R: Factor Analysis](https://www.statmethods.net/advstats/factor.html)

**Exercise:**
- Compute Cronbach's alpha for an engagement scale
- Check item-total correlations to identify problematic items
- Conduct EFA on multi-item survey
- Interpret factor structure: which items load on which factors?
- Compute scale scores based on factor structure

---

## Session 20: Survey Data Management & Visualization

**Learning Objectives:**
- Apply systematic data cleaning for survey research
- Visualize Likert scale data effectively
- Create professional stakeholder-ready visualizations

**Topics:**
- Survey data cleaning workflows: reverse coding, scale computation
- Handling incomplete responses
- Diverging stacked bars for Likert data
- Density ridges for distributions
- Heatmaps for departmental comparisons
- Color schemes for accessibility

**Readings:**
- [likert package](https://github.com/jbryer/likert)
- [ggplot2 extensions for surveys](https://exts.ggplot2.tidyverse.org/gallery/)
- [Visualizing Likert Data](https://www.r-bloggers.com/2016/10/visualizing-likert-scale-data-with-r/)

**Exercise:**
- Clean and score multi-item Likert scales
- Create diverging stacked bar chart for agreement items
- Build engagement heatmap showing scores by department and dimension
- Export publication-ready visualizations

---

## Session 21: Reproducible Reporting with R Markdown

**Learning Objectives:**
- Create reproducible reports with R Markdown
- Integrate code, output, and narrative
- Render to multiple formats

**Topics:**
- R Markdown anatomy: YAML header, markdown text, code chunks
- Chunk options: echo, eval, message, warning
- Inline code for dynamic text
- Rendering to HTML
- Rendering to Word
- Brief intro to Quarto (next-generation R Markdown)
- Tips for reproducibility: relative paths, `here` package, session info

**Readings:**
- [R Markdown: The Definitive Guide](https://bookdown.org/yihui/rmarkdown/) (Chapters 1-2)
- [R Markdown Cheatsheet](https://rstudio.github.io/cheatsheets/html/rmarkdown.html)
- [Quarto documentation](https://quarto.org/docs/get-started/hello/rstudio.html) (optional overview)

**Exercise:**
- Create an R Markdown report combining analysis from previous sessions
- Include dynamic tables with `knitr::kable()` or `gt` package
- Add plots
- Add inline statistics (e.g., "the mean was `r mean(x)`")
- Render to HTML format
- Render to Word format
- Include `sessionInfo()` for package versions

---

## Session 22: Version Control & Package Management

**Learning Objectives:**
- Use Git for version control and collaboration
- Manage package dependencies with renv
- Create parameterized reports for repeated analyses

**Topics:**
- Git basics: init, add, commit, status, log
- Branching and merging concepts
- GitHub for collaboration and backup
- `renv` for reproducible package environments
- Parameterized R Markdown reports
- `.gitignore` for sensitive data

**Readings:**
- [Happy Git with R](https://happygitwithr.com/) (Chapters 1-15)
- [renv: Project Environments](https://rstudio.github.io/renv/articles/renv.html)
- [Parameterized Reports](https://bookdown.org/yihui/rmarkdown/parameterized-reports.html)

**Exercise:**
- Initialize a Git repository for an analysis project
- Make commits documenting your workflow
- Initialize `renv` and snapshot package versions
- Create a parameterized report that runs with different date ranges
- Push your project to GitHub

---

## Session 23: Interactive Dashboards with flexdashboard

**Learning Objectives:**
- Build static dashboards with flexdashboard
- Add basic interactivity with Shiny
- Understand deployment options

**Topics:**
- flexdashboard layout: rows, columns, tabsets
- Value boxes for KPIs
- Embedding ggplot2 plots
- Embedding tables
- Adding basic Shiny inputs (dropdown, slider)
- Making plots reactive to user input
- Deployment basics: shinyapps.io

**Readings:**
- [flexdashboard documentation](https://pkgs.rstudio.com/flexdashboard/)
- [flexdashboard with Shiny](https://pkgs.rstudio.com/flexdashboard/articles/shiny.html)
- [Shiny basics](https://shiny.posit.co/r/getstarted/shiny-basics/lesson1/index.html) (brief overview)

**Exercise:**
- Create a flexdashboard with HR KPIs: headcount, turnover rate, avg satisfaction
- Add engagement trend plot
- Add summary table
- Make dashboard interactive: add dropdown to filter by department
- Deploy to shinyapps.io (free tier)
- Discuss data security considerations for sensitive HR data

---

## Course Resources

**Essential References:**
- [R for Data Science (2e)](https://r4ds.hadley.nz/) - Primary textbook
- [Tidyverse Style Guide](https://style.tidyverse.org/) - Code conventions
- [RStudio Cheatsheets](https://posit.co/resources/cheatsheets/) - Quick references
- [Advanced R](https://adv-r.hadley.nz/) - For deeper programming concepts

**Getting Help:**
- [RStudio Community](https://community.rstudio.com/)
- [Stack Overflow - R tag](https://stackoverflow.com/questions/tagged/r)
- [R4DS Online Learning Community](https://rfordatasci.com/)

**Additional Tools:**
- [here package](https://here.r-lib.org/) - Project-relative paths
- [janitor package](https://sfirke.github.io/janitor/) - Data cleaning helpers
- [gt package](https://gt.rstudio.com/) - Publication-quality tables

---

## Notes on Pacing

This 23-session course is designed for **1-hour teaching sessions** followed by student practice/homework. Key design principles:

- **Sessions 1-4**: Foundations and essential troubleshooting (build confidence early)
- **Sessions 5-11**: Core tidyverse workflows for daily analysis
- **Sessions 12-15**: Programming skills and iteration (efficiency and automation)
- **Sessions 16-20**: Domain-specific applications (organizational research methods)
- **Sessions 21-23**: Communication, version control, and stakeholder deliverables

**Time management tips:**
- Each session covers **one main concept** deeply rather than multiple concepts superficially
- Exercises are designed for ~30-45 minutes of student work
- Advanced topics mentioned but not fully covered to maintain realistic scope
- Readings provide depth for students who want to explore further

**Homework expectations:**
- ~2 hours per week: completing exercises, reading documentation, experimenting with personal data
- Cumulative project suggestion: Students work with one dataset throughout, applying each week's techniques progressively