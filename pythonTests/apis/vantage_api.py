import requests
import pandas as pd

def get_alpha_vantage_forex(api_key, from_currency='USD', to_currency='EUR'):
    """
    Get real-time forex data from Alpha Vantage
    Free tier: 5 requests per minute, 500 requests per day
    """
    url = f"https://www.alphavantage.co/query?function=CURRENCY_EXCHANGE_RATE&from_currency={from_currency}&to_currency={to_currency}&apikey={api_key}"
    
    try:
        response = requests.get(url)
        response.raise_for_status()
        data = response.json()
        
        if "Realtime Currency Exchange Rate" in data:
            rate_data = data["Realtime Currency Exchange Rate"]
            return {
                'from_currency': rate_data['1. From_Currency Code'],
                'to_currency': rate_data['3. To_Currency Code'],
                'exchange_rate': rate_data['5. Exchange Rate'],
                'last_refreshed': rate_data['6. Last Refreshed'],
                'time_zone': rate_data['7. Time Zone'],
                'bid_price': rate_data['8. Bid Price'],
                'ask_price': rate_data['9. Ask Price']
            }
        else:
            print("Error:", data.get("Note", "Unknown error"))
            return None
            
    except Exception as e:
        print(f"Error fetching Alpha Vantage data: {e}")
        return None

# Usage
alpha_vantage_key = "YOUR_API_KEY"  # Get from https://www.alphavantage.co/support/#api-key
forex_data = get_alpha_vantage_forex(alpha_vantage_key, 'USD', 'EUR')
print(pd.DataFrame([forex_data]))