import requests
import pandas as pd
import json

def get_oanda_forex(api_key, account_id, instrument='EUR_USD', count=10):
    """
    Get forex data from OANDA
    Free tier: Limited to practice accounts with demo data
    """
    headers = {
        'Authorization': f'Bearer {api_key}',
        'Content-Type': 'application/json'
    }
    
    url = f"https://api-fxpractice.oanda.com/v3/accounts/{account_id}/instruments/{instrument}/candles?granularity=M1&count={count}"
    
    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        data = response.json()
        
        candles = []
        for candle in data['candles']:
            candles.append({
                'time': candle['time'],
                'volume': candle['volume'],
                'open': candle['mid']['o'],
                'high': candle['mid']['h'],
                'low': candle['mid']['l'],
                'close': candle['mid']['c']
            })
            
        return pd.DataFrame(candles)
        
    except Exception as e:
        print(f"Error fetching OANDA data: {e}")
        return pd.DataFrame()

# Usage
oanda_key = "YOUR_API_KEY"  # Get from OANDA developer portal
oanda_account_id = "YOUR_ACCOUNT_ID"  # Your practice account ID
oanda_data = get_oanda_forex(oanda_key, oanda_account_id)
print(oanda_data.head())