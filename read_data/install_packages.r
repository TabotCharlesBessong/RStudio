# Package Installation Script - Force User Library
# This FORCES installation to user directory to avoid permission issues

# Force user library path (Windows specific)
user_lib <- file.path(Sys.getenv("USERPROFILE"), "Documents", "R", "win-library", R.version$major, R.version$minor)

# Create directory if it doesn't exist
if (!dir.exists(user_lib)) {
  dir.create(user_lib, recursive = TRUE, showWarnings = FALSE)
  cat(paste("Created user library at:", user_lib, "\n"))
} else {
  cat(paste("Using existing user library at:", user_lib, "\n"))
}

# FORCE R to use only the user library
.libPaths(user_lib)

cat("=== FORCED LIBRARY CONFIGURATION ===\n")
cat("Library paths (forced to user only):\n")
print(.libPaths())
cat("\n")

# Check if we have write permission
test_dir <- file.path(user_lib, "test_write_access")
if (dir.create(test_dir, showWarnings = FALSE)) {
  unlink(test_dir, recursive = TRUE)
  cat("✓ Write access confirmed to user library\n\n")
} else {
  cat("✗ Still no write access - using alternative method\n\n")
}

# Install packages with explicit library specification
packages_to_install <- c("ggplot2", "dplyr", "corrplot")

for (pkg in packages_to_install) {
  cat(paste("Processing package:", pkg, "\n"))
  
  # Check if already installed
  if (require(pkg, character.only = TRUE, quietly = TRUE, lib.loc = user_lib)) {
    cat(paste("✓", pkg, "already available\n\n"))
    next
  }
  
  # Try installation with explicit library path
  cat(paste("Installing", pkg, "to:", user_lib, "\n"))
  
  tryCatch({
    install.packages(pkg, 
                     lib = user_lib,
                     dependencies = TRUE,
                     repos = "https://cran.rstudio.com/",
                     type = "binary")  # Use binary packages for faster installation
    
    # Verify installation
    if (require(pkg, character.only = TRUE, quietly = TRUE, lib.loc = user_lib)) {
      cat(paste("✓", pkg, "installed successfully\n\n"))
    } else {
      cat(paste("✗", pkg, "installation may have failed\n\n"))
    }
    
  }, error = function(e) {
    cat(paste("✗ Error installing", pkg, ":", e$message, "\n\n"))
  })
}

cat("=== INSTALLATION SUMMARY ===\n")
cat("Checking which packages are now available:\n")
for (pkg in packages_to_install) {
  if (require(pkg, character.only = TRUE, quietly = TRUE, lib.loc = user_lib)) {
    cat(paste("✓", pkg, "- AVAILABLE\n"))
  } else {
    cat(paste("✗", pkg, "- NOT AVAILABLE\n"))
  }
}

cat("\n=== NEXT STEPS ===\n")
cat("If packages installed successfully, you can now run:\n")
cat("source('script.r')\n")
cat("\nIf packages failed to install, you can run:\n")
cat("source('basic_analysis.r')  # Uses only base R\n")