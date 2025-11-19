import os
from datetime import timedelta

class Config:
    SECRET_KEY = os.getenv("SECRET_KEY", "dev_secret_key")
    SQLALCHEMY_DATABASE_URI = "sqlite:///campus.db"
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    # JWT
    JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "jwt_dev_secret")
    JWT_TOKEN_LOCATION = ["headers", "query_string"]   # Berat eklentisi
    JWT_QUERY_STRING_NAME = "token"                    # Berat eklentisi
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(days=7)       # Berat eklentisi

    # DOSYA YÜKLEME (image upload için gerekli)
    UPLOAD_FOLDER = os.path.join(os.path.dirname(__file__), "uploads")
    MAX_CONTENT_LENGTH = 10 * 1024 * 1024  # 10 MB
