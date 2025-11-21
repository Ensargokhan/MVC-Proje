from extensions import db
from datetime import datetime
from models.user import User  # ⭐ Satıcı bilgilerini almak için

class Listing(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    seller_id = db.Column(db.Integer, db.ForeignKey("user.id"), nullable=False)
    title = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text)
    category = db.Column(db.String(100))
    price = db.Column(db.Float, nullable=False)
    location = db.Column(db.String(120))
    image_url = db.Column(db.String(255))

    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        # ⭐ Satıcı bilgileri (Berat'ın ekledikleri)
        seller_name = None
        seller_email = None
        seller_avatar_url = None

        try:
            seller = User.query.get(self.seller_id)
            if seller:
                seller_name = seller.name
                seller_email = seller.email
                seller_avatar_url = getattr(seller, "avatar_url", None)
        except Exception:
            pass

        return {
            "id": self.id,
            "seller_id": self.seller_id,
            "seller_name": seller_name,           # ⭐ eklendi
            "seller_email": seller_email,         # ⭐ eklendi
            "seller_avatar_url": seller_avatar_url,  # ⭐ eklendi
            "title": self.title,
            "description": self.description,
            "category": self.category,
            "price": self.price,
            "location": self.location,
            "image_url": self.image_url,
            "created_at": self.created_at.isoformat()
        }
