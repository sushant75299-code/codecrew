from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import Product, StockAdjustment, StockLedger
from schemas import (
    StockAdjustmentCreate,
    StockAdjustmentResponse,
    StockLedgerResponse
)


# ==========================================
# STOCK ADJUSTMENT ROUTER
# ==========================================

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
    # Find product
    product = db.query(Product).filter(
        Product.id == adjustment.product_id
    ).first()

    if not product:
        raise HTTPException(
            status_code=404,
            detail="Product not found"
        )

    # Current system stock comes from Product.stock
    system_stock = product.stock or 0

    # Calculate difference
    difference = adjustment.physical_count - system_stock

    # Update actual product stock
    product.stock = adjustment.physical_count

    # Create adjustment record
    new_adjustment = StockAdjustment(
        product_id=adjustment.product_id,
        location_id=adjustment.location_id,
        system_stock=system_stock,
        physical_count=adjustment.physical_count,
        difference=difference,
        reason=adjustment.reason
    )

    db.add(new_adjustment)
    db.flush()

    # Create ledger movement
    ledger_entry = StockLedger(
        product_id=adjustment.product_id,
        operation_type="adjustment",
        quantity=difference,
        location_id=adjustment.location_id,
        reference_id=str(new_adjustment.id)
    )

    db.add(ledger_entry)

    db.commit()
    db.refresh(new_adjustment)

    return new_adjustment


# ==========================================
# GET ALL ADJUSTMENTS
# ==========================================

@router.get(
    "/",
    response_model=list[StockAdjustmentResponse]
)
def get_stock_adjustments(
    db: Session = Depends(get_db)
):
    return db.query(StockAdjustment).order_by(
        StockAdjustment.created_at.desc()
    ).all()


# ==========================================
# GET SINGLE ADJUSTMENT
# ==========================================

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


# ==========================================
# DELETE ADJUSTMENT
# ==========================================

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


# ==========================================
# STOCK ROUTES
# ==========================================

stock_router = APIRouter(
    prefix="/stock",
    tags=["Stock"]
)


# GET STOCK LEDGER
@stock_router.get(
    "/ledger",
    response_model=list[StockLedgerResponse]
)
def get_stock_ledger(
    db: Session = Depends(get_db)
):
    return db.query(StockLedger).order_by(
        StockLedger.created_at.desc()
    ).all()


# GET LOW STOCK PRODUCTS
@stock_router.get("/low-stock")
def get_low_stock_products(
    db: Session = Depends(get_db)
):
    products = db.query(Product).filter(
        Product.stock <= Product.reorder_level,
        Product.stock > 0
    ).all()

    return products


# GET OUT OF STOCK PRODUCTS
@stock_router.get("/out-of-stock")
def get_out_of_stock_products(
    db: Session = Depends(get_db)
):
    products = db.query(Product).filter(
        Product.stock <= 0
    ).all()

    return products


# ==========================================
# REQUIRED /adjustments ALIAS
# ==========================================

adjustments_router = APIRouter(
    prefix="/adjustments",
    tags=["Adjustments"]
)


@adjustments_router.post(
    "/",
    response_model=StockAdjustmentResponse,
    status_code=201
)
def create_adjustment_alias(
    adjustment: StockAdjustmentCreate,
    db: Session = Depends(get_db)
):
    product = db.query(Product).filter(
        Product.id == adjustment.product_id
    ).first()

    if not product:
        raise HTTPException(
            status_code=404,
            detail="Product not found"
        )

    system_stock = product.stock or 0
    difference = adjustment.physical_count - system_stock

    product.stock = adjustment.physical_count

    new_adjustment = StockAdjustment(
        product_id=adjustment.product_id,
        location_id=adjustment.location_id,
        system_stock=system_stock,
        physical_count=adjustment.physical_count,
        difference=difference,
        reason=adjustment.reason
    )

    db.add(new_adjustment)
    db.flush()

    ledger_entry = StockLedger(
        product_id=adjustment.product_id,
        operation_type="adjustment",
        quantity=difference,
        location_id=adjustment.location_id,
        reference_id=str(new_adjustment.id)
    )

    db.add(ledger_entry)

    db.commit()
    db.refresh(new_adjustment)

    return new_adjustment