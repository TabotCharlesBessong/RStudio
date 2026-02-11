
library(dplyr)
library(ggplot2)

# loading the dataset
data_path <- file.path("..","DATA", "HR Employee Attrition.csv")
employee_data <- read.csv(data_path, stringsAsFactors = FALSE)
# Display the structure of the dataset
# str(employee_data)
# dataset dimensions
cat("Employee dataset loaded successfully!\n")
cat("Dataset dimensions: ", dim(employee_data), "\n")
cat("Number of rows: ", nrow(employee_data), "\n")
cat("Number of columns: ", ncol(employee_data), "\n")

# Display the first few rows of the dataset
cat("\nFirst 5 rows of the dataset:\n")
print(head(employee_data, 5))

# PART 1 DATA WAREHOUSE DESIGN

cat("\n=== PART 1: DATA WAREHOUSE DESIGN ===\n")

# TIME DIMENSION TABLE CREATION
cat("\nCreating Time Dimension Table...\n")

time_dim <- data.frame(
  TimeID = 1:12,
  Month = 1:12,
  Quarter = c(rep("Q1", 3), rep("Q2", 3), rep("Q3", 3), rep("Q4", 3)),
  Year = 2025,
  MonthName = month.name[1:12],

  # Prevent automatic conversion to factors
  stringsAsFactors = FALSE
)

print("Time Dimension Table:")
print(time_dim)
cat("\n")

# EMPLOYEE DIMENSION TABLE CREATION
cat("Creating Employee Dimension Table...\n")
employee_dim <- employee_data %>%
  select(
    EmployeeNumber,
    Age,
    Gender,
    MaritalStatus,
    DistanceFromHome,
    NumCompaniesWorked,
    TotalWorkingYears,
    YearsAtCompany,
    YearsSinceLastPromotion,
    YearsWithCurrManager
  ) %>%
  # remove duplicate employee records to ensure dimension table integrity
  distinct() %>%
  # Add surrogate key for Employee Dimension
  mutate(EmployeeID = row_number()) %>%
  # Reorder columns to put surrogate key first
  select(EmployeeID, everything())

print("Employee Dimension Table:")
print(head(employee_dim, 5))
cat("Total number of employees: ", nrow(employee_dim), "\n")

# Education Dimension Table Creation
cat("\nCreating Education Dimension Table...\n")

education_dim <- employee_data %>%
  # extract unique education levels and their descriptions
  select(Education, EducationField) %>%
  # Ensue unique comnbinations only
  distinct() %>%
  # sort for consistency
  arrange(Education, EducationField) %>%
  # Add surrogate key for Education Dimension
  mutate(EducationID = row_number()) %>%
  # Reorder columns to put surrogate key first
  select(EducationID, Education, EducationField)

print("Education Dimension Table:")
print(head(education_dim, 5))
cat("Total number of unique education levels: ", nrow(education_dim), "\n")

# DEPARTMENT DIMENSION TABLE CREATION
cat("\nCreating Department Dimension Table...\n")
department_dim <- employee_data %>%
  # Select organizational attributes relevant to department analysis
  select(Department, JobRole) %>%
  # Ensure unique combinations of department and job role
  distinct() %>%
  # Sort for consistency
  arrange(Department, JobRole) %>%
  # Add surrogate key for Department Dimension
  mutate(DepartmentID = row_number()) %>%
  # Reorder columns to put surrogate key first
  select(DepartmentID, Department, JobRole)

print("Department Dimension Table:")
print(head(department_dim, 5))
cat("Total number of unique department-job role combinations: ", nrow(department_dim), "\n")