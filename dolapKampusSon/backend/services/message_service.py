from models.message import Message
from models.conversation import Conversation
from models.message_template import MessageTemplate
from extensions import db

class MessageService:

    @staticmethod
    def get_or_create_conversation(listing_id, buyer_id, seller_id):
        conversation = Conversation.query.filter_by(
            listing_id=listing_id,
            buyer_id=buyer_id,
            seller_id=seller_id
        ).first()

        if conversation:
            return conversation

        conversation = Conversation(
            listing_id=listing_id,
            buyer_id=buyer_id,
            seller_id=seller_id
        )
        db.session.add(conversation)
        db.session.commit()
        return conversation

    @staticmethod
    def send_message(conversation_id, sender_id, template_id, params):
        template = MessageTemplate.query.get(template_id)
        if not template:
            return None, "Şablon bulunamadı"

        message = Message(
            conversation_id=conversation_id,
            sender_id=sender_id,
            template_id=template_id,
            params=params
        )

        db.session.add(message)
        db.session.commit()
        return message, None

    @staticmethod
    def get_messages(conversation_id):
        return Message.query.filter_by(conversation_id=conversation_id).all()
