from fastapi import APIRouter, HTTPException
from app.services.celery_tasks import celery_app

router = APIRouter()

@router.get("/status/{task_id}", summary="Check async task status (Video Inpainting)")
async def get_task_status(task_id: str):
    """
    Query Celery task state for async video processing jobs.
    Returns progress percentage and current step information.
    """
    try:
        task = celery_app.AsyncResult(task_id)
    except Exception:
        raise HTTPException(status_code=500, detail="Could not connect to task broker")

    if task.state == "PENDING":
        return {
            "task_id": task_id,
            "status": "PENDING",
            "progress": 0,
            "message": "Task is waiting in queue..."
        }
    elif task.state == "PROGRESS":
        meta = task.info or {}
        return {
            "task_id": task_id,
            "status": "PROGRESS",
            "progress": meta.get("progress", 0),
            "message": meta.get("status", "Processing...")
        }
    elif task.state == "SUCCESS":
        result = task.result or {}
        return {
            "task_id": task_id,
            "status": "COMPLETED",
            "progress": 100,
            "message": "Processing complete",
            "result": result
        }
    elif task.state == "FAILURE":
        return {
            "task_id": task_id,
            "status": "FAILED",
            "progress": 0,
            "message": str(task.info) if task.info else "Task failed"
        }
    else:
        return {
            "task_id": task_id,
            "status": task.state,
            "progress": 0,
            "message": "Unknown state"
        }
