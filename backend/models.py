from sqlalchemy import Column, Integer, String, Float, DateTime
from datetime import datetime

from database import Base


class Product(Base):
    __tablename__ = "products"

    id = Column(Integer, primary_key=True, index=True)

    name = Column(String, nullable=False)
    sku = Column(String, nullable=False, unique=True, index=True)
    unit = Column(String, nullable=False)

    created_at = Column(DateTime, default=datetime.utcnow)


class StockAdjustment(Base):
    __tablename__ = "stock_adjustments"

    id = Column(Integer, primary_key=True, index=True)

    product_id = Column(Integer, nullable=False, index=True)
    location_id = Column(Integer, nullable=False, index=True)

    system_stock = Column(Float, nullable=False)
    physical_count = Column(Float, nullable=False)
    difference = Column(Float, nullable=False)

    reason = Column(String, nullable=False)

    created_at = Column(DateTime, default=datetime.utcnow)


class StockLedger(Base):
    __tablename__ = "stock_ledger"

    id = Column(Integer, primary_key=True, index=True)

    product_id = Column(Integer, nullable=False, index=True)

    operation_type = Column(String, nullable=False, index=True)

    quantity = Column(Float, nullable=False)

    location_id = Column(Integer, nullable=True, index=True)

    source_location_id = Column(Integer, nullable=True)
    destination_location_id = Column(Integer, nullable=True)

    reference_id = Column(String, nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow)