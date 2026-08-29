from fastapi import APIRouter, UploadFile, File, Form, HTTPException, status
from fastapi.responses import StreamingResponse
from app.models.inpaint_engine import InpaintEngine
from app.core.config import settings
import cv2
import numpy as np
import io
import uuid
import os
import zipfile

router = APIRouter()

@router.post("/inpaint/batch", summary="Batch process multiple images with the same mask region")
async def batch_inpaint(
    images: list[UploadFile] = File(..., description="Multiple watermarked images"),
    mask: UploadFile = File(..., description="The inpainting mask to apply to all images"),
    engine: str = Form("telea")
):
    """
    Process multiple images through the inpainting pipeline and return a ZIP archive.
    Maximum 10 images per batch.
    """
    if len(images) > 10:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Maximum 10 images per batch. Upgrade to PRO for higher limits."
        )

    # Read mask once
    mask_bytes = await mask.read()
    np_mask = np.frombuffer(mask_bytes, np.uint8)
    gray_mask = cv2.imdecode(np_mask, cv2.IMREAD_GRAYSCALE)
    if gray_mask is None:
        raise HTTPException(status_code=400, detail="Could not decode mask image")

    # Process each image
    zip_buffer = io.BytesIO()
    results = []

    with zipfile.ZipFile(zip_buffer, 'w', zipfile.ZIP_DEFLATED) as zf:
        for idx, image_file in enumerate(images):
            try:
                img_bytes = await image_file.read()
                np_img = np.frombuffer(img_bytes, np.uint8)
                img = cv2.imdecode(np_img, cv2.IMREAD_COLOR)
                if img is None:
                    results.append({"file": image_file.filename, "status": "error", "detail": "Could not decode"})
                    continue

                # Resize mask to match each image
                resized_mask = cv2.resize(gray_mask, (img.shape[1], img.shape[0]), interpolation=cv2.INTER_NEAREST)
                _, binary_mask = cv2.threshold(resized_mask, 10, 255, cv2.THRESH_BINARY)

                # Inpaint
                inpaint_flag = cv2.INPAINT_NS if engine.lower() == "ns" else cv2.INPAINT_TELEA
                cleaned = cv2.inpaint(img, binary_mask, inpaintRadius=4, flags=inpaint_flag)

                # Edge-preserving filter for lama mode
                if engine.lower() == "lama":
                    cleaned = cv2.edgePreservingFilter(cleaned, flags=1, sigma_s=50, sigma_r=0.4)

                # Encode and add to ZIP
                _, encoded = cv2.imencode(".png", cleaned)
                filename = f"cleaned_{idx + 1}_{os.path.splitext(image_file.filename or 'image')[0]}.png"
                zf.writestr(filename, encoded.tobytes())

                results.append({"file": image_file.filename, "status": "success", "output": filename})

            except Exception as e:
                results.append({"file": image_file.filename, "status": "error", "detail": str(e)})

    zip_buffer.seek(0)
    return StreamingResponse(
        zip_buffer,
        media_type="application/zip",
        headers={"Content-Disposition": "attachment; filename=CleanPixel_Batch_Results.zip"}
    )
