from fastapi import FastAPI

from database import Base, engine
from inventory.router import router as inventory_router
from inventory import models as inventory_models

Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="StockSense API",
    description="Inventory Management System Backend",
    version="1.0.0"
)

app.include_router(inventory_router)


@app.get("/")
def home():
    return {
        "message": "Welcome to StockSense API",
        "status": "running"
    }


@app.get("/health")
def health_check():
    return {
        "status": "healthy"
    }