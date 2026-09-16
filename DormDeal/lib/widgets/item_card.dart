import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/item.dart';
import '../screens/item_detail_screen.dart';

// Same tokens as home_screen
const _kPrimary            = Color(0xFF003F87);
const _kSurfaceLowest      = Color(0xFFFFFFFF);
const _kSurfaceContainer   = Color(0xFFEDEEEF);
const _kSurfaceLow         = Color(0xFFF3F4F5);
const _kSecondaryContainer = Color(0xFFD9E3F1);
const _kOnSurface          = Color(0xFF191C1D);
const _kOnSurfaceVariant   = Color(0xFF424752);
const _kOutlineVariant     = Color(0xFFC2C6D4);
const _kError              = Color(0xFFBA1A1A);

class ItemCard extends StatefulWidget {
  final Item item;
  const ItemCard({Key? key, required this.item}) : super(key: key);

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  bool _favoured = false;

  // Pick a category colour dot based on the title keywords (simple heuristic)
  Color get _dotColor {
    final t = widget.item.title.toLowerCase();
    if (t.contains('book') || t.contains('text')) return _kPrimary;
    if (t.contains('chair') || t.contains('desk') || t.contains('table')) {
      return const Color(0xFF555F6B);
    }
    return const Color(0xFF0056B3);
  }

  String get _categoryLabel {
    final t = widget.item.title.toLowerCase();
    if (t.contains('book') || t.contains('text')) return 'Textbooks';
    if (t.contains('chair') || t.contains('desk') || t.contains('table')) {
      return 'Furniture';
    }
    if (t.contains('laptop') || t.contains('phone') || t.contains('headphone')) {
      return 'Electronics';
    }
    return 'Item';
  }

  String _timeLeft() {
    final diff = widget.item.auctionEndsAt.difference(DateTime.now());
    if (diff.isNegative) return 'Ended';
    if (diff.inHours < 1) return '${diff.inMinutes}m left';
    if (diff.inHours < 24) return '${diff.inHours}h left';
    return '${diff.inDays}d left';
  }

  Color _timeColor() {
    final diff = widget.item.auctionEndsAt.difference(DateTime.now());
    if (diff.isNegative) return _kError;
    if (diff.inHours < 4) return _kError;
    return _kOnSurfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ItemDetailScreen(item: widget.item)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _kSurfaceLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kSecondaryContainer),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ──────────────────────────────────────────────────────
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image
                  widget.item.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: widget.item.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: _kSurfaceLow),
                          errorWidget: (_, __, ___) => Container(
                            color: _kSurfaceLow,
                            child: const Icon(
                              Icons.image_not_supported_outlined,
                              size: 36,
                              color: _kOnSurfaceVariant,
                            ),
                          ),
                        )
                      : Container(
                          color: _kSurfaceLow,
                          child: const Icon(
                            Icons.image_outlined,
                            size: 40,
                            color: _kOnSurfaceVariant,
                          ),
                        ),

                  // Favourite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _favoured = !_favoured),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: _kSurfaceLowest.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 4,
                            )
                          ],
                        ),
                        child: Icon(
                          _favoured
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 16,
                          color: _favoured ? _kError : _kOutlineVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Info ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category dot + label
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _categoryLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          color: _kOnSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Title
                  Text(
                    widget.item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                      color: _kOnSurface,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Bid price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Bid',
                        style: TextStyle(
                          fontSize: 11,
                          color: _kOnSurfaceVariant,
                        ),
                      ),
                      Text(
                        'Rs. ${widget.item.currentPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _kPrimary,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Time chip
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _kSurfaceContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 12,
                          color: _timeColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _timeLeft(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _timeColor(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

