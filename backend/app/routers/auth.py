from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from .. import auth, models, schemas
from ..database import get_db

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/register", response_model=schemas.User, status_code=status.HTTP_201_CREATED)
def register_user(
    user_in: schemas.UserCreate, db: Annotated[Session, Depends(get_db)]
) -> schemas.User:
    if db.query(models.User).filter(models.User.username == user_in.username).first():
        raise HTTPException(status_code=400, detail="Username already registered")
    if db.query(models.User).filter(models.User.email == user_in.email).first():
        raise HTTPException(status_code=400, detail="Email already registered")

    db_user = models.User(
        username=user_in.username,
        email=user_in.email,
        full_name=user_in.full_name,
        role=user_in.role,
        hashed_password=auth.get_password_hash(user_in.password),
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user


@router.post("/login", response_model=schemas.Token)
async def login_for_token(
    token: Annotated[schemas.Token, Depends(auth.login_for_access_token)]
) -> schemas.Token:
    return token
