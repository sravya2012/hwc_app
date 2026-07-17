# 🐘 HWC Alert — Human-Wildlife Conflict Risk App

A Flutter mobile app that predicts human-wildlife conflict risk for a given location in real time, using a machine learning model served over a REST API. Built to help residents and forest-edge communities check conflict risk before entering a zone.

> 🔗 Backend / ML model repo: [hwc_backend_fixed](https://github.com/sravya2012/hwc_backend_fixed)

---

## ✨ Features

- 📍 **Live location-based risk prediction** — fetches current GPS location and queries the prediction API for HIGH / MEDIUM / LOW conflict risk
- 🔎 **Manual location search** — check risk for any coordinates, not just your current one
- 🔐 **Phone number (OTP) authentication** via Firebase Auth
- 🗺️ Map integration for visualizing risk zones (Google Maps SDK)
- 🎨 Color-coded risk cards (🔴 High / 🟡 Medium / 🟢 Low) with probability score and contributing driver

## 🛠️ Tech Stack

| Layer | Tech |
|---|---|
| Frontend | Flutter (Dart), Material 3 |
| Auth | Firebase Authentication (Phone/OTP) |
| Maps | Google Maps SDK for Android |
| Backend | FastAPI + Random Forest classifier ([separate repo](https://github.com/sravya2012/hwc_backend_fixed)), hosted on Render |
| HTTP | `http` package calling a REST prediction endpoint |

## 📱 Architecture

```
lib/
├── main.dart                     # App entry, Firebase init, auth state routing
├── screens/
│   ├── login_screen.dart         # Phone/OTP authentication
│   └── home_screen.dart          # Main risk-check screen
├── services/
│   ├── location_service.dart     # Device GPS location handling
│   └── prediction_service.dart   # Calls the FastAPI /predict endpoint
├── widgets/
│   ├── risk_card.dart            # Risk result display component
│   └── manual_search_sheet.dart  # Manual coordinate search UI
└── models/
```

The app calls a hosted FastAPI backend (`/predict?lat=&lon=`), which runs a Random Forest model trained on historical conflict data and returns a risk level, probability, and contributing factor.

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Android Studio or VS Code with the Flutter/Dart plugins
- A Firebase project (for phone auth) and a Google Maps API key

### Setup

1. Clone the repo:
   ```bash
   git clone https://github.com/sravya2012/hwc_app.git
   cd hwc_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. **Firebase**: Create a project at the [Firebase Console](https://console.firebase.google.com), enable Phone Authentication, add an Android app with package name `com.hwc.hwc_app`, and place the downloaded `google-services.json` at `android/app/google-services.json`.

4. **Google Maps**: Enable "Maps SDK for Android" in [Google Cloud Console](https://console.cloud.google.com), create a restricted API key (limited to your app's package name + SHA-1), and set it in `android/app/src/main/AndroidManifest.xml` in place of `YOUR_GOOGLE_MAPS_API_KEY`.

5. Run the app:
   ```bash
   flutter run
   ```

> The app is pre-configured to call the live backend at `https://hwc-backend-fixed.onrender.com` — no backend setup needed to test predictions.

## 🧪 Test Coordinates

Known high-risk zones used during development/testing:

| Location | Lat | Lon |
|---|---|---|
| Nagarhole | 11.93 | 76.13 |
| Bandipur | 11.67 | 76.63 |
| Wayanad | 11.61 | 76.13 |

## 📌 Notes

- This repo intentionally excludes `google-services.json` and any API keys — see setup steps above to configure your own.
- Part of a two-repo project: this Flutter frontend + the [FastAPI/ML backend](https://github.com/sravya2012/hwc_backend_fixed).

---

*Built as part of an academic ML + mobile development project (MCA, SJB Institute of Technology).*
