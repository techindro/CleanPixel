from celery import Celery
from app.core.config import settings
from app.models.inpaint_engine import InpaintEngine
from app.models.video_cleaner import VideoCleanerPipeline
import os

celery_app = Celery(
    "cleanpixel_worker",
    broker=settings.CELERY_BROKER_URL,
    backend=settings.CELERY_RESULT_BACKEND
)

celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
)

@celery_app.task(bind=True)
def async_inpaint_image(self, image_path: str, mask_path: str, output_path: str, engine: str = "telea"):
    self.update_state(state="PROGRESS", meta={"progress": 20, "status": "Segmenting watermark contours..."})
    
    self.update_state(state="PROGRESS", meta={"progress": 55, "status": "Synthesizing neural inpaint tensor..."})
    result = InpaintEngine.inpaint_image(image_path, mask_path, output_path, engine)
    
    self.update_state(state="PROGRESS", meta={"progress": 100, "status": "Completed"})
    return result

@celery_app.task(bind=True)
def async_inpaint_video(self, video_path: str, mask_path: str, output_path: str, engine: str = "telea"):
    def progress_handler(percent):
        self.update_state(state="PROGRESS", meta={"progress": percent, "status": f"Processing video frame {percent}%"})

    return VideoCleanerPipeline.process_video(
        video_path=video_path,
        mask_path=mask_path,
        output_path=output_path,
        engine=engine,
        progress_callback=progress_handler
    )
