# soporteit

Aplicacion Diseña para el uso del soporte It de ADITECH

## Getting Started

This project is a starting point for a Flutter application.

## Backend API

The repository now includes a Python/FastAPI backend located in the [`backend/`](backend/) directory. The service exposes:

- Role-aware authentication for admins and users with JWT-based login.
- MySQL persistence for users and chat messages via SQLAlchemy models.
- Chat endpoints to send and retrieve conversation history for the support workflow.

See [`backend/README.md`](backend/README.md) for setup instructions.
