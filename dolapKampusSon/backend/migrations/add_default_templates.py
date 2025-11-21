from app import create_app
from extensions import db
from models.message_template import MessageTemplate


def seed_templates():
    app = create_app()
    with app.app_context():
        templates = [
            MessageTemplate(
                text="Merhaba, son fiyatınız nedir?",
                category="PRICE",
                param_keys=[]
            ),
            MessageTemplate(
                text="Teklifim: [PRICE] TL",
                category="PRICE",
                param_keys=["price"]
            ),
            MessageTemplate(
                text="Anlaştık, yayından kaldırabilirsiniz.",
                category="PRICE",
                param_keys=[]
            ),
            MessageTemplate(
                text="Üzgünüm, anlaşamadık.",
                category="PRICE",
                param_keys=[]
            ),
        ]

        for template in templates:
            existing = MessageTemplate.query.filter_by(text=template.text).first()
            if not existing:
                db.session.add(template)

        db.session.commit()
        print("Mesaj şablonları eklendi.")


if __name__ == "__main__":
    seed_templates()

