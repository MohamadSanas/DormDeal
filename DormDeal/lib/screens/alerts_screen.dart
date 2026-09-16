import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/notification_model.dart';
import '../services/api_service.dart';
import 'item_detail_screen.dart';

class _D {
  static const primary            = Color(0xFF003F87);
  static const background         = Color(0xFFF8F9FA);
  static const surfaceLowest      = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFD9E3F1);
  static const onSurface          = Color(0xFF191C1D);
  static const onSurfaceVariant   = Color(0xFF424752);
  static const outlineVariant     = Color(0xFFC2C6D4);
  static const error              = Color(0xFFBA1A1A);
  static const success            = Color(0xFF1B6B3A);
}

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  late Future<List<AppNotification>> _futureAlerts;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _futureAlerts = ApiService().getNotifications();
    });
  }

  void _markAllRead() async {
    try {
      await ApiService().markAllNotificationsRead();
      _refresh();
    } catch (_) {}
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
        title: const Text('Alerts',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _D.primary)),
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: const Text('Mark all read',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _D.primary)),
          ),
        ],
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: _D.secondaryContainer)),
      ),
      body: FutureBuilder<List<AppNotification>>(
        future: _futureAlerts,
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
                  const Text('Failed to load notifications',
                      style: TextStyle(fontSize: 16, color: _D.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  TextButton(onPressed: _refresh, child: const Text('Retry')),
                ],
              ),
            );
          }

          final alerts = snapshot.data ?? [];
          if (alerts.isEmpty) {
            return _empty();
          }

          final unread = alerts.where((n) => !n.isRead).toList();
          final read = alerts.where((n) => n.isRead).toList();

          return RefreshIndicator(
            color: _D.primary,
            onRefresh: () async => _refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                if (unread.isNotEmpty) ...[
                  _sectionLabel('New'),
                  const SizedBox(height: 8),
                  ...unread.map((n) => _notifCard(context, n)),
                  const SizedBox(height: 16),
                ],
                if (read.isNotEmpty) ...[
                  _sectionLabel('Earlier'),
                  const SizedBox(height: 8),
                  ...read.map((n) => _notifCard(context, n)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(text,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: _D.onSurfaceVariant));

  Widget _notifCard(BuildContext context, AppNotification n) {
    IconData icon = Icons.notifications_rounded;
    Color iconBg = _D.secondaryContainer;
    Color iconColor = _D.primary;

    if (n.type == 'outbid') {
      icon = Icons.arrow_upward_rounded;
      iconBg = const Color(0xFFFFEDE9);
      iconColor = _D.error;
    } else if (n.type == 'auction_won') {
      icon = Icons.emoji_events_rounded;
      iconBg = const Color(0xFFD6F0E0);
      iconColor = _D.success;
    } else if (n.type == 'new_bid') {
      icon = Icons.gavel_rounded;
      iconBg = _D.secondaryContainer;
      iconColor = _D.primary;
    }

    final hasItem = n.itemId != null && n.itemId!.isNotEmpty;

    return GestureDetector(
      onTap: () async {
        if (!n.isRead) {
          ApiService().markNotificationRead(n.id);
          setState(() => n.isRead = true);
        }
        if (hasItem) {
          try {
            final item = await ApiService().getItem(n.itemId!);
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
              );
            }
          } catch (_) {}
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: !n.isRead ? const Color(0xFFD9E3F1).withOpacity(0.4) : _D.surfaceLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: !n.isRead ? _D.secondaryContainer : _D.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(
                    child: Text(n.title,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: !n.isRead ? FontWeight.w600 : FontWeight.w500,
                            color: _D.onSurface)),
                  ),
                  if (!n.isRead)
                    Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: _D.primary, shape: BoxShape.circle)),
                  if (hasItem) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_right_rounded, size: 16, color: _D.onSurfaceVariant),
                  ],
                ]),
                const SizedBox(height: 4),
                Text(n.body,
                    style:
                        const TextStyle(fontSize: 13, height: 1.4, color: _D.onSurfaceVariant)),
                const SizedBox(height: 6),
                Text(timeago.format(n.createdAt),
                    style: const TextStyle(fontSize: 11, color: _D.onSurfaceVariant)),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty() => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.notifications_none_rounded, size: 64, color: Color(0xFFC2C6D4)),
          const SizedBox(height: 16),
          Text('No alerts yet',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _D.onSurface)),
          const SizedBox(height: 8),
          Text("You'll be notified about bids, listings, and more",
              textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: _D.onSurfaceVariant)),
        ]),
      );
}
