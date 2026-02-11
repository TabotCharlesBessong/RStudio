
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

# FACT TABLE CREATION
cat("\nCreating Fact Table...\n")

fact_table <- employee_data %>%
  # Dimension integration: Join with Employee Dimension to get EmployeeID
  left_join(employee_dim %>% select(EmployeeID, EmployeeNumber), by = "EmployeeNumber") %>%
  # Join with Education Dimension to get EducationID
  left_join(education_dim %>% select(EducationID, Education, EducationField), 
            by = c("Education", "EducationField")) %>%
  # Join with Department Dimension to get DepartmentID
  left_join(department_dim %>% select(DepartmentID, Department, JobRole), 
            by = c("Department", "JobRole")) %>%
  # Simulate temporal distribution for demonstration purposes
  mutate(TimeID = sample(1:12,nrow(employee_data), replace = TRUE)) %>%
  # CORE MEASUREMENT SELECTION
  # Select foreign keys and business metrics relevant to attrition analysis
  select(
    EmployeeID, TimeID, EducationID, DepartmentID,
    
    MonthlyIncome, HourlyRate, DailyRate, MonthlyRate,
    PercentSalaryHike, StockOptionLevel,
    
    WorkLifeBalance, JobSatisfaction, EnvironmentSatisfaction, 
    JobInvolvement, PerformanceRating, RelationshipSatisfaction,
    
    # WORKING LOAD INDICATORS (Stress and Workload Metrics)
    OverTime, BusinessTravel, TrainingTimesLastYear
  ) %>%

  # CALCULATED MEASURE DEVELOPMENT
  # Create composite metrics for enhanced analysis
  mutate(
    # WORKING LOAD SCORE - Composite stress indicator
    # Formula: (Overtime weight + Job involvement + Work-life balance + Inverted satisfaction) / 4
    WorkingLoadScore = (
      as.numeric(OverTime == "Yes") * 2 + JobInvolvement + WorkLifeBalance + (5 - JobSatisfaction)
    ) / 4,

    TotalCompensation = MonthlyIncome + HourlyRate * 160 + DailyRate * 20
  ) %>%

  mutate(FactID = row_number()) %>%
  select(FactID, everything())


print("Fact Table:")
print(head(fact_table, 5))
cat("Total number of fact records: ", nrow(fact_table), "\n")