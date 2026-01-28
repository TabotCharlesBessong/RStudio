# DSC603 Data Warehouse Assignment - Complete Setup Guide

## 📋 Overview
This directory contains a complete Data Warehouse assignment implementation for DSC603, including:
- Star schema design with dimension and fact tables
- 3D data cube representation  
- OLAP operations (Slice, Dice, Roll-up, Drill-down)
- Interactive visualizations and dashboard
- Comprehensive documentation

## 🚀 Quick Start (One-Command Setup)

### Option 1: Automatic Setup
```r
# In R Interactive terminal:
# Option A: If you're already in the read_data folder:
source("install_all_packages.r")  # Install packages
source("dsc603_launcher.r")       # Load launcher
run_full_assignment()             # Run everything

# Option B: Navigate to read_data folder first:
setwd("read_data")  # If read_data folder is in current directory
# OR
setwd("RStudio/read_data")  # If coming from parent directory
# Then run the sources above
```

### Option 2: Manual Step-by-Step
Follow the detailed instructions below.

---

## 📦 Step 1: Package Installation (REQUIRED FIRST STEP)

### Method A: Automatic Package Installation (Recommended)
```r
# Simple options (choose what works for your setup):

# Option 1: Already in read_data folder
source("install_all_packages.r")

# Option 2: Navigate from current location
setwd("read_data")  # If you see read_data folder
source("install_all_packages.r")

# Option 3: Check where you are first
getwd()  # Shows current directory
list.files()  # Shows files in current directory
# Navigate as needed, then source the installer
```

This installs all required packages:
- `dplyr` - Data manipulation
- `ggplot2` - Plotting
- `plotly` - Interactive 3D plots
- `reshape2` - Data reshaping
- `corrplot` - Correlation matrices
- `RColorBrewer` - Color palettes
- `gridExtra` - Multiple plots
- `shiny` - Interactive applications
- `shinydashboard` - Dashboard interface
- `DT` - Interactive data tables

### Method B: Manual Package Installation
If automatic installation fails:
```r
# Install packages individually
install.packages(c("dplyr", "ggplot2", "plotly", "reshape2", 
                   "corrplot", "RColorBrewer", "gridExtra",
                   "shiny", "shinydashboard", "DT"))
```

### ⚠️ Troubleshooting Package Installation
- **Permission Denied**: Run VS Code as Administrator
- **Download Failed**: Try different CRAN mirror:
  ```r
  options(repos = "https://cloud.r-project.org/")
  ```
- **Specific Package Fails**: Install individually:
  ```r
  install.packages("dplyr", dependencies = TRUE)
  ```

---

## 🎯 Step 2: Assignment Execution (Proper Order)

### Method A: One-Click Execution (After packages installed)
```r
source("dsc603_launcher.r")
run_full_assignment()
```

### Method B: Manual Step-by-Step Execution

#### 2.1 Main Data Warehouse Assignment
```r
source("dsc603_datawarehouse_assignment.r")
```
**Creates:**
- ✅ Dimension tables (Time, Employee, Education, Department)  
- ✅ Fact table (Working Load)
- ✅ Data cube representation
- ✅ Slice and Dice operations
- ✅ OLAP analytics

#### 2.2 Advanced Visualizations
```r
source("dsc603_visualizations.r")
```
**Creates:**
- ✅ 3D interactive cube plot
- ✅ Heatmaps and correlation matrices
- ✅ Slice/Dice operation charts
- ✅ Roll-up trend analysis
- ✅ PNG files for presentation

#### 2.3 Interactive Dashboard
```r
source("dsc603_interactive_dashboard.r")
launch_dashboard()  # Opens web browser dashboard
```
**Features:**
- ✅ Interactive 3D cube explorer
- ✅ Dynamic slice operations
- ✅ Multi-dimensional dice filtering
- ✅ Live OLAP analytics
- ✅ Data table browser

---

## 📁 File Structure & Purpose

| File | Purpose | When to Run |
|------|---------|-------------|
| `install_all_packages.r` | Package installation | **FIRST** |
| `dsc603_launcher.r` | Execution manager | After packages |
| `dsc603_datawarehouse_assignment.r` | **Main assignment** | Step 1 |
| `dsc603_visualizations.r` | Enhanced charts | Step 2 |
| `dsc603_interactive_dashboard.r` | Web dashboard | Step 3 |
| `DSC603_Assignment_Documentation.md` | Complete documentation | Reference |
| `R_Script_Guide_for_Python_Developers.md` | R vs Python guide | Reference |

## 📊 Expected Outputs

### After Main Assignment:
- Console output with data summaries
- Dimension and fact tables created
- Cube data structure
- Slice/Dice operation results

### After Visualizations:
- **PNG Files Created:**
  - `working_load_heatmap.png`
  - `slice_q1_visualization.png`
  - `slice_sales_visualization.png`
  - `dice_operation_visualization.png`
  - `rollup_analysis_trends.png`
  - `correlation_matrix.png`
  - `summary_kpi_dashboard.png`

### After Dashboard:
- Interactive web interface opens in browser
- Real-time data exploration tools
- Dynamic filtering and visualization

---

## 🔧 Common Issues & Solutions

### Problem: "Package not found" errors
**Solution:**
```r
source("install_all_packages.r")  # Run package installer first
```

### Problem: "File not found" errors
**Solution:**
```r
# Navigate to the read_data folder containing the assignment files
# Option 1: If you can see read_data folder
setwd("read_data")

# Option 2: Check current location first
getwd()  # Shows where you are
list.files()  # Shows available files/folders

# Option 3: Look for the README.md file
file.exists("README.md")  # Should be TRUE when in correct folder
```

### Problem: Dashboard won't launch
**Solution:**
```r
# Check if main assignment ran successfully first
source("dsc603_datawarehouse_assignment.r")
# Then try dashboard again
source("dsc603_interactive_dashboard.r")
launch_dashboard()
```

### Problem: Plots not displaying
**Solution:**
```r
# For RStudio: Ensure plots pane is visible
# For R terminal: Plots save as PNG files automatically
```

### Problem: Permission denied during package installation
**Solution:**
1. Close VS Code
2. Right-click VS Code → "Run as administrator"  
3. Reopen project and try again

---

## 🎓 Assignment Components Covered

### ✅ Part 1: Data Warehouse Schema Design
- **Time Dimension**: Quarters and months
- **Employee Dimension**: Demographics and career info
- **Education Dimension**: Education levels and fields  
- **Department Dimension**: Departments and job roles
- **Fact Table**: Working load with multiple measures

### ✅ Part 2: Cube Representation  
- **3D Structure**: Time × Department × Education
- **Measures**: Working Load Score, Income, Employee Count
- **Interactive Visualization**: Plotly 3D cube

### ✅ Part 3: Slice and Dice Operations
- **Slice Examples**: Quarter=Q1, Department=Sales
- **Dice Examples**: Multi-dimensional filtering
- **Visual Results**: Charts showing filtered data

### ✅ Part 4: Advanced OLAP (Bonus)
- **Roll-up**: Aggregate by department
- **Drill-down**: Add satisfaction dimension  
- **Pivot**: Rotate data perspectives

---

## 💡 Tips for Success

1. **Always run `install_all_packages.r` first** - This prevents most errors
2. **Check working directory** - Use `getwd()` to verify location
3. **Run scripts in order** - Main → Visualizations → Dashboard
4. **Save your work** - PNG files are automatically generated
5. **Use the launcher** - `run_full_assignment()` handles everything

---

## 📞 Need Help?

### Quick Diagnostic
```r
# Check your setup
getwd()                    # Current directory
list.files()               # Available files  
installed.packages()       # Installed packages
sessionInfo()              # R version info
```

### Emergency Reset
```r
# Start fresh if something goes wrong
rm(list = ls())           # Clear workspace
.rs.restartR()           # Restart R (in RStudio)
source("install_all_packages.r")  # Reinstall packages
```

---

## 🎉 Success Indicators

You'll know everything is working when you see:
- ✅ All packages install without errors
- ✅ Console shows "Assignment completed successfully!"
- ✅ PNG visualization files are created
- ✅ Interactive dashboard opens in browser
- ✅ 3D cube plot displays properly

**Good luck with your DSC603 assignment!** 🎓✨