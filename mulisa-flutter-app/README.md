# MULISA (Patient Care Prototype)

A Flutter prototype for the **MULISA system**, featuring authentication, patient management, local persistence with SQLite, and REST API integration.  
This project uses **clean architecture patterns** with **BLoC + Dependency Injection (GetIt)**.

---

## 🚀 Features
- **Authentication**
    - Login
    - Sign Up
    - Local session storage with `AuthLocalStore`
- **Patient Management**
    - Local SQLite database
    - DAO pattern for patient CRUD
- **Routing**
    - Centralized `AppRoutes` with named routes
- **Dependency Injection**
    - Configured via `GetIt`
- **Networking**
    - `Dio` client with token injection

---

## 📂 Project Structure
![ss/Screenshot 2025-08-16 123846.png](../../../Screenshot%202025-08-16%20123846.png)


---

## 🛠️ Tech Stack
- **Flutter** (Material 3)
- **State Management**: BLoC (Cubit)
- **Dependency Injection**: GetIt
- **Database**: Sqflite
- **Networking**: Dio

---

## 📲 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Android Studio / VSCode with Flutter plugin

### Setup
```bash
# clone the repo
git clone https://github.com/your-username/mulisa-flutter.git
cd mulisa-flutter

# get dependencies
flutter pub get

# clean old builds (recommended if rerun fails)
flutter clean

# run app
flutter run

🗄 Database & DAOs

The app uses Sqflite with a lightweight AppDatabase wrapper.

Example: PatientDao
final patientDao = getIt<PatientDao>();

// Insert a patient
await patientDao.insertPatient(Patient(id: '1', name: 'John Doe'));

// Get all patients
final patients = await patientDao.getAllPatients()


🔄 Dependency Injection (GetIt)

All services, cubits, and DAOs are registered in injector.dart.

Example:
// Accessing AuthCubit
final authCubit = getIt<AuthCubit>();

// Using AuthService via injected Dio
final authService = getIt<AuthService>();

📦 Cubit Usage
AuthCubit
final authCubit = getIt<AuthCubit>();

authCubit.login("username", "password");

PatientCubit
final patientCubit = getIt<PatientCubit>();

patientCubit.loadPatients();

⚡ Known Issues

Gradle build error after rerun:
Sometimes build fails due to cached output files. Fix:

flutter clean
flutter pub get
flutter run


If persists, uninstall the app from the device before rerunning.

📖 Next Steps

Add form validation for login/signup

Implement real patient CRUD

Add unit & widget tests

UI polishing

Integration with real backend APIs

📜 License

