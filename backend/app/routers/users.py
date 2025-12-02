from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from .. import auth, models, schemas
from ..database import get_db

router = APIRouter(prefix="/users", tags=["users"])


@router.get("/me", response_model=schemas.User)
def read_users_me(
    current_user: Annotated[models.User, Depends(auth.get_current_active_user)]
) -> schemas.User:
    return current_user


@router.get("/admins", response_model=list[schemas.User])
def list_admins(db: Annotated[Session, Depends(get_db)]) -> list[models.User]:
    return db.query(models.User).filter(models.User.role == "admin").all()


@router.get("/clients", response_model=list[schemas.User])
def list_clients(db: Annotated[Session, Depends(get_db)]) -> list[models.User]:
    return db.query(models.User).filter(models.User.role == "user").all()


@router.get("/{user_id}", response_model=schemas.User)
def read_user(user_id: int, db: Annotated[Session, Depends(get_db)]) -> models.User:
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user
