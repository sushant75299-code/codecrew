from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import StockAdjustment
from schemas import StockAdjustmentCreate, StockAdjustmentResponse


router = APIRouter(
    prefix="/stock-adjustments",
    tags=["Stock Adjustments"]
)


# CREATE STOCK ADJUSTMENT
@router.post(
    "/",
    response_model=StockAdjustmentResponse,
    status_code=201
)
def create_stock_adjustment(
    adjustment: StockAdjustmentCreate,
    db: Session = Depends(get_db)
):

    # Calculate difference automatically
    difference = adjustment.physical_count - adjustment.system_stock

    new_adjustment = StockAdjustment(
        product_id=adjustment.product_id,
        location_id=adjustment.location_id,
        system_stock=adjustment.system_stock,
        physical_count=adjustment.physical_count,
        difference=difference,
        reason=adjustment.reason
    )

    db.add(new_adjustment)
    db.commit()
    db.refresh(new_adjustment)

    return new_adjustment


# GET ALL STOCK ADJUSTMENTS
@router.get(
    "/",
    response_model=list[StockAdjustmentResponse]
)
def get_stock_adjustments(
    db: Session = Depends(get_db)
):
    return db.query(StockAdjustment).all()


# GET ONE STOCK ADJUSTMENT
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


# DELETE STOCK ADJUSTMENT
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