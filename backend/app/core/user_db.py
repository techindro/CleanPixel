import json
import os
import uuid
from datetime import datetime, timezone
from typing import Optional, Dict
from pathlib import Path
import hashlib
import secrets
from app.core.config import settings
from app.core.schemas import UserProfile

class UserDatabase:
    """
    Persistent JSON-backed User store for authentication & credit balances.
    Uses PBKDF2 SHA-256 password hashing.
    """
    def __init__(self):
        self.db_path = settings.STORAGE_DIR / "users.json"
        self.users: Dict[str, dict] = {}
        self._load()

    def _load(self):
        if self.db_path.exists():
            try:
                with open(self.db_path, "r", encoding="utf-8") as f:
                    self.users = json.load(f)
            except Exception:
                self.users = {}
        else:
            self._save()

    def _save(self):
        with open(self.db_path, "w", encoding="utf-8") as f:
            json.dump(self.users, f, indent=2)

    def hash_password(self, password: str) -> str:
        salt = secrets.token_hex(16)
        key = hashlib.pbkdf2_hmac('sha256', password.encode('utf-8'), salt.encode('utf-8'), 100000)
        return f"{salt}${key.hex()}"

    def verify_password(self, plain_password: str, stored_hash: str) -> bool:
        try:
            salt, key_hex = stored_hash.split('$')
            key = hashlib.pbkdf2_hmac('sha256', plain_password.encode('utf-8'), salt.encode('utf-8'), 100000)
            return key.hex() == key_hex
        except Exception:
            return False

    def get_by_email(self, email: str) -> Optional[dict]:
        email_clean = email.strip().lower()
        for u in self.users.values():
            if u["email"].lower() == email_clean:
                return u
        return None

    def get_by_id(self, user_id: str) -> Optional[dict]:
        return self.users.get(user_id)

    def create_user(self, email: str, password: Optional[str], full_name: str, avatar_url: Optional[str] = None, oauth_provider: Optional[str] = None) -> dict:
        user_id = f"usr_{uuid.uuid4().hex[:12]}"
        now = datetime.now(timezone.utc).isoformat()
        
        user_record = {
            "id": user_id,
            "email": email.strip().lower(),
            "password_hash": self.hash_password(password) if password else None,
            "full_name": full_name,
            "avatar_url": avatar_url or f"https://api.dicebear.com/7.x/bottts/svg?seed={user_id}",
            "is_pro": False,
            "credits_remaining": 150,
            "oauth_provider": oauth_provider,
            "created_at": now
        }
        
        self.users[user_id] = user_record
        self._save()
        return user_record

    def deduct_credit(self, user_id: str, amount: int = 1) -> bool:
        if user_id in self.users and self.users[user_id]["credits_remaining"] >= amount:
            self.users[user_id]["credits_remaining"] -= amount
            self._save()
            return True
        return False

user_db = UserDatabase()
