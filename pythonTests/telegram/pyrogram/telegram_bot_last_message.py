import requests
import os
from dotenv import load_dotenv 

load_dotenv()

url = os.getenv("TELEGRAM_GET_UPDATES_URL")

try:
    response = requests.get(url).json()
    result = response['result']
    if len(result) > 0:
        last_update_id = result[len(result) - 1]['update_id']
        offset_url = f"{url}?offset={last_update_id + 1}"
        requests.get(offset_url)
except requests.exceptions.RequestException as e:
    print(f"Error accessing the website: {e}")