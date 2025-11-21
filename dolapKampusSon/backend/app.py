from flask import Flask, send_from_directory, current_app
from config import Config
from extensions import db, jwt, cors
from database import init_db
import os

from routes.auth_routes import auth_bp
from routes.listing_routes import listing_bp
from routes.message_routes import message_bp
from routes.appointment_routes import appointment_bp
from routes.conversation_routes import conversation_bp


def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    cors.init_app(app)
    jwt.init_app(app)
    db.init_app(app)

    # Veritabanı başlatma
    init_db(app)

    # 📌 Berat’ın eklediği — Upload klasörü yoksa oluştur
    os.makedirs(app.config["UPLOAD_FOLDER"], exist_ok=True)

    # 📌 Blueprint'ler
    app.register_blueprint(auth_bp, url_prefix="/api/auth")
    app.register_blueprint(listing_bp, url_prefix="/api/listings")
    app.register_blueprint(message_bp, url_prefix="/api/messages")
    app.register_blueprint(appointment_bp, url_prefix="/api/appointments")
    app.register_blueprint(conversation_bp, url_prefix="/api/conversations")

    # 📌 Berat’ın eklediği — Yüklenen dosyaları servis etmek için endpoint
    @app.get("/uploads/<path:filename>")
    def uploads_get_file(filename):
        return send_from_directory(current_app.config["UPLOAD_FOLDER"], filename)

    return app


if __name__ == '__main__':
    app = create_app()
    app.run(debug=True)
