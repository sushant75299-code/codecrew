from database import Base, engine
from routers.stock_adjustments import router as stock_adjustments_router
from fastapi import FastAPI

app = FastAPI(
    title="StockSense API",
    description="Inventory Management System Backend",
    version="1.0.0"
)

Base.metadata.create_all(bind=engine)

app.include_router(stock_adjustments_router)


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