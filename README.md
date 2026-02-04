# ui_rentmything

# RentMyThing Frontend (Flutter)

This is the Flutter UI for the **RentMyThing** backend service.  
It provides a mobile interface for users to register, login, manage items, and search based on location.

---

## 📱 Features
- OTP‑based registration flow integrated with backend
- JWT login and secure session handling
- Role‑based UI (Owner vs User)
- Item listing, adding, and deletion
- Location auto‑capture and profile management
- Search items/users by location
- Clean, responsive Flutter UI

---

## 🛠️ Tech Stack
- **Framework:** Flutter (Dart)
- **State Management:** Provider / Riverpod (depending on your setup)
- **Networking:** `http` package (REST API calls)
- **Backend:** RentMyThing Spring Boot server

---

## 🚀 Getting Started

### Prerequisites
- Install [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Android Studio or VS Code with Flutter plugin
- Backend server running locally (`http://localhost:8080/api`)

### Clone the repo
``bash git clone https://github.com/Goluksharma/rentmything_froanend_Ui.gitcd rentmything_froanend_Ui
Install dependencies
bash
flutter pub get
Run the app
bash
flutter run

pdate the backend API base URL in your Flutter project (usually in lib/config/api.dart or similar):

dart
const String baseUrl = "http://localhost:8080/api";

📖 API Integration
The frontend consumes the following backend endpoints:

POST /sendotp → Send OTP to email

POST /verifyotp → Verify OTP

POST /register → Register user

POST /login → Login and get JWT

POST /save-location → Save GPS coordinates

GET /categories → Fetch categories

POST /add-service → Add item

DELETE /deleteItem → Delete item

POST /fetching → Fetch owner profile

POST /serch → Search by location

DELETE /delete-account → Delete account
APP PREVIEW
<img width="371" height="804" alt="Screenshot 2026-02-04 181056" src="https://github.com/user-attachments/assets/9cdafbdd-73ce-47ca-bef3-8921c05b765b" />
<img width="368" height="798" alt="Screenshot 2026-02-04 181112" src="https://github.com/user-attachments/assets/f5ef2ce9-9d2b-4510-8385-f920f1545031" />
<img width="372" height="796" alt="Screenshot 2026-02-04 181125" src="https://github.com/user-attachments/assets/c6b5a221-89d7-434e-a8a8-89f2406e89fe" />



