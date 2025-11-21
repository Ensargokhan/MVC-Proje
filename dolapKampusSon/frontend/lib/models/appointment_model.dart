class Appointment {
  final int id;
  final int conversationId;
  final String date;
  final String time;
  final String location;

  const Appointment({
    required this.id,
    required this.conversationId,
    required this.date,
    required this.time,
    required this.location,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as int,
      conversationId: json['conversation_id'] as int? ?? 0,
      date: (json['date'] as String?) ?? '',
      time: (json['time'] as String?) ?? '',
      location: (json['location'] as String?) ?? '',
    );
  }
}

