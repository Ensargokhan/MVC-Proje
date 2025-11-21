from extensions import db
from datetime import datetime

class Message(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    conversation_id = db.Column(db.Integer, db.ForeignKey("conversation.id"))
    sender_id = db.Column(db.Integer, db.ForeignKey("user.id"))
    template_id = db.Column(db.Integer, db.ForeignKey("message_template.id"))

    # json parametreler (örneğin fiyat, randevu bilgisi)
    params = db.Column(db.JSON)

    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def __repr__(self):
        return f"<Message {self.id}>"
