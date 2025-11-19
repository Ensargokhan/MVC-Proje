from flask import Blueprint, request
from controllers.message_controller import MessageController
from flask_jwt_extended import jwt_required, get_jwt_identity
from models.listing import Listing

message_bp = Blueprint("message_bp", __name__)

@message_bp.post("/start/<int:listing_id>/<int:seller_id>")
@jwt_required()
def start_conversation(listing_id, seller_id):
    from flask import jsonify
    current_user_id = int(get_jwt_identity())
    
    # Listing'i kontrol et
    listing = Listing.query.get(listing_id)
    if not listing:
        return jsonify({"error": "İlan bulunamadı"}), 404
    
    # Conversation'ı bul veya oluştur
    # Listing'den seller_id'yi al, mevcut kullanıcı buyer veya seller olabilir
    convo = MessageController.get_or_create_conversation(
        listing_id=listing_id,
        current_user_id=current_user_id,
        listing_seller_id=listing.seller_id
    )
    
    if convo is None:
        # Seller tek başına conversation oluşturamaz
        return jsonify({"error": "Henüz bir alıcı ile conversation başlatılmamış"}), 400
    
    return MessageController.get_conversation(convo.id)

@message_bp.post("/send")
@jwt_required()
def send_message():
    user_id = int(get_jwt_identity())
    data = request.json
    return MessageController.send_message(data, user_id)

@message_bp.get("/history/<int:conversation_id>")
@jwt_required()
def get_messages(conversation_id):
    return MessageController.get_messages(conversation_id)

@message_bp.get("/templates")
@jwt_required()
def get_templates():
    category = request.args.get("category")
    return MessageController.get_templates(category)

@message_bp.get("/conversation/<int:conversation_id>")
@jwt_required()
def get_conversation(conversation_id):
    return MessageController.get_conversation(conversation_id)
