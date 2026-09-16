import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/api_service.dart';
import 'post_item_screen.dart';
import 'view_listed_item_screen.dart';

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
}

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  late Future<List<Item>> _futureListings;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _futureListings = ApiService().getMyListings();
    });
  }

  ListedItem _toListedItem(Item item) {
    final isEnded = DateTime.now().isAfter(item.auctionEndsAt) || item.isFinalized;
    String status = 'active';
    if (item.isFinalized) {
      status = item.currentBidderName != null ? 'sold' : 'unsold';
    } else if (isEnded) {
      status = item.bidCount > 0 ? 'sold' : 'unsold';
    }

    return ListedItem(
      id: item.id,
      title: item.title,
      imageUrl: item.imageUrl ?? '',
      category: item.category ?? 'Other',
      description: item.description ?? '',
      basePrice: item.basePrice,
      currentBid: item.currentPrice,
      bidCount: item.bidCount,
      topBidderName: item.currentBidderName ?? '',
      topBidderContact: item.currentBidderWhatsapp ?? '',
      auctionEndsAt: item.auctionEndsAt,
      status: status,
    );
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
        title: const Text('My Listings',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _D.primary)),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: _D.secondaryContainer)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
              context, MaterialPageRoute(builder: (_) => const PostItemScreen()));
          _refresh();
        },
        backgroundColor: _D.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Listing',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: FutureBuilder<List<Item>>(
        future: _futureListings,
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
                  const Text('Failed to load listings',
                      style: TextStyle(fontSize: 16, color: _D.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  TextButton(onPressed: _refresh, child: const Text('Retry')),
                ],
              ),
            );
          }

          final rawItems = snapshot.data ?? [];
          final listings = rawItems.map(_toListedItem).toList();

          if (listings.isEmpty) {
            return _empty(context);
          }

          final active = listings.where((l) => l.status == 'active').toList();
          final past = listings.where((l) => l.status != 'active').toList();

          return RefreshIndicator(
            color: _D.primary,
            onRefresh: () async => _refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                if (active.isNotEmpty) ...[
                  _sectionLabel('Active (${active.length})'),
                  const SizedBox(height: 10),
                  ...active.map((l) => _listingCard(context, l)),
                  const SizedBox(height: 20),
                ],
                if (past.isNotEmpty) ...[
                  _sectionLabel('Past (${past.length})'),
                  const SizedBox(height: 10),
                  ...past.map((l) => _listingCard(context, l)),
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

  Widget _listingCard(BuildContext context, ListedItem l) {
    final isActive = l.status == 'active';
    final isSold = l.status == 'sold';
    final chipBg = isActive
        ? const Color(0xFFD6F0E0)
        : isSold
            ? _D.secondaryContainer
            : _D.surfaceContainer;
    final chipFg = isActive
        ? const Color(0xFF1B6B3A)
        : isSold
            ? _D.primary
            : _D.onSurfaceVariant;
    final chipLabel = isActive ? 'Active' : isSold ? 'Sold' : 'Unsold';

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ViewListedItemScreen(item: l)),
        );
        _refresh();
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
              child: l.imageUrl.isNotEmpty
                  ? Image.network(l.imageUrl,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                          width: 72,
                          height: 72,
                          color: _D.surfaceContainer,
                          child: const Icon(Icons.image_outlined, color: _D.outlineVariant)))
                  : Container(
                      width: 72,
                      height: 72,
                      color: _D.surfaceContainer,
                      child: const Icon(Icons.image_outlined, color: _D.outlineVariant)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: _D.onSurface, height: 1.3)),
                const SizedBox(height: 4),
                Text(l.category,
                    style: const TextStyle(fontSize: 12, color: _D.onSurfaceVariant)),
                const SizedBox(height: 6),
                Row(children: [
                  Text('Rs. ${l.currentBid.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700, color: _D.primary)),
                  const SizedBox(width: 8),
                  Text('· ${l.bidCount} ${l.bidCount == 1 ? 'bid' : 'bids'}',
                      style: const TextStyle(fontSize: 12, color: _D.onSurfaceVariant)),
                ]),
              ]),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: chipBg, borderRadius: BorderRadius.circular(6)),
              child: Text(chipLabel,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: chipFg)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront_rounded, size: 64, color: _D.outlineVariant),
            const SizedBox(height: 16),
            const Text("No listings yet",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _D.onSurface)),
            const SizedBox(height: 8),
            const Text("Items you put up for auction will appear here",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: _D.onSurfaceVariant)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const PostItemScreen()));
                _refresh();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _D.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Post Your First Item'),
            ),
          ],
        ),
      );
}
