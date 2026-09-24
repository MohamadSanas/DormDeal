import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  /// Cleans and formats phone numbers to international WhatsApp format
  static String formatPhoneNumber(String rawPhone) {
    var digits = rawPhone.replaceAll(RegExp(r'\D'), '');
    // If standard Sri Lankan number starting with 0 (e.g. 0771234567), replace leading 0 with 94
    if (digits.startsWith('0') && digits.length == 10) {
      digits = '94${digits.substring(1)}';
    }
    return digits;
  }

  /// Opens WhatsApp with the given phone number and optional prefilled message
  static Future<void> launchWhatsApp({
    required BuildContext context,
    required String rawPhone,
    String? message,
    String? recipientName,
  }) async {
    final cleaned = formatPhoneNumber(rawPhone);

    if (cleaned.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No valid contact number available.'),
          backgroundColor: Color(0xFFBA1A1A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final encodedMsg = Uri.encodeComponent(message ?? 'Hi! Contacting you from DormDeal.');

    // Strategy 1: Universal WhatsApp link (wa.me)
    final waMeUri = Uri.parse('https://wa.me/$cleaned?text=$encodedMsg');
    // Strategy 2: Direct app scheme
    final appUri = Uri.parse('whatsapp://send?phone=$cleaned&text=$encodedMsg');
    // Strategy 3: API fallback
    final apiUri = Uri.parse('https://api.whatsapp.com/send?phone=$cleaned&text=$encodedMsg');

    bool launched = false;

    // Try wa.me with externalApplication
    try {
      if (await canLaunchUrl(waMeUri)) {
        launched = await launchUrl(waMeUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}

    // If wa.me wasn't launched, try whatsapp:// native intent
    if (!launched) {
      try {
        if (await canLaunchUrl(appUri)) {
          launched = await launchUrl(appUri, mode: LaunchMode.externalApplication);
        }
      } catch (_) {}
    }

    // If still not launched, try api.whatsapp.com
    if (!launched) {
      try {
        launched = await launchUrl(apiUri, mode: LaunchMode.externalNonBrowserApplication);
      } catch (_) {}
    }

    // If all app launches fail, try opening in browser platformDefault
    if (!launched) {
      try {
        launched = await launchUrl(waMeUri, mode: LaunchMode.platformDefault);
      } catch (_) {}
    }

    // If still failed (e.g. WhatsApp is not installed on device or tablet/emulator)
    if (!launched && context.mounted) {
      _showFallbackContactDialog(
        context: context,
        phone: cleaned,
        displayName: recipientName ?? 'Student',
      );
    }
  }

  /// Direct phone call
  static Future<void> launchPhoneCall(String rawPhone) async {
    final cleaned = formatPhoneNumber(rawPhone);
    final telUri = Uri.parse('tel:$cleaned');
    try {
      await launchUrl(telUri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  /// Fallback dialog shown when WhatsApp application is not installed on the phone
  static void _showFallbackContactDialog({
    required BuildContext context,
    required String phone,
    required String displayName,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.chat_outlined, color: Color(0xFF003F87)),
            const SizedBox(width: 8),
            Text('Contact $displayName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Could not open WhatsApp directly. You can copy the phone number or make a direct call:',
              style: TextStyle(fontSize: 14, color: Color(0xFF424752)),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEDEEEF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone_iphone_rounded, size: 18, color: Color(0xFF003F87)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SelectableText(
                      '+$phone',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF191C1D)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 20, color: Color(0xFF003F87)),
                    tooltip: 'Copy Number',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: '+$phone'));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Phone number copied to clipboard!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF727784))),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              launchPhoneCall(phone);
            },
            icon: const Icon(Icons.call_rounded, size: 16),
            label: const Text('Call Phone'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003F87),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}
