from datetime import datetime
from typing import Optional

from pydantic import BaseModel, EmailStr, Field


class MessageBase(BaseModel):
    content: str = Field(..., min_length=1, max_length=1000)
    receiver_id: Optional[int] = None


class MessageCreate(MessageBase):
    pass


class Message(MessageBase):
    id: int
    sender_id: int
    created_at: datetime

    class Config:
        from_attributes = True


class UserBase(BaseModel):
    username: str = Field(..., min_length=3, max_length=50)
    email: EmailStr
    full_name: Optional[str] = Field(default=None, max_length=255)
    role: str = Field(pattern="^(admin|user)$")


class UserCreate(UserBase):
    password: str = Field(..., min_length=6, max_length=128)


class User(UserBase):
    id: int
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"


class TokenData(BaseModel):
    username: Optional[str] = None
