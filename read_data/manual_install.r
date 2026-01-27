# Manual Package Installation - Alternative Method
# Use this if the automatic installation still fails

# Alternative 1: Install without admin privileges
cat("=== ALTERNATIVE PACKAGE INSTALLATION ===\n")

# Set download method (sometimes helps with permissions)
options(download.file.method = "wininet")

# Try installing to temporary directory first
temp_lib <- file.path(tempdir(), "R_packages")
dir.create(temp_lib, recursive = TRUE, showWarnings = FALSE)

cat("Attempting installation to temporary directory...\n")

# Try minimal installation
tryCatch({
  install.packages("ggplot2", lib = temp_lib, dependencies = FALSE, 
                   repos = "https://cran.rstudio.com/")
  cat("✓ ggplot2 installed to temp directory\n")
}, error = function(e) {
  cat("✗ ggplot2 installation failed\n")
})

# Alternative 2: Manual package download and installation
cat("\n=== MANUAL DOWNLOAD METHOD ===\n")
cat("If automatic installation fails, you can:\n")
cat("1. Download packages manually from CRAN\n")
cat("2. Install them locally\n")
cat("\nExample commands:\n")
cat('download.file("https://cran.r-project.org/bin/windows/contrib/4.5/ggplot2_3.5.1.zip", "ggplot2.zip")\n')
cat('install.packages("ggplot2.zip", repos = NULL, type = "win.binary")\n')

cat("\n=== ALTERNATIVE: USE BASE R ONLY ===\n")
cat("For immediate analysis without packages, run:\n")
cat("source('basic_analysis.r')\n")

# Alternative 3: Check if packages are available in system library
cat("\n=== CHECKING SYSTEM PACKAGES ===\n")
system_packages <- rownames(installed.packages())
target_packages <- c("ggplot2", "dplyr", "corrplot", "lattice", "grid")

cat("Available packages in system library:\n")
for (pkg in target_packages) {
  if (pkg %in% system_packages) {
    cat(paste("✓", pkg, "- AVAILABLE\n"))
  } else {
    cat(paste("✗", pkg, "- not available\n"))
  }
}