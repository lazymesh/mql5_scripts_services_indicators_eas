from pyrogram import Client, filters
from pyrogram.enums import ChatType
from dotenv import load_dotenv
import os

load_dotenv()

bridge_channel = -1002739062404   # your bridge channel ID
source_channels = [-1002960500255,]

pairs = [
    "AUDUSD", "AUDJPY", "CADJPY", "CHFJPY",
    "EURUSD", "EURJPY", "EURGBP", "EURCAD", "EURAUD", "EURNZD", "EURCHF", "GBPUSD", 
    "GBPJPY", "GBPCAD", "GBPAUD", "GBPNZD", "GBPCHF", "NZDUSD", "NZDJPY", 
    "USDCHF", "USDJPY", "USDCAD"
]

buy_trade_types = ["buying", "buy"]
sell_trade_types = ["selling", "sell"]

app = Client("my_account", api_id=os.getenv("TELEGRAM_API_ID"), api_hash=os.getenv("TELEGRAM_API_HASH"))

def list_joined_channels():
    with app:
        print("Fetching dialogs...")
        for dialog in app.get_dialogs():
            if dialog.chat.type in [ChatType.CHANNEL, ChatType.SUPERGROUP]:
                print(f"Channel Name: {dialog.chat.title} (ID: {dialog.chat.id})")
                
def worldMostProfitableChannel(text):
    result = ""
    lowercaseText = text.lower()
    for pair in pairs:
        if pair in text:
            result = result + f"pair: {pair} "
    if "buy" in lowercaseText:
        result = result + "type: buy"
    elif "sell" in lowercaseText:
        result = result + "type: sell"
    textArray = lowercaseText.split("\n")
    for signal in textArray:
        if len(signal) > 0:
            if "take profit at:" in signal:
                result = result + signal.replace("take profit at:", " tp:")
            if "stop loss at:" in signal:
                result = result + signal.replace("stop loss at:", " sl:")
    return result
                
                
@app.on_message(filters.chat(source_channels))
async def forward_to_bridge(client, message):
    toBeForwarded = message.text
    if "new signal" in message.text.lower():
        toBeForwarded = worldMostProfitableChannel(message.text)
    await client.send_message(
        chat_id=bridge_channel,
        text=toBeForwarded
    )
    print(f"Forwarded: {toBeForwarded}")

if __name__ == "__main__":
    #list_joined_channels()
    if app.is_connected:
        print("app is already conneced")
    else:
        print("app just started now listening...")
        app.run()