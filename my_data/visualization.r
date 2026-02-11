
# DATA WAREHOUSE VISUALIZATION

# Load required libraries

required_packages <- c("ggplot2","dplyr","plotly","reshape2","RColorBrewer","gridExtra")

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
  assignment_file <- "assignment.r"
  if (!file.exists(assignment_file)) {
    # Try alternative paths
    possible_paths <- c(
      file.path("my_data", assignment_file),
      file.path("..", "my_data", assignment_file),
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
      stop("Cannot find assignment.r file")
    }
  }
  
  source(assignment_file)
}