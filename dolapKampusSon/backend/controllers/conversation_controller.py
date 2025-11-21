from flask import jsonify
from extensions import db
from models.conversation import Conversation


class ConversationController:

    @staticmethod
    def _serialize(conversation: Conversation):
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
    def _validate_participant(conversation: Conversation, user_id: int):
        return conversation and (conversation.buyer_id == user_id or conversation.seller_id == user_id)

    @staticmethod
    def get_conversation(conversation_id, user_id):
        conversation = Conversation.query.get(conversation_id)
        if not conversation:
            return jsonify({"error": "Sohbet bulunamadı"}), 404
        if not ConversationController._validate_participant(conversation, user_id):
            return jsonify({"error": "Yetkiniz yok"}), 403
        return jsonify(ConversationController._serialize(conversation)), 200

    @staticmethod
    def get_user_conversations(user_id):
        """Kullanıcının tüm conversation'larını döndür (buyer veya seller olarak)"""
        conversations = Conversation.query.filter(
            (Conversation.buyer_id == user_id) | (Conversation.seller_id == user_id)
        ).order_by(Conversation.created_at.desc()).all()
        
        return jsonify([ConversationController._serialize(conv) for conv in conversations]), 200

    @staticmethod
    def update_stage(conversation_id, user_id, stage):
        conversation = Conversation.query.get(conversation_id)
        if not conversation:
            return jsonify({"error": "Sohbet bulunamadı"}), 404
        if not ConversationController._validate_participant(conversation, user_id):
            return jsonify({"error": "Yetkiniz yok"}), 403

        conversation.stage = stage
        db.session.commit()
        return jsonify({
            "message": "Sohbet güncellendi",
            "stage": conversation.stage
        }), 200

    @staticmethod
    def approve_appointment(conversation_id, user_id):
        conversation = Conversation.query.get(conversation_id)
        if not conversation:
            return jsonify({"error": "Sohbet bulunamadı"}), 404
        if not ConversationController._validate_participant(conversation, user_id):
            return jsonify({"error": "Yetkiniz yok"}), 403
        
        # Kullanıcının buyer mı seller mı olduğunu belirle
        if conversation.buyer_id == user_id:
            conversation.buyer_approved_appointment = True
        elif conversation.seller_id == user_id:
            conversation.seller_approved_appointment = True
        else:
            return jsonify({"error": "Geçersiz kullanıcı"}), 400
        
        # Her iki taraf da onayladıysa aşamayı ilerlet
        if conversation.buyer_approved_appointment and conversation.seller_approved_appointment:
            conversation.stage = "APPOINTMENT_CONFIRMED"
        
        db.session.commit()
        return jsonify(ConversationController._serialize(conversation)), 200

    @staticmethod
    def approve_delivery(conversation_id, user_id):
        conversation = Conversation.query.get(conversation_id)
        if not conversation:
            return jsonify({"error": "Sohbet bulunamadı"}), 404
        if not ConversationController._validate_participant(conversation, user_id):
            return jsonify({"error": "Yetkiniz yok"}), 403
        
        # Kullanıcının buyer mı seller mı olduğunu belirle
        if conversation.buyer_id == user_id:
            conversation.buyer_approved_delivery = True
        elif conversation.seller_id == user_id:
            conversation.seller_approved_delivery = True
        else:
            return jsonify({"error": "Geçersiz kullanıcı"}), 400
        
        # Her iki taraf da onayladıysa aşamayı ilerlet
        if conversation.buyer_approved_delivery and conversation.seller_approved_delivery:
            conversation.stage = "DELIVERY_CONFIRMED"
        
        db.session.commit()
        return jsonify(ConversationController._serialize(conversation)), 200

    @staticmethod
    def confirm_delivery(conversation_id, user_id):
        # Eski metod, artık approve_delivery kullanılacak
        return ConversationController.approve_delivery(conversation_id, user_id)

    @staticmethod
    def complete_conversation(conversation_id, user_id):
        return ConversationController.update_stage(conversation_id, user_id, "COMPLETED")

    @staticmethod
    def delete_conversation(conversation_id, user_id):
        conversation = Conversation.query.get(conversation_id)
        if not conversation:
            return jsonify({"error": "Sohbet bulunamadı"}), 404
        if not ConversationController._validate_participant(conversation, user_id):
            return jsonify({"error": "Yetkiniz yok"}), 403
        
        # İlişkili mesajları ve randevuları da sil (cascade delete)
        from models.message import Message
        from models.appointment import Appointment
        
        Message.query.filter_by(conversation_id=conversation_id).delete()
        Appointment.query.filter_by(conversation_id=conversation_id).delete()
        
        db.session.delete(conversation)
        db.session.commit()
        
        return jsonify({"message": "Sohbet silindi"}), 200

