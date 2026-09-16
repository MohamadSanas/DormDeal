import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

// ── Design tokens ──────────────────────────────────────────────────────────
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
}

class PostItemScreen extends StatefulWidget {
  const PostItemScreen({super.key});
  @override
  State<PostItemScreen> createState() => _PostItemScreenState();
}

class _PostItemScreenState extends State<PostItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _waCtrl    = TextEditingController();

  final _picker = ImagePicker();
  final List<XFile> _images = [];

  String _category = '';
  String _condition = '';
  int _durationHours = 72; // default 3 days
  bool _loading = false;

  static const _categories = ['Textbooks', 'Electronics', 'Furniture', 'Clothing', 'Other'];
  static const _conditions = ['New', 'Good', 'Fair', 'Poor'];
  static const _durations  = [
    ('1 Day',  24),
    ('3 Days', 72),
    ('1 Week', 168),
  ];

  @override
  void dispose() {
    _titleCtrl.dispose(); _priceCtrl.dispose();
    _descCtrl.dispose();  _waCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_images.length >= 5) return;
    final f = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (f != null && mounted) setState(() => _images.add(f));
  }

  void _removeImage(int i) => setState(() => _images.removeAt(i));

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final basePrice = double.tryParse(_priceCtrl.text.trim()) ?? 0;
      await ApiService().createItem(
        title: _titleCtrl.text.trim(),
        basePrice: basePrice,
        auctionHours: _durationHours,
        whatsappNumber: _waCtrl.text.trim().isNotEmpty
            ? _waCtrl.text.trim()
            : (ApiService.currentUser?.whatsappNumber ?? '+1234567890'),
        description: _descCtrl.text.trim(),
        category: _category.isNotEmpty ? _category : 'Other',
        image: _images.isNotEmpty ? _images.first : null,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Auction listing created successfully!'),
        backgroundColor: Color(0xFF1B6B3A),
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _inputDecor(String hint, {String? prefix}) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 15, color: _D.outline),
    prefixText: prefix,
    prefixStyle: const TextStyle(fontSize: 15, color: _D.onSurfaceVariant),
    filled: true,
    fillColor: _D.surfaceLowest,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _D.outlineVariant)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _D.outlineVariant)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _D.primary, width: 2)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFBA1A1A))),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 2)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _D.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: _D.background.withOpacity(0.95),
            elevation: 0, scrolledUnderElevation: 1, surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: _D.onSurfaceVariant),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Create Auction',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: _D.primary)),
            centerTitle: true,
            bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: _D.secondaryContainer)),
          ),
        ],
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              _photosSection(),
              const SizedBox(height: 16),
              _itemDetailsSection(),
              const SizedBox(height: 16),
              _auctionSettingsSection(),
            ],
          ),
        ),
      ),
      // Sticky bottom button
      bottomNavigationBar: _loading
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              decoration: BoxDecoration(
                color: _D.background,
                border: const Border(top: BorderSide(color: _D.secondaryContainer)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: _PressableButton(
                  onTap: _submit,
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                    Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('Launch Auction',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  ]),
                ),
              ),
            ),
    );
  }

  // ── Photos section ─────────────────────────────────────────────────────────
  Widget _photosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Photos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _D.onSurface)),
        const SizedBox(height: 4),
        const Text('Add up to 5 photos. The first photo will be your cover image.',
          style: TextStyle(fontSize: 13, color: _D.onSurfaceVariant)),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Add button
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120, height: 120,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: _D.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _D.outlineVariant, width: 1.5, style: BorderStyle.solid),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, color: _D.primary, size: 28),
                      SizedBox(height: 6),
                      Text('Add Photo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _D.primary)),
                    ],
                  ),
                ),
              ),
              // Uploaded images
              ..._images.asMap().entries.map((e) {
                final i = e.key;
                final f = e.value;
                return Stack(
                  children: [
                    Container(
                      width: 120, height: 120,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _D.secondaryContainer),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: kIsWeb
                          ? Image.network(f.path, fit: BoxFit.cover)
                          : Image.file(File(f.path), fit: BoxFit.cover),
                    ),
                    // Remove button
                    Positioned(top: 6, right: 18,
                      child: GestureDetector(
                        onTap: () => _removeImage(i),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(999)),
                          child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                    // Cover label
                    if (i == 0)
                      Positioned(bottom: 0, left: 0, right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: const BoxDecoration(
                            color: Color(0xCC003F87),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                          ),
                          child: const Text('Cover', textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                        ),
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // ── Item Details section ───────────────────────────────────────────────────
  Widget _itemDetailsSection() {
    return _Card(
      title: 'Item Details',
      children: [
        // Title
        _FieldLabel('Title'),
        TextFormField(
          controller: _titleCtrl,
          style: const TextStyle(fontSize: 15, color: _D.onSurface),
          decoration: _inputDecor('What are you selling?'),
          validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a title' : null,
        ),
        const SizedBox(height: 16),

        // Category dropdown
        _FieldLabel('Category'),
        DropdownButtonFormField<String>(
          value: _category.isEmpty ? null : _category,
          decoration: _inputDecor('Select a category'),
          style: const TextStyle(fontSize: 15, color: _D.onSurface),
          dropdownColor: _D.surfaceLowest,
          icon: const Icon(Icons.arrow_drop_down_rounded, color: _D.onSurfaceVariant),
          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) => setState(() => _category = v ?? ''),
          validator: (v) => v == null || v.isEmpty ? 'Please select a category' : null,
        ),
        const SizedBox(height: 16),

        // Condition chips
        _FieldLabel('Condition'),
        const SizedBox(height: 4),
        Row(children: _conditions.map((c) {
          final sel = c == _condition;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _condition = c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? _D.primary : _D.surfaceLowest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: sel ? _D.primary : _D.outlineVariant),
                ),
                child: Text(c, textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                    color: sel ? Colors.white : _D.onSurfaceVariant)),
              ),
            ),
          );
        }).toList()),
        const SizedBox(height: 16),

        // Description
        _FieldLabel('Description (Optional)'),
        TextFormField(
          controller: _descCtrl,
          maxLines: 3,
          style: const TextStyle(fontSize: 15, color: _D.onSurface),
          decoration: _inputDecor('Describe any flaws, usage history, etc.'),
        ),
      ],
    );
  }

  // ── Auction Settings section ───────────────────────────────────────────────
  Widget _auctionSettingsSection() {
    return _Card(
      title: 'Auction Settings',
      children: [
        // Starting price
        _FieldLabel('Starting Price'),
        TextFormField(
          controller: _priceCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontSize: 15, color: _D.onSurface),
          decoration: _inputDecor('0.00', prefix: 'Rs. '),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Please enter a starting price';
            if (double.tryParse(v) == null) return 'Enter a valid number';
            return null;
          },
        ),
        const SizedBox(height: 6),
        const Text('Bidding will start at this price.',
          style: TextStyle(fontSize: 12, color: _D.onSurfaceVariant)),
        const SizedBox(height: 16),

        // WhatsApp number
        _FieldLabel('WhatsApp Number'),
        TextFormField(
          controller: _waCtrl,
          keyboardType: TextInputType.phone,
          style: const TextStyle(fontSize: 15, color: _D.onSurface),
          decoration: _inputDecor('+94 77 123 4567'),
          validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your WhatsApp number' : null,
        ),
        const SizedBox(height: 16),

        // Duration
        _FieldLabel('Auction Duration'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: _D.surfaceLowest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _D.outlineVariant),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _durationHours,
              isExpanded: true,
              icon: const Icon(Icons.schedule_rounded, color: _D.onSurfaceVariant, size: 20),
              dropdownColor: _D.surfaceLowest,
              style: const TextStyle(fontSize: 15, color: _D.onSurface),
              items: _durations.map((d) => DropdownMenuItem(value: d.$2,
                child: Text(d.$1))).toList(),
              onChanged: (v) => setState(() => _durationHours = v ?? 72),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Reusable card ──────────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Card({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9E3F1)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF191C1D))),
        const SizedBox(height: 4),
        const Divider(color: Color(0xFFC2C6D4), height: 16),
        const SizedBox(height: 8),
        ...children,
      ]),
    );
  }
}

// ── Field label ────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
      letterSpacing: 0.1, color: Color(0xFF191C1D))),
  );
}

// ── Pressable primary button ───────────────────────────────────────────────
class _PressableButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  const _PressableButton({required this.onTap, required this.child});
  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => setState(() => _pressed = true),
    onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
    onTapCancel: () => setState(() => _pressed = false),
    child: AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF003F87),
          borderRadius: BorderRadius.circular(10),
        ),
        child: widget.child,
      ),
    ),
  );
}
