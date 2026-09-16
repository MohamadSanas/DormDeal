import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/item.dart';
import '../services/api_service.dart';

class _D {
  static const primary            = Color(0xFF003F87);
  static const background         = Color(0xFFF8F9FA);
  static const surfaceLowest      = Color(0xFFFFFFFF);
  static const surfaceContainer   = Color(0xFFEDEEEF);
  static const surfaceContainerLow= Color(0xFFF3F4F5);
  static const onSurface          = Color(0xFF191C1D);
  static const onSurfaceVariant   = Color(0xFF424752);
  static const outline            = Color(0xFF727784);
  static const outlineVariant     = Color(0xFFC2C6D4);
  static const error              = Color(0xFFBA1A1A);
}

class PlaceBidScreen extends StatefulWidget {
  final Item item;
  final double currentHighestBid;
  final void Function(double newBid)? onBidPlaced;

  const PlaceBidScreen({
    Key? key,
    required this.item,
    required this.currentHighestBid,
    this.onBidPlaced,
  }) : super(key: key);

  @override
  State<PlaceBidScreen> createState() => _PlaceBidScreenState();
}

class _PlaceBidScreenState extends State<PlaceBidScreen> {
  final _bidCtrl = TextEditingController();
  String? _error;
  bool _submitting = false;

  double get _minBid => widget.currentHighestBid + 1;

  @override
  void dispose() { _bidCtrl.dispose(); super.dispose(); }

  void _submit() async {
    final v = double.tryParse(_bidCtrl.text.trim());
    if (v == null || v < _minBid) {
      setState(() => _error = 'Bid must be at least Rs. ${_minBid.toStringAsFixed(2)}');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final user = ApiService.currentUser;
      final bidderName = user?.name.isNotEmpty == true ? user!.name : 'Campus Student';
      final bidderWhatsapp = user?.whatsappNumber?.isNotEmpty == true ? user!.whatsappNumber! : '+1234567890';

      await ApiService().placeBid(
        itemId: widget.item.id,
        bidderName: bidderName,
        bidderWhatsapp: bidderWhatsapp,
        amount: v,
      );

      if (!mounted) return;
      widget.onBidPlaced?.call(v);
      Navigator.pop(context, v);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Bid placed successfully!'),
        backgroundColor: Color(0xFF1B6B3A),
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceAll('Exception: ', '');
      setState(() => _error = msg);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _D.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: _D.surfaceLowest,
                border: Border(bottom: BorderSide(color: Color(0xFFE1E3E4))),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Place Bid',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: _D.onSurface)),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _D.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Icon(Icons.close_rounded, size: 20, color: _D.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Item summary card
                    _itemSummary(),
                    const SizedBox(height: 28),

                    // Current bid display
                    _currentBidDisplay(),
                    const SizedBox(height: 28),

                    // Bid input
                    _bidInput(),
                    const SizedBox(height: 24),

                    // Buttons
                    _PressBtn(
                      onTap: _submitting ? () {} : _submit,
                      color: _D.primary,
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Place Bid',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                    const SizedBox(height: 10),
                    _OutlineBtn(
                      onTap: () => Navigator.pop(context),
                      child: const Text('Cancel',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: _D.primary)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _D.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(0xFFE1E3E4)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 88, height: 88,
              child: widget.item.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: widget.item.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: _D.surfaceContainer),
                      errorWidget: (_, __, ___) => Container(color: _D.surfaceContainer,
                        child: const Icon(Icons.image_outlined, color: _D.outlineVariant)),
                    )
                  : Container(color: _D.surfaceContainer,
                      child: const Icon(Icons.image_outlined, color: _D.outlineVariant)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.item.title,
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _D.onSurface, height: 1.3)),
                const SizedBox(height: 4),
                const Text('University Campus',
                  style: TextStyle(fontSize: 12, color: _D.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _currentBidDisplay() {
    return Column(children: [
      const Text('Current Highest Bid',
        style: TextStyle(fontSize: 15, color: _D.onSurfaceVariant)),
      const SizedBox(height: 6),
      Text('Rs. ${widget.currentHighestBid.toStringAsFixed(0)}',
        style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w700, color: _D.primary, height: 1.0)),
    ]);
  }

  Widget _bidInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Bid',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: _D.onSurface)),
        const SizedBox(height: 6),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: _D.surfaceLowest,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _error != null ? _D.error : _D.outlineVariant,
              width: _error != null ? 1.5 : 1,
            ),
          ),
          child: Row(children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Text('Rs.', style: TextStyle(fontSize: 16, color: _D.onSurfaceVariant)),
            ),
            Expanded(
              child: TextField(
                controller: _bidCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 17, color: _D.onSurface),
                onChanged: (_) { if (_error != null) setState(() => _error = null); },
                decoration: InputDecoration(
                  hintText: '${_minBid.toStringAsFixed(0)}.00',
                  hintStyle: const TextStyle(fontSize: 17, color: _D.outline),
                  border: InputBorder.none, isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 6),
        _error != null
            ? Row(children: [
                const Icon(Icons.error_outline_rounded, size: 14, color: _D.error),
                const SizedBox(width: 4),
                Text(_error!, style: const TextStyle(fontSize: 12, color: _D.error)),
              ])
            : Row(children: [
                const Icon(Icons.info_outline_rounded, size: 14, color: _D.onSurfaceVariant),
                const SizedBox(width: 4),
                Text('Minimum bid: Rs. ${_minBid.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 12, color: _D.onSurfaceVariant)),
              ]),
      ],
    );
  }
}

// ── Filled button ──────────────────────────────────────────────────────────
class _PressBtn extends StatefulWidget {
  final VoidCallback onTap;
  final Color color;
  final Widget child;
  const _PressBtn({required this.onTap, required this.color, required this.child});
  @override
  State<_PressBtn> createState() => _PressBtnState();
}
class _PressBtnState extends State<_PressBtn> {
  bool _p = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => setState(() => _p = true),
    onTapUp: (_) { setState(() => _p = false); widget.onTap(); },
    onTapCancel: () => setState(() => _p = false),
    child: AnimatedScale(scale: _p ? 0.97 : 1.0, duration: const Duration(milliseconds: 100),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(color: widget.color, borderRadius: BorderRadius.circular(10)),
        alignment: Alignment.center,
        child: widget.child,
      )),
  );
}

// ── Outline button ─────────────────────────────────────────────────────────
class _OutlineBtn extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _OutlineBtn({required this.onTap, required this.child});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFD9E3F1),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: child,
    ),
  );
}
