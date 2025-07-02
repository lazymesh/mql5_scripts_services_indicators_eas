import requests
from bs4 import BeautifulSoup
import pandas as pd
from playwright.sync_api import sync_playwright
from time import sleep

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
        
    def scrape_forex_with_playwright(self):
        url = "https://www.investing.com/currencies/streaming-forex-rates-majors"
        
        with sync_playwright() as p:
            # Launch browser (chromium, firefox or webkit)
            browser = p.chromium.launch(headless=True)  # Set headless=False to see browser
            page = browser.new_page()
            
            # Set user agent to mimic real browser
            page.set_extra_http_headers({
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
            })
            
            try:
                # Navigate to page
                page.goto(url, timeout=15000)
                print("Page loaded successfully")
                
                # Wait for the table to load (adjust selector as needed)
                page.wait_for_selector('#cr1', timeout=10000)
                
                # Add a small delay to ensure all data is loaded
                sleep(2)
                
                # Extract table data
                table = page.query_selector('#cr1')
                rows = table.query_selector_all('tbody tr')
                
                data = []
                for row in rows:
                    cols = row.query_selector_all('td')
                    if len(cols) >= 8:
                        data.append({
                            'Pair': cols[1].inner_text().strip(),
                            'Bid': cols[2].inner_text().strip(),
                            'Ask': cols[3].inner_text().strip(),
                            'High': cols[4].inner_text().strip(),
                            'Low': cols[5].inner_text().strip(),
                            'Change': cols[6].inner_text().strip(),
                            'Change%': cols[7].inner_text().strip(),
                            'Time': cols[8].inner_text().strip()
                        })
                
                return pd.DataFrame(data)
                
            except Exception as e:
                print(f"Error occurred: {e}")
                return pd.DataFrame()
            
            finally:
                browser.close()

