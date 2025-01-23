# Define a function to install and import a package
def install_and_import(package):
    try:
        __import__(package)
        print(f"{package} is already installed.")
    except ImportError:
        print(f"{package} is not installed. Attempting installation...")
        try:
            # Use subprocess to call pip install for the package
            subprocess.check_call([sys.executable, "-m", "pip", "install", package])
            print(f"{package} was successfully installed.")
        except Exception as e:
            # Handle exceptions during installation and print the error
            print(f"Error during the installation of {package}: {e}")
            return None
    finally:
        # Attempt to import the package again after installation
        globals()[package] = __import__(package)

# List of all libraries needed
libraries = [
    're',  # Used for regex operations
    'yfinance',  # Used to fetch financial data
    'subprocess',  # Used to execute shell commands from Python
    'sys',  # Provides access to some variables used or maintained by the Python interpreter
    'matplotlib.pyplot',  # Used for plotting graphs
    "datetime"
]

import matplotlib.pyplot as plt  # Import matplotlib for plotting

print("\n" + "-"*50 + "\n")

# Use the function to install and import each library from the list
for library in libraries:
    install_and_import(library)

print("\n" + "-"*50 + "\n")

#####################################################################################################################

class UserAccount:
    def __init__(self, username, password, email, first_name=None, last_name=None):
        self.username = username
        self.__password = password
        self.email = email
        self.first_name = first_name
        self.last_name = last_name
        self.wallets = []  # Uses a list to manage multiple wallets

    def set_username(self, new_username):
        self.username = new_username

    def set_password(self, new_password):
        self.__password = new_password

    def set_email(self, new_email):
        self.email = new_email

    def set_first_name(self, new_first_name):
        self.first_name = new_first_name

    def set_last_name(self, new_last_name):
        self.last_name = new_last_name

    def add_wallet(self, new_wallet):
        # Checks if a wallet with the same name already exists
        if any(wallet.name == new_wallet.name for wallet in self.wallets):
            print(f"A wallet named '{new_wallet.name}' already exists for user {self.username}.")
            return False  # Indicates the wallet was not added
        # Adds the new wallet to the list
        self.wallets.append(new_wallet)
        print(f"Wallet '{new_wallet.name}' successfully added for user {self.username}.")
        return True  # Indicates the wallet was successfully added

    def remove_wallet(self, wallet_to_remove):
        # Searches for the wallet by its name
        for idx, wallet in enumerate(self.wallets):
            if wallet.name == wallet_to_remove.name:
                del self.wallets[idx]  # Removes the wallet from the list
                print(f"Wallet '{wallet_to_remove.name}' was successfully removed.")
                return True  # Indicates the wallet was successfully removed
        print(f"No wallet named '{wallet_to_remove.name}' found.")
        return False  # Indicates the wallet was not found and therefore not removed

    def view_total_liquidity(self):
        total_liquidity = sum(wallet.cash for wallet in self.wallets)
        return total_liquidity

    def get_user_info(self):
        info = f"Username: {self.username}, Email: {self.email}, First Name: {self.first_name}, Last Name: {self.last_name}"
        if self.wallets:
            info += "\nWallets:"
            for wallet in self.wallets:
                info += f"\n- {wallet.name}"
            total_liquidity = self.view_total_liquidity()
            info += f"\nTotal liquidity available across all wallets: {total_liquidity} USD"
        else:
            info += "\nNo wallets created."

        print(info)
        return info

"""
user1 = UserAccount("johnDoe123", "supersecretpassword", "johndoe@example.com", "John", "Doe")
print(user1.get_user_info())

Updating user information
user1.set_email("newemail@example.com")
user1.set_first_name("Johnny")
user1.set_last_name("Doe II")
print(user1.get_user_info())
"""

################################################################################################################################################################

# Remplacer 'BTC-USD' par le ticker de votre choix
"""
ticker = yfinance.Ticker("BTC-USD")
info = ticker.info
Imprime toutes les clés et leurs valeurs associées
for key, value in info.items():
   print(f"{key}: {value}")
"""
    
class Crypto:
    def __init__(self, ticker):
        self.ticker = ticker
        self.info = None
        self.load_info()

    def load_info(self):
        """Loads the cryptocurrency information from Yahoo Finance."""
        try:
            self.info = yfinance.Ticker(self.ticker).info
        except Exception as e:
            print(f"Error while loading information for {self.ticker}: {e}")

    def get_price_close(self):
        """Returns the current price."""
        return self.info.get('previousClose') if self.info else None

    def get_volume(self):
        """Returns the current volume."""
        return self.info.get('regularMarketVolume') if self.info else None
    
    def get_market_cap(self):
        """Returns the market capitalization."""
        return self.info.get('marketCap') if self.info else "Market cap information not available."

    def get_description(self):
        """Returns the description."""
        return self.info.get('longDescription') if self.info else None

    def extract_price_from_description(self):
        """Extracts the price from the description."""
        description = self.get_description()
        if description:
            match = re.search(r"The last known price of Bitcoin is ([\d,]+.\d+) USD", description)
            if match:
                return match.group(1)
            else:
                return "Price not found in the description."
        else:
            return "Description not available."

    def analyze_investment_opportunity(self):
        """Analyzes the investment opportunity based on historical data."""
        # Download historical data for the specified ticker
        today = datetime.datetime.today().strftime('%Y-%m-%d')
        data = yfinance.download(self.ticker, start="2020-01-01", end=today)
        
        # Calculate the moving averages for 120 and 240 days
        data['MA120'] = data['Adj Close'].rolling(window=120).mean()
        data['MA240'] = data['Adj Close'].rolling(window=240).mean()

        # Investment decision based on moving averages
        last_MA120 = data['MA120'].iloc[-1]
        last_MA240 = data['MA240'].iloc[-1]
        if last_MA120 > last_MA240:
            decision = "It's a good time to invest as MA120 > MA240."
        else:
            decision = "It's not a favorable time to invest as MA120 < MA240."

        # Display the chart
        plt.figure(figsize=(14, 7))
        plt.plot(data['Adj Close'], label='Adjusted Close Price', color='blue')
        plt.plot(data['MA120'], label='MA 120 days', color='green', linestyle='--')
        plt.plot(data['MA240'], label='MA 240 days', color='red', linestyle='--')
        plt.title(f'Bitcoin Course Analysis with MA120 and MA240\n{decision}')
        plt.xlabel('Date')
        plt.ylabel('Adjusted Close Price')
        plt.legend()
        plt.show()

        return decision

        
########################################################################################################################

class Bitcoin(Crypto):
    def __init__(self):
        super().__init__('BTC-USD')

tickers = [
    'BTC-USD',  # Bitcoin
    'ETH-USD',  # Ethereum
    'BNB-USD',  # Binance Coin
    'XRP-USD',  # XRP
    'SOL-USD',  # Solana
    'ADA-USD',  # Cardano
    'DOT-USD',  # Polkadot
    'DOGE-USD', # Dogecoin
    'LTC-USD',  # Litecoin
    'LINK-USD'  # Chainlink
]

# Processing information for each cryptocurrency

for ticker in tickers:
    crypto = Crypto(ticker)
    # Uncomment the lines below to print information for each cryptocurrency
    """
    print(f"{ticker} Price Close: {crypto.get_price_close()} USD")
    print(f"{ticker} Volume: {crypto.get_volume()}")
    # print(f"{ticker} Description: {crypto.get_description()}")
    print(f"{ticker} Market Cap: {crypto.get_market_cap()} USD")
    print("\n" + "-"*50 + "\n")
    """


#######################################################################################################

class Wallet:
    def __init__(self, name):
        self.name = name
        self.cash = 0  # This attribute holds the cash value
        self.crypto_balances = {}
        self.transaction_history = []
    
    def set_name(self, new_name):
        self.name = new_name
        print(f"The wallet's name has been changed to '{new_name}'.")

    def view_transaction_history(self):
        if self.transaction_history:
            print("Transaction History:")
            for transaction in self.transaction_history:
                print(transaction)
        else:
            print("No transactions have been made.")

    def get_wallet_info(self):
        info = f"Wallet Name: {self.name}\nAvailable Cash: {self.cash} USD\n"
        if self.crypto_balances:
            info += "Cryptocurrency Balances:\n"
            for ticker, quantity in self.crypto_balances.items():
                info += f"  {ticker}: {quantity}\n"
        else:
            info += "No cryptocurrency in this wallet.\n"
        info += "\nTransaction History:\n" + ("\n".join(self.transaction_history) if self.transaction_history else "No transactions made.")
        print(info)

    def add_cash(self):
        amount = input("How much cash would you like to add? ")
        try:
            amount = float(amount)
            if amount > 0:
                self.cash += amount
                self.transaction_history.append(f"Added {amount} USD to cash.")
                print(f"{amount} USD added to cash. Total cash: {self.cash} USD.")
            else:
                print("Please enter a positive amount.")
        except ValueError:
            print("Please enter a valid number.")

    def withdraw_cash(self, amount):
        try:
            amount = float(amount)
            if amount > 0 and self.cash >= amount:
                self.cash -= amount
                self.transaction_history.append(f"Withdrew {amount} USD from cash.")
                print(f"{amount} USD withdrawn from cash. Remaining cash: {self.cash} USD.")
            elif amount <= 0:
                print("Please enter a positive amount.")
            else:
                print("Insufficient balance.")
        except ValueError:
            print("Please enter a valid number.")

    def view_balances(self):
        print(f"Available Cash: {self.cash} USD")
        print("Cryptocurrency Balances:")
        for ticker, quantity in self.crypto_balances.items():
            print(f"  {ticker}: {quantity}")

    def buy_crypto(self):
        available_tickers = ['BTC-USD', 'ETH-USD', 'BNB-USD', 'XRP-USD', 'SOL-USD', 'ADA-USD', 'DOT-USD', 'DOGE-USD', 'LTC-USD', 'LINK-USD']
        while True:
            ticker = input(f"Which crypto would you like to buy from the following: {', '.join(available_tickers)}? Enter the ticker or 'cancel' to exit: ").strip()
            if ticker == 'cancel':
                print("Operation cancelled.")
                break
            if ticker not in available_tickers:
                print("This ticker is not on the list of available cryptos. Please try again or cancel.")
                continue

            try:
                total_amount = float(input("Enter the total amount in USD you wish to spend: "))
            except ValueError:
                print("Please enter a valid number.")
                continue

            crypto = Crypto(ticker)
            current_price = crypto.get_price_close()
            if current_price is None:
                print(f"Unable to fetch the current price for {ticker}. Please try again.")
                continue

            fee = total_amount * 0.05  # Platform fee calculation
            amount_after_fee = total_amount - fee  # Effective amount for the purchase

            if self.cash >= total_amount:
                purchasable_quantity = amount_after_fee / current_price
                self.crypto_balances[ticker] = self.crypto_balances.get(ticker, 0) + purchasable_quantity
                self.cash -= total_amount  # Deducting the total amount including fees
                Platform.charge_fee(fee)  # Adding fees to the platform's total fees
                print(f"Successful purchase: {purchasable_quantity} of {ticker} for {amount_after_fee} USD (5% fees included).")
                print(f"Remaining Cash: {self.cash} USD.")
                break
            else:
                print("Purchase failed. Insufficient cash balance.")
                break

    def sell_crypto(self):
        if not self.crypto_balances:
            print("Your cryptocurrency wallet is empty.")
            return

        while True:
            print("Cryptos available for sale in your wallet:")
            for ticker, quantity in self.crypto_balances.items():
                print(f"{ticker}: {quantity}")

            ticker = input("Enter the ticker of the crypto you wish to sell or 'cancel' to exit: ").strip()

            if ticker.lower() == 'cancel':
                print("Operation cancelled.")
                break

            if ticker not in self.crypto_balances:
                print("This ticker is not present in your wallet. Please try again.")
                continue

            quantity_to_sell = self.crypto_balances[ticker]

            crypto = Crypto(ticker)
            current_price = crypto.get_price_close()
            if current_price is None:
                print(f"Unable to fetch the current price for {ticker}. Please try again.")
                continue

            amount_received = quantity_to_sell * current_price
            self.cash += amount_received
            del self.crypto_balances[ticker]
            print(f"Successful sale: You sold {quantity_to_sell} {ticker} for a total of {amount_received} USD.")
            self.transaction_history.append(f"Sale of {quantity_to_sell} {ticker} received {amount_received} USD.")
            print(f"Remaining Cash: {self.cash} USD.")  # Display remaining cash after the sale
            break

#####################################################################################################################################

class Platform:
    _instance = None
    total_fees = 0  # Tracking the total fees accumulated by the platform

    def __new__(cls, name, siret, location):
        if cls._instance is None:
            cls._instance = super(Platform, cls).__new__(cls)
            cls._instance.name = name
            cls._instance.siret = siret
            cls._instance.location = location
            cls._instance.users = []
        return cls._instance

    @classmethod
    def charge_fee(cls, fee):
        cls.total_fees += fee
        print(f"Fee of {fee} USD added. Total fees accumulated: {cls.total_fees} USD.")

    def add_user(self, user):
        self.users.append(user)
        print(f"User {user.username} added to the platform.")

    def remove_user(self, user):
        self.users = [u for u in self.users if u.username != user.username]
        print(f"User {user.username} removed from the platform.")

    @classmethod
    def pay_taxes(cls):
        taxes = cls.total_fees * 0.30
        cls.total_fees -= taxes
        print(f"Taxes of {taxes} USD paid. Remaining fees: {cls.total_fees} USD.")

#################################################################################################################################
platform = Platform("CryptoPlatform", "10", "Paris")
#################################################################################################################################    
user1 = UserAccount("johnDoe123", "supersecretpassword", "johndoe@example.com", "John", "Doe")
platform.add_user(user1)
user1.get_user_info()
###########################################################################################################################
print()
wallet1 = Wallet("wallet1")
wallet2 = Wallet("wallet2")

user1.add_wallet(wallet1)
user1.get_user_info()
print()
user1.add_wallet(wallet2)
user1.get_user_info()
print()
user1.remove_wallet(wallet2)
user1.get_user_info()
####################################################################################################################################
print()
wallet1.add_cash()
print()
########################################################################################################################################
# Create an instance for Bitcoin
crypto_btc = Crypto("BTC-USD")
investment_decision = crypto_btc.analyze_investment_opportunity()
######################################################################################################################################
print(investment_decision)
wallet1.buy_crypto()
wallet1.buy_crypto()
print()
wallet1.sell_crypto()
wallet1.sell_crypto()
print()
wallet1.view_balances()
print()
wallet1.view_transaction_history()
wallet1.view_balances()
#####################################################################################################################################
# Display total fees
print()
print(f"Total fees accumulated on the platform: {Platform.total_fees} USD")

# Paying taxes
platform.pay_taxes()

# Display remaining fees after paying taxes
print(f"Fees remaining after taxes: {Platform.total_fees} USD")
