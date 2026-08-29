from fastapi import APIRouter
from app.api.endpoints import inpaint, auth, status, batch

api_router = APIRouter()
api_router.include_router(auth.router, prefix="/auth", tags=["OAuth & JWT Authentication"])
api_router.include_router(inpaint.router, tags=["Inpainting & Cleaner Services"])
api_router.include_router(status.router, tags=["Async Task Status"])
api_router.include_router(batch.router, tags=["Batch Processing"])
