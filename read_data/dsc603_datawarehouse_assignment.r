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

# =============================================================================
# TIME DIMENSION TABLE CREATION
# Purpose: Creates temporal hierarchy for multidimensional analysis
# Business Value: Enables quarterly reporting and seasonal pattern analysis
# Design: Star schema dimension table with surrogate key optimization
# =============================================================================

cat("1. CREATING TIME DIMENSION TABLE\n")
cat("   (Based on employee tenure and hire dates)\n")

# Create Time Dimension - we'll simulate time data since it's not explicitly in the dataset
time_dim <- data.frame(
  # Primary surrogate key - optimizes join performance vs natural keys
  TimeID = 1:12,
  
  # Business year context - enables year-over-year comparisons
  Year = 2023,
  
  # Quarterly hierarchy - supports executive reporting cycles
  Quarter = c(rep("Q1", 3), rep("Q2", 3), rep("Q3", 3), rep("Q4", 3)),
  
  # Monthly detail - provides operational analysis granularity
  Month = 1:12,
  
  # User-friendly labels - improves report readability
  MonthName = month.name[1:12],
  
  # Prevents automatic factor conversion - maintains data type control
  stringsAsFactors = FALSE
)

print("Time Dimension Table:")
print(time_dim)
cat("\n")

# =============================================================================
# EMPLOYEE INFORMATION DIMENSION TABLE
# Purpose: Captures demographic and professional employee characteristics
# Business Value: Enables segmentation analysis and targeted HR strategies
# Design: Comprehensive employee profile with surrogate key for efficiency
# =============================================================================

cat("2. CREATING EMPLOYEE INFORMATION DIMENSION TABLE\n")

employee_dim <- hr_data %>%
  # Select demographic and professional attributes for analysis
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
  # Remove duplicate employee records to ensure dimension integrity
  distinct() %>%
  # Create surrogate key for efficient joins and future flexibility
  mutate(EmployeeID = row_number()) %>%
  # Reorder columns to put surrogate key first (DW best practice)
  select(EmployeeID, everything())

cat("Employee Information Dimension (first 5 rows):\n")
print(head(employee_dim, 5))
cat("Total employees:", nrow(employee_dim), "\n\n")


cat("3. CREATING EDUCATION DIMENSION TABLE\n")

education_dim <- hr_data %>%
  # Extract unique education level and field combinations
  select(
    Education,
    EducationField
  ) %>%
  # Ensure unique combinations only (eliminates duplicates)
  distinct() %>%
  # Sort for consistent presentation and improved performance
  arrange(Education, EducationField) %>%
  # Add surrogate key for dimension table optimization
  mutate(EducationID = row_number()) %>%
  # Standard dimension structure with surrogate key first
  select(EducationID, Education, EducationField)

print("Education Dimension Table:")
print(education_dim)
cat("\n")

# =============================================================================
# DEPARTMENT DIMENSION TABLE
# Purpose: Captures organizational structure for departmental analysis
# Business Value: Enables organizational performance comparison and optimization
# Design: Two-level hierarchy (Department + Role) for flexible analysis
# =============================================================================

cat("4. CREATING DEPARTMENT DIMENSION TABLE\n")

department_dim <- hr_data %>%
  # Select organizational hierarchy attributes
  select(
    Department,
    JobRole
  ) %>%
  # Create unique department-role combinations
  distinct() %>%
  # Sort by department then role for logical organization
  arrange(Department, JobRole) %>%
  # Generate surrogate key for efficient relationships
  mutate(DepartmentID = row_number()) %>%
  # Organize with surrogate key first (dimension modeling standard)
  select(DepartmentID, Department, JobRole)

print("Department Dimension Table:")
print(department_dim)
cat("\n")

# =============================================================================
# WORKING LOAD FACT TABLE IMPLEMENTATION
# Purpose: Central measurement table connecting all dimensions with metrics
# Business Value: Enables comprehensive working load and performance analysis
# Design: Star schema fact table with additive and semi-additive measures
# =============================================================================

cat("5. CREATING FACT TABLE: WORKING LOAD\n")

# Join dimensions with main data to create fact table
fact_working_load <- hr_data %>%
  # DIMENSION INTEGRATION PHASE
  # Left joins preserve all employees while adding dimensional context
  
  left_join(employee_dim %>% select(EmployeeID, EmployeeNumber), 
            by = "EmployeeNumber") %>%
  left_join(education_dim %>% select(EducationID, Education, EducationField), 
            by = c("Education", "EducationField")) %>%
  left_join(department_dim %>% select(DepartmentID, Department, JobRole), 
            by = c("Department", "JobRole")) %>%
  # Simulate temporal distribution for demonstration purposes
  mutate(TimeID = sample(1:12, nrow(hr_data), replace = TRUE)) %>%
  
  # CORE MEASUREMENT SELECTION
  # Select foreign keys and business measures for analysis
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
      as.numeric(OverTime == "Yes") * 2 +
      JobInvolvement +
      WorkLifeBalance +
      (5 - JobSatisfaction)
    ) / 4,
    
    # TOTAL COMPENSATION - Comprehensive financial package
    # Includes monthly + estimated hourly (160 hrs) + estimated daily (20 days)
    TotalCompensation = MonthlyIncome + HourlyRate * 160 + DailyRate * 20
  ) %>%
  mutate(FactID = row_number()) %>%
  select(FactID, everything())

cat("Fact Table: Working Load (first 5 rows):\n")
print(head(fact_working_load, 5))
cat("Total fact records:", nrow(fact_working_load), "\n\n")

# =============================================================================
# MULTIDIMENSIONAL CUBE DATA STRUCTURE IMPLEMENTATION
# Purpose: Creates 3D analytical cube for OLAP operations
# Dimensions: Time (Quarter) × Organization (Department) × Demographics (Education)
# Business Value: Enables interactive multidimensional analysis and reporting
# =============================================================================

cat("=== PART 2: DATA WAREHOUSE CUBE REPRESENTATION ===\n\n")

# Create summary cube data for visualization
cube_data <- fact_working_load %>%
  # DIMENSION INTEGRATION FOR CUBE CREATION
  # Bring in dimensional attributes needed for cube structure
  
  # Add time dimension context (quarterly aggregation)
  left_join(time_dim %>% select(TimeID, Quarter), by = "TimeID") %>%
  # Add organizational dimension context
  left_join(department_dim %>% select(DepartmentID, Department), by = "DepartmentID") %>%
  # Add demographic dimension context (education level)
  left_join(education_dim %>% select(EducationID, Education), by = "EducationID") %>%
  
  # MULTIDIMENSIONAL AGGREGATION
  # Create cube cells by grouping across all three dimensions
  group_by(Quarter, Department, Education) %>%
  
  # Calculate aggregated measures for each cube cell
  summarise(
    # AVERAGE WORKING LOAD SCORE
    # Mean stress/workload indicator across employees in this cell
    AvgWorkingLoadScore = round(mean(WorkingLoadScore, na.rm = TRUE), 2),
    
    # AVERAGE MONTHLY INCOME
    # Mean compensation for employees in this dimensional combination
    AvgMonthlyIncome = round(mean(MonthlyIncome, na.rm = TRUE), 0),
    
    # EMPLOYEE COUNT
    # Population size for statistical significance assessment
    EmployeeCount = n(),
    
    # AVERAGE JOB SATISFACTION
    # Mean satisfaction rating for this employee segment
    AvgJobSatisfaction = round(mean(JobSatisfaction, na.rm = TRUE), 2),
    
    # Drop grouping for subsequent operations
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

# =============================================================================
# PART 3: SLICE AND DICE OPERATIONS (OLAP IMPLEMENTATION)
# Purpose: Demonstrate multidimensional analysis capabilities
# Business Value: Enable focused analysis and exception identification
# =============================================================================

cat("=== PART 3: SLICE AND DICE OPERATIONS ===\n\n")

# =============================================================================
# SLICE OPERATION 1: TEMPORAL FOCUS ANALYSIS
# OLAP Operation: Fix Time dimension to Q1, analyze across Dept × Education
# Business Purpose: Q1 performance analysis and seasonal pattern identification
# =============================================================================

cat("SLICE OPERATION 1: Quarter = Q1 (Fix time dimension to Q1)\n")
slice_q1 <- cube_data %>%
  # SLICE: Fix Quarter dimension to Q1 only
  filter(Quarter == "Q1") %>%
  # Select remaining dimensions and key measures for analysis
  select(
    Department,
    Education,
    AvgWorkingLoadScore,
    AvgMonthlyIncome,
    EmployeeCount
  )

print(slice_q1)
cat("\n")

# =============================================================================
# SLICE OPERATION 2: ORGANIZATIONAL FOCUS ANALYSIS
# OLAP Operation: Fix Department dimension to Sales, analyze Time × Education
# Business Purpose: Sales department performance across time and demographics
# =============================================================================

cat("SLICE OPERATION 2: Department = Sales (Fix department dimension to Sales)\n")
slice_sales <- cube_data %>%
  # SLICE: Fix Department dimension to Sales only
  filter(Department == "Sales") %>%
  # Select remaining dimensions and measures for focused analysis
  select(
    Quarter,
    Education,
    AvgWorkingLoadScore,
    AvgMonthlyIncome,
    EmployeeCount
  )

print(slice_sales)
cat("\n")

# =============================================================================
# DICE OPERATION 1: MULTI-DIMENSIONAL STRATEGIC ANALYSIS
# OLAP Operation: Apply multiple filters across Time and Department dimensions
# Business Purpose: Strategic comparison between key departments in H1
# =============================================================================

cat("DICE OPERATION 1: Quarter IN (Q1, Q2) AND Department IN (Sales, Research & Development)\n")
dice_q1q2_sales_rd <- cube_data %>%
  # DICE FILTER 1: Restrict Time dimension to first half of year
  filter(Quarter %in% c("Q1", "Q2")) %>%
  # DICE FILTER 2: Restrict Department to strategic business units
  filter(Department %in% c("Sales", "Research & Development")) %>%
  # Select all remaining dimensions and key measures
  select(
    Quarter,
    Department,
    Education,
    AvgWorkingLoadScore,
    AvgMonthlyIncome,
    EmployeeCount
  )

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