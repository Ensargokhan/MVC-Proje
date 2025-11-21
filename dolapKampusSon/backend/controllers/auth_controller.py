from flask import jsonify
from models.user import User
from extensions import db
from utils.security import hash_password, verify_password
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
import re

class AuthController:

    # ----------------------------------------------------------------------
    #  KAYIT OL
    # ----------------------------------------------------------------------
    @staticmethod
    def register(data):
        email = data.get("email")
        password = data.get("password")
        name = data.get("name")

        if not email or not password or not name:
            return jsonify({"error": "Eksik alanlar var"}), 400

        if not email.endswith("@selcuk.edu.tr"):
            return jsonify({"error": "Sadece @selcuk.edu.tr e-postası ile kayıt olunabilir"}), 400

        if User.query.filter_by(email=email).first():
            return jsonify({"error": "Bu e-posta zaten kayıtlı"}), 400

        new_user = User(
            email=email,
            password_hash=hash_password(password),
            name=name
        )

        db.session.add(new_user)
        db.session.commit()

        return jsonify({"message": "Kayıt başarılı"}), 201

    # ----------------------------------------------------------------------
    #  GİRİŞ
    # ----------------------------------------------------------------------
    @staticmethod
    def login(data):
        email = data.get("email")
        password = data.get("password")

        user = User.query.filter_by(email=email).first()

        if not user or not verify_password(password, user.password_hash):
            return jsonify({"error": "E-posta veya şifre hatalı"}), 401

        token = create_access_token(identity=str(user.id))

        return jsonify({
            "token": token,
            "user": {
                "id": user.id,
                "email": user.email,
                "name": user.name,
                "avatar_url": getattr(user, "avatar_url", None)
            }
        }), 200

    # ----------------------------------------------------------------------
    #  PROFİL GÜNCELLE (isim + avatar_url)
    # ----------------------------------------------------------------------
    @staticmethod
    @jwt_required()
    def update_profile(data):
        user_id = int(get_jwt_identity())
        user = User.query.get(user_id)

        if not user:
            return jsonify({"error": "Kullanıcı bulunamadı"}), 404

        name = data.get("name")
        avatar_url = data.get("avatar_url")

        if name is not None:
            user.name = name

        if avatar_url is not None:
            user.avatar_url = avatar_url

        db.session.commit()

        return jsonify({
            "id": user.id,
            "email": user.email,
            "name": user.name,
            "avatar_url": getattr(user, "avatar_url", None)
        }), 200
