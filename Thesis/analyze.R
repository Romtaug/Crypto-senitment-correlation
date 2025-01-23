# Check and load the openxlsx package
if (!require(openxlsx)) {
  install.packages("openxlsx")
  library(openxlsx)
}


# Path to the Excel file
file_path <- "output_weekly.xlsx"

# Start and end dates for each week
start_dates <- as.Date(c("2024-01-22", "2024-01-29", "2024-02-05", "2024-02-12", "2024-02-19"))
end_dates <- as.Date(c("2024-01-28", "2024-02-04", "2024-02-11", "2024-02-18", "2024-02-25"))

# Names of the weeks
week_names <- c("Week1", "Week2", "Week3", "Week4", "Week5")

# Initialize a vector to store the number of rows per week
num_rows_per_week <- numeric(length(week_names) - 1)  # Minus one week

# Initialize a vector to store the average of the 'v' column per week
mean_v_per_week <- numeric(length(week_names) - 1)  # Minus one week

# Initialize a vector to store the average of the 'a' column per week
mean_a_per_week <- numeric(length(week_names) - 1)  # Minus one week

# Loop through each week to calculate the number of rows and the average of 'v' and 'a'
for (i in seq_along(week_names)) {
  if (week_names[i] != "Week5") {  # Check if the week name is not Week5
    # Read the data for the current week
    data <- read.xlsx(file_path, sheet = week_names[i])
    
    # Calculate and store the number of rows
    num_rows_per_week[i] <- nrow(data)
    
    # Calculate and store the average of 'v', making sure there are no NAs
    mean_v_per_week[i] <- mean(data$v, na.rm = TRUE)
    
    # Calculate and store the average of 'a', making sure there are no NAs
    mean_a_per_week[i] <- mean(data$a, na.rm = TRUE)
  }
}

# Create a dataframe to store the results
result_df <- data.frame(
  Week = week_names[week_names != "Week5"],  # Exclude Week5 from week names
  Start_Date = start_dates[week_names != "Week5"],  # Exclude Week5 from start dates
  End_Date = end_dates[week_names != "Week5"],  # Exclude Week5 from end dates
  Num_Posts = num_rows_per_week,
  Mean_V = mean_v_per_week,
  Mean_A = mean_a_per_week
)

# Print the results
print(result_df)
