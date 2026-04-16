import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    # ── Database ──────────────────────────────────────────
    DB_HOST     = os.getenv("DB_HOST",     "localhost")
    DB_PORT     = int(os.getenv("DB_PORT", 3306))
    DB_USER     = os.getenv("DB_USER",     "root")
    DB_PASSWORD = os.getenv("DB_PASSWORD", "DPSnt23@")
    DB_NAME     = os.getenv("DB_NAME",     "right_time")

    # ── JWT ───────────────────────────────────────────────
    JWT_SECRET_KEY          = os.getenv("JWT_SECRET_KEY", "dev-secret-change-me")
    JWT_ACCESS_TOKEN_EXPIRES = 3600   # 1 hour in seconds

    # ── Flask ─────────────────────────────────────────────
    DEBUG = os.getenv("FLASK_DEBUG", "0") == "1"
