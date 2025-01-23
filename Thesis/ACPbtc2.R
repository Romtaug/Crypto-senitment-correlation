# Check and load the quantmod package
if (!require(quantmod)) {
  install.packages("quantmod")
  library(quantmod)
}

# Check and load the readxl package
if (!require(readxl)) {
  install.packages("readxl")
  library(readxl)
}

# Check and load the FactoMineR package
if (!require(FactoMineR)) {
  install.packages("FactoMineR")
  library(FactoMineR)
}


# Download and prepare Bitcoin data
symbol <- "BTC-USD"
getSymbols(symbol, src = "yahoo", auto.assign = TRUE)
btc_recent <- window(get(symbol), start = as.Date("2024-01-22"), end = as.Date("2024-02-19"))
btc_df <- data.frame(Date = index(btc_recent), BTC_Close = Cl(btc_recent), BTC_Volume = Vo(btc_recent))

head(btc_df)

# Read and prepare additional data from an Excel file
file_path <- "tweets.xlsx"  # Ensure this path is correct
data <- read_excel(file_path)

# Determine sentiment based on the difference from 5
data$differenceFrom5 <- data$a - 5

# Create the 'sentiment' column based on the difference
data$sentiment <- ifelse(data$differenceFrom5 > 0, "positive", "negative")

# Rename 'v' column to 'virality'
data$virality <- data$v

# Calculate the 'weightedSentiment' by multiplying the difference by virality
data$weightedSentiment <- data$differenceFrom5 * data$virality 

# Adjust 'weightedSentiment' values to determine the sentiment strength
data$sentimentStrength <- ifelse(data$weightedSentiment > 0, "positive", 
                                 ifelse(data$weightedSentiment < 0, "negative", "neutral"))

# Adjust the Date column in `data` to match the format of `btc_df`
data$Date <- as.Date(data$Date, format = "%m-%d-%y")
data <- data[, c("Date", "weightedSentiment")]

# Regrouper les données par date et calculer la somme de `weightedSentiment`
data <- aggregate(weightedSentiment ~ Date, data = data, sum)


head(data)


head(btc_df)

# Convertir la colonne `Date` au format date
data$Date <- as.Date(data$Date, format = "%m-%d-%y")
head(data)
# Regrouper les données par date et calculer la somme de `weightedSentiment`
data_summed <- aggregate(weightedSentiment ~ Date, data = data, sum)
head(data)
# Now, try merging again
merged_data <- merge(btc_df, data, by = "Date")


print(names(merged_data))
head(merged_data)

# Correcting the column names for PCA
final_df_cleaned <- merged_data[, c("BTC.USD.Close", "BTC.USD.Volume", "weightedSentiment")]

head(final_df_cleaned)

# Renaming these columns for clarity before PCA
final_df_cleaned <- setNames(final_df_cleaned, c("Close", "Volume", "weightedSentiment"))

# Verify column names after rename
print(names(final_df_cleaned))

head(final_df_cleaned)

# Performing PCA on the 'Close', 'Volume', and 'weightedSentiment' columns
res.pca <- PCA(final_df_cleaned, graph = TRUE)

# Displaying PCA results
print(res.pca)

