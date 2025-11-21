class Conversation {
  final int id;
  final int listingId;
  final int buyerId;
  final int sellerId;
  final String stage;
  final DateTime createdAt;
  final bool buyerApprovedAppointment;
  final bool sellerApprovedAppointment;
  final bool buyerApprovedDelivery;
  final bool sellerApprovedDelivery;

  const Conversation({
    required this.id,
    required this.listingId,
    required this.buyerId,
    required this.sellerId,
    required this.stage,
    required this.createdAt,
    this.buyerApprovedAppointment = false,
    this.sellerApprovedAppointment = false,
    this.buyerApprovedDelivery = false,
    this.sellerApprovedDelivery = false,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as int,
      listingId: json['listing_id'] as int,
      buyerId: json['buyer_id'] as int,
      sellerId: json['seller_id'] as int,
      stage: (json['stage'] as String?) ?? 'PRICE_NEGOTIATION',
      createdAt: DateTime.parse(json['created_at'] as String),
      buyerApprovedAppointment: (json['buyer_approved_appointment'] as bool?) ?? false,
      sellerApprovedAppointment: (json['seller_approved_appointment'] as bool?) ?? false,
      buyerApprovedDelivery: (json['buyer_approved_delivery'] as bool?) ?? false,
      sellerApprovedDelivery: (json['seller_approved_delivery'] as bool?) ?? false,
    );
  }

  Conversation copyWith({
    String? stage,
    bool? buyerApprovedAppointment,
    bool? sellerApprovedAppointment,
    bool? buyerApprovedDelivery,
    bool? sellerApprovedDelivery,
  }) {
    return Conversation(
      id: id,
      listingId: listingId,
      buyerId: buyerId,
      sellerId: sellerId,
      stage: stage ?? this.stage,
      createdAt: createdAt,
      buyerApprovedAppointment: buyerApprovedAppointment ?? this.buyerApprovedAppointment,
      sellerApprovedAppointment: sellerApprovedAppointment ?? this.sellerApprovedAppointment,
      buyerApprovedDelivery: buyerApprovedDelivery ?? this.buyerApprovedDelivery,
      sellerApprovedDelivery: sellerApprovedDelivery ?? this.sellerApprovedDelivery,
    );
  }
}

