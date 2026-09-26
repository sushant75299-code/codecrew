from sqlalchemy import Column, Integer, String, Float, ForeignKey
from database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, nullable=False, index=True)
    password_hash = Column(String, nullable=False)


class Product(Base):
    __tablename__ = "products"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    sku = Column(String, nullable=False, index=True)
    category = Column(String, nullable=False)
    unit = Column(String, nullable=False)
    stock = Column(Float, default=0)
    reorder_level = Column(Float, default=0)

    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)

class PasswordResetOTP(Base):
    __tablename__ = "password_reset_otps"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, nullable=False, index=True)
    otp = Column(String, nullable=False)
    expires_at = Column(String, nullable=False)