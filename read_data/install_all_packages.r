# Quick Package Installer for DSC603 Assignment
# Run this FIRST if you get package not found errors

cat("=== DSC603 PACKAGE INSTALLER ===\n")

# Function to install packages to user library (avoids permission issues)
install_user_packages <- function(packages) {
  # Create user library path
  user_lib <- file.path(Sys.getenv("USERPROFILE"), "Documents", "R", "win-library", R.version$major, R.version$minor)
  
  # Create directory if it doesn't exist
  if (!dir.exists(user_lib)) {
    dir.create(user_lib, recursive = TRUE, showWarnings = FALSE)
    cat("Created user library at:", user_lib, "\n")
  }
  
  # Set library paths to use user library first
  .libPaths(c(user_lib, .libPaths()))
  
  cat("Installing packages to:", user_lib, "\n\n")
  
  # Install each package
  for (pkg in packages) {
    cat(paste("Checking package:", pkg, "\n"))
    
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      cat(paste("Installing", pkg, "...\n"))
      
      tryCatch({
        install.packages(pkg, 
                         lib = user_lib,
                         dependencies = TRUE,
                         repos = "https://cran.rstudio.com/",
                         type = "binary")
        
        # Test if installation worked
        if (require(pkg, character.only = TRUE, quietly = TRUE, lib.loc = user_lib)) {
          cat(paste("✓", pkg, "installed successfully!\n"))
        } else {
          cat(paste("✗", pkg, "installation may have failed\n"))
        }
        
      }, error = function(e) {
        cat(paste("✗ Error installing", pkg, ":", e$message, "\n"))
      })
    } else {
      cat(paste("✓", pkg, "already available\n"))
    }
    cat("\n")
  }
}

# List of all packages needed for the assignment
all_packages <- c(
  # Essential packages
  "dplyr",           # Data manipulation
  "ggplot2",         # Basic plotting
  
  # Visualization packages
  "plotly",          # Interactive 3D plots
  "reshape2",        # Data reshaping
  "RColorBrewer",    # Color palettes
  "gridExtra",       # Multiple plots
  "corrplot",        # Correlation plots
  
  # Dashboard packages  
  "shiny",           # Interactive apps
  "shinydashboard",  # Dashboard layout
  "DT"               # Interactive tables
)

cat("Installing packages for DSC603 Data Warehouse Assignment...\n")
cat("This may take a few minutes...\n\n")

# Install all packages
install_user_packages(all_packages)

cat("\n=== INSTALLATION SUMMARY ===\n")
cat("Checking which packages are now available:\n")

for (pkg in all_packages) {
  if (require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat(paste("✓", pkg, "- READY\n"))
  } else {
    cat(paste("✗", pkg, "- NOT AVAILABLE\n"))
  }
}

cat("\n=== NEXT STEPS ===\n")
cat("If all packages show ✓ READY, you can now run:\n")
cat("source('dsc603_launcher.r')\n")
cat("run_full_assignment()\n\n")

cat("If some packages show ✗ NOT AVAILABLE, try:\n")
cat("1. Restart R/RStudio\n")
cat("2. Run this script again\n")
cat("3. Or install individual packages manually\n\n")

cat("Package installation completed!\n")