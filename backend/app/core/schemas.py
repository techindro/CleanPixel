from pydantic import BaseModel, Field
from typing import Optional

class UserRegister(BaseModel):
    email: str = Field(..., description="Valid email address")
    password: str = Field(..., min_length=6, description="Password minimum 6 characters")
    full_name: Optional[str] = "CleanPixel Creator"

class UserLogin(BaseModel):
    email: str
    password: str

class GoogleOAuthRequest(BaseModel):
    id_token: Optional[str] = None
    email: str
    name: Optional[str] = "Google User"
    avatar_url: Optional[str] = None

class UserProfile(BaseModel):
    id: str
    email: str
    full_name: str
    avatar_url: Optional[str] = None
    is_pro: bool = False
    credits_remaining: int = 150
    created_at: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_in: int
    user: UserProfile
