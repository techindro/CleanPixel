from fastapi import APIRouter, HTTPException, status, Depends
from fastapi.security import OAuth2PasswordRequestForm
from app.core.schemas import UserRegister, UserLogin, GoogleOAuthRequest, TokenResponse, UserProfile
from app.core.user_db import user_db
from app.core.security import create_access_token, get_current_user
from app.core.config import settings

router = APIRouter()

@router.post("/register", response_model=TokenResponse, summary="Register a new CleanPixel account")
async def register(user_in: UserRegister):
    existing = user_db.get_by_email(user_in.email)
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="An account with this email already exists."
        )

    user_record = user_db.create_user(
        email=user_in.email,
        password=user_in.password,
        full_name=user_in.full_name or "CleanPixel Creator"
    )

    access_token = create_access_token(user_record["id"])

    return TokenResponse(
        access_token=access_token,
        token_type="bearer",
        expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        user=UserProfile(
            id=user_record["id"],
            email=user_record["email"],
            full_name=user_record["full_name"],
            avatar_url=user_record.get("avatar_url"),
            is_pro=user_record.get("is_pro", False),
            credits_remaining=user_record.get("credits_remaining", 150),
            created_at=user_record.get("created_at", "")
        )
    )

@router.post("/login", response_model=TokenResponse, summary="Sign in with Email and Password")
async def login(user_in: UserLogin):
    user_record = user_db.get_by_email(user_in.email)
    if not user_record or not user_record.get("password_hash"):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password."
        )

    if not user_db.verify_password(user_in.password, user_record["password_hash"]):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password."
        )

    access_token = create_access_token(user_record["id"])

    return TokenResponse(
        access_token=access_token,
        token_type="bearer",
        expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        user=UserProfile(
            id=user_record["id"],
            email=user_record["email"],
            full_name=user_record["full_name"],
            avatar_url=user_record.get("avatar_url"),
            is_pro=user_record.get("is_pro", False),
            credits_remaining=user_record.get("credits_remaining", 150),
            created_at=user_record.get("created_at", "")
        )
    )

@router.post("/google", response_model=TokenResponse, summary="OAuth 2.0 Google Sign In / Sign Up")
async def google_oauth_login(oauth_in: GoogleOAuthRequest):
    """
    Exchanges a verified Google OAuth profile or token for a CleanPixel JWT access token.
    """
    user_record = user_db.get_by_email(oauth_in.email)

    if not user_record:
        # Auto-create user from Google profile
        user_record = user_db.create_user(
            email=oauth_in.email,
            password=None,
            full_name=oauth_in.name or "Google Creator",
            avatar_url=oauth_in.avatar_url or f"https://api.dicebear.com/7.x/bottts/svg?seed={oauth_in.email}",
            oauth_provider="google"
        )

    access_token = create_access_token(user_record["id"])

    return TokenResponse(
        access_token=access_token,
        token_type="bearer",
        expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        user=UserProfile(
            id=user_record["id"],
            email=user_record["email"],
            full_name=user_record["full_name"],
            avatar_url=user_record.get("avatar_url"),
            is_pro=user_record.get("is_pro", False),
            credits_remaining=user_record.get("credits_remaining", 150),
            created_at=user_record.get("created_at", "")
        )
    )

@router.get("/me", response_model=UserProfile, summary="Get current authenticated user profile & balance")
async def get_my_profile(current_user: UserProfile = Depends(get_current_user)):
    if not current_user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication required"
        )
    return current_user
