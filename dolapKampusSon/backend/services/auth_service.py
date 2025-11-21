from models.user import User
from extensions import db
from utils.security import hash_password, verify_password
from flask_jwt_extended import create_access_token

class AuthService:

    @staticmethod
    def register_user(email, password, name):
        if User.query.filter_by(email=email).first():
            return None, "Bu e-posta zaten kayıtlı."

        if not email.endswith("@selcuk.edu.tr"):
            return None, "@selcuk.edu.tr zorunludur."

        user = User(
            email=email,
            password_hash=hash_password(password),
            name=name
        )

        db.session.add(user)
        db.session.commit()
        return user, None

    @staticmethod
    def login_user(email, password):
        user = User.query.filter_by(email=email).first()
        if not user or not verify_password(password, user.password_hash):
            return None, "Giriş bilgileri hatalı."

        token = create_access_token(identity=user.id)
        return token, user
