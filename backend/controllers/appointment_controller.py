from flask import jsonify
from extensions import db
from models.appointment import Appointment
from models.conversation import Conversation


class AppointmentController:

    @staticmethod
    def _serialize(appointment: Appointment):
        return {
            "id": appointment.id,
            "conversation_id": appointment.conversation_id,
            "date": appointment.date,
            "time": appointment.time,
            "location": appointment.location,
            "created_at": appointment.created_at.isoformat()
        }

    @staticmethod
    def create_appointment(data):
        conversation_id = data.get("conversation_id")
        date = data.get("date")
        time = data.get("time")
        location = data.get("location")

        appointment = Appointment(
            conversation_id=conversation_id,
            date=date,
            time=time,
            location=location
        )

        # Randevu oluşturuldu, ancak stage değişmez
        # Her iki taraf da onayladığında approve_appointment metodu stage'i ilerletecek
        db.session.add(appointment)
        db.session.commit()

        return jsonify(AppointmentController._serialize(appointment)), 201

    @staticmethod
    def get_appointment(conversation_id):
        appt = Appointment.query.filter_by(conversation_id=conversation_id).first()
        if not appt:
            return jsonify({"error": "Randevu yok"}), 404

        return jsonify(AppointmentController._serialize(appt)), 200
