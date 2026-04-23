class Item {
  final String id;
  final String title;
  final double basePrice;
  final double currentPrice;
  final String? description;
  final String whatsappNumber;
  final String? imageUrl;
  final DateTime auctionEndsAt;
  final String paymentMethod;
  final String? currentBidderName;
  final String? currentBidderWhatsapp;
  final DateTime? bidUpdatedAt;
  final DateTime createdAt;

  Item({
    required this.id,
    required this.title,
    required this.basePrice,
    required this.currentPrice,
    this.description,
    required this.whatsappNumber,
    this.imageUrl,
    required this.auctionEndsAt,
    required this.paymentMethod,
    this.currentBidderName,
    this.currentBidderWhatsapp,
    this.bidUpdatedAt,
    required this.createdAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      title: json['title'],
      basePrice: (json['base_price'] as num).toDouble(),
      currentPrice: (json['current_price'] as num).toDouble(),
      description: json['description'],
      whatsappNumber: json['whatsapp_number'],
      imageUrl: json['image_url'],
      auctionEndsAt: json['auction_ends_at'] != null
          ? DateTime.parse(json['auction_ends_at'])
          : DateTime.parse(json['created_at']).add(const Duration(hours: 24)),
      paymentMethod: json['payment_method'] ?? 'Cash on Delivery',
      currentBidderName: json['current_bidder_name'],
      currentBidderWhatsapp: json['current_bidder_whatsapp'],
      bidUpdatedAt: json['bid_updated_at'] != null
          ? DateTime.parse(json['bid_updated_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
