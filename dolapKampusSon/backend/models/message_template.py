from extensions import db

class MessageTemplate(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    text = db.Column(db.String(255), nullable=False)
    category = db.Column(db.String(50))  # PRICE, APPOINTMENT, DELIVERY, FEEDBACK
    param_keys = db.Column(db.JSON)      # ör: ["price"], ["date", "time", "location"]

    messages = db.relationship("Message", backref="template", lazy=True)

    def __repr__(self):
        return f"<MsgTemplate {self.id}>"
