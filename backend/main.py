from fastapi import FastAPI

app = FastAPI(
    title="StockSense API",
    description="Inventory Management System Backend",
    version="1.0.0"
)


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