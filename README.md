# 🩺 MULISA – Mobile Patient Care System

> A full-stack healthcare prototype combining Flutter mobile app with Django REST API backend for comprehensive patient monitoring, vitals tracking, and appointment management.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Django](https://img.shields.io/badge/Django-5.x-092E20?logo=django)](https://www.djangoproject.com)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-316192?logo=postgresql)](https://www.postgresql.org)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## ⭐ Overview

**MULISA** is an mHealth ecosystem designed for patient monitoring, vitals tracking, appointments, and clinical workflows. This prototype implements:

- ✅ Secure login/registration with JWT authentication
- ✅ Patient profile management with local and remote sync
- ✅ Real-time vitals tracking (BP, HR, Temperature, Respiratory Rate)
- ✅ Appointment scheduling system
- ✅ Persistent local storage with SQLite
- ✅ Clean Architecture with BLoC pattern
- ✅ RESTful API integration

---

## 📦 Repository Structure

```
MULISA/
├── mulisa-flutter/          # Flutter Mobile App (Frontend)
└── Mulisa-Server/           # Django REST API (Backend)
```

---

## 📱 Flutter Mobile App

### 🚀 Key Features

#### Authentication

- Login and registration flows
- JWT-based session management
- Auto-session restore
- Secure token storage

#### Patient Module

- Local SQLite database with remote sync
- DAO Pattern implementation (`PatientDao`)
- CRUD operations for patient records
- Profile management

#### Vitals Module

- Blood Pressure monitoring
- Heart Rate tracking
- Temperature recording
- Respiratory Rate measurement
- Visual card-based UI
- Cubit + Repository Architecture

#### UI & Navigation

- Material 3 design system
- Named route navigation (`AppRoutes`)
- Responsive layouts
- Professional gradients and animations

#### Networking

- Dio HTTP client with token injection
- Automatic request/response interceptors
- Error handling and retry logic

#### Dependency Injection

- Fully wired with GetIt (`injector.dart`)
- Service locator pattern
- Clean separation of concerns

### 🗂️ Project Structure

```
lib/
├── core/
│   ├── db/                  # SQLite database configuration
│   ├── network/             # Dio client and interceptors
│   ├── di/                  # Dependency injection setup
│   └── config.dart          # App configuration
├── features/
│   ├── auth/                # Authentication feature
│   ├── patient/             # Patient management
│   ├── vitals/              # Vitals tracking
│   └── appointments/        # Appointment scheduling
└── main.dart                # Application entry point
```

### 🛠️ Tech Stack

| Component            | Technology         |
| -------------------- | ------------------ |
| Framework            | Flutter 3.x        |
| State Management     | BLoC (Cubit)       |
| Dependency Injection | GetIt              |
| HTTP Client          | Dio                |
| Local Database       | Sqflite            |
| Architecture         | Clean Architecture |

### ▶️ Getting Started

#### Prerequisites

- Flutter SDK (3.x or higher)
- Android Studio / VS Code
- Android Emulator or physical device
- Git

#### Installation

```bash
# Clone the repository
git clone https://github.com/<your-username>/mulisa-flutter.git
cd mulisa-flutter

# Install dependencies
flutter pub get

# Clean build artifacts
flutter clean

# Run the app
flutter run
```

#### Configuration

Update the API base URL in `lib/core/config.dart`:

```dart
class Config {
  static const String baseUrl = 'http://your-api-url:8000/api';
}
```

---

## 🖥️ Django REST Backend

### 🚀 Key Features

- **JWT Authentication**: Secure token-based authentication with refresh tokens
- **Patients API**: Complete CRUD operations for patient management
- **Vitals API**: Store and retrieve patient vital signs
- **Appointments API**: Schedule and manage appointments
- **Swagger/OpenAPI**: Interactive API documentation
- **PostgreSQL**: Robust relational database
- **Admin Panel**: Django admin interface for data management

### ⚙️ Tech Stack

| Layer             | Technology                       |
| ----------------- | -------------------------------- |
| Language          | Python 3.13                      |
| Framework         | Django 5 + Django REST Framework |
| Database          | PostgreSQL 15                    |
| Authentication    | JWT (SimpleJWT)                  |
| API Documentation | drf-spectacular                  |
| Environment       | python-dotenv                    |

### 📦 Project Structure

```
Mulisa-Server/
├── accounts/                # User authentication and management
├── patients/                # Patient records API
├── vitals/                  # Patient vitals API
├── appointments/            # Appointment scheduling API
├── mulisa_api/              # Main Django settings
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
├── .env                     # Environment variables
├── manage.py
└── requirements.txt
```

### ▶️ Backend Setup

#### Prerequisites

- Python 3.13+
- PostgreSQL 15+
- pip package manager

#### Installation

```bash
# Clone the repository
git clone https://github.com/<your-username>/Mulisa-Server.git
cd Mulisa-Server

# Create virtual environment
python -m venv .venv

# Activate virtual environment
# Windows:
.\.venv\Scripts\activate
# Mac/Linux:
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

#### Configuration

Create a `.env` file in the root directory:

```env
SECRET_KEY=your-secret-key-here
DEBUG=True
DATABASE_NAME=mulisa_db
DATABASE_USER=your_db_user
DATABASE_PASSWORD=your_db_password
DATABASE_HOST=localhost
DATABASE_PORT=5432
ALLOWED_HOSTS=localhost,127.0.0.1
```

#### Database Setup

```bash
# Run migrations
python manage.py makemigrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser

# Load initial data (optional)
python manage.py loaddata fixtures/initial_data.json
```

#### Run Development Server

```bash
python manage.py runserver
```

The server will start at `http://127.0.0.1:8000`

### 📚 API Documentation

Access the interactive API documentation:

- **Swagger UI**: http://127.0.0.1:8000/api/docs/
- **ReDoc**: http://127.0.0.1:8000/api/redoc/
- **Django Admin**: http://127.0.0.1:8000/admin/

### 🔗 Main Endpoints

#### Authentication

```
POST   /api/auth/register/          # Register new user
POST   /api/auth/login/             # Login and get tokens
POST   /api/auth/token/refresh/     # Refresh access token
POST   /api/auth/logout/            # Logout user
```

#### Patients

```
GET    /api/patients/               # List all patients
POST   /api/patients/               # Create new patient
GET    /api/patients/{id}/          # Get patient details
PUT    /api/patients/{id}/          # Update patient
DELETE /api/patients/{id}/          # Delete patient
```

#### Vitals

```
GET    /api/vitals/                 # List all vitals
POST   /api/vitals/                 # Record new vitals
GET    /api/vitals/{id}/            # Get vital details
GET    /api/vitals/patient/{id}/    # Get patient's vitals history
```

#### Appointments

```
GET    /api/appointments/           # List all appointments
POST   /api/appointments/           # Create new appointment
GET    /api/appointments/{id}/      # Get appointment details
PUT    /api/appointments/{id}/      # Update appointment
DELETE /api/appointments/{id}/      # Cancel appointment
```

---

## 🏗️ Architecture

### Flutter App Architecture

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│  (UI Widgets, BLoC/Cubit, Pages)   │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│          Domain Layer                │
│  (Entities, Use Cases, Repositories) │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│           Data Layer                 │
│  (API, Local DB, Models, DAOs)      │
└─────────────────────────────────────┘
```

### Django Backend Architecture

```
┌─────────────────────────────────────┐
│          API Layer (Views)          │
│     (DRF ViewSets & Serializers)    │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│         Business Logic              │
│      (Models, Managers, Utils)      │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│         Data Layer (ORM)            │
│         (PostgreSQL Database)        │
└─────────────────────────────────────┘
```

---

## 🔒 Security Features

- JWT token-based authentication
- Password hashing with Django's built-in security
- CORS configuration for cross-origin requests
- SQL injection protection via ORM
- XSS protection in Django templates
- CSRF protection for state-changing operations
- Secure environment variable management

## 📈 Future Enhancements

- [ ] Push notifications for appointments
- [ ] Real-time vitals monitoring dashboard
- [ ] Telemedicine video consultation
- [ ] Electronic health records (EHR) integration
- [ ] Multi-language support
- [ ] Dark mode
- [ ] Offline-first synchronization
- [ ] Analytics and reporting dashboard
- [ ] Role-based access control (Doctor, Nurse, Admin)
- [ ] Medical imaging integration

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 MULISA Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 👥 Team

- **Developer**: Md Istiak Morsalin
- **Project Type**: Healthcare Prototype
- **Institution**: Kennesaw State University

---

## 📞 Support

For support, email mmorsali@students.kennesaw.edu or open an issue in the GitHub repository.

---

## 🙏 Acknowledgments

- Flutter team for the excellent framework
- Django and DRF communities for robust backend tools
- All contributors and testers

---

**Made with ❤️ for better healthcare**
