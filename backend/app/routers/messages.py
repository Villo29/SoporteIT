from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from .. import auth, models, schemas
from ..database import get_db

router = APIRouter(prefix="/messages", tags=["messages"])


@router.get("/history", response_model=list[schemas.Message])
def list_messages(
    limit: int = Query(default=50, ge=1, le=200),
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[models.User, Depends(auth.get_current_active_user)],
) -> list[models.Message]:
    return (
        db.query(models.Message)
        .order_by(models.Message.created_at.desc())
        .limit(limit)
        .all()
    )


@router.post("/send", response_model=schemas.Message, status_code=status.HTTP_201_CREATED)
def send_message(
    message_in: schemas.MessageCreate,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[models.User, Depends(auth.get_current_active_user)],
) -> models.Message:
    if message_in.receiver_id is not None:
        receiver = db.query(models.User).filter(models.User.id == message_in.receiver_id).first()
        if receiver is None:
            raise HTTPException(status_code=404, detail="Receiver not found")

    db_message = models.Message(
        sender_id=current_user.id,
        receiver_id=message_in.receiver_id,
        content=message_in.content,
    )
    db.add(db_message)
    db.commit()
    db.refresh(db_message)
    return db_message
