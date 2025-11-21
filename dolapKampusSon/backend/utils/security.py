from werkzeug.security import generate_password_hash, check_password_hash

def hash_password(password: str) -> str:
    """Parolayı güvenli şekilde hash'ler."""
    return generate_password_hash(password)

def verify_password(password: str, hashed: str) -> bool:
    """Parolanın hash ile eşleşip eşleşmediğini kontrol eder."""
    return check_password_hash(hashed, password)
