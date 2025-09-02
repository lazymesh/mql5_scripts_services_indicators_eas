from pyrogram import Client
from dotenv import load_dotenv
import os

load_dotenv()

api_id = os.getenv("TELEGRAM_API_ID")
api_hash = os.getenv("TELEGRAM_API_HASH")

with Client("gen", api_id, api_hash, True) as app:
    app.start()
    print(app.export_session_string())
    app.stop()
