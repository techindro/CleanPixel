<div align="center">
  <img src="assets/logo.png" width="128" height="128" alt="CleanPixel AI Logo" style="border-radius: 24px;" />
  <h1>CleanPixel AI: Image & Video Watermark Remover</h1>
  <p><strong>Next-Generation Neural Inpainting & Seamless Watermark Eradication</strong></p>
</div>

CleanPixel AI is a full-stack computer vision application designed to seamlessly remove watermarks, logos, timestamps, and unwanted text overlays from high-resolution images and video streams.

---

## System Architecture

```text
cleanpixel-ai/
│
├── backend/                  # FastAPI Backend Services
│   ├── app/
│   │   ├── api/              # API Endpoints (Upload, Inpaint, Async Video, Auth, Results)
│   │   ├── core/             # Config, Security, JWT, Directory & S3 Storage
│   │   ├── models/           # OpenCV Telea/NS & Neural Inpainting Pipelines
│   │   ├── services/         # Celery Async Background Workers
│   │   └── main.py           # FastAPI Application Entry Point
│   ├── Dockerfile
│   └── requirements.txt
│
├── frontend/                 # Cross-Platform Flutter Mobile Application
│   ├── lib/
│   │   ├── components/       # Interactive Canvas, Contextual Toolbar, Paywall, Comparison Slider
│   │   ├── screens/          # Workspace Studio, Splash, Pro Subscription
│   │   ├── services/         # CleanPixel API & Auth Client
│   │   └── main.dart
│   └── pubspec.yaml
│
├── infrastructure/           # Cloud Deployment Configuration
│   └── docker-compose.yml    # FastAPI API + Celery Worker + Redis Queue
│
└── ui/                       # High-End Silicon Valley Web Studio (HTML5/CSS3/Vanilla JS)
    ├── assets/               # Official CleanPixel Brand Assets
    ├── index.html            # 4-State Central Studio Viewport
    ├── index.css             # Deep Slate & Electric Blue Design Tokens
    └── app.js                # State Machine & Canvas Brush Drawing Engine
```

---

## Quick Start Guide

### 1. Web Studio (Instant Browser Access)
Open [`ui/index.html`](ui/index.html) in any modern browser to immediately access the interactive studio with sample photo presets, live neon-brush drawing, and split-slider comparison.

### 2. FastAPI Backend Engine
```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```
API Documentation will be accessible at: `http://localhost:8000/docs`

### 3. Docker Compose Stack (API + Celery Worker + Redis)
```bash
cd infrastructure
docker-compose up --build
```

### 4. Flutter Mobile App
```bash
cd frontend
flutter pub get
flutter run
```

---

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
