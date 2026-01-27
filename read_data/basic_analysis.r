# HR Employee Attrition Data Analysis - Base R Version
# No external packages required

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

# Data structure
cat("=== DATA STRUCTURE ===\n")
str(hr_data)
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

# ==============================
# 3. BASIC ANALYSIS
# ==============================

# Identify numerical and categorical variables
numerical_vars <- names(hr_data)[sapply(hr_data, is.numeric)]
categorical_vars <- names(hr_data)[sapply(hr_data, function(x) is.character(x) || is.factor(x))]

cat("=== VARIABLE TYPES ===\n")
cat("Numerical variables:", paste(numerical_vars, collapse = ", "), "\n")
cat("Categorical variables:", paste(categorical_vars, collapse = ", "), "\n\n")

# Frequency tables for categorical variables (first 3)
cat("=== CATEGORICAL VARIABLES ANALYSIS ===\n")
for(i in 1:min(3, length(categorical_vars))) {
  var <- categorical_vars[i]
  cat(paste("=== Frequency table for", var, "===\n"))
  freq_table <- table(hr_data[[var]])
  print(freq_table)
  cat("\n")
}

# Basic plots using base R
if(length(numerical_vars) > 0) {
  cat("=== CREATING BASIC VISUALIZATIONS ===\n")
  
  # Set up plotting
  par(mfrow = c(2, 2))
  
  # Histograms for first 4 numerical variables
  for(i in 1:min(4, length(numerical_vars))) {
    var <- numerical_vars[i]
    hist(hr_data[[var]], main = paste("Distribution of", var), 
         xlab = var, col = "skyblue", border = "black")
  }
  
  # Reset plotting parameters
  par(mfrow = c(1, 1))
  
  # Correlation matrix
  if(length(numerical_vars) > 1) {
    cat("\n=== CORRELATION MATRIX ===\n")
    cor_matrix <- cor(hr_data[numerical_vars], use = "complete.obs")
    print(round(cor_matrix, 3))
  }
}

# ==============================
# 4. SUMMARY REPORT
# ==============================

cat("\n=== FINAL SUMMARY REPORT ===\n")
cat(paste("Dataset:", "HR Employee Attrition"), "\n")
cat(paste("Total records:", nrow(hr_data)), "\n")
cat(paste("Total variables:", ncol(hr_data)), "\n")
cat(paste("Categorical variables:", length(categorical_vars)), "\n")
cat(paste("Numerical variables:", length(numerical_vars)), "\n")
cat(paste("Missing values:", sum(missing_values)), "\n")
cat(paste("Duplicate rows:", duplicate_count), "\n")

cat("\nBasic Exploratory Data Analysis completed successfully!\n")