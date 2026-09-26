from pydantic import BaseModel
from datetime import datetime


# =========================
# PRODUCT SCHEMAS
# =========================

class ProductCreate(BaseModel):
    name: str
    sku: str
    unit: str


class ProductResponse(BaseModel):
    id: int
    name: str
    sku: str
    unit: str
    created_at: datetime

    class Config:
        from_attributes = True


# =========================
# STOCK ADJUSTMENT SCHEMAS
# =========================

class StockAdjustmentCreate(BaseModel):
    product_id: int
    location_id: int
    system_stock: float
    physical_count: float
    reason: str


class StockAdjustmentResponse(BaseModel):
    id: int
    product_id: int
    location_id: int
    system_stock: float
    physical_count: float
    difference: float
    reason: str
    created_at: datetime

    class Config:
        from_attributes = True