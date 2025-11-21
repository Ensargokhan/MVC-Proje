from flask import Blueprint, request
from controllers.auth_controller import AuthController
from flask_jwt_extended import jwt_required

auth_bp = Blueprint("auth_bp", __name__)

@auth_bp.post("/register")
def register():
    data = request.json
    return AuthController.register(data)

@auth_bp.post("/login")
def login():
    data = request.json
    return AuthController.login(data)

# ⭐ Berat’ın eklediği profil güncelleme endpoint’i
@auth_bp.put("/profile")
@jwt_required()
def update_profile():
    data = request.json
    return AuthController.update_profile(data)
