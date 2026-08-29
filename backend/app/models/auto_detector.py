import cv2
import numpy as np
import os
from typing import Dict, Any

class AutoWatermarkDetector:
    """
    Computer vision algorithm for automatic watermark, text, and logo detection.
    Generates binary inpainting masks automatically using edge-density & MSER contour analysis.
    """

    @staticmethod
    def detect_watermarks(image_path: str, sensitivity: float = 0.5) -> np.ndarray:
        if not os.path.exists(image_path):
            raise FileNotFoundError(f"Image not found at {image_path}")

        img = cv2.imread(image_path, cv2.IMREAD_COLOR)
        if img is None:
            raise ValueError("Could not decode image")

        h, w = img.shape[:2]
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

        # 1. Gradient analysis using Sobel & Morphological Gradient
        grad_x = cv2.Sobel(gray, cv2.CV_32F, 1, 0, ksize=3)
        grad_y = cv2.Sobel(gray, cv2.CV_32F, 0, 1, ksize=3)
        gradient = cv2.subtract(grad_x, grad_y)
        gradient = cv2.convertScaleAbs(gradient)

        # 2. Blur & Adaptive Thresholding
        blurred = cv2.GaussianBlur(gradient, (9, 9), 0)
        _, thresh = cv2.threshold(blurred, int(180 * (1.0 - sensitivity * 0.5)), 255, cv2.THRESH_BINARY)

        # 3. Morphological closing to connect letter contours
        kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (15, 7))
        closed = cv2.morphologyEx(thresh, cv2.MORPH_CLOSE, kernel)

        # 4. Find text/logo bounding contours
        contours, _ = cv2.findContours(closed, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        mask = np.zeros((h, w), dtype=np.uint8)

        for c in contours:
            x, y, cw, ch = cv2.boundingRect(c)
            aspect_ratio = cw / float(ch)
            area = cw * ch
            
            # Filter out whole-image false positives and tiny noise
            if 50 < area < (h * w * 0.45) and (aspect_ratio > 1.2 or aspect_ratio < 0.8):
                # Dilate slightly around detected watermark box
                pad_x = int(cw * 0.08)
                pad_y = int(ch * 0.08)
                x1 = max(0, x - pad_x)
                y1 = max(0, y - pad_y)
                x2 = min(w, x + cw + pad_x)
                y2 = min(h, y + ch + pad_y)
                
                cv2.rectangle(mask, (x1, y1), (x2, y2), 255, -1)

        # If nothing detected, focus on common watermark zones (bottom-right & center)
        if np.count_nonzero(mask) == 0:
            # Subtle center text search
            center_zone = gray[int(h*0.3):int(h*0.7), int(w*0.2):int(w*0.8)]
            edges = cv2.Canny(center_zone, 80, 200)
            if np.count_nonzero(edges) > 100:
                cv2.rectangle(mask, (int(w*0.25), int(h*0.4)), (int(w*0.75), int(h*0.6)), 255, -1)

        return mask
