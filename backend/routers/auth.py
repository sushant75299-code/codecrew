import secrets
from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import User, PasswordResetOTP
from schemas import UserCreate, UserLogin, UserResponse, TokenResponse
from auth import hash_password, verify_password, create_access_token


router = APIRouter(
    prefix="/auth",
    tags=["Authentication"]
)


@router.post("/register", response_model=UserResponse)
def register(
    user_data: UserCreate,
    db: Session = Depends(get_db)
):
    existing_user = db.query(User).filter(
        User.email == user_data.email
    ).first()

    if existing_user:
        raise HTTPException(
            status_code=400,
            detail="Email already registered"
        )

    user = User(
        name=user_data.name,
        email=user_data.email,
        password_hash=hash_password(user_data.password)
    )

    db.add(user)
    db.commit()
    db.refresh(user)

    return user


@router.post("/login", response_model=TokenResponse)
def login(
    user_data: UserLogin,
    db: Session = Depends(get_db)
):
    user = db.query(User).filter(
        User.email == user_data.email
    ).first()

    if not user or not verify_password(
        user_data.password,
        user.password_hash
    ):
        raise HTTPException(
            status_code=401,
            detail="Invalid email or password"
        )

    token = create_access_token(user.id)

    return {
        "access_token": token,
        "token_type": "bearer"
    }


@router.post("/forgot-password")
def forgot_password(
    email: str,
    db: Session = Depends(get_db)
):
    user = db.query(User).filter(
        User.email == email
    ).first()

    if not user:
        raise HTTPException(
            status_code=404,
            detail="User not found"
        )

    otp = str(secrets.randbelow(900000) + 100000)

    expires_at = datetime.now(timezone.utc) + timedelta(minutes=10)

    reset_otp = PasswordResetOTP(
        email=email,
        otp=otp,
        expires_at=expires_at.isoformat()
    )

    db.add(reset_otp)
    db.commit()

    # Temporary for development/testing.
    # Later we will send the OTP by email.
    return {
        "message": "OTP generated successfully",
        "otp": otp
    }

@router.post("/reset-password")
def reset_password(
    email: str,
    otp: str,
    new_password: str,
    db: Session = Depends(get_db)
):
    reset_record = db.query(PasswordResetOTP).filter(
        PasswordResetOTP.email == email,
        PasswordResetOTP.otp == otp
    ).order_by(
        PasswordResetOTP.id.desc()
    ).first()

    if not reset_record:
        raise HTTPException(
            status_code=400,
            detail="Invalid OTP"
        )

    expires_at = datetime.fromisoformat(reset_record.expires_at)

    if datetime.now(timezone.utc) > expires_at:
        raise HTTPException(
            status_code=400,
            detail="OTP expired"
        )

    user = db.query(User).filter(
        User.email == email
    ).first()

    if not user:
        raise HTTPException(
            status_code=404,
            detail="User not found"
        )

    user.password_hash = hash_password(new_password)

    db.delete(reset_record)
    db.commit()

    return {
        "message": "Password reset successfully"
    }