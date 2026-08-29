from fastapi import FastAPI, UploadFile, File, HTTPException, status
from fastapi.responses import StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import cv2
import numpy as np
import io
import os

from app.core.config import settings
from app.api.router import api_router

app = FastAPI(
    title="CleanPixel AI Core Engine",
    description="Startup enterprise microservice for watermark removal",
    version="1.0.0",
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    docs_url="/docs",
    redoc_url="/redoc"
)

# CORS Configuration for Flutter Web/Mobile & Frontend Studio
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Healthcheck Endpoint
@app.get("/health", tags=["System Health"])
async def health_check():
    return {
        "status": "healthy",
        "service": "CleanPixel AI Core Engine",
        "version": "1.0.0",
        "engine": "OpenCV Navier-Stokes Inpainting"
    }

# -------------------------------------------------------------
# HIGH-SPEED IN-MEMORY WATERMARK REMOVAL ENDPOINT (NO DISK I/O)
# -------------------------------------------------------------
@app.post(
    "/api/v1/media/remove-watermark", 
    status_code=status.HTTP_200_OK,
    summary="Remove watermark from an uploaded image using a custom brush mask",
    tags=["High-Speed Inpainting Engine"]
)
async def remove_watermark_endpoint(
    image: UploadFile = File(..., description="The original watermarked image file"),
    mask: UploadFile = File(..., description="The binary black-and-white mask drawn by the user")
):
    # 1. सिक्योरिटी और फॉर्मेट वैलिडेशन
    allowed_extensions = ["image/jpeg", "image/png", "image/jpg", "image/webp"]
    if image.content_type not in allowed_extensions or mask.content_type not in allowed_extensions:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid file format. Only JPEG, PNG, and WebP images are supported."
        )

    try:
        # 2. बाइनरी डेटा को री-डिटेक्ट करके मेमोरी में रीड करना (No Disk I/O for ultra-speed)
        image_bytes = await image.read()
        mask_bytes = await mask.read()

        # 3. OpenCV के लिए बाइनरी एरे को इमेजेस में डिकोड करना
        np_img = np.frombuffer(image_bytes, np.uint8)
        img = cv2.imdecode(np_img, cv2.IMREAD_COLOR)
        if img is None:
            raise HTTPException(status_code=400, detail="Could not decode source image")

        np_mask = np.frombuffer(mask_bytes, np.uint8)
        gray_mask = cv2.imdecode(np_mask, cv2.IMREAD_GRAYSCALE)
        if gray_mask is None:
            raise HTTPException(status_code=400, detail="Could not decode mask image")

        # 4. सेफ्टी चेक: सुनिश्चित करें कि इमेज और मास्क का साइज बिल्कुल सेम हो
        if img.shape[0:2] != gray_mask.shape[0:2]:
            gray_mask = cv2.resize(gray_mask, (img.shape[1], img.shape[0]), interpolation=cv2.INTER_NEAREST)

        # Ensure pure binary mask
        _, binary_mask = cv2.threshold(gray_mask, 10, 255, cv2.THRESH_BINARY)

        # 5. OpenCV Navier-Stokes inpainting
        inpainting_radius = 4
        cleaned_img = cv2.inpaint(img, binary_mask, inpainting_radius, cv2.INPAINT_NS)

        # 6. Return StreamingResponse
        _, encoded_img = cv2.imencode(".png", cleaned_img)
        io_buf = io.BytesIO(encoded_img.tobytes())

        return StreamingResponse(io_buf, media_type="image/png")

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"An error occurred during AI processing: {str(e)}"
        )

# Mount API Routers (Auth + Inpainting)
app.include_router(api_router, prefix=settings.API_V1_STR)

# Mount Static Storage directory for file previews
if os.path.exists(settings.STORAGE_DIR):
    app.mount("/storage", StaticFiles(directory=str(settings.STORAGE_DIR)), name="storage")

# Mount Web Studio UI directory at Root
UI_DIR = settings.BASE_DIR.parent / "ui"
if UI_DIR.exists():
    app.mount("/", StaticFiles(directory=str(UI_DIR), html=True), name="web_studio")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
