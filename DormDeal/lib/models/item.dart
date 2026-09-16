class Item {
  final String id;
  final String? ownerId;
  final String title;
  final double basePrice;
  final double currentPrice;
  final String? description;
  final String? category;
  final String whatsappNumber;
  final String? imageUrl;
  final DateTime auctionEndsAt;
  final String paymentMethod;
  final String? currentBidderName;
  final String? currentBidderWhatsapp;
  final String? currentBidderId;
  final DateTime? bidUpdatedAt;
  final bool isFinalized;
  final int bidCount;
  final DateTime createdAt;

  Item({
    required this.id,
    this.ownerId,
    required this.title,
    required this.basePrice,
    required this.currentPrice,
    this.description,
    this.category,
    required this.whatsappNumber,
    this.imageUrl,
    required this.auctionEndsAt,
    required this.paymentMethod,
    this.currentBidderName,
    this.currentBidderWhatsapp,
    this.currentBidderId,
    this.bidUpdatedAt,
    this.isFinalized = false,
    this.bidCount = 0,
    required this.createdAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] ?? '',
      ownerId: json['owner_id'],
      title: json['title'] ?? '',
      basePrice: ((json['base_price'] ?? 0) as num).toDouble(),
      currentPrice: ((json['current_price'] ?? json['base_price'] ?? 0) as num).toDouble(),
      description: json['description'],
      category: json['category'],
      whatsappNumber: json['whatsapp_number'] ?? '',
      imageUrl: json['image_url'],
      auctionEndsAt: json['auction_ends_at'] != null
          ? DateTime.parse(json['auction_ends_at'])
          : (json['created_at'] != null
              ? DateTime.parse(json['created_at']).add(const Duration(hours: 24))
              : DateTime.now().add(const Duration(hours: 24))),
      paymentMethod: json['payment_method'] ?? 'Cash on Delivery',
      currentBidderName: json['current_bidder_name'],
      currentBidderWhatsapp: json['current_bidder_whatsapp'],
      currentBidderId: json['current_bidder_id'],
      bidUpdatedAt: json['bid_updated_at'] != null
          ? DateTime.parse(json['bid_updated_at'])
          : null,
      isFinalized: json['is_finalized'] ?? false,
      bidCount: json['bid_count'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
