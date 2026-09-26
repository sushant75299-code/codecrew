from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from database import Base, engine

from routers.stock_adjustments import (
    router as stock_adjustments_router,
    stock_router,
    adjustments_router,
)

from routers.products import router as products_router


# Create database tables
Base.metadata.create_all(bind=engine)


app = FastAPI(
    title="StockSense API",
    description="Inventory Management System Backend",
    version="1.0.0",
)


# Register routers
app.include_router(stock_adjustments_router)
app.include_router(stock_router)
app.include_router(adjustments_router)
app.include_router(products_router)


# Allow Flutter frontend to communicate with FastAPI
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"https?://(localhost|127\.0\.0\.1)(:\d+)?$",
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def home():
    return {
        "message": "Welcome to StockSense API",
        "status": "running",
    }


@app.get("/health")
def health_check():
    return {
        "status": "healthy",
    }