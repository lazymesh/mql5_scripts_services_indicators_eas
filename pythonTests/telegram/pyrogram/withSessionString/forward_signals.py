from pyrogram import Client, filters
from pyrogram.session import StringSession

api_id = 123456
api_hash = "your_api_hash_here"

# Paste the session string you got earlier
session_string = "your_session_string_here"

bridge_channel = -1001234567890   # your bridge channel ID
source_channels = ["ForexSignalsFree", "SomeOtherProvider"]

app = Client(StringSession(session_string), api_id, api_hash)

@app.on_message(filters.chat(source_channels))
def forward_to_bridge(client, message):
    message.forward(chat_id=bridge_channel)
    print(f"Forwarded: {message.text}")

print("Listening for signals...")
app.run()
