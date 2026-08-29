import os
import sys
from pathlib import Path

# Prepend backend path to avoid conflict with global Python directories
backend_dir = Path(__file__).resolve().parent.parent
if str(backend_dir) not in sys.path:
    sys.path.insert(0, str(backend_dir))

import cv2
import numpy as np
import io
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_health_check():
    """Verify healthcheck endpoint returns healthy status"""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert "OpenCV" in data["engine"]

def test_remove_watermark_endpoint():
    """Test in-memory inpaint streaming endpoint with synthetic test image & mask"""
    # Create 200x200 RGB test image
    img = np.zeros((200, 200, 3), dtype=np.uint8)
    img[:, :] = (100, 150, 200) # Blue background
    # Draw a simulated watermark
    cv2.putText(img, "TEST", (30, 100), cv2.FONT_HERSHEY_SIMPLEX, 1.5, (255, 255, 255), 3)

    # Create 200x200 binary mask
    mask = np.zeros((200, 200), dtype=np.uint8)
    cv2.putText(mask, "TEST", (30, 100), cv2.FONT_HERSHEY_SIMPLEX, 1.5, 255, 6)

    # Encode to PNG in-memory
    _, img_encoded = cv2.imencode(".png", img)
    _, mask_encoded = cv2.imencode(".png", mask)

    files = {
        "image": ("test.png", img_encoded.tobytes(), "image/png"),
        "mask": ("mask.png", mask_encoded.tobytes(), "image/png"),
    }

    response = client.post("/api/v1/media/remove-watermark", files=files)
    assert response.status_code == 200
    assert response.headers["content-type"] == "image/png"
    assert len(response.content) > 0

    # Verify returned image can be decoded
    np_res = np.frombuffer(response.content, np.uint8)
    cleaned = cv2.imdecode(np_res, cv2.IMREAD_COLOR)
    assert cleaned is not None
    assert cleaned.shape == (200, 200, 3)

def test_invalid_format_rejection():
    """Verify endpoint rejects invalid non-image formats"""
    files = {
        "image": ("test.txt", b"plain text", "text/plain"),
        "mask": ("mask.png", b"binary", "image/png"),
    }
    response = client.post("/api/v1/media/remove-watermark", files=files)
    assert response.status_code == 400
