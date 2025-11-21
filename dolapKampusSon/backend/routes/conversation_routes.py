from flask import Blueprint
from flask_jwt_extended import jwt_required, get_jwt_identity

from controllers.conversation_controller import ConversationController

conversation_bp = Blueprint("conversation_bp", __name__)


@conversation_bp.get("/my-conversations")
@jwt_required()
def get_my_conversations():
    user_id = int(get_jwt_identity())
    return ConversationController.get_user_conversations(user_id)


@conversation_bp.get("/<int:conversation_id>")
@jwt_required()
def get_conversation(conversation_id):
    user_id = int(get_jwt_identity())
    return ConversationController.get_conversation(conversation_id, user_id)


@conversation_bp.post("/<int:conversation_id>/approve-appointment")
@jwt_required()
def approve_appointment(conversation_id):
    user_id = int(get_jwt_identity())
    return ConversationController.approve_appointment(conversation_id, user_id)


@conversation_bp.post("/<int:conversation_id>/approve-delivery")
@jwt_required()
def approve_delivery(conversation_id):
    user_id = int(get_jwt_identity())
    return ConversationController.approve_delivery(conversation_id, user_id)


@conversation_bp.post("/<int:conversation_id>/confirm-delivery")
@jwt_required()
def confirm_delivery(conversation_id):
    user_id = int(get_jwt_identity())
    return ConversationController.confirm_delivery(conversation_id, user_id)


@conversation_bp.post("/<int:conversation_id>/complete")
@jwt_required()
def complete_conversation(conversation_id):
    user_id = int(get_jwt_identity())
    return ConversationController.complete_conversation(conversation_id, user_id)


@conversation_bp.delete("/<int:conversation_id>")
@jwt_required()
def delete_conversation(conversation_id):
    user_id = int(get_jwt_identity())
    return ConversationController.delete_conversation(conversation_id, user_id)

