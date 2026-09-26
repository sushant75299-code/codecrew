from pydantic import BaseModel, EmailStr


# =========================
# USER SCHEMAS
# =========================

class UserCreate(BaseModel):
    name: str
    email: EmailStr
    password: str


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserResponse(BaseModel):
    id: int
    name: str
    email: EmailStr

    class Config:
        from_attributes = True


class TokenResponse(BaseModel):
    access_token: str
    token_type: str


# =========================
# PRODUCT SCHEMAS
# =========================

class ProductCreate(BaseModel):
    name: str
    sku: str
    category: str
    unit: str
    stock: float = 0
    reorder_level: float = 0


class ProductUpdate(BaseModel):
    name: str
    sku: str
    category: str
    unit: str
    stock: float
    reorder_level: float


class ProductResponse(BaseModel):
    id: int
    name: str
    sku: str
    category: str
    unit: str
    stock: float
    reorder_level: float
    user_id: int

    class Config:
        from_attributes = True


# =========================
# STOCK ADJUSTMENT
# =========================

class StockAdjustmentCreate(BaseModel):
    product_id: int
    location_id: int
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

    class Config:
        from_attributes = True


# =========================
# STOCK LEDGER
# =========================

class StockLedgerResponse(BaseModel):
    id: int
    product_id: int
    operation_type: str
    quantity: float
    location_id: int | None
    source_location_id: int | None
    destination_location_id: int | None
    reference_id: str | None

    class Config:
        from_attributes = True