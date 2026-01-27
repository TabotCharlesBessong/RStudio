# HR Employee Attrition Data Analysis
# Complete exploratory data analysis script

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

# List of required packages
required_packages <- c("ggplot2", "dplyr", "corrplot")

# Install and load required packages
cat("=== INSTALLING AND LOADING REQUIRED PACKAGES ===\n")
install_and_load(required_packages)

# Set working directory and read the data
# Read the CSV file from the DATA directory
data_path <- file.path("..", "DATA", "HR Employee Attrition.csv")
hr_data <- read.csv(data_path, stringsAsFactors = FALSE)

# ==============================
# 1. BASIC DATA EXPLORATION
# ==============================

cat("=== DATASET OVERVIEW ===\n")
print(paste("Dataset dimensions:", nrow(hr_data), "rows,", ncol(hr_data), "columns"))
cat("\n")

# Display first few rows
cat("=== FIRST 6 ROWS ===\n")
print(head(hr_data))
cat("\n")

# Display last few rows
cat("=== LAST 6 ROWS ===\n")
print(tail(hr_data))
cat("\n")

# Data structure
cat("=== DATA STRUCTURE ===\n")
str(hr_data)
cat("\n")

# Column names
cat("=== COLUMN NAMES ===\n")
print(colnames(hr_data))
cat("\n")

# Summary statistics
cat("=== SUMMARY STATISTICS ===\n")
print(summary(hr_data))
cat("\n")

# ==============================
# 2. DATA QUALITY ANALYSIS
# ==============================

cat("=== DATA QUALITY ANALYSIS ===\n")

# Check for missing values
missing_values <- sapply(hr_data, function(x) sum(is.na(x)))
cat("Missing values per column:\n")
print(missing_values[missing_values > 0])

if(sum(missing_values) == 0) {
  cat("No missing values found in the dataset!\n")
}
cat("\n")

# Check for duplicates
duplicate_count <- sum(duplicated(hr_data))
cat(paste("Number of duplicate rows:", duplicate_count), "\n\n")

# Data types
cat("=== DATA TYPES ===\n")
data_types <- sapply(hr_data, class)
print(data_types)
cat("\n")

# Detailed inspection of each column
cat("=== DETAILED COLUMN INSPECTION ===\n")
for(col in names(hr_data)) {
  cat(paste("Column:", col))
  cat(paste(" | Type:", class(hr_data[[col]])))
  cat(paste(" | Unique values:", length(unique(hr_data[[col]]))))
  if(is.numeric(hr_data[[col]])) {
    cat(" | NUMERIC")
  } else {
    cat(" | NON-NUMERIC")
  }
  cat("\n")
}
cat("\n")

# ==============================
# 3. CATEGORICAL VARIABLES ANALYSIS
# ==============================

cat("=== CATEGORICAL VARIABLES ANALYSIS ===\n")

# Identify categorical variables
categorical_vars <- names(hr_data)[sapply(hr_data, function(x) is.character(x) || is.factor(x))]
cat("Categorical variables:", paste(categorical_vars, collapse = ", "), "\n\n")

# Frequency tables for categorical variables
for(var in categorical_vars) {
  cat(paste("=== Frequency table for", var, "===\n"))
  freq_table <- table(hr_data[[var]])
  print(freq_table)
  cat(paste("Unique values:", length(unique(hr_data[[var]])), "\n\n"))
}

# ==============================
# 4. NUMERICAL VARIABLES ANALYSIS
# ==============================

cat("=== NUMERICAL VARIABLES ANALYSIS ===\n")

# Identify numerical variables (more robust detection)
numerical_vars <- names(hr_data)[sapply(hr_data, function(x) is.numeric(x) && !is.factor(x))]

# Remove any variables that might cause issues
problematic_vars <- c()
for(var in numerical_vars) {
  # Check if variable contains only finite numbers
  if(all(is.na(hr_data[[var]])) || !is.numeric(hr_data[[var]])) {
    problematic_vars <- c(problematic_vars, var)
  }
}

# Remove problematic variables
if(length(problematic_vars) > 0) {
  numerical_vars <- numerical_vars[!numerical_vars %in% problematic_vars]
  cat("Removed problematic variables:", paste(problematic_vars, collapse = ", "), "\n")
}

cat("Numerical variables:", paste(numerical_vars, collapse = ", "), "\n\n")

# Descriptive statistics for numerical variables
if(length(numerical_vars) > 0) {
  cat("=== DESCRIPTIVE STATISTICS FOR NUMERICAL VARIABLES ===\n")
  print(summary(hr_data[numerical_vars]))
  cat("\n")
  
  # Standard deviation with error handling
  cat("=== STANDARD DEVIATIONS ===\n")
  std_devs <- c()
  for(var in numerical_vars) {
    tryCatch({
      std_dev <- sd(hr_data[[var]], na.rm = TRUE)
      std_devs[var] <- std_dev
    }, error = function(e) {
      cat(paste("Error calculating SD for", var, ":", e$message, "\n"))
      std_devs[var] <- NA
    })
  }
  print(std_devs)
  cat("\n")
  
  # Variance with error handling
  cat("=== VARIANCES ===\n")
  variances <- c()
  for(var in numerical_vars) {
    tryCatch({
      variance <- var(hr_data[[var]], na.rm = TRUE)
      variances[var] <- variance
    }, error = function(e) {
      cat(paste("Error calculating variance for", var, ":", e$message, "\n"))
      variances[var] <- NA
    })
  }
  print(variances)
  cat("\n")
}

# ==============================
# 5. CORRELATION ANALYSIS
# ==============================

# ==============================
# 5. CORRELATION ANALYSIS
# ==============================

if(length(numerical_vars) > 1) {
  cat("=== CORRELATION ANALYSIS ===\n")
  
  # Filter numerical variables for correlation (only truly numeric)
  cor_vars <- c()
  for(var in numerical_vars) {
    if(is.numeric(hr_data[[var]]) && !all(is.na(hr_data[[var]]))) {
      cor_vars <- c(cor_vars, var)
    }
  }
  
  if(length(cor_vars) > 1) {
    # Correlation matrix with error handling
    tryCatch({
      cor_matrix <- cor(hr_data[cor_vars], use = "complete.obs")
      print(round(cor_matrix, 3))
      cat("\n")
      
      # Plot correlation matrix if corrplot is available
      if(require(corrplot, quietly = TRUE)) {
        cat("Creating correlation plot...\n")
        corrplot(cor_matrix, method = "color", type = "upper", 
                 order = "hclust", tl.cex = 0.8, tl.col = "black")
      }
    }, error = function(e) {
      cat(paste("Error in correlation analysis:", e$message, "\n"))
      cat("Skipping correlation matrix\n\n")
    })
  } else {
    cat("Not enough numeric variables for correlation analysis\n\n")
  }
} else {
  cat("=== CORRELATION ANALYSIS ===\n")
  cat("Not enough numeric variables for correlation analysis\n\n")
}

# ==============================
# 6. DATA VISUALIZATION
# ==============================

cat("=== CREATING VISUALIZATIONS ===\n")

# Set up plotting parameters
par(mfrow = c(2, 2))

# Histograms for numerical variables
if(length(numerical_vars) > 0) {
  for(i in 1:min(4, length(numerical_vars))) {
    var <- numerical_vars[i]
    hist(hr_data[[var]], main = paste("Distribution of", var), 
         xlab = var, col = "skyblue", border = "black")
  }
}

# Reset plotting parameters
par(mfrow = c(1, 1))

# Bar plots for categorical variables (first few)
if(length(categorical_vars) > 0) {
  for(i in 1:min(3, length(categorical_vars))) {
    var <- categorical_vars[i]
    if(length(unique(hr_data[[var]])) <= 10) {  # Only plot if not too many categories
      barplot(table(hr_data[[var]]), main = paste("Distribution of", var), 
              xlab = var, col = "lightcoral", las = 2)
    }
  }
}

# ==============================
# 7. OUTLIER DETECTION
# ==============================

if(length(numerical_vars) > 0) {
  cat("=== OUTLIER DETECTION ===\n")
  
  for(var in numerical_vars) {
    # Calculate IQR
    Q1 <- quantile(hr_data[[var]], 0.25, na.rm = TRUE)
    Q3 <- quantile(hr_data[[var]], 0.75, na.rm = TRUE)
    IQR <- Q3 - Q1
    
    # Define outlier bounds
    lower_bound <- Q1 - 1.5 * IQR
    upper_bound <- Q3 + 1.5 * IQR
    
    # Find outliers
    outliers <- hr_data[[var]][hr_data[[var]] < lower_bound | hr_data[[var]] > upper_bound]
    outliers <- outliers[!is.na(outliers)]
    
    cat(paste("Variable:", var, "\n"))
    cat(paste("  Number of outliers:", length(outliers), "\n"))
    if(length(outliers) > 0 && length(outliers) <= 10) {
      cat(paste("  Outlier values:", paste(outliers, collapse = ", "), "\n"))
    }
    cat("\n")
  }
  
  # Box plots for outlier visualization
  if(length(numerical_vars) <= 6) {
    par(mfrow = c(2, 3))
    for(var in numerical_vars) {
      boxplot(hr_data[[var]], main = paste("Boxplot of", var), col = "lightgreen")
    }
    par(mfrow = c(1, 1))
  }
}

# ==============================
# 8. SUMMARY REPORT
# ==============================

cat("\n=== FINAL SUMMARY REPORT ===\n")
cat(paste("Dataset:", "HR Employee Attrition"), "\n")
cat(paste("Total records:", nrow(hr_data)), "\n")
cat(paste("Total variables:", ncol(hr_data)), "\n")
cat(paste("Categorical variables:", length(categorical_vars)), "\n")
cat(paste("Numerical variables:", length(numerical_vars)), "\n")
cat(paste("Missing values:", sum(missing_values)), "\n")
cat(paste("Duplicate rows:", duplicate_count), "\n")

if(length(numerical_vars) > 0) {
  cat("\nNumerical variables summary:\n")
  for(var in numerical_vars) {
    cat(paste("- ", var, ": Mean =", round(mean(hr_data[[var]], na.rm = TRUE), 2), 
              ", SD =", round(sd(hr_data[[var]], na.rm = TRUE), 2)), "\n")
  }
}

cat("\nExploratory Data Analysis completed successfully!\n")
cat("Check the plots and statistics above for detailed insights.\n")