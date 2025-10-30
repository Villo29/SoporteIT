# SoporteIT Backend API

This directory contains a FastAPI application that provides the backend for the SoporteIT frontend. The API exposes endpoints for authentication, role-based profile access, and a simple chat system backed by MySQL.

## Features

- User registration with role selection (admin or user).
- Password-based authentication with JWT access tokens.
- Role-aware profile retrieval for use in the Flutter frontend.
- Chat endpoints that allow authenticated users to send and fetch messages.
- SQLAlchemy models for managing a MySQL database.

## Project structure

```
backend/
├── README.md
├── requirements.txt
└── app/
    ├── __init__.py
    ├── auth.py
    ├── config.py
    ├── database.py
    ├── main.py
    ├── models.py
    ├── schemas.py
    └── routers/
        ├── auth.py
        ├── messages.py
        └── users.py
```

## Getting started

1. **Install dependencies**

   ```bash
   python -m venv .venv
   source .venv/bin/activate
   pip install -r requirements.txt
   ```

2. **Configure environment variables**

   Create a `.env` file inside `backend/` (next to `requirements.txt`) with content similar to:

   ```env
   DATABASE_URL=mysql+pymysql://username:password@localhost:3306/soporteit
   SECRET_KEY=change-me
   ACCESS_TOKEN_EXPIRE_MINUTES=60
   ```

   Replace the database credentials and secret key with values that match your environment.

3. **Apply migrations / create tables**

   The application will automatically create the required tables on startup by calling `Base.metadata.create_all`. Ensure that the database defined in the connection string already exists in MySQL.

4. **Run the server**

   ```bash
   uvicorn app.main:app --reload
   ```

   The API will be available at `http://127.0.0.1:8000`. Interactive API docs can be accessed at `http://127.0.0.1:8000/docs`.

## Database schema

The backend uses two tables:

- `users`: stores authentication data, role information, and optional profile details.
- `messages`: stores chat messages, linking each message to the user that sent it and optionally to the receiver.

## Roles

The `role` field in the `users` table can be `admin` or `user`. The `/users/me` endpoint returns the authenticated user's profile, while `/users/admins` and `/users/clients` expose role-filtered listings that the frontend can use when navigating to the appropriate profile dashboard.

## Chat

Messages can be sent to a specific recipient or broadcast to everyone by omitting the `receiver_id`. The `/messages/history` endpoint returns the most recent messages, and `/messages/send` persists a new message linked to the authenticated sender.

## Running tests

Currently there are no automated tests for the backend service. You can add unit tests using `pytest` or integration tests with tools such as `httpx` as the project evolves.
