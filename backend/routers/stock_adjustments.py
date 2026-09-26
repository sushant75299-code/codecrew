from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import StockAdjustment
from schemas import StockAdjustmentCreate, StockAdjustmentResponse


router = APIRouter(
    prefix="/stock-adjustments",
    tags=["Stock Adjustments"]
)


@router.post(
    "/",
    response_model=StockAdjustmentResponse,
    status_code=201
)
def create_stock_adjustment(
    adjustment: StockAdjustmentCreate,
    db: Session = Depends(get_db)
):
    new_adjustment = StockAdjustment(
        product_id=adjustment.product_id,
        adjustment_type=adjustment.adjustment_type,
        quantity=adjustment.quantity,
        reason=adjustment.reason
    )

    db.add(new_adjustment)
    db.commit()
    db.refresh(new_adjustment)

    return new_adjustment


@router.get(
    "/",
    response_model=list[StockAdjustmentResponse]
)
def get_stock_adjustments(
    db: Session = Depends(get_db)
):
    return db.query(StockAdjustment).all()


@router.get(
    "/{adjustment_id}",
    response_model=StockAdjustmentResponse
)
def get_stock_adjustment(
    adjustment_id: int,
    db: Session = Depends(get_db)
):
    adjustment = db.query(StockAdjustment).filter(
        StockAdjustment.id == adjustment_id
    ).first()

    if not adjustment:
        raise HTTPException(
            status_code=404,
            detail="Stock adjustment not found"
        )

    return adjustment


@router.delete(
    "/{adjustment_id}",
    status_code=204
)
def delete_stock_adjustment(
    adjustment_id: int,
    db: Session = Depends(get_db)
):
    adjustment = db.query(StockAdjustment).filter(
        StockAdjustment.id == adjustment_id
    ).first()

    if not adjustment:
        raise HTTPException(
            status_code=404,
            detail="Stock adjustment not found"
        )

    db.delete(adjustment)
    db.commit()