from decimal import Decimal

from sqlalchemy.orm import Session

from .models import (
    Delivery,
    DeliveryItem,
    Inventory,
    Receipt,
    ReceiptItem,
    StockMovement,
    Transfer,
    TransferItem,
)
from .schemas import DeliveryCreate, ReceiptCreate, TransferCreate


def _get_or_create_inventory(
    db: Session,
    product_id: int,
    location_id: int,
) -> Inventory:
    inventory = (
        db.query(Inventory)
        .filter(
            Inventory.product_id == product_id,
            Inventory.location_id == location_id,
        )
        .first()
    )

    if not inventory:
        inventory = Inventory(
            product_id=product_id,
            location_id=location_id,
            quantity=Decimal("0"),
        )
        db.add(inventory)
        db.flush()

    return inventory


# ---------- RECEIPTS ----------

def create_receipt(db: Session, data: ReceiptCreate):
    try:
        receipt = Receipt(
            supplier_id=data.supplier_id,
            location_id=data.location_id,
            status="done",
        )

        db.add(receipt)
        db.flush()

        receipt_item = ReceiptItem(
            receipt_id=receipt.id,
            product_id=data.product_id,
            quantity=data.quantity,
        )

        inventory = _get_or_create_inventory(
            db,
            data.product_id,
            data.location_id,
        )

        inventory.quantity = (
            inventory.quantity + data.quantity
        )

        movement = StockMovement(
            product_id=data.product_id,
            location_id=data.location_id,
            movement_type="receipt",
            quantity=data.quantity,
            reference_id=receipt.id,
        )

        db.add(receipt_item)
        db.add(movement)

        db.commit()
        db.refresh(receipt)

        return {
            "id": receipt.id,
            "supplier_id": receipt.supplier_id,
            "location_id": receipt.location_id,
            "product_id": data.product_id,
            "quantity": data.quantity,
            "status": receipt.status,
            "created_at": receipt.created_at,
        }

    except Exception:
        db.rollback()
        raise


# ---------- DELIVERIES ----------

def create_delivery(db: Session, data: DeliveryCreate):
    try:
        inventory = (
            db.query(Inventory)
            .filter(
                Inventory.product_id == data.product_id,
                Inventory.location_id == data.location_id,
            )
            .first()
        )

        if not inventory:
            raise ValueError("No stock found for this product at this location.")

        if inventory.quantity < data.quantity:
            raise ValueError(
                f"Insufficient stock. Available: {inventory.quantity}"
            )

        delivery = Delivery(
            location_id=data.location_id,
            status="done",
        )

        db.add(delivery)
        db.flush()

        delivery_item = DeliveryItem(
            delivery_id=delivery.id,
            product_id=data.product_id,
            quantity=data.quantity,
        )

        inventory.quantity = (
            inventory.quantity - data.quantity
        )

        movement = StockMovement(
            product_id=data.product_id,
            location_id=data.location_id,
            movement_type="delivery",
            quantity=-data.quantity,
            reference_id=delivery.id,
        )

        db.add(delivery_item)
        db.add(movement)

        db.commit()
        db.refresh(delivery)

        return {
            "id": delivery.id,
            "location_id": delivery.location_id,
            "product_id": data.product_id,
            "quantity": data.quantity,
            "status": delivery.status,
            "created_at": delivery.created_at,
        }

    except Exception:
        db.rollback()
        raise


# ---------- TRANSFERS ----------

def create_transfer(db: Session, data: TransferCreate):
    try:
        if data.source_location_id == data.destination_location_id:
            raise ValueError(
                "Source and destination locations must be different."
            )

        source_inventory = (
            db.query(Inventory)
            .filter(
                Inventory.product_id == data.product_id,
                Inventory.location_id == data.source_location_id,
            )
            .first()
        )

        if not source_inventory:
            raise ValueError(
                "No stock found at the source location."
            )

        if source_inventory.quantity < data.quantity:
            raise ValueError(
                f"Insufficient stock. Available: {source_inventory.quantity}"
            )

        destination_inventory = _get_or_create_inventory(
            db,
            data.product_id,
            data.destination_location_id,
        )

        transfer = Transfer(
            source_location_id=data.source_location_id,
            destination_location_id=data.destination_location_id,
            status="done",
        )

        db.add(transfer)
        db.flush()

        transfer_item = TransferItem(
            transfer_id=transfer.id,
            product_id=data.product_id,
            quantity=data.quantity,
        )

        source_inventory.quantity -= data.quantity
        destination_inventory.quantity += data.quantity

        source_movement = StockMovement(
            product_id=data.product_id,
            location_id=data.source_location_id,
            movement_type="transfer",
            quantity=-data.quantity,
            reference_id=transfer.id,
        )

        destination_movement = StockMovement(
            product_id=data.product_id,
            location_id=data.destination_location_id,
            movement_type="transfer",
            quantity=data.quantity,
            reference_id=transfer.id,
        )

        db.add(transfer_item)
        db.add(source_movement)
        db.add(destination_movement)

        db.commit()
        db.refresh(transfer)

        return {
            "id": transfer.id,
            "source_location_id": transfer.source_location_id,
            "destination_location_id": transfer.destination_location_id,
            "product_id": data.product_id,
            "quantity": data.quantity,
            "status": transfer.status,
            "created_at": transfer.created_at,
        }

    except Exception:
        db.rollback()
        raise


# ---------- GET RECEIPTS ----------

def get_receipts(db: Session):
    receipts = (
        db.query(Receipt)
        .order_by(Receipt.id.desc())
        .all()
    )

    result = []

    for receipt in receipts:
        item = (
            db.query(ReceiptItem)
            .filter(ReceiptItem.receipt_id == receipt.id)
            .first()
        )

        if item:
            result.append({
                "id": receipt.id,
                "supplier_id": receipt.supplier_id,
                "location_id": receipt.location_id,
                "product_id": item.product_id,
                "quantity": item.quantity,
                "status": receipt.status,
                "created_at": receipt.created_at,
            })

    return result


# ---------- GET DELIVERIES ----------

def get_deliveries(db: Session):
    deliveries = (
        db.query(Delivery)
        .order_by(Delivery.id.desc())
        .all()
    )

    result = []

    for delivery in deliveries:
        item = (
            db.query(DeliveryItem)
            .filter(DeliveryItem.delivery_id == delivery.id)
            .first()
        )

        if item:
            result.append({
                "id": delivery.id,
                "location_id": delivery.location_id,
                "product_id": item.product_id,
                "quantity": item.quantity,
                "status": delivery.status,
                "created_at": delivery.created_at,
            })

    return result


# ---------- GET TRANSFERS ----------

def get_transfers(db: Session):
    transfers = (
        db.query(Transfer)
        .order_by(Transfer.id.desc())
        .all()
    )

    result = []

    for transfer in transfers:
        item = (
            db.query(TransferItem)
            .filter(TransferItem.transfer_id == transfer.id)
            .first()
        )

        if item:
            result.append({
                "id": transfer.id,
                "source_location_id": transfer.source_location_id,
                "destination_location_id": transfer.destination_location_id,
                "product_id": item.product_id,
                "quantity": item.quantity,
                "status": transfer.status,
                "created_at": transfer.created_at,
            })

    return result