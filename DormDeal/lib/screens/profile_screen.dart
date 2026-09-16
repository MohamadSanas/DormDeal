import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
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
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: _D.secondaryContainer)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
        children: [
          _avatarSection(),
          const SizedBox(height: 24),
          _statsRow(),
          const SizedBox(height: 24),
          _settingsCard('Account', [
            _SettingItem(icon: Icons.person_outline_rounded, label: 'Edit Profile', onTap: () {}),
            _SettingItem(icon: Icons.phone_outlined, label: 'Phone & WhatsApp', onTap: () {}),
            _SettingItem(icon: Icons.school_outlined, label: 'University Email', onTap: () {}),
          ]),
          const SizedBox(height: 14),
          _settingsCard('Preferences', [
            _SettingItem(
                icon: Icons.notifications_outlined, label: 'Notification Settings', onTap: () {}),
            _SettingItem(icon: Icons.privacy_tip_outlined, label: 'Privacy', onTap: () {}),
          ]),
          const SizedBox(height: 14),
          _settingsCard('Support', [
            _SettingItem(icon: Icons.help_outline_rounded, label: 'Help & FAQ', onTap: () {}),
            _SettingItem(icon: Icons.policy_outlined, label: 'Terms & Privacy Policy', onTap: () {}),
            _SettingItem(icon: Icons.info_outline_rounded, label: 'About DormDeal', onTap: () {}),
          ]),
          const SizedBox(height: 24),
          _logoutButton(context),
        ],
      ),
    );
  }

  Widget _avatarSection() {
    final user = ApiService.currentUser;
    final displayName = user?.name.isNotEmpty == true ? user!.name : 'Campus Student';
    final displayEmail = user?.email.isNotEmpty == true ? user!.email : 'student@campus.edu';
    final uni = user?.university?.isNotEmpty == true ? user!.university! : 'Verified Student';

    return Column(children: [
      Stack(children: [
        Container(
          width: 88,
          height: 88,
          decoration: const BoxDecoration(color: _D.secondaryContainer, shape: BoxShape.circle),
          child: user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(44),
                  child: Image.network(user.avatarUrl!, fit: BoxFit.cover),
                )
              : const Icon(Icons.person_rounded, size: 48, color: _D.primary),
        ),
        Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: _D.primary, shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
            )),
      ]),
      const SizedBox(height: 12),
      Text(displayName,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _D.onSurface)),
      const SizedBox(height: 4),
      Text(displayEmail, style: const TextStyle(fontSize: 13, color: _D.onSurfaceVariant)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration:
            BoxDecoration(color: _D.secondaryContainer, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.verified_user_rounded, size: 14, color: _D.primary),
          const SizedBox(width: 4),
          Text(uni,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _D.primary)),
        ]),
      ),
    ]);
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
