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


# Spécification du symbole du Bitcoin sur Yahoo Finance
symbol <- "BTC-USD"

# Téléchargement des données du Bitcoin pour la période spécifiée
getSymbols(symbol, src = "yahoo", auto.assign = TRUE)

# Calcul des moyennes mobiles de 120 et 240 jours
btc_data <- get(symbol)
ma120 <- EMA(Cl(btc_data), 120) # Moyenne mobile exponentielle sur 120 jours
ma240 <- SMA(Cl(btc_data), 240) # Moyenne mobile simple sur 240 jours

# Créer le graphique pour le prix avec moyennes mobiles
#chartSeries(btc_data, name = "Bitcoin Price", TA=NULL, subset = '2024-01-22::2024-02-19')

# Créer le graphique pour le volume des transactions
chartSeries(btc_data, name = "Bitcoin Volume", TA="addVo()", subset = '2024-01-29::2024-02-04')
