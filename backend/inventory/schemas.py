from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, Field


# ---------- Receipt ----------

class ReceiptCreate(BaseModel):
    supplier_id: int | None = None
    location_id: int
    product_id: int
    quantity: Decimal = Field(gt=0)


class ReceiptResponse(BaseModel):
    id: int
    supplier_id: int | None
    location_id: int
    product_id: int
    quantity: Decimal
    status: str
    created_at: datetime

    class Config:
        from_attributes = True


# ---------- Delivery ----------

class DeliveryCreate(BaseModel):
    location_id: int
    product_id: int
    quantity: Decimal = Field(gt=0)


class DeliveryResponse(BaseModel):
    id: int
    location_id: int
    product_id: int
    quantity: Decimal
    status: str
    created_at: datetime

    class Config:
        from_attributes = True


# ---------- Transfer ----------

class TransferCreate(BaseModel):
    source_location_id: int
    destination_location_id: int
    product_id: int
    quantity: Decimal = Field(gt=0)


class TransferResponse(BaseModel):
    id: int
    source_location_id: int
    destination_location_id: int
    product_id: int
    quantity: Decimal
    status: str
    created_at: datetime

    class Config:
        from_attributes = True