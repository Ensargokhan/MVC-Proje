import re

def is_empty(value):
    return value is None or value == "" or str(value).strip() == ""

def validate_email(email: str) -> bool:
    """email formatı doğru mu?"""
    pattern = r"[^@]+@[^@]+\.[^@]+"
    return re.match(pattern, email) is not None

def validate_selcuk_email(email: str) -> bool:
    """Sadece @selcuk.edu.tr izin ver"""
    return email.endswith("@selcuk.edu.tr")

def validate_price(value) -> bool:
    """Fiyat pozitif mi?"""
    try:
        return float(value) >= 0
    except:
        return False

def validate_required_fields(data: dict, fields: list):
    """Zorunlu alanları kontrol eder."""
    missing = []
    for field in fields:
        if field not in data or is_empty(data[field]):
            missing.append(field)
    return missing
