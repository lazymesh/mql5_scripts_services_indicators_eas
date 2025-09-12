import requests

url = "https://api.telegram.org/bot8252325868:AAHirzVsByusZQ3F3fUKGg26UCbXT5kFLL8/getUpdates?offset=-1"

try:
    response = requests.get(url)
except requests.exceptions.RequestException as e:
    print(f"Error accessing the website: {e}")