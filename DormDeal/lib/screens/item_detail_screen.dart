import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/item.dart';
import 'place_bid_screen.dart';

class _D {
  static const primary            = Color(0xFF003F87);
  static const background         = Color(0xFFF8F9FA);
  static const surfaceLowest      = Color(0xFFFFFFFF);
  static const surfaceContainer   = Color(0xFFEDEEEF);
  static const secondaryContainer = Color(0xFFD9E3F1);
  static const onSurface          = Color(0xFF191C1D);
  static const onSurfaceVariant   = Color(0xFF424752);
  static const outline            = Color(0xFF727784);
  static const outlineVariant     = Color(0xFFC2C6D4);
  static const error              = Color(0xFFBA1A1A);
}

class ItemDetailScreen extends StatefulWidget {
  final Item item;
  const ItemDetailScreen({Key? key, required this.item}) : super(key: key);
  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late double _highestBid;
  final _bidCtrl = TextEditingController();
  int _thumb = 0;
  bool _bookmarked = false;
  Timer? _timer;
  Duration _remaining = Duration.zero;

  List<String?> get _thumbs =>
      [widget.item.imageUrl, widget.item.imageUrl, widget.item.imageUrl];

  @override
  void initState() {
    super.initState();
    _highestBid = widget.item.currentPrice;
    _tick();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) { if (mounted) setState(_tick); },
    );
  }

  void _tick() {
    final d = widget.item.auctionEndsAt.difference(DateTime.now());
    _remaining = d.isNegative ? Duration.zero : d;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bidCtrl.dispose();
    super.dispose();
  }

  bool get _over => _remaining == Duration.zero;

  String get _timerLabel {
    if (_over) return 'Ended';
    final h = _remaining.inHours.toString().padLeft(2, '0');
    final m = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  void _placeBid() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlaceBidScreen(
          item: widget.item,
          currentHighestBid: _highestBid,
          onBidPlaced: (newBid) => setState(() {
            _highestBid = newBid;
            _bidCtrl.clear();
          }),
        ),
      ),
    );
  }

  Future<void> _contact() async {
    final n = widget.item.whatsappNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('https://wa.me/$n');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _D.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: _D.background.withOpacity(0.95),
            elevation: 0,
            scrolledUnderElevation: 1,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: _D.onSurfaceVariant),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'DormDeal',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22, color: _D.primary),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, color: _D.onSurfaceVariant),
                onPressed: () {},
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: _D.surfaceContainer),
            ),
          ),
        ],
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _gallery(),
              const SizedBox(height: 16),
              _titleSection(),
              const SizedBox(height: 16),
              _biddingPanel(),
              const SizedBox(height: 16),
              _sellerCard(),
              const SizedBox(height: 16),
              _description(),
              const SizedBox(height: 24),
              _reportLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gallery() {
    final url = _thumbs[_thumb];
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Stack(fit: StackFit.expand, children: [
              url != null
                  ? CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: _D.surfaceContainer),
                      errorWidget: (_, __, ___) => Container(
                        color: _D.surfaceContainer,
                        child: const Icon(Icons.image_outlined, size: 56, color: _D.outlineVariant),
                      ),
                    )
                  : Container(
                      color: _D.surfaceContainer,
                      child: const Icon(Icons.image_outlined, size: 56, color: _D.outlineVariant),
                    ),
              if (_thumb > 0)
                Positioned(
                  left: 8, top: 0, bottom: 0,
                  child: Center(child: _Btn(
                    icon: Icons.chevron_left_rounded,
                    onTap: () => setState(() => _thumb--),
                  )),
                ),
              if (_thumb < _thumbs.length - 1)
                Positioned(
                  right: 8, top: 0, bottom: 0,
                  child: Center(child: _Btn(
                    icon: Icons.chevron_right_rounded,
                    onTap: () => setState(() => _thumb++),
                  )),
                ),
            ]),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _thumbs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final sel = i == _thumb;
              return GestureDetector(
                onTap: () => setState(() => _thumb = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 72,
                  height: 72,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: sel ? _D.primary : _D.outlineVariant,
                      width: sel ? 2 : 1,
                    ),
                  ),
                  child: _thumbs[i] != null
                      ? CachedNetworkImage(imageUrl: _thumbs[i]!, fit: BoxFit.cover)
                      : Container(color: _D.surfaceContainer),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _titleSection() {
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _D.surfaceContainer)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.item.title,
                  style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w600, height: 1.3, color: _D.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _bookmarked = !_bookmarked),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    _bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: _bookmarked ? _D.primary : _D.onSurfaceVariant,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _Chip(label: widget.item.category?.isNotEmpty == true ? widget.item.category! : 'General', filled: true),
              const _Chip(label: 'Like New', filled: false),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.schedule_rounded, size: 14, color: _D.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    'Listed ${timeago.format(widget.item.createdAt)}',
                    style: const TextStyle(fontSize: 13, color: _D.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _biddingPanel() {
    final min = _highestBid + 1;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _D.surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _D.secondaryContainer),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Highest Bid',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: _D.onSurfaceVariant),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rs. ${_highestBid.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: _D.primary, height: 1.1),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Auction Ends In',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: _D.onSurfaceVariant),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.timer_rounded, size: 18, color: _over ? _D.onSurfaceVariant : _D.error),
                      const SizedBox(width: 4),
                      Text(
                        _timerLabel,
                        style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w600,
                          color: _over ? _D.onSurfaceVariant : _D.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: _D.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _D.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('Rs.', style: TextStyle(fontSize: 15, color: _D.onSurfaceVariant)),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _bidCtrl,
                          enabled: !_over,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(fontSize: 15, color: _D.onSurface),
                          decoration: const InputDecoration(
                            hintText: 'Enter bid amount',
                            hintStyle: TextStyle(fontSize: 14, color: _D.outline),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _over ? null : _placeBid,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: _over ? _D.surfaceContainer : _D.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Place Bid',
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500,
                      color: _over ? _D.onSurfaceVariant : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Minimum next bid: Rs. ${min.toStringAsFixed(2)}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: _D.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _sellerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _D.surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _D.secondaryContainer),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: _D.secondaryContainer,
            child: Icon(Icons.person_rounded, color: _D.primary, size: 28),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Seller', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _D.onSurface)),
                SizedBox(height: 2),
                Row(children: [
                  Icon(Icons.verified_user_rounded, size: 14, color: _D.primary),
                  SizedBox(width: 4),
                  Text('Verified Student', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _D.primary)),
                ]),
              ],
            ),
          ),
          GestureDetector(
            onTap: _contact,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _D.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Contact',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _D.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _description() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Description', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: _D.onSurface)),
        const SizedBox(height: 8),
        Text(
          widget.item.description?.isNotEmpty == true
              ? widget.item.description!
              : 'No description provided.',
          style: const TextStyle(fontSize: 15, height: 1.6, color: _D.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _reportLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {},
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flag_outlined, size: 14, color: _D.onSurfaceVariant),
            SizedBox(width: 4),
            Text('Report Listing', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _D.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _Btn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Color(0x18000000), blurRadius: 6)],
        ),
        child: Icon(icon, size: 22, color: const Color(0xFF191C1D)),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool filled;
  const _Chip({required this.label, required this.filled});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? const Color(0xFF003F87) : const Color(0xFFD9E3F1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          color: filled ? Colors.white : const Color(0xFF003F87),
        ),
      ),
    );
  }
}
