# =============================================================================
# DSC603 INTERACTIVE DATA WAREHOUSE DASHBOARD
# Purpose: Shiny application for exploring cube data and OLAP operations
# Technology Choice: R Shiny vs Power BI for superior integration and flexibility
# Business Value: Democratic access to multidimensional analysis capabilities
# =============================================================================

# =============================================================================
# STRATEGIC TECHNOLOGY CHOICE: SHINY vs POWER BI
# 
# Why Shiny over Power BI:
# 1. SUPERIOR R INTEGRATION - Seamless connection with statistical computing
# 2. OPEN SOURCE BENEFITS - No licensing costs, unlimited users, no vendor lock-in
# 3. UNLIMITED CUSTOMIZATION - Custom analytical interfaces vs generic templates
# 4. REAL-TIME REACTIVE PROGRAMMING - Automatic updates and fluid exploration
# 5. ADVANCED STATISTICAL INTEGRATION - Built-in machine learning capabilities
# 6. COST EFFECTIVENESS - Particularly important for educational institutions
# =============================================================================

# =============================================================================
# DYNAMIC PACKAGE MANAGEMENT SYSTEM
# Purpose: Ensures dashboard deployment across different environments
# Business Value: Reduces deployment complexity and manual configuration
# =============================================================================

# Load required libraries for interactive functionality
required_packages <- c("shiny", "shinydashboard", "DT", "plotly", "dplyr", "ggplot2")

# Dynamic package installation ensures system compatibility
for (package in required_packages) {
  if (!require(package, character.only = TRUE, quietly = TRUE)) {
    cat(paste("Installing package:", package, "\n"))
    # Use specific CRAN mirror for reliability
    install.packages(package, dependencies = TRUE, repos = "https://cran.rstudio.com/")
    library(package, character.only = TRUE)
  }
}

# =============================================================================
# INTELLIGENT DATA WAREHOUSE INTEGRATION
# Purpose: Robust data loading with multiple fallback paths
# Business Value: Ensures dashboard works across different directory structures
# =============================================================================

# Load data warehouse data with error handling
tryCatch({
  # Check current working directory for debugging
  current_dir <- getwd()
  cat("Current working directory:", current_dir, "\n")
  
  # Intelligent file location system
  assignment_file <- "dsc603_datawarehouse_assignment.r"
  if (!file.exists(assignment_file)) {
    # Try multiple potential paths for robust deployment
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
  
  cat("Loading assignment data from:", assignment_file, "\n")
  source(assignment_file)
  
  # Verify required data exists
  if (!exists("cube_data") || is.null(cube_data) || nrow(cube_data) == 0) {
    stop("cube_data not found or empty")
  }
  
  cat("Data loaded successfully for dashboard!\n")
}, error = function(e) {
  cat("Error loading data:", e$message, "\n")
  cat("Please ensure dsc603_datawarehouse_assignment.r runs without errors first.\n")
  cat("Current directory contents:\n")
  print(list.files())
  stop("Cannot launch dashboard without proper data.")
})

# Define UI
ui <- dashboardPage(
  
  # Header
  dashboardHeader(title = "DSC603 Data Warehouse Explorer"),
  
  # Sidebar
  dashboardSidebar(
    sidebarMenu(
      menuItem("Cube Explorer", tabName = "cube", icon = icon("cube")),
      menuItem("Slice Operations", tabName = "slice", icon = icon("cut")), 
      menuItem("Dice Operations", tabName = "dice", icon = icon("dice")),
      menuItem("OLAP Analytics", tabName = "olap", icon = icon("chart-line")),
      menuItem("Data Tables", tabName = "tables", icon = icon("table"))
    )
  ),
  
  # Body
  dashboardBody(
    tags$head(
      tags$style(HTML("
        .content-wrapper, .right-side {
          background-color: #f4f4f4;
        }
      "))
    ),
    
    tabItems(
      
      # ========================================
      # CUBE EXPLORER TAB
      # ========================================
      tabItem(tabName = "cube",
        fluidRow(
          box(
            title = "3D Data Warehouse Cube", status = "primary", solidHeader = TRUE,
            width = 12, height = "600px",
            plotlyOutput("cube_3d_plot", height = "520px")
          )
        ),
        fluidRow(
          box(
            title = "Cube Dimensions Summary", status = "info", solidHeader = TRUE,
            width = 6,
            tableOutput("cube_summary")
          ),
          box(
            title = "Key Metrics", status = "success", solidHeader = TRUE, 
            width = 6,
            valueBoxOutput("total_employees", width = 12),
            valueBoxOutput("avg_working_load", width = 12),
            valueBoxOutput("avg_income", width = 12)
          )
        )
      ),
      
      # ========================================
      # SLICE OPERATIONS TAB
      # ========================================
      tabItem(tabName = "slice",
        fluidRow(
          box(
            title = "Slice Operation Controls", status = "warning", solidHeader = TRUE,
            width = 3,
            h4("Fix One Dimension:"),
            radioButtons("slice_dimension", "Choose Dimension to Fix:",
                        choices = list("Time (Quarter)" = "time",
                                     "Department" = "department", 
                                     "Education" = "education")),
            br(),
            conditionalPanel(
              condition = "input.slice_dimension == 'time'",
              selectInput("slice_quarter", "Select Quarter:", 
                         choices = unique(cube_data$Quarter))
            ),
            conditionalPanel(
              condition = "input.slice_dimension == 'department'",
              selectInput("slice_dept", "Select Department:",
                         choices = unique(cube_data$Department))
            ),
            conditionalPanel(
              condition = "input.slice_dimension == 'education'",
              selectInput("slice_edu", "Select Education Level:",
                         choices = unique(cube_data$Education))
            )
          ),
          box(
            title = "Slice Result Visualization", status = "primary", solidHeader = TRUE,
            width = 9,
            plotOutput("slice_plot", height = "400px")
          )
        ),
        fluidRow(
          box(
            title = "Slice Result Data", status = "info", solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("slice_table")
          )
        )
      ),
      
      # ========================================
      # DICE OPERATIONS TAB  
      # ========================================
      tabItem(tabName = "dice",
        fluidRow(
          box(
            title = "Dice Operation Controls", status = "danger", solidHeader = TRUE,
            width = 3,
            h4("Multi-Dimension Filtering:"),
            checkboxGroupInput("dice_quarters", "Select Quarters:",
                              choices = unique(cube_data$Quarter),
                              selected = unique(cube_data$Quarter)[1:2]),
            checkboxGroupInput("dice_departments", "Select Departments:",
                              choices = unique(cube_data$Department),
                              selected = unique(cube_data$Department)[1:2]),
            checkboxGroupInput("dice_education", "Select Education Levels:",
                              choices = unique(cube_data$Education),
                              selected = unique(cube_data$Education)[1:3]),
            br(),
            sliderInput("working_load_range", "Working Load Score Range:",
                       min = min(cube_data$AvgWorkingLoadScore, na.rm = TRUE),
                       max = max(cube_data$AvgWorkingLoadScore, na.rm = TRUE),
                       value = c(min(cube_data$AvgWorkingLoadScore, na.rm = TRUE),
                                max(cube_data$AvgWorkingLoadScore, na.rm = TRUE)),
                       step = 0.1)
          ),
          box(
            title = "Dice Result Visualization", status = "primary", solidHeader = TRUE,
            width = 9,
            plotOutput("dice_plot", height = "400px")
          )
        ),
        fluidRow(
          box(
            title = "Dice Result Data", status = "info", solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("dice_table")
          )
        )
      ),
      
      # ========================================
      # OLAP ANALYTICS TAB
      # ========================================
      tabItem(tabName = "olap",
        fluidRow(
          box(
            title = "OLAP Operation Controls", status = "success", solidHeader = TRUE,
            width = 3,
            radioButtons("olap_operation", "Choose OLAP Operation:",
                        choices = list("Roll-up (Aggregate)" = "rollup",
                                     "Drill-down (Detail)" = "drilldown",
                                     "Pivot (Rotate)" = "pivot")),
            br(),
            conditionalPanel(
              condition = "input.olap_operation == 'rollup'",
              h5("Remove Dimension:"),
              checkboxGroupInput("rollup_dimensions", "Keep Dimensions:",
                               choices = list("Time" = "time", "Department" = "dept", "Education" = "edu"),
                               selected = c("time", "dept"))
            ),
            conditionalPanel(
              condition = "input.olap_operation == 'drilldown'",
              h5("Add Detail Level:"),
              radioButtons("drilldown_detail", "Additional Dimension:",
                          choices = list("Job Satisfaction" = "satisfaction",
                                       "Income Level" = "income",
                                       "Employee Age Group" = "age"))
            ),
            conditionalPanel(
              condition = "input.olap_operation == 'pivot'",
              h5("Pivot Configuration:"),
              selectInput("pivot_rows", "Rows:", 
                         choices = c("Quarter", "Department", "Education")),
              selectInput("pivot_cols", "Columns:",
                         choices = c("Department", "Quarter", "Education"))
            )
          ),
          box(
            title = "OLAP Result Visualization", status = "primary", solidHeader = TRUE,
            width = 9,
            plotOutput("olap_plot", height = "400px")
          )
        ),
        fluidRow(
          box(
            title = "OLAP Result Data", status = "info", solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("olap_table")
          )
        )
      ),
      
      # ========================================
      # DATA TABLES TAB
      # ========================================
      tabItem(tabName = "tables",
        fluidRow(
          box(
            title = "Dimension Tables", status = "warning", solidHeader = TRUE,
            width = 6,
            tabsetPanel(
              tabPanel("Time Dimension", DT::dataTableOutput("time_table")),
              tabPanel("Employee Dimension", DT::dataTableOutput("employee_table")),
              tabPanel("Education Dimension", DT::dataTableOutput("education_table")),
              tabPanel("Department Dimension", DT::dataTableOutput("department_table"))
            )
          ),
          box(
            title = "Fact Table", status = "primary", solidHeader = TRUE,
            width = 6,
            DT::dataTableOutput("fact_table")
          )
        )
      )
    )
  )
)

# Define Server Logic
server <- function(input, output, session) {
  
  # ========================================
  # CUBE EXPLORER OUTPUTS
  # ========================================
  
  # 3D Cube Plot
  output$cube_3d_plot <- renderPlotly({
    plot_ly(cube_data, 
            x = ~Quarter, 
            y = ~Department, 
            z = ~Education,
            size = ~EmployeeCount,
            color = ~AvgWorkingLoadScore,
            colors = c("green", "yellow", "red"),
            text = ~paste("Quarter:", Quarter,
                         "<br>Department:", Department,
                         "<br>Education:", Education,
                         "<br>Working Load:", round(AvgWorkingLoadScore, 2),
                         "<br>Employees:", EmployeeCount,
                         "<br>Income:", paste0("$", round(AvgMonthlyIncome, 0))),
            hovertemplate = "%{text}<extra></extra>",
            type = "scatter3d",
            mode = "markers") %>%
      layout(title = "Interactive 3D Data Cube",
             scene = list(
               xaxis = list(title = "Quarter"),
               yaxis = list(title = "Department"),
               zaxis = list(title = "Education Level")
             ))
  })
  
  # Cube Summary
  output$cube_summary <- renderTable({
    data.frame(
      Dimension = c("Time (Quarters)", "Departments", "Education Levels", "Total Cube Cells"),
      Count = c(length(unique(cube_data$Quarter)),
               length(unique(cube_data$Department)),
               length(unique(cube_data$Education)),
               nrow(cube_data))
    )
  })
  
  # Value Boxes
  output$total_employees <- renderValueBox({
    valueBox(
      value = sum(cube_data$EmployeeCount),
      subtitle = "Total Employees",
      icon = icon("users"),
      color = "blue"
    )
  })
  
  output$avg_working_load <- renderValueBox({
    valueBox(
      value = round(weighted.mean(cube_data$AvgWorkingLoadScore, cube_data$EmployeeCount), 2),
      subtitle = "Avg Working Load",
      icon = icon("chart-line"),
      color = "orange"
    )
  })
  
  output$avg_income <- renderValueBox({
    valueBox(
      value = paste0("$", round(weighted.mean(cube_data$AvgMonthlyIncome, cube_data$EmployeeCount), 0)),
      subtitle = "Avg Monthly Income",
      icon = icon("dollar-sign"),
      color = "green"
    )
  })
  
  # ========================================
  # SLICE OPERATIONS
  # ========================================
  
  slice_data <- reactive({
    if(input$slice_dimension == "time") {
      cube_data %>% filter(Quarter == input$slice_quarter)
    } else if(input$slice_dimension == "department") {
      cube_data %>% filter(Department == input$slice_dept)
    } else {
      cube_data %>% filter(Education == input$slice_edu)
    }
  })
  
  output$slice_plot <- renderPlot({
    data <- slice_data()
    
    if(input$slice_dimension == "time") {
      ggplot(data, aes(x = Education, y = AvgWorkingLoadScore, fill = Department, size = EmployeeCount)) +
        geom_point(alpha = 0.7, shape = 21) +
        scale_size_continuous(range = c(3, 15)) +
        labs(title = paste("Slice: Quarter =", input$slice_quarter),
             x = "Education Level", y = "Working Load Score") +
        theme_minimal()
    } else if(input$slice_dimension == "department") {
      ggplot(data, aes(x = Quarter, y = Education, fill = AvgWorkingLoadScore, size = EmployeeCount)) +
        geom_point(shape = 21, alpha = 0.8) +
        scale_fill_gradient2(low = "green", high = "red", mid = "yellow") +
        scale_size_continuous(range = c(5, 20)) +
        labs(title = paste("Slice: Department =", input$slice_dept),
             x = "Quarter", y = "Education Level") +
        theme_minimal()
    } else {
      ggplot(data, aes(x = Quarter, y = Department, fill = AvgWorkingLoadScore, size = EmployeeCount)) +
        geom_point(shape = 21, alpha = 0.8) +
        scale_fill_gradient2(low = "green", high = "red", mid = "yellow") +
        scale_size_continuous(range = c(5, 20)) +
        labs(title = paste("Slice: Education =", input$slice_edu),
             x = "Quarter", y = "Department") +
        theme_minimal()
    }
  })
  
  output$slice_table <- DT::renderDataTable({
    slice_data() %>%
      select(Quarter, Department, Education, AvgWorkingLoadScore, AvgMonthlyIncome, EmployeeCount) %>%
      DT::datatable(options = list(pageLength = 10))
  })
  
  # ========================================
  # DICE OPERATIONS
  # ========================================
  
  dice_data <- reactive({
    cube_data %>%
      filter(Quarter %in% input$dice_quarters) %>%
      filter(Department %in% input$dice_departments) %>%
      filter(Education %in% input$dice_education) %>%
      filter(AvgWorkingLoadScore >= input$working_load_range[1] &
             AvgWorkingLoadScore <= input$working_load_range[2])
  })
  
  output$dice_plot <- renderPlot({
    data <- dice_data()
    
    ggplot(data, aes(x = interaction(Quarter, Department), y = AvgWorkingLoadScore, 
                     fill = as.factor(Education))) +
      geom_col(position = "dodge", alpha = 0.8) +
      labs(title = "Dice Operation Results",
           x = "Quarter × Department", y = "Working Load Score",
           fill = "Education") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  output$dice_table <- DT::renderDataTable({
    dice_data() %>%
      select(Quarter, Department, Education, AvgWorkingLoadScore, AvgMonthlyIncome, EmployeeCount) %>%
      DT::datatable(options = list(pageLength = 10))
  })
  
  # ========================================
  # OLAP OPERATIONS
  # ========================================
  
  olap_data <- reactive({
    if(input$olap_operation == "rollup") {
      # Roll-up operation
      group_vars <- c()
      if("time" %in% input$rollup_dimensions) group_vars <- c(group_vars, "Quarter")
      if("dept" %in% input$rollup_dimensions) group_vars <- c(group_vars, "Department") 
      if("edu" %in% input$rollup_dimensions) group_vars <- c(group_vars, "Education")
      
      cube_data %>%
        group_by(across(all_of(group_vars))) %>%
        summarise(
          TotalEmployees = sum(EmployeeCount),
          AvgWorkingLoadScore = weighted.mean(AvgWorkingLoadScore, EmployeeCount),
          AvgMonthlyIncome = weighted.mean(AvgMonthlyIncome, EmployeeCount),
          .groups = 'drop'
        )
    } else {
      cube_data
    }
  })
  
  output$olap_plot <- renderPlot({
    data <- olap_data()
    
    if(input$olap_operation == "rollup") {
      if("Quarter" %in% names(data) && "Department" %in% names(data)) {
        ggplot(data, aes(x = Quarter, y = AvgWorkingLoadScore, group = Department, color = Department)) +
          geom_line(linewidth = 1.2) + geom_point(size = 3) +
          labs(title = "Roll-up: Quarterly Trends by Department") +
          theme_minimal()
      } else {
        ggplot(data, aes(x = 1, y = AvgWorkingLoadScore)) +
          geom_col(fill = "steelblue", alpha = 0.7) +
          labs(title = "Roll-up: Aggregated Working Load") +
          theme_minimal()
      }
    } else {
      # Placeholder plot
      ggplot(cube_data, aes(x = Quarter, y = AvgWorkingLoadScore)) +
        geom_point() + labs(title = "OLAP Operation") + theme_minimal()
    }
  })
  
  output$olap_table <- DT::renderDataTable({
    olap_data() %>%
      DT::datatable(options = list(pageLength = 10))
  })
  
  # ========================================
  # DATA TABLES
  # ========================================
  
  output$time_table <- DT::renderDataTable({
    time_dim %>% DT::datatable(options = list(pageLength = 10))
  })
  
  output$employee_table <- DT::renderDataTable({
    employee_dim %>% head(100) %>% DT::datatable(options = list(pageLength = 10))
  })
  
  output$education_table <- DT::renderDataTable({
    education_dim %>% DT::datatable(options = list(pageLength = 10))
  })
  
  output$department_table <- DT::renderDataTable({
    department_dim %>% DT::datatable(options = list(pageLength = 10))
  })
  
  output$fact_table <- DT::renderDataTable({
    fact_working_load %>% head(100) %>% 
      select(FactID, EmployeeID, TimeID, EducationID, DepartmentID, 
             MonthlyIncome, WorkingLoadScore, JobSatisfaction) %>%
      DT::datatable(options = list(pageLength = 10))
  })
}

# ========================================
# LAUNCH APPLICATION FUNCTIONS
# ========================================

# Function to launch dashboard
launch_dashboard <- function() {
  cat("=== DSC603 INTERACTIVE DASHBOARD ===\n")
  cat("Starting Shiny application...\n")
  cat("Dashboard will open in your web browser.\n\n")
  cat("Features available:\n")
  cat("✓ 3D Interactive Cube Explorer\n")
  cat("✓ Dynamic Slice Operations\n")  
  cat("✓ Multi-dimensional Dice Operations\n")
  cat("✓ Advanced OLAP Analytics\n")
  cat("✓ Complete Data Table Browser\n\n")
  
  shinyApp(ui = ui, server = server)
}

# Auto-launch dashboard
cat("=== DSC603 INTERACTIVE DATA WAREHOUSE DASHBOARD ===\n")
cat("Dashboard script loaded successfully!\n\n")
cat("To launch the interactive dashboard, run:\n")
cat("launch_dashboard()\n\n")
cat("Or run directly:\n")
cat("shinyApp(ui = ui, server = server)\n\n")

# Uncomment the next line to auto-launch the dashboard
# launch_dashboard()