import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/item.dart';
import '../services/api_service.dart';

class ItemDetailScreen extends StatefulWidget {
  final Item item;

  const ItemDetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final ApiService _apiService = ApiService();
  late double _highestBid;

  @override
  void initState() {
    super.initState();
    _highestBid = widget.item.currentPrice;
  }

  Future<void> _launchWhatsApp(BuildContext context) async {
    final number = widget.item.whatsappNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final whatsappUri = Uri.parse('https://wa.me/$number');
    
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open WhatsApp. Do you have it installed?')),
      );
    }
  }

  void _placeBid() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Place your bid'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Your name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'WhatsApp number'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Your bid amount',
                  hintText: 'Enter amount higher than current bid',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final bid = double.tryParse(controller.text.trim());
              final bidderName = nameController.text.trim();
              final bidderWhatsapp = phoneController.text.trim();
              if (bidderName.isEmpty || bidderWhatsapp.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name and WhatsApp are required')),
                );
                return;
              }
              if (bid == null || bid <= _highestBid) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Bid must be higher than \$${_highestBid.toStringAsFixed(2)}')),
                );
                return;
              }
              try {
                final updated = await _apiService.placeBid(
                  itemId: widget.item.id,
                  bidderName: bidderName,
                  bidderWhatsapp: bidderWhatsapp,
                  amount: bid,
                );
                if (!mounted) return;
                setState(() {
                  _highestBid = updated.currentPrice;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bid submitted successfully.')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                );
              }
            },
            child: const Text('Submit Bid'),
          ),
        ],
      ),
    );
  }

  String _timeLeftText() {
    final end = widget.item.auctionEndsAt;
    final remaining = end.difference(DateTime.now());
    if (remaining.isNegative) {
      return 'Bidding ended';
    }
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    return '$hours h $minutes m left';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.item.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            widget.item.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: widget.item.imageUrl!,
                    height: 300,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Container(
                      height: 300,
                      color: Colors.grey[300],
                      child: Icon(Icons.error, size: 50, color: Colors.grey[500]),
                    ),
                  )
                : Container(
                    height: 300,
                    color: Colors.grey[300],
                    child: Icon(Icons.image, size: 80, color: Colors.grey[500]),
                  ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.item.title,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Base Price: \$${widget.item.basePrice.toStringAsFixed(2)}'),
                        const SizedBox(height: 4),
                        Text(
                          'Current Highest Bid: \$${_highestBid.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text('Auction status: ${_timeLeftText()}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Posted ${timeago.format(widget.item.createdAt)}',
                    style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Cash on Delivery Only',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'The winning bidder pays in person on delivery/pickup.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.item.description?.isNotEmpty == true
                        ? widget.item.description!
                        : 'No description provided by the seller.',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    icon: const Icon(Icons.gavel),
                    label: const Text(
                      'Place a Bid',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _placeBid,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    icon: const Icon(Icons.chat),
                    label: const Text(
                      'Contact on WhatsApp',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _launchWhatsApp(context),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
