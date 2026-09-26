from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import Product, User
from dependencies import get_current_user


router = APIRouter(
    prefix="/products",
    tags=["Products"]
)


@router.post("/")
def create_product(
    name: str,
    sku: str,
    category: str,
    unit: str,
    stock: float = 0,
    reorder_level: float = 0,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    product = Product(
        name=name,
        sku=sku,
        category=category,
        unit=unit,
        stock=stock,
        reorder_level=reorder_level,
        user_id=current_user.id
    )

    db.add(product)
    db.commit()
    db.refresh(product)

    return product


@router.get("/")
def get_products(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    products = db.query(Product).filter(
        Product.user_id == current_user.id
    ).all()

    return products


@router.put("/{product_id}")
def update_product(
    product_id: int,
    name: str,
    sku: str,
    category: str,
    unit: str,
    stock: float,
    reorder_level: float,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    product = db.query(Product).filter(
        Product.id == product_id,
        Product.user_id == current_user.id
    ).first()

    if product is None:
        raise HTTPException(
            status_code=404,
            detail="Product not found"
        )

    product.name = name
    product.sku = sku
    product.category = category
    product.unit = unit
    product.stock = stock
    product.reorder_level = reorder_level

    db.commit()
    db.refresh(product)

    return product


@router.delete("/{product_id}")
def delete_product(
    product_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    product = db.query(Product).filter(
        Product.id == product_id,
        Product.user_id == current_user.id
    ).first()

    if product is None:
        raise HTTPException(
            status_code=404,
            detail="Product not found"
        )

    db.delete(product)
    db.commit()

    return {
        "message": "Product deleted successfully"
    }