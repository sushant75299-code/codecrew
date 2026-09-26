from pydantic import BaseModel
from datetime import datetime


class StockAdjustmentCreate(BaseModel):
    product_id: int
    adjustment_type: str
    quantity: float
    reason: str


class StockAdjustmentResponse(BaseModel):
    id: int
    product_id: int
    adjustment_type: str
    quantity: float
    reason: str
    created_at: datetime

    class Config:
        from_attributes = True