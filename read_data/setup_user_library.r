# R User Library Setup - Run this once
# This sets up R to use user library by default (like pip --user)

# Get user library path
user_lib <- Sys.getenv("R_LIBS_USER")
cat(paste("User library path:", user_lib, "\n"))

# Create user library directory if it doesn't exist
if (!dir.exists(user_lib)) {
  dir.create(user_lib, recursive = TRUE, showWarnings = FALSE)
  cat("Created user library directory\n")
} else {
  cat("User library directory already exists\n")
}

# Create .Rprofile file to automatically use user library
rprofile_content <- paste0(
  '# Auto-generated R configuration\n',
  '# Set user library as default\n',
  'user_lib <- Sys.getenv("R_LIBS_USER")\n',
  'if (!dir.exists(user_lib)) {\n',
  '  dir.create(user_lib, recursive = TRUE, showWarnings = FALSE)\n',
  '}\n',
  '.libPaths(c(user_lib, .libPaths()))\n',
  '\n',
  '# Function to install packages to user library\n',
  'install_user <- function(packages) {\n',
  '  install.packages(packages, lib = user_lib, dependencies = TRUE)\n',
  '}\n'
)

# Write to user's home directory .Rprofile
home_dir <- Sys.getenv("HOME")
if (home_dir == "") {
  home_dir <- Sys.getenv("USERPROFILE")  # Windows fallback
}

rprofile_path <- file.path(home_dir, ".Rprofile")
writeLines(rprofile_content, rprofile_path)

cat(paste("Created .Rprofile at:", rprofile_path, "\n"))
cat("\n=== SETUP COMPLETE ===\n")
cat("From now on, R will automatically use your user library.\n")
cat("Restart R or VS Code for changes to take effect.\n")
cat("\nTo install packages to user library in the future, use:\n")
cat("install_user(c('package1', 'package2'))\n")
cat("\nOr use the regular install.packages() - it will now default to user library.\n")