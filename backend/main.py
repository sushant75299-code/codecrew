from fastapi import FastAPI

from database import engine, Base
import models

from routers.auth import router as auth_router
from routers.products import router as products_router


Base.metadata.create_all(bind=engine)


app = FastAPI(
    title="StockSense API",
    description="Inventory Management System Backend",
    version="1.0.0"
)


app.include_router(auth_router)
app.include_router(products_router)


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