import os
from pathlib import Path
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(case_sensitive=True)
    
    PROJECT_NAME: str = "CleanPixel AI Engine"
    VERSION: str = "2.5.0"
    API_V1_STR: str = "/api/v1"
    
    # Environment
    ENV: str = os.getenv("ENV", "development")
    DEBUG: bool = os.getenv("DEBUG", "True").lower() == "true"
    
    # Security & Auth
    SECRET_KEY: str = os.getenv("SECRET_KEY", "cleanpixel-super-secret-key-38bdf8-2563eb")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7 # 7 days

    # RevenueCat API v2 Configuration
    REVENUECAT_SECRET_KEY: str = os.getenv("REVENUECAT_SECRET_KEY", "sk_zqLkKtrQaqjbngcxsjgFuhaVZcxcs")
    
    # Storage Configuration
    BASE_DIR: Path = Path(__file__).resolve().parent.parent.parent
    STORAGE_DIR: Path = BASE_DIR / "storage"
    UPLOAD_DIR: Path = STORAGE_DIR / "uploads"
    RESULT_DIR: Path = STORAGE_DIR / "results"
    TEMP_DIR: Path = STORAGE_DIR / "temp"
    
    # Max payload limits (e.g. 50MB for 4K images, 500MB for video)
    MAX_IMAGE_SIZE_MB: int = 50
    MAX_VIDEO_SIZE_MB: int = 500
    
    # Celery & Redis Configuration
    REDIS_URL: str = os.getenv("REDIS_URL", "redis://localhost:6379/0")
    CELERY_BROKER_URL: str = os.getenv("CELERY_BROKER_URL", "redis://localhost:6379/0")
    CELERY_RESULT_BACKEND: str = os.getenv("CELERY_RESULT_BACKEND", "redis://localhost:6379/0")
    
    # Model Configurations
    DEFAULT_INPAINT_ENGINE: str = "telea" # Options: lama, telea, ns

settings = Settings()

# Ensure directories exist
for directory in [settings.STORAGE_DIR, settings.UPLOAD_DIR, settings.RESULT_DIR, settings.TEMP_DIR]:
    directory.mkdir(parents=True, exist_ok=True)
