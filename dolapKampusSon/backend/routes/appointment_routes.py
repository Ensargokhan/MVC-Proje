from flask import Blueprint, request
from controllers.appointment_controller import AppointmentController
from flask_jwt_extended import jwt_required

appointment_bp = Blueprint("appointment_bp", __name__)

@appointment_bp.post("/create")
@jwt_required()
def create_appointment():
    data = request.json
    return AppointmentController.create_appointment(data)

@appointment_bp.get("/conversation/<int:conversation_id>")
@jwt_required()
def get_appointment(conversation_id):
    return AppointmentController.get_appointment(conversation_id)
