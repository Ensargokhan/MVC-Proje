from models.appointment import Appointment
from models.conversation import Conversation
from extensions import db

class AppointmentService:

    @staticmethod
    def create_appointment(conversation_id, date, time, location):
        appointment = Appointment(
            conversation_id=conversation_id,
            date=date,
            time=time,
            location=location
        )

        convo = Conversation.query.get(conversation_id)
        convo.stage = "APPOINTMENT_SET"

        db.session.add(appointment)
        db.session.commit()
        return appointment

    @staticmethod
    def get_appointment(conversation_id):
        return Appointment.query.filter_by(conversation_id=conversation_id).first()
