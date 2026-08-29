from datetime import datetime, timedelta, timezone
from typing import Optional, Union, Any
from jose import jwt, JWTError
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from app.core.config import settings
from app.core.user_db import user_db
from app.core.schemas import UserProfile

oauth2_scheme = OAuth2PasswordBearer(tokenUrl=f"{settings.API_V1_STR}/auth/login", auto_error=False)

def create_access_token(subject: Union[str, Any], expires_delta: Optional[timedelta] = None) -> str:
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        
    to_encode = {"exp": expire, "sub": str(subject)}
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return encoded_jwt

def verify_token(token: str) -> Optional[str]:
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        return payload.get("sub")
    except JWTError:
        return None

async def get_current_user(token: Optional[str] = Depends(oauth2_scheme)) -> Optional[UserProfile]:
    if not token:
        return None

    user_id = verify_token(token)
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials or token expired",
            headers={"WWW-Authenticate": "Bearer"},
        )

    user_record = user_db.get_by_id(user_id)
    if not user_record:
        raise HTTPException(status_code=404, detail="User not found")

    return UserProfile(
        id=user_record["id"],
        email=user_record["email"],
        full_name=user_record["full_name"],
        avatar_url=user_record.get("avatar_url"),
        is_pro=user_record.get("is_pro", False),
        credits_remaining=user_record.get("credits_remaining", 150),
        created_at=user_record.get("created_at", "")
    )
