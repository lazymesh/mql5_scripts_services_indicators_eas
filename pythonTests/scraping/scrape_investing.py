import requests
from bs4 import BeautifulSoup
import pandas as pd

class Scrape_Investing:
    def __init__(self, headers):
        self.headers = headers
    
    def scrape_investing_forex(self):
        url = "https://www.investing.com/currencies/single-currency-crosses"
        
        try:
            response = requests.get(url, headers=self.headers)
            response.raise_for_status()  # Check for HTTP errors
            
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Find the table containing forex data
            table = soup.find('table', {'id': 'cr1'})
            
            data = []
            for row in table.find_all('tr')[1:]:  # Skip header row
                cols = row.find_all('td')
                if len(cols) > 1:
                    pair = cols[1].text.strip()
                    bid = cols[2].text.strip()
                    ask = cols[3].text.strip()
                    high = cols[4].text.strip()
                    low = cols[5].text.strip()
                    change = cols[6].text.strip()
                    change_percent = cols[7].text.strip()
                    time = cols[8].text.strip()
                    
                    data.append({
                        'Currency Pair': pair,
                        'Bid': bid,
                        'Ask': ask,
                        'High': high,
                        'Low': low,
                        'Change': change,
                        'Change %': change_percent,
                        'Time': time
                    })
            
            return pd.DataFrame(data)
        
        except Exception as e:
            print(f"Error scraping data: {e}")
            return pd.DataFrame()

