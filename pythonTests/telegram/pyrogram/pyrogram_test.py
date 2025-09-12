from pyrogram import Client, filters
from pyrogram.enums import ChatType
from dotenv import load_dotenv
import os

load_dotenv()

# your bridge channel ID
bridge_channel = -1002739062404
source_channels = [
    -1001986228221, # World’s Most Profitable Forex Signals 🔥📈
    -1001800276787, # FREE SIGNALS (Forex channel)
    -1002468597860, # VASILY TRADER
    -1002632623445, # FX GOAT TRADING (Signals Free)🐐
    -1002556657124, # SureShot FX (Gold Signals) ®️ 
    -1001175463265, # Forex GDP - Free Signals 
    -1002296311807  # Kara Trading
]

pairs = [
    "AUDUSD", "AUDJPY", "CADJPY", "CHFJPY",
    "EURUSD", "EURJPY", "EURGBP", "EURCAD", "EURAUD", "EURNZD", "EURCHF", "GBPUSD", 
    "GBPJPY", "GBPCAD", "GBPAUD", "GBPNZD", "GBPCHF", "NZDCAD", "NZDUSD", "NZDJPY", 
    "USDCHF", "USDJPY", "USDCAD", "XAUUSD", "GOLD"
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

                
def worldMostProfitableChannel(lowercaseText):
    return prepareResultJson(lowercaseText, "World_Most_Profitable_Channel")

def forexSignal(lowercaseText):
    return prepareResultJson(lowercaseText, "Forex_Signal")
                
def vasilyTrader(lowercaseText):
    return prepareResultJson(lowercaseText, "Vasily_Trader")

def fxGoatTrading(lowercaseText):
    return prepareResultJson(lowercaseText, "Forex_Goat_Trading")

def sureShotFx(lowercaseText):
    return prepareResultJson(lowercaseText, "Sure_Shot_Forex")

def forexGDP(lowercaseText):
    return prepareResultJson(lowercaseText, "Forex_GDP")

def karaTrading(lowercaseText):
    if "long-term" in lowercaseText or "long position" in lowercaseText:
        lowercaseText = lowercaseText.replace("entry:\n", "buy: ")
    if "short" in lowercaseText and "market price" in lowercaseText:
        lowercaseText = lowercaseText.replace("entry:\n", "sell: ")
    lowercaseText = lowercaseText.replace("targets:\n", "tp: ")
    lowercaseText = lowercaseText.replace("stop loss:\n", "sl: ")
    lowercaseText = lowercaseText.replace("/", "")
    return prepareResultJson(lowercaseText, "Kara_Trading")
    

def prepareResultJson(lowercaseText, clientStr):
    result = "{" + getSourceStr(clientStr)
    result = commonResult(lowercaseText, result)
    return commonExtractor(lowercaseText, result)
                
def getSourceStr(source):
    return f"\"source\":\"{source}\","
    
def commonExtractor(lowercaseText, result):
    textArray = lowercaseText.split("\n")
    for signal in textArray:
        if len(signal) > 0:
            if ("@" in signal or "sell" in signal or "buy" in signal) and "price" not in result:
                result = extractAndAdd(result, signal, "price", "")
            if ("tp" in signal or "take profit" in signal or "target" in signal) and "tp" not in result:
                result = extractAndAdd(result, signal, "tp", "tp")
            if ("sl" in signal or "stop loss" in signal) and "sl" not in result:
                result = extractAndAdd(result, signal, "sl", "sl")
    return result[:len(result) - 1] + "}"

def extractAndAdd(result, signal, key, replaceStr):
    extractedPrice = valueExtractor(signal, replaceStr)
    if extractedPrice != "":
        result = result + f" \"{key}\":{extractedPrice[:6]},"
    return result

def valueExtractor(signal, replaceStr):
    if " " in signal:
        return loopValues(" ", signal)
    elif ":" in signal:
        return loopValues(":", signal)
    elif "-" in signal:
        return loopValues("-", signal)
    else:
        return signal.replace(replaceStr, "").strip()
    
def loopValues(splitter, signal):
    splittedSignal = signal.split(splitter)
    for value in reversed(splittedSignal):
        checkValue = value.strip()
        checkValue = valueExtractor(checkValue, "-") if "-" in checkValue else checkValue
        if checkValue.replace('.', '', 1).isdigit():
            return checkValue
    return ""

    
def commonResult(lowercaseText, result):
    for pair in pairs:
        if pair.lower() in lowercaseText:
            result = result + f" \"pair\":\"{"XAUUSD" if pair == "GOLD" else pair}\","
    if "buy" in lowercaseText:
        result = result + " \"type\":\"buy\","
    elif "sell" in lowercaseText:
        result = result + " \"type\":\"sell\","
    return result
                
@app.on_message(filters.chat(source_channels))
async def forward_to_bridge(client, message):
    if message is not None and message.text is not None:
        toBeForwarded = message.text.lower()
        if message.chat.id == -1001986228221:
            toBeForwarded = worldMostProfitableChannel(toBeForwarded)
        if message.chat.id == -1001800276787:
            toBeForwarded = forexSignal(toBeForwarded)
        if message.chat.id == -1002468597860:
            toBeForwarded = vasilyTrader(toBeForwarded)
        if message.chat.id == -1002632623445:
            toBeForwarded = fxGoatTrading(toBeForwarded)
        if message.chat.id == -1002556657124:
            toBeForwarded = sureShotFx(toBeForwarded)
        if message.chat.id == -1001175463265:
            toBeForwarded = forexGDP(toBeForwarded)
        if message.chat.id == -1002296311807:
            toBeForwarded = karaTrading(toBeForwarded)
        if "pair" in toBeForwarded and "type" in toBeForwarded and "price" in toBeForwarded and "sl" in toBeForwarded and "tp" in toBeForwarded:
            await client.send_message(
                chat_id=bridge_channel,
                text=toBeForwarded
            )
            print(f"Forwarded: {toBeForwarded}")

if __name__ == "__main__":
    if app.is_connected:
        print("app is already conneced")
    else:
        print("app just started now listening...")
        app.run()