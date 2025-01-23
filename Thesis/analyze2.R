# Check and load the openxlsx package
if (!require(openxlsx)) {
  install.packages("openxlsx")
  library(openxlsx)
}

# Check and load the ggplot2 package
if (!require(ggplot2)) {
  install.packages("ggplot2")
  library(ggplot2)
}

# Check and load the zoo package
if (!require(zoo)) {
  install.packages("zoo")
  library(zoo)
}



# Path to the Excel file
file_path <- "tweets.xlsx"

# Read the Excel file into a data frame
data <- read.xlsx(file_path)

# Convert the 'Date' column to Date format to keep only the date (year-month-day)
data$Date <- as.Date(data$Date, format="%m-%d-%y %H:%M")

# Remove 'Post' and 'User' columns from the data frame
data$Post <- NULL
data$User <- NULL

# Calculate daily averages
daily_averages <- aggregate(. ~ Date, data, mean)

# Calculate moving averages
# You can adjust the window width (here 2 for a moving average over 2 days)
daily_averages$mv = rollmean(daily_averages$v, 3, fill = NA, align = 'right')
daily_averages$ma = rollmean(daily_averages$a, 7, fill = NA, align = 'right')

# Create the plot for 'a' with moving averages
# Plot for 'a'
ggplot(daily_averages, aes(x = Date)) + 
  geom_line(aes(y = a, colour = "a"), size = 0.5, linetype = "dashed") +  # Fine line for 'a' points
  geom_point(aes(y = a, colour = "a"), size = 1) +  # Small points for 'a'
  geom_line(aes(y = ma, colour = "Moving Average of a"), size = 1.5) +  # Thicker line for 'ma'
  scale_color_manual(values = c("a" = "red", "Moving Average of a" = "darkred")) +
  labs(title = "Daily Averages and Moving Averages for 'a'",
       x = "Date",
       y = "Value",
       colour = "Variable") +
  theme_minimal()

# Plot for 'v'
ggplot(daily_averages, aes(x = Date)) + 
  geom_line(aes(y = v, colour = "v"), size = 0.5, linetype = "dashed") +  # Fine line for 'v' points
  geom_point(aes(y = v, colour = "v"), size = 1) +  # Small points for 'v'
  geom_line(aes(y = mv, colour = "Moving Average of v"), size = 1.5) +  # Thicker line for 'mv'
  scale_color_manual(values = c("v" = "blue", "Moving Average of v" = "darkblue")) +
  labs(title = "Daily Averages and Moving Averages for 'v'",
       x = "Date",
       y = "Value",
       colour = "Variable") +
  theme_minimal()
