# R Script Guide for Python Developers
## HR Employee Attrition Data Analysis - R vs Python Comparison

This guide explains the R script step by step, with Python equivalents to help you understand the differences and similarities between the two languages.

---

## Table of Contents
1. [Package Management](#package-management)
2. [Data Loading](#data-loading)
3. [Basic Data Exploration](#basic-data-exploration)
4. [Data Quality Analysis](#data-quality-analysis)
5. [Variable Type Analysis](#variable-type-analysis)
6. [Statistical Analysis](#statistical-analysis)
7. [Correlation Analysis](#correlation-analysis)
8. [Data Visualization](#data-visualization)
9. [Key R vs Python Differences](#key-r-vs-python-differences)

---

## Package Management

### R Code:
```r
# Function to install and load packages
install_and_load <- function(packages) {
  for (package in packages) {
    if (!require(package, character.only = TRUE, quietly = TRUE)) {
      cat(paste("Installing package:", package, "\n"))
      install.packages(package, dependencies = TRUE, repos = "https://cran.rstudio.com/")
      library(package, character.only = TRUE)
    }
  }
}

required_packages <- c("ggplot2", "dplyr", "corrplot")
install_and_load(required_packages)
```

### Python Equivalent:
```python
import subprocess
import sys

def install_and_import(packages):
    for package in packages:
        try:
            __import__(package)
        except ImportError:
            print(f"Installing package: {package}")
            subprocess.check_call([sys.executable, "-m", "pip", "install", package])

required_packages = ["pandas", "matplotlib", "seaborn", "numpy"]
install_and_import(required_packages)

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
```

### Key Differences:
- **R**: Uses `require()` and `library()` functions
- **Python**: Uses `import` statements
- **R**: `install.packages()` for installation
- **Python**: `pip install` through subprocess

---

## Data Loading

### R Code:
```r
data_path <- file.path("..", "DATA", "HR Employee Attrition.csv")
hr_data <- read.csv(data_path, stringsAsFactors = FALSE)
```

### Python Equivalent:
```python
import os
data_path = os.path.join("..", "DATA", "HR Employee Attrition.csv")
hr_data = pd.read_csv(data_path)
```

### Key Differences:
- **R**: `file.path()` for path construction, `read.csv()`
- **Python**: `os.path.join()` for paths, `pd.read_csv()`
- **R**: `stringsAsFactors = FALSE` prevents automatic string-to-factor conversion
- **Python**: Pandas automatically handles data types

---

## Basic Data Exploration

### R Code:
```r
# Dataset dimensions
print(paste("Dataset dimensions:", nrow(hr_data), "rows,", ncol(hr_data), "columns"))

# First few rows
print(head(hr_data))

# Data structure
str(hr_data)

# Summary statistics
summary(hr_data)
```

### Python Equivalent:
```python
# Dataset dimensions
print(f"Dataset dimensions: {hr_data.shape[0]} rows, {hr_data.shape[1]} columns")

# First few rows
print(hr_data.head())

# Data structure
print(hr_data.info())

# Summary statistics
print(hr_data.describe())
```

### Key Differences:
- **R**: `nrow()`, `ncol()` for dimensions
- **Python**: `.shape` attribute
- **R**: `paste()` for string concatenation
- **Python**: f-strings or `.format()`
- **R**: `str()` shows structure, `summary()` for statistics
- **Python**: `.info()` for structure, `.describe()` for statistics

---

## Data Quality Analysis

### R Code:
```r
# Missing values
missing_values <- sapply(hr_data, function(x) sum(is.na(x)))
print(missing_values[missing_values > 0])

# Duplicates
duplicate_count <- sum(duplicated(hr_data))
print(paste("Number of duplicate rows:", duplicate_count))
```

### Python Equivalent:
```python
# Missing values
missing_values = hr_data.isnull().sum()
print(missing_values[missing_values > 0])

# Duplicates
duplicate_count = hr_data.duplicated().sum()
print(f"Number of duplicate rows: {duplicate_count}")
```

### Key Differences:
- **R**: `sapply()` with `is.na()` for missing values
- **Python**: `.isnull().sum()` method
- **R**: `duplicated()` function
- **Python**: `.duplicated().sum()` method
- **R**: Uses functions more than methods
- **Python**: Uses object methods more than functions

---

## Variable Type Analysis

### R Code:
```r
# Identify numerical variables
numerical_vars <- names(hr_data)[sapply(hr_data, function(x) is.numeric(x) && !is.factor(x))]

# Identify categorical variables
categorical_vars <- names(hr_data)[sapply(hr_data, function(x) is.character(x) || is.factor(x))]

# Data types
data_types <- sapply(hr_data, class)
```

### Python Equivalent:
```python
# Identify numerical variables
numerical_vars = hr_data.select_dtypes(include=[np.number]).columns.tolist()

# Identify categorical variables
categorical_vars = hr_data.select_dtypes(include=['object', 'category']).columns.tolist()

# Data types
data_types = hr_data.dtypes
```

### Key Differences:
- **R**: `sapply()` with custom functions to filter columns
- **Python**: `.select_dtypes()` method is more direct
- **R**: `is.numeric()`, `is.character()`, `is.factor()` for type checking
- **Python**: Uses NumPy data types like `np.number`, `'object'`

---

## Statistical Analysis

### R Code:
```r
# Standard deviation with error handling
std_devs <- c()
for(var in numerical_vars) {
  tryCatch({
    std_dev <- sd(hr_data[[var]], na.rm = TRUE)
    std_devs[var] <- std_dev
  }, error = function(e) {
    std_devs[var] <- NA
  })
}

# Variance
variances <- c()
for(var in numerical_vars) {
  tryCatch({
    variance <- var(hr_data[[var]], na.rm = TRUE)
    variances[var] <- variance
  }, error = function(e) {
    variances[var] <- NA
  })
}
```

### Python Equivalent:
```python
# Standard deviation
try:
    std_devs = hr_data[numerical_vars].std()
except Exception as e:
    print(f"Error calculating standard deviation: {e}")
    std_devs = {}

# Variance
try:
    variances = hr_data[numerical_vars].var()
except Exception as e:
    print(f"Error calculating variance: {e}")
    variances = {}
```

### Key Differences:
- **R**: `sd()` and `var()` functions, `na.rm = TRUE` to ignore NA values
- **Python**: `.std()` and `.var()` methods, automatically handles NaN
- **R**: `tryCatch()` for error handling
- **Python**: `try/except` blocks
- **R**: Manual loops often needed
- **Python**: Vectorized operations more common

---

## Correlation Analysis

### R Code:
```r
# Correlation matrix
cor_matrix <- cor(hr_data[cor_vars], use = "complete.obs")

# Correlation plot
if(require(corrplot, quietly = TRUE)) {
  corrplot(cor_matrix, method = "color", type = "upper", 
           order = "hclust", tl.cex = 0.8, tl.col = "black")
}
```

### Python Equivalent:
```python
# Correlation matrix
cor_matrix = hr_data[numerical_vars].corr()

# Correlation plot
import seaborn as sns
import matplotlib.pyplot as plt

plt.figure(figsize=(10, 8))
sns.heatmap(cor_matrix, annot=True, cmap='coolwarm', center=0)
plt.show()
```

### Key Differences:
- **R**: `cor()` function with `use = "complete.obs"`
- **Python**: `.corr()` method
- **R**: `corrplot` package for visualization
- **Python**: `seaborn.heatmap()` for correlation plots
- **R**: More granular control over plot parameters
- **Python**: Often more concise visualization code

---

## Data Visualization

### R Code:
```r
# Histograms
for(i in 1:min(4, length(numerical_vars))) {
  var <- numerical_vars[i]
  hist(hr_data[[var]], main = paste("Distribution of", var), 
       xlab = var, col = "skyblue", border = "black")
}

# Bar plots
for(i in 1:min(3, length(categorical_vars))) {
  var <- categorical_vars[i]
  barplot(table(hr_data[[var]]), main = paste("Distribution of", var), 
          xlab = var, col = "lightcoral")
}
```

### Python Equivalent:
```python
# Histograms
fig, axes = plt.subplots(2, 2, figsize=(12, 8))
axes = axes.ravel()

for i, var in enumerate(numerical_vars[:4]):
    hr_data[var].hist(ax=axes[i], bins=20, color='skyblue', edgecolor='black')
    axes[i].set_title(f'Distribution of {var}')
    axes[i].set_xlabel(var)

plt.tight_layout()
plt.show()

# Bar plots
for var in categorical_vars[:3]:
    plt.figure(figsize=(8, 6))
    hr_data[var].value_counts().plot(kind='bar', color='lightcoral')
    plt.title(f'Distribution of {var}')
    plt.xlabel(var)
    plt.xticks(rotation=45)
    plt.show()
```

### Key Differences:
- **R**: `hist()`, `barplot(table())` for plots
- **Python**: `.hist()`, `.value_counts().plot(kind='bar')` methods
- **R**: `par(mfrow = c(2, 2))` for subplots
- **Python**: `plt.subplots()` for subplot management
- **R**: Base R plotting vs ggplot2
- **Python**: Matplotlib/Seaborn ecosystem

---

## Key R vs Python Differences

### Syntax Differences

| Aspect | R | Python |
|--------|---|--------|
| **Assignment** | `<-` or `=` | `=` |
| **String concatenation** | `paste()` | f-strings or `+` |
| **Array/List indexing** | 1-based `[1]` | 0-based `[0]` |
| **Column selection** | `df$column` or `df[["column"]]` | `df['column']` |
| **Missing values** | `NA` | `NaN` or `None` |
| **Logical operators** | `&` and `|` | `and` and `or` |

### Functional vs Object-Oriented

**R (Functional approach):**
```r
# Functions operate on objects
result <- function_name(data, parameters)
summary(hr_data)
cor(hr_data[numerical_vars])
```

**Python (Object-oriented approach):**
```python
# Methods called on objects
result = data.method_name(parameters)
hr_data.describe()
hr_data[numerical_vars].corr()
```

### Package Management

**R:**
- **CRAN**: Central repository
- **install.packages()**: Installation
- **library()**: Loading packages

**Python:**
- **PyPI**: Main repository
- **pip install**: Installation
- **import**: Loading modules

### Data Structures

**R:**
- **data.frame**: Main tabular structure
- **Vectors**: Basic data structure
- **Lists**: Heterogeneous collections

**Python (Pandas):**
- **DataFrame**: Main tabular structure
- **Series**: Column structure
- **Lists/Arrays**: Basic collections

---

## Tips for Python Developers Learning R

1. **Embrace the functional style**: R is more functional than object-oriented
2. **Use RStudio**: Similar to Jupyter notebooks but for R
3. **Learn the apply family**: `sapply()`, `lapply()`, `apply()` are powerful
4. **Understand data.frame**: Similar to pandas DataFrame but with differences
5. **Use dplyr**: Makes data manipulation more Python-like
6. **ggplot2**: Powerful plotting library (similar to matplotlib/seaborn)

---

## Common Gotchas for Python Developers

1. **1-based indexing**: R starts counting from 1, not 0
2. **Assignment operator**: `<-` is preferred over `=`
3. **String operations**: Different functions than Python
4. **Factor variables**: Categorical data behaves differently
5. **Namespace**: Functions from different packages can conflict

---

## Conclusion

This R script performs comprehensive exploratory data analysis similar to what you'd do with pandas, matplotlib, and seaborn in Python. The main differences are:

- **R is more functional**, Python is more object-oriented
- **R has excellent built-in statistics functions**
- **R excels at statistical analysis and data visualization**
- **Python might be more intuitive for general programming**

Both languages are powerful for data analysis - choose based on your needs and team preferences!