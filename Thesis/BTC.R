# Check and install quantmod package if necessary
if (!requireNamespace("quantmod", quietly = TRUE)) {
  install.packages("quantmod")
}
# Load the quantmod package
library(quantmod)

# Check and install TTR package if necessary
if (!requireNamespace("TTR", quietly = TRUE)) {
  install.packages("TTR")
}
# Load the TTR package
library(TTR)

symbol <- "BTC-USD"

getSymbols(symbol, src = "yahoo", auto.assign = TRUE)

btc_data <- get(symbol)
ma120 <- EMA(Cl(btc_data), 120) 
ma240 <- SMA(Cl(btc_data), 240) 

crossover <- which(diff(sign(ma120 - ma240)) != 0)

chartSeries(btc_data, name = "Bitcoin Price with 120 and 240-day Moving Averages", TA=NULL)
addTA(ma120, on = 1, col = "green", lwd = 2) 
addTA(ma240, on = 1, col = "red", lwd = 2) 

for(i in crossover) {
  
  crossoverDate <- index(btc_data)[i]
  
  if(ma120[i] > ma240[i]) {
    addTA(Cl(btc_data)[crossoverDate], on = 1, pch = 17, col = "gold", lwd = 3, type = 'p')
  } else {
    addTA(Cl(btc_data)[crossoverDate], on = 1, pch = 4, col = "gold", lwd = 3, type = 'p')
  }
}
