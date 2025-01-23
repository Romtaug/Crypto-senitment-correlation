# Load necessary libraries: quantmod, readxl, and FactoMineR
if (!require(quantmod)) {
  install.packages("quantmod")
  library(quantmod)
}

if (!require(readxl)) {
  install.packages("readxl")
  library(readxl)
}

if (!require(FactoMineR)) {
  install.packages("FactoMineR")
  library(FactoMineR)
}

# Loading the necessary packages: quantmod, TTR, openxlsx, and FactoMineR
# quantmod is already covered in the previous block.

if (!require(TTR)) {
  install.packages("TTR")
  library(TTR)
}

if (!require(openxlsx)) {
  install.packages("openxlsx")
  library(openxlsx)
}

# FactoMineR is also already covered in the previous block.


# Downloading and preparing Bitcoin data
symbol <- "BTC-USD"
getSymbols(symbol, src = "yahoo", auto.assign = TRUE)
btc_recent <- window(get(symbol), start = as.Date("2024-01-22"), end = as.Date("2024-02-19"))
btc_df <- data.frame(Date = index(btc_recent), BTC_Close = Cl(btc_recent), BTC_Volume = Vo(btc_recent))

# Reading and preparing additional data from an Excel file
file_path <- "tweets.xlsx"
data <- read.xlsx(file_path)
data$Date <- as.Date(data$Date, format="%m-%d-%y %H:%M")
data <- data[, !(names(data) %in% c("Post", "User"))] # Removing unnecessary columns
daily_averages <- aggregate(. ~ Date, data, mean)

# Calculating moving averages for 'a' and 'v' as examples
# Assume 'a' and 'v' are the columns for which you want to calculate mv and ma
#daily_averages$mv <- rollmean(daily_averages$a, 7, fill = NA, align = 'right')
#daily_averages$ma <- rollmean(daily_averages$v, 2, fill = NA, align = 'right')

# Merging Bitcoin data with additional daily averages
final_df <- merge(btc_df, daily_averages, by = "Date", all = TRUE)

# Removing rows with NA values
final_df_cleaned <- na.omit(final_df)

# Renaming 'BTC_Close' and 'BTC_Volume' columns to 'price' and 'volume'
names(final_df_cleaned)[names(final_df_cleaned) == "BTC.USD.Close"] <- "price"
names(final_df_cleaned)[names(final_df_cleaned) == "BTC.USD.Volume"] <- "volume"

# Removing the 'Date' column as PCA can only be applied to numerical data
final_df_cleaned$Date <- NULL

# Performing PCA
res.pca <- PCA(final_df_cleaned, graph = TRUE)

# Displaying PCA results
print(res.pca)
