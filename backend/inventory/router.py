from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db

from .schemas import (
    DeliveryCreate,
    DeliveryResponse,
    ReceiptCreate,
    ReceiptResponse,
    TransferCreate,
    TransferResponse,
)

from .service import (
    create_delivery,
    create_receipt,
    create_transfer,
    get_deliveries,
    get_receipts,
    get_transfers,
)


router = APIRouter(
    tags=["Inventory Operations"]
)


# ---------- RECEIPTS ----------

@router.post(
    "/receipts",
    response_model=ReceiptResponse,
    status_code=201,
)
def add_receipt(
    data: ReceiptCreate,
    db: Session = Depends(get_db),
):
    try:
        return create_receipt(db, data)
    except ValueError as error:
        raise HTTPException(
            status_code=400,
            detail=str(error),
        )


@router.get(
    "/receipts",
    response_model=list[ReceiptResponse],
)
def list_receipts(
    db: Session = Depends(get_db),
):
    return get_receipts(db)


# ---------- DELIVERIES ----------

@router.post(
    "/deliveries",
    response_model=DeliveryResponse,
    status_code=201,
)
def add_delivery(
    data: DeliveryCreate,
    db: Session = Depends(get_db),
):
    try:
        return create_delivery(db, data)
    except ValueError as error:
        raise HTTPException(
            status_code=400,
            detail=str(error),
        )


@router.get(
    "/deliveries",
    response_model=list[DeliveryResponse],
)
def list_deliveries(
    db: Session = Depends(get_db),
):
    return get_deliveries(db)


# ---------- TRANSFERS ----------

@router.post(
    "/transfers",
    response_model=TransferResponse,
    status_code=201,
)
def add_transfer(
    data: TransferCreate,
    db: Session = Depends(get_db),
):
    try:
        return create_transfer(db, data)
    except ValueError as error:
        raise HTTPException(
            status_code=400,
            detail=str(error),
        )


@router.get(
    "/transfers",
    response_model=list[TransferResponse],
)
def list_transfers(
    db: Session = Depends(get_db),
):
    return get_transfers(db)