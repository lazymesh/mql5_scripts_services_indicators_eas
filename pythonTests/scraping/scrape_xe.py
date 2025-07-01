import requests
from bs4 import BeautifulSoup
import pandas as pd


class Scrape_XE:
    def __init__(self, headers):
        self.headers = headers
        
    def scrape_xe_forex(self):
        url = "https://www.xe.com/currencytables/"
        
        try:
            response = requests.get(url, headers=self.headers)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Find the main currency table
            table = soup.find('table', {'class': 'currencytables__Table-xlq26m-2'})
            
            data = []
            for row in table.find_all('tr')[1:]:  # Skip header row
                cols = row.find_all('td')
                if len(cols) >= 4:
                    currency_code = cols[0].text.strip()
                    currency_name = cols[1].text.strip()
                    units_per_usd = cols[2].text.strip()
                    usd_per_unit = cols[3].text.strip()
                    
                    data.append({
                        'Currency Code': currency_code,
                        'Currency Name': currency_name,
                        'Units per USD': units_per_usd,
                        'USD per Unit': usd_per_unit
                    })
            
            return pd.DataFrame(data)
        
        except Exception as e:
            print(f"Error scraping data: {e}")
            return pd.DataFrame()

