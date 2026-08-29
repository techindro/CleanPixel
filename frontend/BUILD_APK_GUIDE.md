# 📱 CleanPixel AI — APK & Play Store Build Guide

Follow these steps to generate the **Installable APK** (for direct phone install/testing) and **Google Play Bundle (.aab)** (for Play Store upload).

---

## ⚡ Method 1: One-Click Build Script (Recommended)

Just double-click or run:
```cmd
cd frontend
build_apk.bat
```

---

## 🛠️ Method 2: Manual Terminal Commands

Open terminal in the `frontend/` folder:

### 1. Direct Installable APK (Phone Testing)
```bash
flutter build apk --release
```
📍 **Output Location:**
`frontend/build/app/outputs/flutter-apk/app-release.apk`

---

### 2. Google Play Store Bundle (.AAB) (Play Console Upload)
```bash
flutter build appbundle --release
```
📍 **Output Location:**
`frontend/build/app/outputs/bundle/release/app-release.aab`

---

## 📲 How to Install the APK on your Android Phone:
1. Connect your phone via USB or send `app-release.apk` to your phone (via WhatsApp/Drive/Telegram).
2. Tap the `.apk` file on your phone.
3. Select **Install** (Allow "Install Unknown Apps" if prompted).
4. Launch **CleanPixel AI** and enjoy the full Onboarding, Neural Inpainting & Studio experience!
