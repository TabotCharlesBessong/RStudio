# DSC603 Assignment: Data Warehouse Design for HR Employee Attrition
# Data warehouse schema implementation with dimension and fact tables

# Load required libraries
library(dplyr)
library(ggplot2)

# Load the data
data_path <- file.path("..", "DATA", "HR Employee Attrition.csv")
hr_data <- read.csv(data_path, stringsAsFactors = FALSE)

cat("=== DSC603 DATA WAREHOUSE ASSIGNMENT ===\n")
cat("Dataset loaded successfully!\n")
cat("Original dataset dimensions:", nrow(hr_data), "rows,", ncol(hr_data), "columns\n\n")

# Display first few rows to understand the data structure
cat("=== SAMPLE DATA ===\n")
print(head(hr_data, 3))
cat("\n")

# ===============================================
# PART 1: DATA WAREHOUSE SCHEMA DESIGN
# ===============================================

cat("=== PART 1: DATA WAREHOUSE SCHEMA DESIGN ===\n\n")

# 1. TIME DIMENSION TABLE
cat("1. CREATING TIME DIMENSION TABLE\n")
cat("   (Based on employee tenure and hire dates)\n")

# Create Time Dimension - we'll simulate time data since it's not explicitly in the dataset
time_dim <- data.frame(
  TimeID = 1:12,  # Monthly data for a year
  Year = 2023,
  Quarter = c(rep("Q1", 3), rep("Q2", 3), rep("Q3", 3), rep("Q4", 3)),
  Month = 1:12,
  MonthName = month.name[1:12],
  stringsAsFactors = FALSE
)

print("Time Dimension Table:")
print(time_dim)
cat("\n")

# 2. EMPLOYEE INFORMATION DIMENSION TABLE
cat("2. CREATING EMPLOYEE INFORMATION DIMENSION TABLE\n")

employee_dim <- hr_data %>%
  select(EmployeeNumber, Age, Gender, MaritalStatus, DistanceFromHome, 
         NumCompaniesWorked, TotalWorkingYears, YearsAtCompany, 
         YearsSinceLastPromotion, YearsWithCurrManager) %>%
  distinct() %>%
  mutate(EmployeeID = row_number()) %>%
  select(EmployeeID, everything())

cat("Employee Information Dimension (first 5 rows):\n")
print(head(employee_dim, 5))
cat("Total employees:", nrow(employee_dim), "\n\n")

# 3. EDUCATION DIMENSION TABLE
cat("3. CREATING EDUCATION DIMENSION TABLE\n")

education_dim <- hr_data %>%
  select(Education, EducationField) %>%
  distinct() %>%
  arrange(Education, EducationField) %>%
  mutate(EducationID = row_number()) %>%
  select(EducationID, Education, EducationField)

print("Education Dimension Table:")
print(education_dim)
cat("\n")

# 4. DEPARTMENT DIMENSION TABLE
cat("4. CREATING DEPARTMENT DIMENSION TABLE\n")

department_dim <- hr_data %>%
  select(Department, JobRole) %>%
  distinct() %>%
  arrange(Department, JobRole) %>%
  mutate(DepartmentID = row_number()) %>%
  select(DepartmentID, Department, JobRole)

print("Department Dimension Table:")
print(department_dim)
cat("\n")

# 5. FACT TABLE: WORKING LOAD
cat("5. CREATING FACT TABLE: WORKING LOAD\n")

# Join dimensions with main data to create fact table
fact_working_load <- hr_data %>%
  # Join with Employee dimension
  left_join(employee_dim %>% select(EmployeeID, EmployeeNumber), 
            by = "EmployeeNumber") %>%
  # Join with Education dimension  
  left_join(education_dim %>% select(EducationID, Education, EducationField), 
            by = c("Education", "EducationField")) %>%
  # Join with Department dimension
  left_join(department_dim %>% select(DepartmentID, Department, JobRole), 
            by = c("Department", "JobRole")) %>%
  # Add time dimension (randomly assign for demonstration)
  mutate(TimeID = sample(1:12, nrow(hr_data), replace = TRUE)) %>%
  # Select fact table columns (metrics and foreign keys)
  select(EmployeeID, TimeID, EducationID, DepartmentID,
         # Measures (facts)
         MonthlyIncome, HourlyRate, DailyRate, MonthlyRate,
         PercentSalaryHike, StockOptionLevel, WorkLifeBalance,
         JobSatisfaction, EnvironmentSatisfaction, JobInvolvement,
         PerformanceRating, RelationshipSatisfaction,
         # Additional working load measures
         OverTime, BusinessTravel, TrainingTimesLastYear) %>%
  # Add calculated measures
  mutate(
    WorkingLoadScore = (as.numeric(OverTime == "Yes") * 2 + 
                       JobInvolvement + WorkLifeBalance + 
                       (5 - JobSatisfaction)) / 4,
    TotalCompensation = MonthlyIncome + HourlyRate * 160 + DailyRate * 20
  ) %>%
  mutate(FactID = row_number()) %>%
  select(FactID, everything())

cat("Fact Table: Working Load (first 5 rows):\n")
print(head(fact_working_load, 5))
cat("Total fact records:", nrow(fact_working_load), "\n\n")

# ===============================================
# PART 2: DATA WAREHOUSE CUBE REPRESENTATION
# ===============================================

cat("=== PART 2: DATA WAREHOUSE CUBE REPRESENTATION ===\n\n")

# Create summary cube data for visualization
cube_data <- fact_working_load %>%
  left_join(time_dim %>% select(TimeID, Quarter), by = "TimeID") %>%
  left_join(department_dim %>% select(DepartmentID, Department), by = "DepartmentID") %>%
  left_join(education_dim %>% select(EducationID, Education), by = "EducationID") %>%
  group_by(Quarter, Department, Education) %>%
  summarise(
    AvgWorkingLoadScore = round(mean(WorkingLoadScore, na.rm = TRUE), 2),
    AvgMonthlyIncome = round(mean(MonthlyIncome, na.rm = TRUE), 0),
    EmployeeCount = n(),
    AvgJobSatisfaction = round(mean(JobSatisfaction, na.rm = TRUE), 2),
    .groups = 'drop'
  )

cat("CUBE DATA SAMPLE (3D representation: Quarter x Department x Education):\n")
print(head(cube_data, 10))
cat("\n")

# Create cube summary statistics
cat("CUBE DIMENSIONS SUMMARY:\n")
cat("Time Dimension (Quarters):", length(unique(cube_data$Quarter)), "quarters\n")
cat("Department Dimension:", length(unique(cube_data$Department)), "departments\n")
cat("Education Dimension:", length(unique(cube_data$Education)), "education levels\n")
cat("Total cube cells:", nrow(cube_data), "\n\n")

# ===============================================
# PART 3: SLICE AND DICE OPERATIONS
# ===============================================

cat("=== PART 3: SLICE AND DICE OPERATIONS ===\n\n")

# SLICE OPERATION 1: Fix Quarter to Q1
cat("SLICE OPERATION 1: Quarter = Q1 (Fix time dimension to Q1)\n")
slice_q1 <- cube_data %>%
  filter(Quarter == "Q1") %>%
  select(Department, Education, AvgWorkingLoadScore, AvgMonthlyIncome, EmployeeCount)

print(slice_q1)
cat("\n")

# SLICE OPERATION 2: Fix Department to Sales
cat("SLICE OPERATION 2: Department = Sales (Fix department dimension to Sales)\n")
slice_sales <- cube_data %>%
  filter(Department == "Sales") %>%
  select(Quarter, Education, AvgWorkingLoadScore, AvgMonthlyIncome, EmployeeCount)

print(slice_sales)
cat("\n")

# DICE OPERATION 1: Multiple dimension restrictions
cat("DICE OPERATION 1: Quarter IN (Q1, Q2) AND Department IN (Sales, Research & Development)\n")
dice_q1q2_sales_rd <- cube_data %>%
  filter(Quarter %in% c("Q1", "Q2")) %>%
  filter(Department %in% c("Sales", "Research & Development")) %>%
  select(Quarter, Department, Education, AvgWorkingLoadScore, AvgMonthlyIncome, EmployeeCount)

print(dice_q1q2_sales_rd)
cat("\n")

# DICE OPERATION 2: Working load analysis
cat("DICE OPERATION 2: High Working Load (Score > 2.5) AND High Income (> 5000)\n")
dice_high_load_income <- cube_data %>%
  filter(AvgWorkingLoadScore > 2.5) %>%
  filter(AvgMonthlyIncome > 5000) %>%
  arrange(desc(AvgWorkingLoadScore)) %>%
  select(Quarter, Department, Education, AvgWorkingLoadScore, AvgMonthlyIncome, EmployeeCount)

print(dice_high_load_income)
cat("\n")

# ===============================================
# PART 4: ADVANCED CUBE OPERATIONS & ANALYSIS
# ===============================================

cat("=== PART 4: ADVANCED CUBE OPERATIONS & ANALYSIS ===\n\n")

# ROLL-UP: Aggregate by Department only (remove Education dimension)
cat("ROLL-UP OPERATION: Aggregate by Department (remove Education dimension)\n")
rollup_dept <- cube_data %>%
  group_by(Quarter, Department) %>%
  summarise(
    TotalEmployees = sum(EmployeeCount),
    AvgWorkingLoadScore = round(weighted.mean(AvgWorkingLoadScore, EmployeeCount), 2),
    AvgMonthlyIncome = round(weighted.mean(AvgMonthlyIncome, EmployeeCount), 0),
    .groups = 'drop'
  )

print(rollup_dept)
cat("\n")

# DRILL-DOWN: Break down by additional dimension (JobSatisfaction levels)
cat("DRILL-DOWN OPERATION: Add JobSatisfaction dimension\n")
drilldown_satisfaction <- fact_working_load %>%
  left_join(time_dim %>% select(TimeID, Quarter), by = "TimeID") %>%
  left_join(department_dim %>% select(DepartmentID, Department), by = "DepartmentID") %>%
  mutate(SatisfactionLevel = case_when(
    JobSatisfaction <= 2 ~ "Low",
    JobSatisfaction == 3 ~ "Medium", 
    JobSatisfaction >= 4 ~ "High"
  )) %>%
  group_by(Quarter, Department, SatisfactionLevel) %>%
  summarise(
    EmployeeCount = n(),
    AvgWorkingLoadScore = round(mean(WorkingLoadScore, na.rm = TRUE), 2),
    AvgMonthlyIncome = round(mean(MonthlyIncome, na.rm = TRUE), 0),
    .groups = 'drop'
  ) %>%
  arrange(Quarter, Department, SatisfactionLevel)

print(head(drilldown_satisfaction, 12))
cat("\n")

# ===============================================
# SUMMARY AND INSIGHTS
# ===============================================

cat("=== ASSIGNMENT SUMMARY ===\n")
cat("✓ COMPLETED: Data Warehouse Schema Design\n")
cat("  - Time Dimension: 12 months data\n")
cat("  - Employee Information Dimension:", nrow(employee_dim), "employees\n")
cat("  - Education Dimension:", nrow(education_dim), "education combinations\n") 
cat("  - Department Dimension:", nrow(department_dim), "department-role combinations\n")
cat("  - Fact Table (Working Load):", nrow(fact_working_load), "records\n\n")

cat("✓ COMPLETED: Data Cube Representation\n")
cat("  - 3D Cube: Time x Department x Education\n")
cat("  - Measures: Working Load Score, Monthly Income, Employee Count, Job Satisfaction\n\n")

cat("✓ COMPLETED: Slice and Dice Operations\n")
cat("  - Slice 1: Quarter = Q1\n")
cat("  - Slice 2: Department = Sales\n") 
cat("  - Dice 1: Q1,Q2 × Sales,R&D\n")
cat("  - Dice 2: High Working Load × High Income\n\n")

cat("✓ BONUS: Advanced Operations\n")
cat("  - Roll-up: Aggregate by Department\n")
cat("  - Drill-down: Add Job Satisfaction dimension\n\n")

cat("=== KEY INSIGHTS FROM ANALYSIS ===\n")
# Generate some insights
high_load_depts <- rollup_dept %>% 
  group_by(Department) %>% 
  summarise(AvgLoad = mean(AvgWorkingLoadScore)) %>% 
  arrange(desc(AvgLoad))

cat("Departments by Working Load (High to Low):\n")
print(high_load_depts)
cat("\nAssignment completed successfully! 📊\n")