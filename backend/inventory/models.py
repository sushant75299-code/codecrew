from datetime import datetime

from sqlalchemy import Column, DateTime, Integer, Numeric, String

from database import Base


class Inventory(Base):
    __tablename__ = "inventory"

    id = Column(Integer, primary_key=True, index=True)
    product_id = Column(Integer, nullable=False, index=True)
    location_id = Column(Integer, nullable=False, index=True)
    quantity = Column(Numeric(12, 2), default=0, nullable=False)


class Receipt(Base):
    __tablename__ = "receipts"

    id = Column(Integer, primary_key=True, index=True)
    supplier_id = Column(Integer, nullable=True)
    location_id = Column(Integer, nullable=False)
    status = Column(String, default="draft", nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)


class ReceiptItem(Base):
    __tablename__ = "receipt_items"

    id = Column(Integer, primary_key=True, index=True)
    receipt_id = Column(Integer, nullable=False)
    product_id = Column(Integer, nullable=False)
    quantity = Column(Numeric(12, 2), nullable=False)


class Delivery(Base):
    __tablename__ = "deliveries"

    id = Column(Integer, primary_key=True, index=True)
    location_id = Column(Integer, nullable=False)
    status = Column(String, default="draft", nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)


class DeliveryItem(Base):
    __tablename__ = "delivery_items"

    id = Column(Integer, primary_key=True, index=True)
    delivery_id = Column(Integer, nullable=False)
    product_id = Column(Integer, nullable=False)
    quantity = Column(Numeric(12, 2), nullable=False)


class Transfer(Base):
    __tablename__ = "transfers"

    id = Column(Integer, primary_key=True, index=True)
    source_location_id = Column(Integer, nullable=False)
    destination_location_id = Column(Integer, nullable=False)
    status = Column(String, default="draft", nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)


class TransferItem(Base):
    __tablename__ = "transfer_items"

    id = Column(Integer, primary_key=True, index=True)
    transfer_id = Column(Integer, nullable=False)
    product_id = Column(Integer, nullable=False)
    quantity = Column(Numeric(12, 2), nullable=False)


class StockMovement(Base):
    __tablename__ = "stock_movements"

    id = Column(Integer, primary_key=True, index=True)
    product_id = Column(Integer, nullable=False, index=True)
    location_id = Column(Integer, nullable=False, index=True)
    movement_type = Column(String, nullable=False)
    quantity = Column(Numeric(12, 2), nullable=False)
    reference_id = Column(Integer, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)