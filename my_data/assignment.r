
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

# DATA CUBE IMPLEMENTATION
cat("\n=== DATA CUBE IMPLEMENTATION ===\n")

# Create a summary cube data for visualization
cube_data <- fact_table %>%
  # Dimension integration for cube creation
  # we will add time dimension context by joining with time_dim
  left_join(time_dim %>% select(TimeID, Quarter), by = "TimeID") %>%
  # Add organizational dimension context (department)
  left_join(department_dim %>% select(DepartmentID, Department), by = "DepartmentID") %>%
  # Add organizational dimension context (education level)
  left_join(education_dim %>% select(EducationID, Education), by = "EducationID") %>%

  # Multidimensional aggregation for cube creation
  group_by(Quarter, Department, Education) %>%

  # calculate aggregated measures for each cube cell
  summarise(
    # average working load score for the cell
    AvgWorkingLoadScore = round(mean(WorkingLoadScore, na.rm = TRUE), 2),

    # Average monthly income for the cell
    AvgMonthlyIncome = round(mean(MonthlyIncome, na.rm = TRUE), 2),

    # Employee count
    # Population size for statistical significance assessment
    EmployeeCount = n(),

    # average job satisfaction for the cell
    AvgJobSatisfaction = round(mean(JobSatisfaction, na.rm = TRUE), 2),

    # Drop grouping for subsequent 
    .groups = "drop"
  )

cat("\nData Cube Summary:\n")
print(head(cube_data, 10))
cat("Total number of cube cells: ", nrow(cube_data), "\n")


# PART 3 SLICE AND DICE ANALYSIS OLAP OPERATIONS

cat("\n=== PART 3: SLICE AND DICE ANALYSIS (OLAP OPERATIONS) ===\n")

cat("SLICE OPERATION: Analyzing Q1 data...\n")
slice_q1 <- cube_data %>%
  filter(Quarter == "Q1") %>%
  # select remaining dimensions and measures for analysis
  select(
    Department, 
    Education, 
    AvgWorkingLoadScore, 
    AvgMonthlyIncome, 
    EmployeeCount
  )

cat("\nSliced Data (Q1):\n")
print(slice_q1)
cat("\nDICE OPERATION: Analyzing Q1 data for Sales department with Bachelor's degree...\n")

# Slice operation 2: organazational focus analysis
# OLAP Operations: Fix department dimension to sales, analyze time x Education

slice_sales <- cube_data %>%
  # Slice: Fix Department dimension to sales only
  filter(Department == "Sales") %>%
  # Select remaining dimensions and measures for analysis
  select(
    Quarter, 
    Education, 
    AvgWorkingLoadScore, 
    AvgMonthlyIncome, 
    EmployeeCount
  )

cat("\nDiced Data (Sales Department):\n")
print(slice_sales)

# DICE OPERATION 1: Multi-dimensional focus analysis
# OLAP Operations: Apply multiple filters across time and department dimensions

cat("DICE OPERATION 1: Quarter IN (Q1, Q2) AND Department IN (Sales, Research & Development)\n")

dice_q1q2_sales_rd <- cube_data %>%
  # dice filter 1: restrict time dimension to Q1 and Q2
  filter(Quarter %in% c("Q1", "Q2")) %>%
  # dice filter 2: restrict department to strategic business units
  filter(Department %in% c("Sales", "Research & Development")) %>%
  # select remaining dimensions and measures for analysis
  select(
    Quarter, 
    Department, 
    Education, 
    AvgWorkingLoadScore, 
    AvgMonthlyIncome, 
    EmployeeCount
  )

print(dice_q1q2_sales_rd)
cat("\nTotal number of records after DICE operation: ", nrow(dice_q1q2_sales_rd), "\n")

# dice operation 2: working load analysis
cat("DICE OPERATION 2: Analyzing high working load scores (>= 2.5) and High Income (> 5000) across all dimensions...\n")
dice_high_load_income <- cube_data %>%
  # dice filter 1: focus on high working load scores
  filter(AvgWorkingLoadScore >= 2.5) %>%
  # dice filter 2: focus on high income employees
  filter(AvgMonthlyIncome > 5000) %>%
  # select remaining dimensions and measures for analysis
  select(
    Quarter, 
    Department, 
    Education, 
    AvgWorkingLoadScore, 
    AvgMonthlyIncome, 
    EmployeeCount
  )

cat("\nDiced Data (High Load and Income):\n")
print(dice_high_load_income)
cat("\nTotal number of records after DICE operation: ", nrow(dice_high_load_income), "\n")
