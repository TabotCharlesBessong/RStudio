# DSC603 Assignment Launcher
# Run this script to ensure all components work together

cat("=== DSC603 ASSIGNMENT LAUNCHER ===\n")

# Function to install and load packages
install_and_load <- function(packages) {
  for (package in packages) {
    if (!require(package, character.only = TRUE, quietly = TRUE)) {
      cat(paste("Installing package:", package, "\n"))
      
      # Create user library directory if it doesn't exist
      user_lib <- Sys.getenv("R_LIBS_USER")
      if (user_lib == "") {
        user_lib <- file.path(Sys.getenv("USERPROFILE"), "Documents", "R", "win-library", R.version$major, R.version$minor)
      }
      
      if (!dir.exists(user_lib)) {
        dir.create(user_lib, recursive = TRUE, showWarnings = FALSE)
      }
      
      # Install to user library
      install.packages(package, 
                       lib = user_lib,
                       dependencies = TRUE, 
                       repos = "https://cran.rstudio.com/")
      
      # Load the package
      library(package, character.only = TRUE, lib.loc = user_lib)
    }
  }
}

# Install essential packages first
cat("Installing/loading required packages...\n")
essential_packages <- c("dplyr", "ggplot2")
install_and_load(essential_packages)
cat("✓ Essential packages ready!\n\n")

# Set working directory to the script location
script_dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
if (script_dir != "") {
  setwd(script_dir)
  cat("Working directory set to:", getwd(), "\n")
} else {
  cat("Current working directory:", getwd(), "\n")
  cat("Make sure you're in the read_data directory\n")
}

# List available files
cat("\nAvailable files in current directory:\n")
files <- list.files(pattern = "\\.r$")
for (file in files) {
  cat("-", file, "\n")
}

cat("\n=== STEP-BY-STEP EXECUTION GUIDE ===\n")
cat("1. Run Main Assignment:\n")
cat("   source('dsc603_datawarehouse_assignment.r')\n\n")

cat("2. Create Visualizations:\n") 
cat("   source('dsc603_visualizations.r')\n\n")

cat("3. Launch Interactive Dashboard:\n")
cat("   source('dsc603_interactive_dashboard.r')\n")
cat("   launch_dashboard()\n\n")

# Function to run everything in sequence
run_full_assignment <- function() {
  cat("\n=== RUNNING FULL ASSIGNMENT SEQUENCE ===\n")
  
  tryCatch({
    cat("Step 1: Loading main assignment...\n")
    source("dsc603_datawarehouse_assignment.r")
    cat("✓ Main assignment completed successfully!\n\n")
    
    cat("Step 2: Creating visualizations...\n") 
    source("dsc603_visualizations.r")
    cat("✓ Visualizations created successfully!\n\n")
    
    cat("Step 3: Launching dashboard...\n")
    source("dsc603_interactive_dashboard.r")
    cat("✓ Dashboard loaded successfully!\n")
    cat("Run launch_dashboard() to open the interactive interface.\n\n")
    
    cat("🎉 ASSIGNMENT COMPLETED SUCCESSFULLY! 🎉\n")
    
  }, error = function(e) {
    cat("❌ Error occurred:", e$message, "\n")
    cat("Please run scripts individually to debug.\n")
  })
}

# Option to run everything at once
cat("To run everything automatically, execute:\n")
cat("run_full_assignment()\n\n")

cat("Files are ready! Choose your execution method above.\n")