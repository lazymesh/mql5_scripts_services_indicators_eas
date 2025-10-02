from fastapi import FastAPI, Body
from pydantic import BaseModel
import uvicorn
from motor.motor_asyncio import AsyncIOMotorClient
from dotenv import load_dotenv
import os

load_dotenv()

app = FastAPI()

# MongoDB connection setup
MONGODB_URL = os.getenv("MONGODB_URL")
DATABASE_NAME = os.getenv("DATABASE_NAME")

client = AsyncIOMotorClient(MONGODB_URL)
database = client[DATABASE_NAME]
history_deals = database["HistoryDeals"]
history_orders = database["HistoryOrders"]
open_positions = database["OpenPositions"]
account_info = database["AccountInfo"]
mt4_history_orders = database["MT4HistoryOrders"]
mt4_open_positions = database["MT4OpenPositions"]
mt4_account_info = database["MT4AccountInfo"]

@app.get("/")
def home():
    return "this is home page"

# Async GET endpoint
@app.get("/last_item/{collection}")
async def last_item(collection: str, q: str | None = None):
    return await get_last_inserted_document(collection)

# Async POST endpoint for history deals
@app.post("/history_deals")
async def historyDeals(histDeals = Body(...)):
    result = await insertData(histDeals, history_deals)
    return result

# Async POST endpoint for history orders
@app.post("/history_orders")
async def historyOrders(histOrders = Body(...)):
    result = await insertData(histOrders, history_orders)
    return result

# Async POST endpoint for open positions
@app.post("/positions")
async def positions(openPositions = Body(...)):
    await database.drop_collection("OpenPositions")
    result = await insertData(openPositions, open_positions)
    return result

# Async POST endpoint for account information
@app.post("/account")
async def account(accountInfo = Body(...)):
    await database.drop_collection("AccountInfo")
    result = await insertData(accountInfo, account_info)
    return result

# Async POST endpoint for history orders
@app.post("/mt4_history_orders")
async def historyOrders(histOrders = Body(...)):
    result = await insertData(histOrders, mt4_history_orders)
    return result

# Async POST endpoint for open positions
@app.post("/mt4_positions")
async def positions(openPositions = Body(...)):
    await database.drop_collection("MT4OpenPositions")
    result = await insertData(openPositions, mt4_open_positions)
    return result

# Async POST endpoint for account information
@app.post("/mt4_account")
async def account(accountInfo = Body(...)):
    await database.drop_collection("MT4AccountInfo")
    result = await insertData(accountInfo, mt4_account_info)
    return result

async def insertData(data, collection):
    data_count = len(data)
    inserted_count = 0
    for i in range(0, data_count):
        result = await collection.insert_one(data[i])
        if result.inserted_id:
            inserted_count = i + 1
            continue
        else:
            break
    if(inserted_count == data_count):
        return {"message": "success"}
    elif inserted_count > 0 and inserted_count < data_count:
        return {"message": "partial_success"}
    else:
        return {"message": "failure"}

async def get_last_inserted_document(collection):
    collection = database[collection]
    
    # Method 1: Sort by _id (ObjectId contains timestamp)
    last_doc = await collection.find_one(
        sort=[("_id", -1)] # -1 for descending (newest first)
    )
    if last_doc:
        # Convert ObjectId to string
        last_doc["_id"] = str(last_doc["_id"])
        print(last_doc)
        return last_doc

if __name__ == "__main__":
    uvicorn.run("fastapi_test:app", host="127.0.0.1", port=8000, reload=True)
