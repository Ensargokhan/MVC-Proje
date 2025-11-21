class ConversationMessage {
  final int id;
  final int senderId;
  final String template;
  final Map<String, dynamic>? params;
  final DateTime createdAt;

  const ConversationMessage({
    required this.id,
    required this.senderId,
    required this.template,
    required this.params,
    required this.createdAt,
  });

  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    return ConversationMessage(
      id: json['id'] as int,
      senderId: json['sender_id'] as int,
      template: (json['template'] as String?) ?? '',
      params: (json['params'] as Map<String, dynamic>?),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String render() {
    var text = template;
    params?.forEach((key, value) {
      text = text.replaceAll('[$key]'.toUpperCase(), value.toString());
    });
    return text;
  }
}

