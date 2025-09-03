from pyrogram import Client, filters
from pyrogram.enums import ChatType
from dotenv import load_dotenv
import os

load_dotenv()

bridge_channel = -1002739062404   # your bridge channel ID
source_channels = [-1002960500255,]

app = Client("my_account", api_id=os.getenv("TELEGRAM_API_ID"), api_hash=os.getenv("TELEGRAM_API_HASH"))

# with app:
#     for message in app.get_chat_history("SomeChannel", limit=5):
#         print(message.text)


def list_joined_channels():
    with app:
        print("Fetching dialogs...")
        for dialog in app.get_dialogs():
            if dialog.chat.type in [ChatType.CHANNEL, ChatType.SUPERGROUP]:
                print(f"Channel Name: {dialog.chat.title} (ID: {dialog.chat.id})")
                
@app.on_message(filters.chat(source_channels))
def forward_to_bridge(client, message):
    print(message.text, source_channels)
    message.forward(chat_id=bridge_channel)
    print(f"Forwarded: {message.text}")

if __name__ == "__main__":
    if app.is_connected:
        print("app is already conneced")
    else:
        app.run()