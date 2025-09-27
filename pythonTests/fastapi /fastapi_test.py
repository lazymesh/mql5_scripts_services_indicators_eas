from fastapi import FastAPI, Body
from pydantic import BaseModel
import uvicorn

app = FastAPI()

# Pydantic model for POST body
class Item(BaseModel):
    name: str
    price: float
    in_stock: bool = True

@app.get("/")
def home():
    return "this is home page"

# Async GET endpoint
@app.get("/items/{item_id}")
async def get_item(item_id: int, q: str | None = None):
    return {
        "item_id": item_id,
        "query": q,
        "message": "Item retrieved successfully"
    }


# Async POST endpoint
@app.post("/webhook/")
async def webhook(item: Item = Body(...)):
    return {
        "message": "Item created successfully",
        "item": item.dict()
    }


if __name__ == "__main__":
    uvicorn.run("fastapi_test:app", host="127.0.0.1", port=8000, reload=True)
