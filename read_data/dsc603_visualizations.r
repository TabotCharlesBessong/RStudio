# =============================================================================
# DSC603 DATA WAREHOUSE VISUALIZATION ENHANCEMENT
# Purpose: Advanced charts and graphs for cube data and OLAP operations
# Technology: R's superior statistical visualization capabilities
# Business Value: Professional-grade analytics visualization beyond basic BI tools
# =============================================================================

# =============================================================================
# ADVANCED VISUALIZATION PACKAGE ECOSYSTEM
# Purpose: Comprehensive visualization capabilities for business intelligence
# Advantage over Power BI: Unlimited customization and statistical integration
# =============================================================================

# Load required libraries for advanced visualization
required_packages <- c("ggplot2", "dplyr", "plotly", "reshape2", "RColorBrewer", "gridExtra")

for (package in required_packages) {
  if (!require(package, character.only = TRUE, quietly = TRUE)) {
    cat(paste("Installing package:", package, "\n"))
    install.packages(package, dependencies = TRUE, repos = "https://cran.rstudio.com/")
    library(package, character.only = TRUE)
  }
}

# Load data (assuming main assignment script was run first)
# If not, run the main script first
if (!exists("cube_data")) {
  cat("Loading main assignment data...\n")
  
  # Check if assignment file exists in current directory
  assignment_file <- "dsc603_datawarehouse_assignment.r"
  if (!file.exists(assignment_file)) {
    # Try alternative paths
    possible_paths <- c(
      file.path("read_data", assignment_file),
      file.path("..", "read_data", assignment_file),
      assignment_file
    )
    
    found_file <- FALSE
    for (path in possible_paths) {
      if (file.exists(path)) {
        assignment_file <- path
        found_file <- TRUE
        cat("Found assignment file at:", path, "\n")
        break
      }
    }
    
    if (!found_file) {
      stop("Cannot find dsc603_datawarehouse_assignment.r file")
    }
  }
  
  source(assignment_file)
}

# Verify data exists and has correct structure
if (!exists("cube_data") || is.null(cube_data) || nrow(cube_data) == 0) {
  stop("Error: cube_data not found or empty. Please run dsc603_datawarehouse_assignment.r first.")
}

# Ensure all required columns exist
required_cols <- c("Quarter", "Department", "Education", "AvgWorkingLoadScore", "EmployeeCount", "AvgMonthlyIncome")
missing_cols <- setdiff(required_cols, names(cube_data))
if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

cat("=== DSC603 DATA WAREHOUSE VISUALIZATION ENHANCEMENT ===\n\n")

# ===============================================
# 1. 3D CUBE VISUALIZATION
# ===============================================

cat("1. CREATING 3D CUBE VISUALIZATION\n")

# Create 3D scatter plot of the cube (with error handling)
tryCatch({
  # Ensure numeric education for z-axis
  cube_data_3d <- cube_data %>%
    mutate(
      Education_Numeric = as.numeric(Education),
      Quarter_Numeric = as.numeric(factor(Quarter, levels = c("Q1", "Q2", "Q3", "Q4"))),
      Department_Numeric = as.numeric(factor(Department))
    )
  
  cube_3d_plot <- plot_ly(cube_data_3d, 
                          x = ~Quarter_Numeric, 
                          y = ~Department_Numeric, 
                          z = ~Education_Numeric,
                          size = ~EmployeeCount,
                          color = ~AvgWorkingLoadScore,
                          colors = c("green", "yellow", "red"),
                          text = ~paste("Quarter:", Quarter,
                                       "<br>Department:", Department,
                                       "<br>Education Level:", Education,
                                       "<br>Working Load:", round(AvgWorkingLoadScore, 2),
                                       "<br>Employees:", EmployeeCount,
                                       "<br>Avg Income:", round(AvgMonthlyIncome, 0)),
                          hovertemplate = "%{text}<extra></extra>",
                          type = "scatter3d",
                          mode = "markers") %>%
    layout(title = "3D Data Warehouse Cube: Time × Department × Education",
           scene = list(
             xaxis = list(title = "Quarter (Time Dimension)",
                         tickmode = "array",
                         tickvals = 1:4,
                         ticktext = c("Q1", "Q2", "Q3", "Q4")),
             yaxis = list(title = "Department Dimension",
                         tickmode = "array",
                         tickvals = 1:length(unique(cube_data$Department)),
                         ticktext = unique(cube_data$Department)),
             zaxis = list(title = "Education Level")
           ))
  
  # Display the 3D plot
  print(cube_3d_plot)
}, error = function(e) {
  cat("Error creating 3D plot:", e$message, "\n")
  cat("Skipping 3D visualization...\n")
})

# ===============================================
# 2. HEATMAP VISUALIZATIONS
# ===============================================

cat("2. CREATING HEATMAP VISUALIZATIONS\n")

# Working Load Heatmap by Department and Quarter (with error handling)
tryCatch({
  heatmap_data <- cube_data %>%
    group_by(Quarter, Department) %>%
    summarise(AvgWorkingLoad = mean(AvgWorkingLoadScore, na.rm = TRUE), .groups = 'drop') %>%
    filter(!is.na(AvgWorkingLoad))
  
  if (nrow(heatmap_data) > 0) {
    heatmap_plot <- ggplot(heatmap_data, aes(x = Quarter, y = Department, fill = AvgWorkingLoad)) +
      geom_tile(color = "white", linewidth = 0.5) +
      scale_fill_gradient2(low = "green", mid = "yellow", high = "red", 
                           midpoint = median(heatmap_data$AvgWorkingLoad, na.rm = TRUE),
                           name = "Working\nLoad Score") +
      labs(title = "Working Load Heatmap: Department × Quarter",
           x = "Quarter (Time Dimension)",
           y = "Department",
           caption = "Color intensity represents average working load score") +
      theme_minimal() +
      theme(
        plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
        axis.text.x = element_text(angle = 0),
        panel.grid = element_blank()
      ) +
      geom_text(aes(label = round(AvgWorkingLoad, 2)), color = "black", size = 3)
    
    print(heatmap_plot)
    ggsave("working_load_heatmap.png", heatmap_plot, width = 10, height = 6, dpi = 300)
  } else {
    cat("Warning: No data available for heatmap\n")
  }
}, error = function(e) {
  cat("Error creating heatmap:", e$message, "\n")
})



# ===============================================
# 3. SLICE OPERATION VISUALIZATIONS
# ===============================================

cat("3. CREATING SLICE OPERATION VISUALIZATIONS\n")

# Slice 1: Quarter = Q1 visualization
slice_q1_data <- cube_data %>% filter(Quarter == "Q1")

slice_q1_plot <- ggplot(slice_q1_data, aes(x = Education, y = AvgWorkingLoadScore, 
                                           fill = Department, size = EmployeeCount)) +
  geom_point(alpha = 0.7, shape = 21, color = "black") +
  scale_size_continuous(range = c(3, 15), name = "Employee\nCount") +
  scale_fill_brewer(type = "qual", palette = "Set2") +
  labs(title = "SLICE Operation: Quarter = Q1",
       subtitle = "Working Load by Education Level and Department",
       x = "Education Level",
       y = "Average Working Load Score") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, size = 14, face = "bold"))

print(slice_q1_plot)
ggsave("slice_q1_visualization.png", slice_q1_plot, width = 12, height = 8, dpi = 300)

# Slice 2: Department = Sales visualization  
slice_sales_data <- cube_data %>% filter(Department == "Sales")

slice_sales_plot <- ggplot(slice_sales_data, aes(x = Quarter, y = Education, 
                                                 fill = AvgWorkingLoadScore, size = EmployeeCount)) +
  geom_point(shape = 21, color = "black", alpha = 0.8) +
  scale_fill_gradient2(low = "green", mid = "yellow", high = "red",
                       midpoint = median(slice_sales_data$AvgWorkingLoadScore),
                       name = "Working\nLoad") +
  scale_size_continuous(range = c(5, 20), name = "Employee\nCount") +
  labs(title = "SLICE Operation: Department = Sales",
       subtitle = "Working Load across Time and Education Dimensions",
       x = "Quarter (Time)",
       y = "Education Level") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, size = 14, face = "bold"))

print(slice_sales_plot)
ggsave("slice_sales_visualization.png", slice_sales_plot, width = 12, height = 8, dpi = 300)

# ===============================================
# 4. DICE OPERATION VISUALIZATIONS  
# ===============================================

cat("4. CREATING DICE OPERATION VISUALIZATIONS\n")

# Dice 1: Q1,Q2 × Sales,R&D
dice_data <- cube_data %>%
  filter(Quarter %in% c("Q1", "Q2")) %>%
  filter(Department %in% c("Sales", "Research & Development"))

dice_plot1 <- ggplot(dice_data, aes(x = interaction(Quarter, Department), 
                                   y = AvgWorkingLoadScore, fill = as.factor(Education))) +
  geom_col(position = "dodge", alpha = 0.8) +
  scale_fill_brewer(type = "qual", palette = "Spectral", name = "Education\nLevel") +
  labs(title = "DICE Operation: Q1,Q2 × Sales,R&D",
       subtitle = "Working Load Comparison by Quarter-Department Combinations",
       x = "Quarter × Department",
       y = "Average Working Load Score") +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

print(dice_plot1)
ggsave("dice_operation_visualization.png", dice_plot1, width = 14, height = 8, dpi = 300)

# ===============================================
# 5. ADVANCED ANALYTICS VISUALIZATIONS
# ===============================================

cat("5. CREATING ADVANCED ANALYTICS VISUALIZATIONS\n")

# Roll-up visualization
rollup_data <- cube_data %>%
  group_by(Quarter, Department) %>%
  summarise(
    TotalEmployees = sum(EmployeeCount),
    AvgWorkingLoad = weighted.mean(AvgWorkingLoadScore, EmployeeCount),
    AvgIncome = weighted.mean(AvgMonthlyIncome, EmployeeCount),
    .groups = 'drop'
  )

# Multi-panel visualization
income_plot <- ggplot(rollup_data, aes(x = Quarter, y = AvgIncome, group = Department, color = Department)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  scale_color_brewer(type = "qual", palette = "Dark2") +
  labs(title = "Average Income Trends",
       x = "Quarter", y = "Average Monthly Income") +
  theme_minimal()

workload_plot <- ggplot(rollup_data, aes(x = Quarter, y = AvgWorkingLoad, group = Department, color = Department)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  scale_color_brewer(type = "qual", palette = "Dark2") +
  labs(title = "Working Load Trends",
       x = "Quarter", y = "Average Working Load") +
  theme_minimal()

employees_plot <- ggplot(rollup_data, aes(x = Quarter, y = TotalEmployees, fill = Department)) +
  geom_col(position = "dodge", alpha = 0.8) +
  scale_fill_brewer(type = "qual", palette = "Set3") +
  labs(title = "Employee Count by Department",
       x = "Quarter", y = "Total Employees") +
  theme_minimal()

# Combine plots
combined_plot <- grid.arrange(income_plot, workload_plot, employees_plot, 
                             ncol = 1, top = "ROLL-UP Analysis: Quarterly Department Trends")

ggsave("rollup_analysis_trends.png", combined_plot, width = 14, height = 12, dpi = 300)

# ===============================================
# 6. CORRELATION MATRIX VISUALIZATION
# ===============================================

cat("6. CREATING CORRELATION MATRIX VISUALIZATION\n")

# Create correlation data
correlation_data <- cube_data %>%
  select(AvgWorkingLoadScore, AvgMonthlyIncome, EmployeeCount, AvgJobSatisfaction) %>%
  cor(use = "complete.obs")

# Convert to long format for ggplot (with error handling)
tryCatch({
  correlation_melted <- reshape2::melt(correlation_data)
}, error = function(e) {
  # Alternative method if melt fails
  correlation_melted <- expand.grid(Var1 = rownames(correlation_data), 
                                    Var2 = colnames(correlation_data)) %>%
    mutate(value = as.vector(correlation_data))
})

correlation_plot <- ggplot(correlation_melted, aes(x = Var1, y = Var2, fill = value)) +
  geom_tile(color = "white") +
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                       midpoint = 0, limit = c(-1,1), space = "Lab",
                       name = "Correlation") +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1),
    axis.title.x = element_blank(),
    axis.title.y = element_blank()
  ) +
  coord_fixed() +
  geom_text(aes(label = round(value, 2)), color = "black", size = 4) +
  labs(title = "Cube Measures Correlation Matrix",
       subtitle = "Relationships between key performance indicators")

print(correlation_plot)
ggsave("correlation_matrix.png", correlation_plot, width = 10, height = 8, dpi = 300)

# ===============================================
# 7. SUMMARY DASHBOARD-STYLE VISUALIZATION
# ===============================================

cat("7. CREATING SUMMARY DASHBOARD VISUALIZATION\n")

# Key metrics summary
total_employees <- sum(cube_data$EmployeeCount)
avg_working_load <- weighted.mean(cube_data$AvgWorkingLoadScore, cube_data$EmployeeCount)
avg_income <- weighted.mean(cube_data$AvgMonthlyIncome, cube_data$EmployeeCount)
high_stress_employees <- sum(cube_data$EmployeeCount[cube_data$AvgWorkingLoadScore > 3])

# Create summary metrics plot
metrics_data <- data.frame(
  Metric = c("Total Employees", "Avg Working Load", "Avg Monthly Income", "High Stress Employees"),
  Value = c(total_employees, avg_working_load, avg_income/1000, high_stress_employees),
  Label = c(paste(total_employees), 
           paste(round(avg_working_load, 2)), 
           paste("$", round(avg_income/1000, 1), "K"),
           paste(high_stress_employees))
)

summary_plot <- ggplot(metrics_data, aes(x = Metric, y = Value, fill = Metric)) +
  geom_col(alpha = 0.8, width = 0.7) +
  geom_text(aes(label = Label), vjust = -0.5, size = 5, fontface = "bold") +
  scale_fill_brewer(type = "qual", palette = "Set1") +
  labs(title = "Data Warehouse Key Performance Indicators",
       subtitle = "Summary metrics from OLAP cube analysis",
       y = "Value", x = "") +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "none"
  )

print(summary_plot)
ggsave("summary_kpi_dashboard.png", summary_plot, width = 12, height = 8, dpi = 300)

# ===============================================
# VISUALIZATION SUMMARY
# ===============================================

cat("\n=== VISUALIZATION ENHANCEMENT SUMMARY ===\n")
cat("✓ 3D Cube Interactive Plot (plotly)\n")
cat("✓ Working Load Heatmap (Department × Quarter)\n") 
cat("✓ Slice Operations Visualization (Q1 & Sales)\n")
cat("✓ Dice Operations Charts (Multi-dimensional filtering)\n")
cat("✓ Roll-up Trend Analysis (Quarterly summaries)\n")
cat("✓ Correlation Matrix Heatmap\n")
cat("✓ KPI Summary Dashboard\n\n")

cat("Generated PNG files:\n")
cat("- working_load_heatmap.png\n")
cat("- slice_q1_visualization.png\n") 
cat("- slice_sales_visualization.png\n")
cat("- dice_operation_visualization.png\n")
cat("- rollup_analysis_trends.png\n")
cat("- correlation_matrix.png\n")
cat("- summary_kpi_dashboard.png\n\n")

cat("📊 Visualization enhancement completed! All charts saved as high-resolution PNG files.\n")
cat("🚀 Ready for presentation or inclusion in your assignment report.\n")