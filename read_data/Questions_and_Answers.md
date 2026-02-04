# Questions and Answers - Interactive Data Analysis

## Question 1: What does the interactive 3D data cube show us?
![alt text](image-2.png)
**Answer:** 
The interactive 3D data cube visualizes HR employee data across three key dimensions:
- **Education Level** (x-axis): Shows different levels of employee education (1-5 scale)
- **Department** (y-axis): Displays various company departments (Human Resources, Research & Development, Sales)
- **Quarter** (z-axis): Represents time periods (Q1, Q2, Q3, Q4)

Each yellow dot represents data points (likely employees) positioned in this 3D space based on their education level, department, and the quarter being analyzed. This visualization allows us to:
- Identify patterns in employee distribution across departments and education levels over time
- Spot clusters or gaps in the data
- Perform OLAP operations like slice, dice, roll-up, and drill-down to analyze employee attrition patterns
- Understand the relationship between education, department placement, and temporal trends

The cube enables multidimensional analysis of the HR Employee Attrition dataset, making it easier to discover insights about workforce composition and potential attrition factors.

## Question 2: What does the slice operation plot represent, and what is the significance of each bubble with respect to slicing in data mining?

**Answer:**
![alt text](image-1.png)
This plot shows a **slice operation** where the Quarter dimension is fixed to Q2, creating a 2D view from the 3D cube.

**What Slicing Does in Data Mining:**
Slicing **reduces dimensions** by fixing one dimension to a specific value. It's like cutting a piece from the data cube to focus on a subset.

**In This Plot:**
- Each bubble = employees with specific Education Level + Department in Q2 only
- Bubble size = number of employees
- Bubble color = department type
- Shows patterns within just Q2 data, ignoring other quarters

**Extended Analysis - Department Slice (New Image):**
The new image shows a **different slice** - this time the **Department dimension is fixed to "Human Resources"** only.
![alt text](image.png)

**Key Differences:**
- **X-axis**: Quarter (Q1, Q2, Q3, Q4) - time progression
- **Y-axis**: Education Level (1-5)
- **All bubbles are orange/red** because they're all Human Resources employees
- **Bubble size**: Employee count at each education level per quarter
- **Color intensity**: Represents AvgWorkingLoadScore (darker = higher workload)

**Why the Table Shows Only HR Data:**
The table displays **only Human Resources entries** because the slice operation filtered out all other departments (Research & Development, Sales). This demonstrates how slicing creates focused subsets - we can now analyze HR workforce patterns across quarters and education levels without noise from other departments.

**Purpose:** Slicing helps analysts focus on specific subsets of data (like "only Q2 employees" or "only HR employees") to find patterns without being overwhelmed by the full dataset.

---
