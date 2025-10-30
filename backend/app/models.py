from __future__ import annotations

from datetime import datetime

from sqlalchemy import Boolean, CheckConstraint, DateTime, Enum, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .database import Base


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    username: Mapped[str] = mapped_column(String(50), unique=True, nullable=False, index=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False, index=True)
    full_name: Mapped[str | None] = mapped_column(String(255), nullable=True)
    hashed_password: Mapped[str] = mapped_column(String(255), nullable=False)
    role: Mapped[str] = mapped_column(
        Enum("admin", "user", name="user_roles"), nullable=False, default="user"
    )
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)

    sent_messages: Mapped[list["Message"]] = relationship(
        "Message", back_populates="sender", foreign_keys="Message.sender_id"
    )
    received_messages: Mapped[list["Message"]] = relationship(
        "Message", back_populates="receiver", foreign_keys="Message.receiver_id"
    )


class Message(Base):
    __tablename__ = "messages"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    sender_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)
    receiver_id: Mapped[int | None] = mapped_column(ForeignKey("users.id"), nullable=True)
    content: Mapped[str] = mapped_column(Text, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)

    sender: Mapped[User] = relationship(
        "User", foreign_keys=[sender_id], back_populates="sent_messages"
    )
    receiver: Mapped[User | None] = relationship(
        "User", foreign_keys=[receiver_id], back_populates="received_messages"
    )

    __table_args__ = (
        CheckConstraint("char_length(content) > 0", name="messages_content_non_empty"),
    )
