class MessageTemplate {
  final int id;
  final String text;
  final String? category;
  final List<String> paramKeys;

  const MessageTemplate({
    required this.id,
    required this.text,
    this.category,
    required this.paramKeys,
  });

  factory MessageTemplate.fromJson(Map<String, dynamic> json) {
    return MessageTemplate(
      id: json['id'] as int,
      text: (json['text'] as String?) ?? '',
      category: json['category'] as String?,
      paramKeys: ((json['param_keys'] as List?) ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

