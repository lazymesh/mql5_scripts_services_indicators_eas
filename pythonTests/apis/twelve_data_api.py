import requests
import pandas as pd

def get_twelve_data_forex(api_key, symbol='EUR/USD', interval='1min', output_size=10):
    """
    Get forex data from Twelve Data
    Free tier: 8 requests per minute, 800 per day
    """
    url = f"https://api.twelvedata.com/time_series?symbol={symbol}&interval={interval}&outputsize={output_size}&apikey={api_key}"
    
    try:
        response = requests.get(url)
        response.raise_for_status()
        data = response.json()
        
        if data.get('status') == 'error':
            print("Error:", data.get('message', 'Unknown error'))
            return pd.DataFrame()
            
        df = pd.DataFrame(data['values'])
        df['datetime'] = pd.to_datetime(df['datetime'])
        return df.sort_values('datetime')
        
    except Exception as e:
        print(f"Error fetching Twelve Data: {e}")
        return pd.DataFrame()

# Usage
twelve_data_key = "YOUR_API_KEY"  # Get from https://twelvedata.com/pricing
twelve_data = get_twelve_data_forex(twelve_data_key)
print(twelve_data.head())