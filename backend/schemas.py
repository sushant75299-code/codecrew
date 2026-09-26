from pydantic import BaseModel, EmailStr


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