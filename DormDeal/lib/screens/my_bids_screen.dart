import 'package:flutter/material.dart';
import '../models/bid_item.dart';
import '../services/api_service.dart';
import 'item_detail_screen.dart';

class _D {
  static const primary            = Color(0xFF003F87);
  static const background         = Color(0xFFF8F9FA);
  static const surfaceLowest      = Color(0xFFFFFFFF);
  static const surfaceContainer   = Color(0xFFEDEEEF);
  static const secondaryContainer = Color(0xFFD9E3F1);
  static const onSurface          = Color(0xFF191C1D);
  static const onSurfaceVariant   = Color(0xFF424752);
  static const outlineVariant     = Color(0xFFC2C6D4);
  static const error              = Color(0xFFBA1A1A);
  static const success            = Color(0xFF1B6B3A);
  static const successContainer   = Color(0xFFD6F0E0);
}

class MyBidsScreen extends StatefulWidget {
  const MyBidsScreen({super.key});

  @override
  State<MyBidsScreen> createState() => _MyBidsScreenState();
}

class _MyBidsScreenState extends State<MyBidsScreen> {
  late Future<List<BidItem>> _futureBids;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _futureBids = ApiService().getMyBids();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _D.background,
      appBar: AppBar(
        backgroundColor: _D.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: const Text('My Bids',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _D.primary)),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: _D.secondaryContainer)),
      ),
      body: FutureBuilder<List<BidItem>>(
        future: _futureBids,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _D.primary));
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: _D.error),
                  const SizedBox(height: 12),
                  Text('Failed to load bids',
                      style: const TextStyle(fontSize: 16, color: _D.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  TextButton(onPressed: _refresh, child: const Text('Retry')),
                ],
              ),
            );
          }

          final bids = snapshot.data ?? [];
          if (bids.isEmpty) {
            return _empty();
          }

          final active = bids.where((b) => !b.isEnded).toList();
          final past = bids.where((b) => b.isEnded).toList();

          return RefreshIndicator(
            color: _D.primary,
            onRefresh: () async => _refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                if (active.isNotEmpty) ...[
                  _sectionLabel('Active Bids'),
                  const SizedBox(height: 10),
                  ...active.map((b) => _bidCard(context, b)),
                  const SizedBox(height: 20),
                ],
                if (past.isNotEmpty) ...[
                  _sectionLabel('Past Bids'),
                  const SizedBox(height: 10),
                  ...past.map((b) => _bidCard(context, b)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(text,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _D.onSurface));

  Widget _bidCard(BuildContext context, BidItem b) {
    final isWinning = b.status == 'winning';
    final isOutbid = b.status == 'outbid';
    final isWon = b.status == 'ended_won';

    Color chipBg;
    Color chipFg;
    String chipLabel;
    IconData chipIcon;

    if (isWinning) {
      chipBg = _D.successContainer;
      chipFg = _D.success;
      chipLabel = 'Winning';
      chipIcon = Icons.emoji_events_rounded;
    } else if (isOutbid) {
      chipBg = const Color(0xFFFFEDE9);
      chipFg = _D.error;
      chipLabel = 'Outbid';
      chipIcon = Icons.arrow_upward_rounded;
    } else if (isWon) {
      chipBg = _D.successContainer;
      chipFg = _D.success;
      chipLabel = 'Won';
      chipIcon = Icons.check_circle_rounded;
    } else {
      chipBg = _D.surfaceContainer;
      chipFg = _D.onSurfaceVariant;
      chipLabel = 'Lost';
      chipIcon = Icons.cancel_rounded;
    }

    return GestureDetector(
      onTap: () async {
        try {
          final item = await ApiService().getItem(b.itemId);
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
            );
          }
        } catch (_) {}
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _D.surfaceLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _D.outlineVariant),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: b.itemImageUrl != null && b.itemImageUrl!.isNotEmpty
                  ? Image.network(
                      b.itemImageUrl!,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 72,
                        height: 72,
                        color: _D.surfaceContainer,
                        child: const Icon(Icons.image_outlined, color: _D.outlineVariant),
                      ),
                    )
                  : Container(
                      width: 72,
                      height: 72,
                      color: _D.surfaceContainer,
                      child: const Icon(Icons.image_outlined, color: _D.outlineVariant),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(b.itemTitle ?? 'Auction Item',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: _D.onSurface, height: 1.3)),
                const SizedBox(height: 6),
                Row(children: [
                  Text('My bid: Rs. ${b.amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600, color: _D.primary)),
                  if (b.itemCurrentPrice != null) ...[
                    const SizedBox(width: 6),
                    Text('· High: Rs. ${b.itemCurrentPrice!.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 12, color: _D.onSurfaceVariant)),
                  ],
                ]),
              ]),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: chipBg, borderRadius: BorderRadius.circular(6)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(chipIcon, size: 12, color: chipFg),
                const SizedBox(width: 3),
                Text(chipLabel,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: chipFg)),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.gavel_rounded, size: 64, color: _D.outlineVariant),
            const SizedBox(height: 16),
            const Text("No bids yet",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _D.onSurface)),
            const SizedBox(height: 8),
            const Text("Start bidding on items in the marketplace",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: _D.onSurfaceVariant)),
          ],
        ),
      );
}
