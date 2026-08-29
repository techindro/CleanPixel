import cv2
import numpy as np
import os
import subprocess
import time
from pathlib import Path

class VideoCleanerPipeline:
    """
    Frame-by-frame video watermark removal pipeline with audio preservation.
    """

    @staticmethod
    def process_video(
        video_path: str,
        mask_path: str,
        output_path: str,
        engine: str = "telea",
        progress_callback=None
    ) -> dict:
        start_time = time.time()

        if not os.path.exists(video_path):
            raise FileNotFoundError(f"Video file not found: {video_path}")
        if not os.path.exists(mask_path):
            raise FileNotFoundError(f"Mask file not found: {mask_path}")

        # Open video capture
        cap = cv2.VideoCapture(video_path)
        if not cap.isOpened():
            raise ValueError(f"Could not open video file: {video_path}")

        fps = cap.get(cv2.CAP_PROP_FPS) or 30.0
        width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))

        # Load and resize mask
        mask = cv2.imread(mask_path, cv2.IMREAD_GRAYSCALE)
        if mask is None:
            raise ValueError("Invalid mask file")
        mask = cv2.resize(mask, (width, height), interpolation=cv2.INTER_NEAREST)
        _, binary_mask = cv2.threshold(mask, 10, 255, cv2.THRESH_BINARY)
        kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3, 3))
        binary_mask = cv2.dilate(binary_mask, kernel, iterations=1)

        # Temporary raw video file
        temp_video_path = output_path + ".temp.mp4"
        fourcc = cv2.VideoWriter_fourcc(*'mp4v')
        out = cv2.VideoWriter(temp_video_path, fourcc, fps, (width, height))

        inpaint_flag = cv2.INPAINT_NS if engine.lower() == "ns" else cv2.INPAINT_TELEA

        frame_count = 0
        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break

            # Inpaint frame
            cleaned_frame = cv2.inpaint(frame, binary_mask, inpaintRadius=3, flags=inpaint_flag)
            out.write(cleaned_frame)

            frame_count += 1
            if progress_callback and total_frames > 0 and frame_count % 10 == 0:
                progress_callback(int((frame_count / total_frames) * 100))

        cap.release()
        out.release()

        # Stitch original audio back using ffmpeg if available, otherwise rename
        try:
            cmd = [
                "ffmpeg", "-y",
                "-i", temp_video_path,
                "-i", video_path,
                "-c:v", "libx264",
                "-c:a", "aac",
                "-map", "0:v:0",
                "-map", "1:a:0?",
                "-shortest",
                output_path
            ]
            subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
            if os.path.exists(temp_video_path):
                os.remove(temp_video_path)
        except Exception:
            # Fallback if ffmpeg is not available in local PATH
            if os.path.exists(temp_video_path):
                if os.path.exists(output_path):
                    os.remove(output_path)
                os.rename(temp_video_path, output_path)

        elapsed_sec = round(time.time() - start_time, 2)

        return {
            "success": True,
            "total_frames": frame_count,
            "fps": fps,
            "resolution": f"{width}x{height}",
            "elapsed_seconds": elapsed_sec,
            "output_path": output_path
        }
