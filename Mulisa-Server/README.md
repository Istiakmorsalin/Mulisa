# 🩺 MULISA Backend API (Django + PostgreSQL + DRF)

This repository contains the **MULISA Backend Service**, built with **Django REST Framework** to support
authentication and patient data management for the MULISA mHealth system.

It exposes RESTful endpoints for:
- **User Authentication (JWT)**
- **Patient Records Management**
- **Swagger/OpenAPI Docs**

---

## 🧱 Project Structure

```bash
Mulisa-Server/
│
├── manage.py
├── .env
├── requirements.txt
├── accounts/        # Auth & JWT logic
├── patients/        # Patient CRUD API
├── mulisa_api/      # Project settings & URLs
└── .venv/           # Python virtual environment
```

## ⚙️ Tech Stack

| Layer | Technology |
|-------|-------------|
| Language | Python 3.13 |
| Framework | Django 5 + Django REST Framework |
| Database | PostgreSQL 15 + psycopg |
| Auth | JWT (via `djangorestframework-simplejwt`) |
| Docs | drf-spectacular / Swagger UI |
| Filtering | django-filter |
| Env config | python-dotenv |

---

## 🚀 Local Development Setup

### 1️⃣ Clone and enter project
```bash
git clone https://github.com/<yourusername>/Mulisa-Server.git
cd Mulisa-Server
```

### 2️⃣ Create virtual environment

```bash
python -m venv .venv
# Activate (Windows)
.\.venv\Scripts\activate
# macOS / Linux
For Mac source .venv/bin/activate
For Windows .\.venv\Scripts\Activate
```


### 3️⃣ Install dependencies
```bash
pip install -r requirements.txt
```
### Useful Commands

```bash

python manage.py makemigrations accounts patients
python manage.py migrate
python manage.py createsuperuser
### Start server
python manage.py runserver
python manage.py runserver 0.0.0.0:8000
```


📘 **Documentation**
```bash
After running the server:
Swagger UI → http://127.0.0.1:8000/api/docs/
```

📄 License
MIT License – Use, modify, and distribute freely with attribution.
