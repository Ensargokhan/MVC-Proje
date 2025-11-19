from flask import jsonify
from extensions import db
from models.message import Message
from models.conversation import Conversation
from models.message_template import MessageTemplate


class MessageController:

    @staticmethod
    def _serialize_conversation(conversation: Conversation):
        return {
            "id": conversation.id,
            "listing_id": conversation.listing_id,
            "buyer_id": conversation.buyer_id,
            "seller_id": conversation.seller_id,
            "stage": conversation.stage,
            "created_at": conversation.created_at.isoformat(),
            "buyer_approved_appointment": conversation.buyer_approved_appointment,
            "seller_approved_appointment": conversation.seller_approved_appointment,
            "buyer_approved_delivery": conversation.buyer_approved_delivery,
            "seller_approved_delivery": conversation.seller_approved_delivery,
        }

    @staticmethod
    def get_or_create_conversation(listing_id, current_user_id, listing_seller_id):
        """
        Conversation'ı bul veya oluştur.
        listing_id: İlan ID'si
        current_user_id: Mevcut kullanıcı (buyer veya seller olabilir)
        listing_seller_id: İlanın sahibi (seller)
        """
        # Önce listing_id'ye göre tüm conversation'ları bul
        conversations = Conversation.query.filter_by(listing_id=listing_id).all()
        
        # Mevcut kullanıcı seller ise, buyer_id=current_user_id olan conversation'ı bul
        # Mevcut kullanıcı buyer ise, buyer_id=current_user_id ve seller_id=listing_seller_id olan conversation'ı bul
        conversation = None
        if current_user_id == listing_seller_id:
            # Seller conversation'ı açıyor - aynı listing için birden fazla conversation olabilir
            # En son oluşturulan conversation'ı döndür (en güncel olan)
            seller_conversations = [conv for conv in conversations if conv.seller_id == current_user_id]
            if seller_conversations:
                # En son oluşturulan conversation'ı al
                conversation = max(seller_conversations, key=lambda c: c.created_at)
        else:
            # Buyer conversation'ı açıyor - buyer için sadece bir conversation olmalı
            for conv in conversations:
                if conv.buyer_id == current_user_id and conv.seller_id == listing_seller_id:
                    conversation = conv
                    break

        if conversation:
            return conversation

        # Yeni conversation oluştur
        # Eğer mevcut kullanıcı seller ise, conversation oluşturulamaz (seller tek başına conversation oluşturamaz)
        # Sadece buyer conversation oluşturabilir
        if current_user_id == listing_seller_id:
            # Seller conversation'ı açmaya çalışıyor ama henüz buyer yok
            # Bu durumda None döndür veya hata fırlat
            from flask import jsonify
            return None  # Veya hata fırlatılabilir
        
        # Mevcut kullanıcı buyer, listing sahibi seller olarak kaydedilir
        conversation = Conversation(
            listing_id=listing_id,
            buyer_id=current_user_id,
            seller_id=listing_seller_id,
            stage="PRICE_NEGOTIATION"  # Yeni conversation her zaman PRICE_NEGOTIATION ile başlar
        )
        db.session.add(conversation)
        db.session.commit()

        return conversation

    @staticmethod
    def send_message(data, user_id):
        conversation_id = data.get("conversation_id")
        template_id = data.get("template_id")
        params = data.get("params")

        template = MessageTemplate.query.get(template_id)
        if not template:
            return jsonify({"error": "Şablon bulunamadı"}), 400

        message = Message(
            conversation_id=conversation_id,
            sender_id=user_id,
            template_id=template_id,
            params=params
        )

        db.session.add(message)
        db.session.commit()

        return jsonify({"message": "Mesaj gönderildi"}), 201

    @staticmethod
    def get_messages(conversation_id):
        msgs = Message.query.filter_by(conversation_id=conversation_id).all()
        return jsonify([
            {
                "id": m.id,
                "sender_id": m.sender_id,
                "template": m.template.text,
                "params": m.params,
                "created_at": m.created_at.isoformat()
            }
            for m in msgs
        ]), 200

    @staticmethod
    def get_conversation(conversation_id):
        conversation = Conversation.query.get(conversation_id)
        if not conversation:
            return jsonify({"error": "Sohbet bulunamadı"}), 404
        return jsonify(MessageController._serialize_conversation(conversation)), 200

    @staticmethod
    def get_templates(category=None):
        query = MessageTemplate.query
        if category:
            query = query.filter_by(category=category)
        templates = query.all()
        return jsonify([
            {
                "id": t.id,
                "text": t.text,
                "category": t.category,
                "param_keys": t.param_keys or []
            }
            for t in templates
        ]), 200
