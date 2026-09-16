class BidItem {
  final String id;
  final String itemId;
  final String? bidderId;
  final String bidderName;
  final String bidderWhatsapp;
  final double amount;
  final DateTime createdAt;
  final String? itemTitle;
  final String? itemImageUrl;
  final double? itemCurrentPrice;
  final DateTime? itemAuctionEndsAt;
  final bool? itemIsFinalized;

  BidItem({
    required this.id,
    required this.itemId,
    this.bidderId,
    required this.bidderName,
    required this.bidderWhatsapp,
    required this.amount,
    required this.createdAt,
    this.itemTitle,
    this.itemImageUrl,
    this.itemCurrentPrice,
    this.itemAuctionEndsAt,
    this.itemIsFinalized,
  });

  factory BidItem.fromJson(Map<String, dynamic> json) {
    return BidItem(
      id: json['id'] ?? '',
      itemId: json['item_id'] ?? '',
      bidderId: json['bidder_id'],
      bidderName: json['bidder_name'] ?? '',
      bidderWhatsapp: json['bidder_whatsapp'] ?? '',
      amount: ((json['amount'] ?? 0) as num).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      itemTitle: json['item_title'],
      itemImageUrl: json['item_image_url'],
      itemCurrentPrice: json['item_current_price'] != null
          ? ((json['item_current_price'] as num).toDouble())
          : null,
      itemAuctionEndsAt: json['item_auction_ends_at'] != null
          ? DateTime.parse(json['item_auction_ends_at'])
          : null,
      itemIsFinalized: json['item_is_finalized'],
    );
  }

  bool get isWinning =>
      itemCurrentPrice != null && amount >= itemCurrentPrice!;

  bool get isEnded =>
      (itemAuctionEndsAt != null && DateTime.now().isAfter(itemAuctionEndsAt!)) ||
      (itemIsFinalized == true);

  String get status {
    if (isEnded) {
      return isWinning ? 'ended_won' : 'ended_lost';
    }
    return isWinning ? 'winning' : 'outbid';
  }
}
