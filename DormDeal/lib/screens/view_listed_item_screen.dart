import 'dart:async';
import 'package:flutter/material.dart';

class _D {
  static const primary            = Color(0xFF003F87);
  static const background         = Color(0xFFF8F9FA);
  static const surfaceLowest      = Color(0xFFFFFFFF);
  static const surfaceContainer   = Color(0xFFEDEEEF);
  static const surfaceContainerLow= Color(0xFFF3F4F5);
  static const secondaryContainer = Color(0xFFD9E3F1);
  static const onSurface          = Color(0xFF191C1D);
  static const onSurfaceVariant   = Color(0xFF424752);
  static const outline            = Color(0xFF727784);
  static const outlineVariant     = Color(0xFFC2C6D4);
  static const error              = Color(0xFFBA1A1A);
  static const errorContainer     = Color(0xFFFFEDE9);
}

// ── Data passed in from MyListingsScreen ─────────────────────────────────
class ListedItem {
  final String id;
  final String title;
  final String imageUrl;
  String category;
  String description;
  final double basePrice;
  final double currentBid;
  final int bidCount;
  final String topBidderName;
  final String topBidderContact;
  final DateTime auctionEndsAt;
  String status; // 'active' | 'sold' | 'unsold'

  ListedItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.category,
    required this.description,
    required this.basePrice,
    required this.currentBid,
    required this.bidCount,
    required this.topBidderName,
    required this.topBidderContact,
    required this.auctionEndsAt,
    required this.status,
  });
}

// ── Screen ─────────────────────────────────────────────────────────────────
class ViewListedItemScreen extends StatefulWidget {
  final ListedItem item;
  const ViewListedItemScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<ViewListedItemScreen> createState() => _ViewListedItemScreenState();
}

class _ViewListedItemScreenState extends State<ViewListedItemScreen> {
  late String _category;
  late TextEditingController _descCtrl;
  bool _editMode = false;
  bool _sold = false;
  Timer? _timer;
  Duration _remaining = Duration.zero;

  static const _categories = ['Textbooks', 'Electronics', 'Furniture', 'Clothing', 'Mobility', 'Other'];

  @override
  void initState() {
    super.initState();
    _category = widget.item.category;
    _descCtrl = TextEditingController(text: widget.item.description);
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(_tick);
    });
    _sold = widget.item.status == 'sold';
  }

  void _tick() {
    final d = widget.item.auctionEndsAt.difference(DateTime.now());
    _remaining = d.isNegative ? Duration.zero : d;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _descCtrl.dispose();
    super.dispose();
  }

  bool get _auctionOver => _remaining == Duration.zero || _sold;
  bool get _hasBids => widget.item.bidCount > 0;

  String get _timerLabel {
    if (_sold) return 'Sold';
    if (_remaining == Duration.zero) return 'Ended';
    final h = _remaining.inHours.toString().padLeft(2, '0');
    final m = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  // ── Save edits ─────────────────────────────────────────────────────────
  void _saveEdits() {
    setState(() {
      widget.item.category    = _category;
      widget.item.description = _descCtrl.text.trim();
      _editMode = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Listing updated!'),
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ── Sell Now ────────────────────────────────────────────────────────────
  void _confirmSellNow() {
    if (!_hasBids) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No bids yet — nobody to sell to.'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _D.surfaceLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sell Now?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _D.onSurface)),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('This will immediately end the auction and sell to:',
            style: TextStyle(fontSize: 14, color: _D.onSurfaceVariant)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _D.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _D.outlineVariant),
            ),
            child: Row(children: [
              const CircleAvatar(radius: 20, backgroundColor: _D.secondaryContainer,
                child: Icon(Icons.person_rounded, color: _D.primary, size: 22)),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.item.topBidderName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _D.onSurface)),
                Text('Rs. ${widget.item.currentBid.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _D.primary)),
              ]),
            ]),
          ),
          const SizedBox(height: 12),
          const Text('This action cannot be undone.',
            style: TextStyle(fontSize: 12, color: _D.outline)),
        ]),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
              style: TextStyle(color: _D.onSurfaceVariant, fontWeight: FontWeight.w500)),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _sold = true;
                widget.item.status = 'sold';
              });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Sold to ${widget.item.topBidderName} for Rs. ${widget.item.currentBid.toStringAsFixed(0)}!'),
                backgroundColor: const Color(0xFF1B6B3A),
                behavior: SnackBarBehavior.floating,
              ));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(color: _D.primary, borderRadius: BorderRadius.circular(8)),
              child: const Text('Confirm Sale',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _D.background,
      appBar: AppBar(
        backgroundColor: _D.background,
        elevation: 0, scrolledUnderElevation: 1, surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _D.onSurfaceVariant),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Listing',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _D.primary)),
        centerTitle: true,
        actions: [
          if (!_auctionOver)
            TextButton.icon(
              onPressed: () => setState(() => _editMode = !_editMode),
              icon: Icon(_editMode ? Icons.close_rounded : Icons.edit_rounded, size: 18),
              label: Text(_editMode ? 'Cancel' : 'Edit'),
              style: TextButton.styleFrom(foregroundColor: _D.primary),
            ),
          if (_editMode) const SizedBox(width: 4),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _D.secondaryContainer)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _imageSection(),
          const SizedBox(height: 16),
          _titleAndStatus(),
          const SizedBox(height: 16),
          _statsRow(),
          const SizedBox(height: 16),
          _topBidderCard(),
          const SizedBox(height: 16),
          _editSection(),
          if (_sold) ...[
            const SizedBox(height: 16),
            _soldBanner(),
          ],
        ]),
      ),
      bottomNavigationBar: _auctionOver ? null : _bottomBar(),
    );
  }

  // ── Image ───────────────────────────────────────────────────────────────
  Widget _imageSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          widget.item.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: _D.surfaceContainer,
            child: const Icon(Icons.image_outlined, size: 56, color: _D.outlineVariant),
          ),
        ),
      ),
    );
  }

  // ── Title + status chip ─────────────────────────────────────────────────
  Widget _titleAndStatus() {
    Color chipBg; Color chipFg; String chipLabel;
    if (_sold)                             { chipBg = const Color(0xFFD6F0E0); chipFg = const Color(0xFF1B6B3A); chipLabel = 'Sold'; }
    else if (_auctionOver)                 { chipBg = _D.surfaceContainer;      chipFg = _D.onSurfaceVariant;    chipLabel = 'Ended'; }
    else                                   { chipBg = _D.secondaryContainer;    chipFg = _D.primary;             chipLabel = 'Active'; }

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        child: Text(widget.item.title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _D.onSurface, height: 1.3)),
      ),
      const SizedBox(width: 10),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: chipBg, borderRadius: BorderRadius.circular(6)),
        child: Text(chipLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: chipFg)),
      ),
    ]);
  }

  // ── Stats row ───────────────────────────────────────────────────────────
  Widget _statsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: _D.surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _D.outlineVariant),
      ),
      child: Row(children: [
        _StatCell(value: 'Rs. ${widget.item.currentBid.toStringAsFixed(0)}', label: 'Current Bid'),
        _vDivider(),
        _StatCell(value: '${widget.item.bidCount}', label: 'Total Bids'),
        _vDivider(),
        _StatCell(
          value: _timerLabel,
          label: _sold ? 'Status' : 'Time Left',
          valueColor: _sold
              ? const Color(0xFF1B6B3A)
              : (_auctionOver ? _D.onSurfaceVariant : _D.error),
        ),
      ]),
    );
  }

  Widget _vDivider() => Container(width: 1, height: 36, color: _D.outlineVariant);

  // ── Top bidder card ─────────────────────────────────────────────────────
  Widget _topBidderCard() {
    if (!_hasBids) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _D.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _D.outlineVariant),
        ),
        child: const Row(children: [
          Icon(Icons.person_off_outlined, size: 20, color: _D.onSurfaceVariant),
          SizedBox(width: 10),
          Text('No bids yet', style: TextStyle(fontSize: 14, color: _D.onSurfaceVariant)),
        ]),
      );
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _D.surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _D.secondaryContainer),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Highest Bidder',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
            letterSpacing: 0.4, color: _D.onSurfaceVariant)),
        const SizedBox(height: 10),
        Row(children: [
          const CircleAvatar(radius: 22, backgroundColor: _D.secondaryContainer,
            child: Icon(Icons.person_rounded, color: _D.primary, size: 24)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.item.topBidderName,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _D.onSurface)),
            const SizedBox(height: 2),
            Row(children: [
              const Icon(Icons.verified_user_rounded, size: 13, color: _D.primary),
              const SizedBox(width: 4),
              const Text('Verified Student',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _D.primary)),
            ]),
          ])),
          Text('Rs. ${widget.item.currentBid.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _D.primary)),
        ]),
      ]),
    );
  }

  // ── Edit section ────────────────────────────────────────────────────────
  Widget _editSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _D.surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _D.outlineVariant),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Listing Details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _D.onSurface)),
          if (_editMode)
            GestureDetector(
              onTap: _saveEdits,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(color: _D.primary, borderRadius: BorderRadius.circular(6)),
                child: const Text('Save',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
        ]),
        const Divider(height: 20, color: _D.outlineVariant),

        // Category
        const Text('Category',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
            letterSpacing: 0.4, color: _D.onSurfaceVariant)),
        const SizedBox(height: 8),
        _editMode
            ? Wrap(
                spacing: 8, runSpacing: 8,
                children: _categories.map((c) {
                  final sel = c == _category;
                  return GestureDetector(
                    onTap: () => setState(() => _category = c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: sel ? _D.primary : _D.surfaceLowest,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: sel ? _D.primary : _D.outlineVariant),
                      ),
                      child: Text(c, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                        color: sel ? Colors.white : _D.onSurfaceVariant)),
                    ),
                  );
                }).toList(),
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: _D.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_category,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _D.primary)),
              ),

        const SizedBox(height: 16),

        // Description
        const Text('Description',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
            letterSpacing: 0.4, color: _D.onSurfaceVariant)),
        const SizedBox(height: 8),
        _editMode
            ? TextField(
                controller: _descCtrl,
                maxLines: 4,
                style: const TextStyle(fontSize: 14, color: _D.onSurface),
                decoration: InputDecoration(
                  hintText: 'Describe your item...',
                  hintStyle: const TextStyle(color: _D.outline, fontSize: 14),
                  filled: true, fillColor: _D.surfaceContainerLow,
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _D.outlineVariant)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _D.outlineVariant)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _D.primary, width: 2)),
                ),
              )
            : Text(
                widget.item.description.isNotEmpty
                    ? widget.item.description
                    : 'No description provided.',
                style: const TextStyle(fontSize: 14, height: 1.6, color: _D.onSurfaceVariant),
              ),
      ]),
    );
  }

  // ── Sold banner ─────────────────────────────────────────────────────────
  Widget _soldBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD6F0E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF8FD4A8)),
      ),
      child: Row(children: [
        const Icon(Icons.check_circle_rounded, color: Color(0xFF1B6B3A), size: 28),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Auction Ended — Item Sold!',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1B6B3A))),
          const SizedBox(height: 2),
          Text('Sold to ${widget.item.topBidderName} for Rs. ${widget.item.currentBid.toStringAsFixed(0)}.',
            style: const TextStyle(fontSize: 13, color: Color(0xFF2D6A4F))),
          const SizedBox(height: 4),
          Text('Contact: ${widget.item.topBidderContact}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF1B6B3A))),
        ])),
      ]),
    );
  }

  // ── Bottom bar ──────────────────────────────────────────────────────────
  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: const BoxDecoration(
        color: _D.background,
        border: Border(top: BorderSide(color: _D.secondaryContainer)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: _editMode
            ? OutlinedButton(
                onPressed: () => setState(() => _editMode = false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: _D.outlineVariant),
                  foregroundColor: _D.onSurfaceVariant,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Cancel Edit', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              )
            : _SellNowButton(onTap: _hasBids ? _confirmSellNow : null, hasBids: _hasBids),
      ),
    );
  }
}

// ── Sell Now button ─────────────────────────────────────────────────────────
class _SellNowButton extends StatefulWidget {
  final VoidCallback? onTap;
  final bool hasBids;
  const _SellNowButton({required this.onTap, required this.hasBids});
  @override
  State<_SellNowButton> createState() => _SellNowButtonState();
}
class _SellNowButtonState extends State<_SellNowButton> {
  bool _p = false;
  @override
  Widget build(BuildContext context) {
    final enabled = widget.hasBids;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _p = true) : null,
      onTapUp: enabled ? (_) { setState(() => _p = false); widget.onTap?.call(); } : null,
      onTapCancel: () => setState(() => _p = false),
      child: AnimatedScale(
        scale: _p ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: enabled ? const Color(0xFFBA1A1A) : const Color(0xFFEDEEEF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.gavel_rounded, size: 20,
              color: enabled ? Colors.white : const Color(0xFF727784)),
            const SizedBox(width: 8),
            Text(
              enabled ? 'Sell Now to Highest Bidder' : 'No Bids Yet',
              style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700,
                color: enabled ? Colors.white : const Color(0xFF727784),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Stat cell ────────────────────────────────────────────────────────────────
class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;
  const _StatCell({required this.value, required this.label, this.valueColor});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Text(value,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
          color: valueColor ?? const Color(0xFF003F87))),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF424752))),
    ]),
  );
}
