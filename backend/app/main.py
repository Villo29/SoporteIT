from fastapi import FastAPI

from . import models
from .database import Base, engine
from .routers import auth as auth_router
from .routers import messages as messages_router
from .routers import users as users_router

# Ensure database tables exist on startup.
Base.metadata.create_all(bind=engine)

app = FastAPI(title="SoporteIT API", version="1.0.0")

app.include_router(auth_router.router)
app.include_router(users_router.router)
app.include_router(messages_router.router)


@app.get("/health", tags=["health"])
def health_check() -> dict[str, str]:
    return {"status": "ok"}
