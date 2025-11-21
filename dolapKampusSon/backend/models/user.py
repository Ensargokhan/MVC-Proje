from extensions import db
from datetime import datetime

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    name = db.Column(db.String(100))
    avatar_url = db.Column(db.String(255))

    trust_score = db.Column(db.Float, default=5.0)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    listings = db.relationship("Listing", backref="seller", lazy=True)
    messages = db.relationship("Message", backref="sender", lazy=True)
    feedback_received = db.relationship("Feedback", backref="user", lazy=True)

    def __repr__(self):
        return f"<User {self.email}>"
