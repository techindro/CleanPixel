import sys
from pathlib import Path

backend_dir = Path(__file__).resolve().parent.parent
if str(backend_dir) not in sys.path:
    sys.path.insert(0, str(backend_dir))

from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_auth_registration_and_login():
    test_email = "creator_test@cleanpixel.ai"
    test_password = "password123"

    # 1. Registration
    reg_res = client.post("/api/v1/auth/register", json={
        "email": test_email,
        "password": test_password,
        "full_name": "Test Creator"
    })
    assert reg_res.status_code in [200, 400] # 400 if user already created in previous run

    # 2. Login
    login_res = client.post("/api/v1/auth/login", json={
        "email": test_email,
        "password": test_password
    })
    assert login_res.status_code == 200
    token_data = login_res.json()
    assert "access_token" in token_data
    token = token_data["access_token"]

    # 3. Protected /me profile with JWT
    me_res = client.get("/api/v1/auth/me", headers={
        "Authorization": f"Bearer {token}"
    })
    assert me_res.status_code == 200
    user_info = me_res.json()
    assert user_info["email"] == test_email
    assert user_info["credits_remaining"] >= 0

def test_google_oauth_exchange():
    oauth_res = client.post("/api/v1/auth/google", json={
        "email": "oauth_user@gmail.com",
        "name": "Google User Test",
        "avatar_url": "https://example.com/avatar.png"
    })
    assert oauth_res.status_code == 200
    data = oauth_res.json()
    assert "access_token" in data
    assert data["user"]["email"] == "oauth_user@gmail.com"
