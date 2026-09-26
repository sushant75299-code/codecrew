from sqlalchemy import Column, Integer, String, Float, DateTime
from datetime import datetime

from database import Base


class StockAdjustment(Base):
    __tablename__ = "stock_adjustments"

    id = Column(Integer, primary_key=True, index=True)
    product_id = Column(Integer, nullable=False, index=True)

    adjustment_type = Column(String, nullable=False)
    quantity = Column(Float, nullable=False)

    reason = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)