import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class _D {
  static const primary            = Color(0xFF003F87);
  static const primaryContainer   = Color(0xFF0056B3);
  static const background         = Color(0xFFF8F9FA);
  static const surfaceLowest      = Color(0xFFFFFFFF);
  static const surfaceContainer   = Color(0xFFEDEEEF);
  static const secondaryContainer = Color(0xFFD9E3F1);
  static const onSurface          = Color(0xFF191C1D);
  static const onSurfaceVariant   = Color(0xFF424752);
  static const outlineVariant     = Color(0xFFC2C6D4);
  static const error              = Color(0xFFBA1A1A);
  static const success            = Color(0xFF1B6B3A);
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _listingsCount = 0;
  int _bidsCount = 0;
  int _wonCount = 0;
  bool _loadingStats = true;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = ApiService.currentUser;
    _loadProfileAndStats();
  }

  Future<void> _loadProfileAndStats() async {
    try {
      final user = await ApiService().getMe();
      if (mounted) {
        setState(() {
          _user = user;
        });
      }
    } catch (_) {}

    try {
      final listings = await ApiService().getMyListings();
      final bids = await ApiService().getMyBids();
      if (mounted) {
        setState(() {
          _listingsCount = listings.length;
          _bidsCount = bids.length;
          _wonCount = bids.where((b) => b.isEnded && b.isWinning).length;
          _loadingStats = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingStats = false);
    }
  }

  void _showEditProfileModal() {
    final nameCtrl = TextEditingController(text: _user?.name ?? '');
    final waCtrl = TextEditingController(text: _user?.whatsappNumber ?? '');
    final uniCtrl = TextEditingController(text: _user?.university ?? '');
    final formKey = GlobalKey<FormState>();
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Edit Profile',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _D.primary),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  const Text('Full Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _D.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      hintText: 'Enter your full name',
                      prefixIcon: const Icon(Icons.person_outline_rounded, size: 20, color: _D.primary),
                      filled: true,
                      fillColor: _D.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _D.outlineVariant)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _D.outlineVariant)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Name cannot be empty' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text('WhatsApp Mobile Number', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _D.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: waCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'e.g. 0771234567 or +94771234567',
                      prefixIcon: const Icon(Icons.chat_bubble_outline_rounded, size: 20, color: Color(0xFF25D366)),
                      filled: true,
                      fillColor: _D.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _D.outlineVariant)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _D.outlineVariant)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'WhatsApp number is required for deal coordination' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text('University / Faculty', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _D.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: uniCtrl,
                    decoration: InputDecoration(
                      hintText: 'e.g. Faculty of Engineering / Science',
                      prefixIcon: const Icon(Icons.school_outlined, size: 20, color: _D.primary),
                      filled: true,
                      fillColor: _D.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _D.outlineVariant)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _D.outlineVariant)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: saving
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              setModalState(() => saving = true);
                              try {
                                final updated = await ApiService().updateProfile(
                                  name: nameCtrl.text.trim(),
                                  whatsappNumber: waCtrl.text.trim(),
                                  university: uniCtrl.text.trim(),
                                );
                                if (mounted) {
                                  setState(() {
                                    _user = updated;
                                  });
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Profile updated successfully!'),
                                      backgroundColor: _D.success,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              } catch (e) {
                                setModalState(() => saving = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Update failed: ${e.toString().replaceAll('Exception: ', '')}'),
                                    backgroundColor: _D.error,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _D.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: saving
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Save Changes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showHelpModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: ListView(
            controller: scrollCtrl,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.help_outline_rounded, color: _D.primary, size: 24),
                      SizedBox(width: 8),
                      Text('Help & FAQ',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _D.primary)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 20),
              _faqItem(
                question: 'How does bidding work on DormDeal?',
                answer: 'Sellers post items with a base starting price and an auction deadline (1 Day, 3 Days, or 1 Week). Prospective student buyers submit bids with 1-tap quick increment buttons. When the countdown timer reaches zero, the highest bidder automatically wins the auction.',
              ),
              _faqItem(
                question: 'How do I arrange payment & pickup?',
                answer: 'DormDeal connects the winning buyer and seller directly on WhatsApp. Both students can then coordinate a convenient public campus meeting spot (e.g., Faculty Canteen, Library Lobby, or Hostel Gate) for safe Cash on Delivery (COD) inspection and handover.',
              ),
              _faqItem(
                question: 'What happens if I get outbid?',
                answer: 'You will receive an instant notification in your Alerts tab, and your status on "My Bids" will switch to "Outbid" in red. You can tap the item to submit a higher counter-bid before the auction closes.',
              ),
              _faqItem(
                question: 'Can I edit or cancel my listing?',
                answer: 'Yes! Navigate to the "My Listings" tab, select your item, and tap "Edit" in the top bar to update the description or category. You can also conclude the auction early by tapping "Sell Now".',
              ),
              _faqItem(
                question: 'Who is eligible to use DormDeal?',
                answer: 'DormDeal is exclusively reserved for enrolled university undergraduates and postgraduates. Verified student profiles and faculty affiliations foster a secure, trusted peer community.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _faqItem({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _D.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _D.outlineVariant),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        iconColor: _D.primary,
        collapsedIconColor: _D.onSurfaceVariant,
        title: Text(question,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _D.onSurface)),
        children: [
          Text(answer,
            style: const TextStyle(fontSize: 13, height: 1.5, color: _D.onSurfaceVariant)),
        ],
      ),
    );
  }

  void _showTermsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: ListView(
            controller: scrollCtrl,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.policy_outlined, color: _D.primary, size: 24),
                      SizedBox(width: 8),
                      Text('Terms & Safety Policy',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _D.primary)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 20),
              _policyCard(
                icon: Icons.shield_outlined,
                title: 'Campus Safety & Handover Guidelines',
                body: '• Always meet inside university premises during daytime.\n'
                      '• Preferred handover spots: Faculty Canteen, Library reception, or Hostel Security gate.\n'
                      '• Inspect electronics, appliances, and textbooks thoroughly before handing over payment.\n'
                      '• Use Cash on Delivery (COD) in person. Never transfer advance funds to unverified bank accounts.',
              ),
              const SizedBox(height: 12),
              _policyCard(
                icon: Icons.verified_user_outlined,
                title: 'Student Code of Conduct',
                body: '• Every bid placed is a binding commitment to purchase if you win.\n'
                      '• Fake, speculative, or malicious bids violate campus standards and lead to account deactivation.\n'
                      '• Maintain courteous and honest peer-to-peer communication when chatting on WhatsApp.',
              ),
              const SizedBox(height: 12),
              _policyCard(
                icon: Icons.block_rounded,
                title: 'Prohibited Items Policy',
                body: 'The following are strictly banned from listing on DormDeal:\n'
                      '• Alcoholic beverages, tobacco, vapes, and drugs.\n'
                      '• Weapons, explosives, or hazardous laboratory chemicals.\n'
                      '• Academic dishonesty items (e.g. leaked exam papers, completed coursework).\n'
                      '• Counterfeit or stolen merchandise.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _policyCard({required IconData icon, required String title, required String body}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _D.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _D.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: _D.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _D.onSurface)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(body,
            style: const TextStyle(fontSize: 13, height: 1.5, color: _D.onSurfaceVariant)),
        ],
      ),
    );
  }

  void _showAboutModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: _D.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.storefront_rounded, size: 32, color: _D.primary),
            ),
            const SizedBox(height: 10),
            const Text('DormDeal',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _D.primary)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFD6F0E0),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text('Alpha v3 (Release Candidate)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1B6B3A))),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              const Text(
                'University Campus Peer-to-Peer Auction & Marketplace Platform designed for students moving out of boarding.',
                style: TextStyle(fontSize: 13, height: 1.4, color: _D.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const Divider(height: 24),
              const Text('Academic Project Context',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _D.onSurfaceVariant)),
              const SizedBox(height: 4),
              const Text('• Course: EC9540 – Human Computer Interaction\n• Batch: E22 Faculty of Engineering\n• Team: Team DormDeal',
                style: TextStyle(fontSize: 12, height: 1.5, color: _D.onSurface)),
              const SizedBox(height: 12),
              const Text('What\'s New in Alpha v3:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _D.primary)),
              const SizedBox(height: 4),
              const Text(
                '✔ Interactive Price & Sort Filters (Under Rs. 1k to 6k+)\n'
                '✔ Native WhatsApp Linking with Number Formatting\n'
                '✔ Automatic 401 Session Expiration & Re-Auth\n'
                '✔ View & Edit Profile with Campus Credentials\n'
                '✔ Direct WhatsApp Coordination on Sold Listings\n'
                '✔ Full In-App Help, FAQ & Campus Safety Rules',
                style: TextStyle(fontSize: 12, height: 1.5, color: _D.onSurfaceVariant),
              ),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: _D.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
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
        title: const Text('Profile',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _D.primary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: _D.primary, size: 26),
            tooltip: 'Edit Profile',
            onPressed: _showEditProfileModal,
          ),
        ],
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: _D.secondaryContainer)),
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfileAndStats,
        color: _D.primary,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
          children: [
            _avatarSection(),
            const SizedBox(height: 20),
            _statsRow(),
            const SizedBox(height: 20),
            _accountDetailsCard(),
            const SizedBox(height: 14),
            _settingsCard('Support & Information', [
              _SettingItem(
                icon: Icons.help_outline_rounded,
                label: 'Help & FAQ',
                onTap: () => _showHelpModal(context),
              ),
              _SettingItem(
                icon: Icons.policy_outlined,
                label: 'Terms & Safety Policy',
                onTap: () => _showTermsModal(context),
              ),
              _SettingItem(
                icon: Icons.info_outline_rounded,
                label: 'About DormDeal (Alpha v3)',
                onTap: () => _showAboutModal(context),
              ),
            ]),
            const SizedBox(height: 24),
            _logoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _avatarSection() {
    final user = _user ?? ApiService.currentUser;
    final displayName = user?.name.isNotEmpty == true ? user!.name : 'Campus Student';
    final displayEmail = user?.email.isNotEmpty == true ? user!.email : 'student@campus.edu';
    final uni = user?.university?.isNotEmpty == true ? user!.university! : 'Verified Student';
    final phone = user?.whatsappNumber?.isNotEmpty == true ? user!.whatsappNumber! : 'No WhatsApp set';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _D.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _D.outlineVariant),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(children: [
        Stack(children: [
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(color: _D.secondaryContainer, shape: BoxShape.circle),
            child: user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(42),
                    child: Image.network(user.avatarUrl!, fit: BoxFit.cover),
                  )
                : const Icon(Icons.person_rounded, size: 48, color: _D.primary),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _showEditProfileModal,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: _D.primary, shape: BoxShape.circle),
                child: const Icon(Icons.edit_rounded, size: 14, color: Colors.white),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Text(displayName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _D.onSurface)),
        const SizedBox(height: 4),
        Text(displayEmail, style: const TextStyle(fontSize: 13, color: _D.onSurfaceVariant)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: _D.secondaryContainer, borderRadius: BorderRadius.circular(999)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.verified_user_rounded, size: 14, color: _D.primary),
                const SizedBox(width: 4),
                Text(uni, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _D.primary)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFD6F0E0), borderRadius: BorderRadius.circular(999)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.chat_bubble_rounded, size: 13, color: Color(0xFF1B6B3A)),
                const SizedBox(width: 4),
                Text(phone, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1B6B3A))),
              ]),
            ),
          ],
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: _showEditProfileModal,
          icon: const Icon(Icons.edit_outlined, size: 16),
          label: const Text('Edit Profile Details'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _D.primary,
            side: const BorderSide(color: _D.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ]),
    );
  }

  Widget _accountDetailsCard() {
    final user = _user ?? ApiService.currentUser;
    return Container(
      decoration: BoxDecoration(
        color: _D.surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _D.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Account Information',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: _D.onSurfaceVariant)),
                GestureDetector(
                  onTap: _showEditProfileModal,
                  child: const Text('Edit',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _D.primary)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _D.outlineVariant),
          _detailRow(
            icon: Icons.person_outline_rounded,
            label: 'Full Name',
            value: user?.name.isNotEmpty == true ? user!.name : 'Not set',
            onTap: _showEditProfileModal,
          ),
          const Divider(height: 1, indent: 52, color: _D.outlineVariant),
          _detailRow(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'WhatsApp Phone',
            value: user?.whatsappNumber?.isNotEmpty == true ? user!.whatsappNumber! : 'Not set',
            onTap: _showEditProfileModal,
          ),
          const Divider(height: 1, indent: 52, color: _D.outlineVariant),
          _detailRow(
            icon: Icons.school_outlined,
            label: 'University / Faculty',
            value: user?.university?.isNotEmpty == true ? user!.university! : 'Not set',
            onTap: _showEditProfileModal,
          ),
          const Divider(height: 1, indent: 52, color: _D.outlineVariant),
          _detailRow(
            icon: Icons.email_outlined,
            label: 'Campus Email',
            value: user?.email.isNotEmpty == true ? user!.email : 'Not set',
            onTap: null, // Email is immutable login identity
          ),
        ],
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 20, color: _D.primary),
      title: Text(label, style: const TextStyle(fontSize: 12, color: _D.onSurfaceVariant)),
      subtitle: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _D.onSurface)),
      trailing: onTap != null ? const Icon(Icons.edit_rounded, size: 16, color: _D.outlineVariant) : null,
      dense: true,
      onTap: onTap,
    );
  }

  Widget _statsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: _D.surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _D.outlineVariant),
      ),
      child: _loadingStats
          ? const Center(
              child: SizedBox(
                  width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)))
          : Row(children: [
              _StatCell(value: '$_listingsCount', label: 'Listings'),
              _divider(),
              _StatCell(value: '$_bidsCount', label: 'Bids Placed'),
              _divider(),
              _StatCell(value: '$_wonCount', label: 'Won'),
            ]),
    );
  }

  Widget _divider() => Container(width: 1, height: 36, color: _D.outlineVariant);

  Widget _settingsCard(String title, List<_SettingItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: _D.surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _D.outlineVariant),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
          child: Text(title,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: _D.onSurfaceVariant)),
        ),
        const Divider(height: 1, color: _D.outlineVariant),
        ...items.asMap().entries.map((e) {
          final item = e.value;
          final isLast = e.key == items.length - 1;
          return Column(children: [
            ListTile(
              leading: Icon(item.icon, size: 20, color: _D.onSurfaceVariant),
              title: Text(item.label,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500, color: _D.onSurface)),
              trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: _D.onSurfaceVariant),
              onTap: item.onTap,
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            ),
            if (!isLast) const Divider(height: 1, indent: 52, color: _D.outlineVariant),
          ]);
        }),
      ]),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ApiService().logout();
        Navigator.pushAndRemoveUntil(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEDE9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFFCDD2)),
        ),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.logout_rounded, size: 18, color: _D.error),
          SizedBox(width: 8),
          Text('Log Out',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _D.error)),
        ]),
      ),
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SettingItem({required this.icon, required this.label, required this.onTap});
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  const _StatCell({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(children: [
          Text(value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _D.primary)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: _D.onSurfaceVariant)),
        ]),
      );
}
