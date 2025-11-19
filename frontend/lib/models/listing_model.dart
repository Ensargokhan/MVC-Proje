class Listing {
  final int id;
  final String title;
  final double price;
  final String description;
  final String? category;
  final String? location;
  final String? imageUrl;
  final int? sellerId;

  // ⭐ Berat’tan gelen yeni alanlar
  final String? sellerName;
  final String? sellerEmail;
  final String? sellerAvatarUrl;

  final DateTime? createdAt;

  const Listing({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    this.category,
    this.location,
    this.imageUrl,
    this.sellerId,
    this.sellerName,
    this.sellerEmail,
    this.sellerAvatarUrl,
    this.createdAt,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'] as int,
      title: (json['title'] ?? '') as String,
      price: (json['price'] as num).toDouble(),
      description: (json['description'] as String?) ?? '',
      category: json['category'] as String?,
      location: json['location'] as String?,
      imageUrl: json['image_url'] as String?,
      sellerId: json['seller_id'] as int?,

      // ⭐ Güvenli şekilde ekledim
      sellerName: json['seller_name'] as String?,
      sellerEmail: json['seller_email'] as String?,
      sellerAvatarUrl: json['seller_avatar_url'] as String?,

      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'location': location,
      'image_url': imageUrl,
      'seller_id': sellerId,

      // ⭐ Yeni alanlar JSON formatında
      'seller_name': sellerName,
      'seller_email': sellerEmail,
      'seller_avatar_url': sellerAvatarUrl,

      'created_at': createdAt?.toIso8601String(),
    };
  }
}
