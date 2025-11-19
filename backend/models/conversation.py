from extensions import db
from datetime import datetime

class Conversation(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    listing_id = db.Column(db.Integer, db.ForeignKey("listing.id"), nullable=False)
    buyer_id = db.Column(db.Integer, db.ForeignKey("user.id"), nullable=False)
    seller_id = db.Column(db.Integer, db.ForeignKey("user.id"), nullable=False)

    stage = db.Column(db.String(50), default="PRICE_NEGOTIATION")
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # İki taraflı onay mekanizması
    buyer_approved_appointment = db.Column(db.Boolean, default=False)
    seller_approved_appointment = db.Column(db.Boolean, default=False)
    buyer_approved_delivery = db.Column(db.Boolean, default=False)
    seller_approved_delivery = db.Column(db.Boolean, default=False)

    messages = db.relationship("Message", backref="conversation", lazy=True)
    appointments = db.relationship("Appointment", backref="conversation", lazy=True)

    def __repr__(self):
        return f"<Conversation {self.id}>"
