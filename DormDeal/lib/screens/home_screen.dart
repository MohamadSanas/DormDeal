import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/item.dart';
import '../services/api_service.dart';
import '../widgets/item_card.dart';
import 'post_item_screen.dart';
import 'my_bids_screen.dart';
import 'alerts_screen.dart';
import 'my_listings_screen.dart';
import 'profile_screen.dart';

// ── Shared design tokens ───────────────────────────────────────────────────
class _C {
  static const primary            = Color(0xFF003F87);
  static const primaryContainer   = Color(0xFF0056B3);
  static const background         = Color(0xFFF8F9FA);
  static const surface            = Color(0xFFF8F9FA);
  static const surfaceContainer   = Color(0xFFEDEEEF);
  static const surfaceLowest      = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFD9E3F1);
  static const onSurface          = Color(0xFF191C1D);
  static const onSurfaceVariant   = Color(0xFF424752);
  static const outline            = Color(0xFF727784);
  static const outlineVariant     = Color(0xFFC2C6D4);
  static const onPrimary          = Colors.white;
  static const error              = Color(0xFFBA1A1A);
  static const secondary          = Color(0xFF555F6B);
}

// ── Category data model ────────────────────────────────────────────────────
class _Category {
  final String label;
  final IconData icon;
  const _Category(this.label, this.icon);
}

const _categories = [
  _Category('All Items',  Icons.auto_awesome_rounded),
  _Category('Textbooks',  Icons.menu_book_rounded),
  _Category('Electronics',Icons.devices_rounded),
  _Category('Furniture',  Icons.chair_rounded),
  _Category('Clothing',   Icons.checkroom_rounded),
  _Category('Mobility',   Icons.directions_bike_rounded),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Item>> _futureItems;
  int _selectedCategory = 0;
  int _selectedNav = 0;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  // ── Price & Sort Filter state ──────────────────────────────────────────
  double? _minPrice;
  double? _maxPrice;
  String _sortBy = 'default'; // 'default', 'price_asc', 'price_desc', 'time_asc'

  bool get _hasPriceFilter => _minPrice != null || _maxPrice != null || _sortBy != 'default';

  @override
  void initState() {
    super.initState();
    _refreshItems();
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _refreshItems() {
    setState(() { _futureItems = _apiService.getItems(); });
  }

  // ── Price Filter Modal ───────────────────────────────────────────────────
  void _showPriceFilterModal() {
    double? tempMin = _minPrice;
    double? tempMax = _maxPrice;
    String tempSort = _sortBy;

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
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.tune_rounded, color: _C.primary, size: 22),
                      SizedBox(width: 8),
                      Text('Price & Sort Filters',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _C.primary)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 16),
              const Text('Sort Listings By',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _C.onSurface)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildSortChip('Default / Recent', 'default', tempSort, (v) => setModalState(() => tempSort = v)),
                  _buildSortChip('Price: Low to High', 'price_asc', tempSort, (v) => setModalState(() => tempSort = v)),
                  _buildSortChip('Price: High to Low', 'price_desc', tempSort, (v) => setModalState(() => tempSort = v)),
                  _buildSortChip('Ending Soonest', 'time_asc', tempSort, (v) => setModalState(() => tempSort = v)),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Filter by Price Range',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _C.onSurface)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildPriceChip('All Prices', null, null, tempMin, tempMax, (min, max) => setModalState(() { tempMin = min; tempMax = max; })),
                  _buildPriceChip('Under Rs. 1,000', 0, 1000, tempMin, tempMax, (min, max) => setModalState(() { tempMin = min; tempMax = max; })),
                  _buildPriceChip('Rs. 1,000 – 3,000', 1000, 3000, tempMin, tempMax, (min, max) => setModalState(() { tempMin = min; tempMax = max; })),
                  _buildPriceChip('Rs. 3,000 – 6,000', 3000, 6000, tempMin, tempMax, (min, max) => setModalState(() { tempMin = min; tempMax = max; })),
                  _buildPriceChip('Above Rs. 6,000', 6000, null, tempMin, tempMax, (min, max) => setModalState(() { tempMin = min; tempMax = max; })),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _minPrice = null;
                          _maxPrice = null;
                          _sortBy = 'default';
                        });
                        Navigator.pop(ctx);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Reset All'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _minPrice = tempMin;
                          _maxPrice = tempMax;
                          _sortBy = tempSort;
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _C.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Apply Filter', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(String label, String value, String current, ValueChanged<String> onSelected) {
    final selected = value == current;
    return GestureDetector(
      onTap: () => onSelected(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _C.primary : _C.surfaceLowest,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? _C.primary : _C.outlineVariant),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? Colors.white : _C.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildPriceChip(
    String label,
    double? min,
    double? max,
    double? currentMin,
    double? currentMax,
    void Function(double?, double?) onSelected,
  ) {
    final selected = min == currentMin && max == currentMax;
    return GestureDetector(
      onTap: () => onSelected(min, max),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _C.primary : _C.surfaceLowest,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? _C.primary : _C.outlineVariant),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? Colors.white : _C.onSurface,
          ),
        ),
      ),
    );
  }

  // ── build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: _C.background,
      body: IndexedStack(
        index: _selectedNav,
        children: [
          // ── Tab 0: Home ──────────────────────────────────────────────────
          Scaffold(
            backgroundColor: _C.background,
            extendBodyBehindAppBar: false,
            appBar: _buildAppBar(),
            body: RefreshIndicator(
              color: _C.primary,
              onRefresh: () async => _refreshItems(),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSearchBar(),
                          const SizedBox(height: 20),
                          _buildCategorySection(),
                          const SizedBox(height: 20),
                          _buildSectionHeader(),
                        ],
                      ),
                    ),
                  ),
                  _buildItemGrid(),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
            floatingActionButton: _buildFAB(),
          ),
          // ── Tab 1: My Bids ───────────────────────────────────────────────
          const MyBidsScreen(),
          // ── Tab 2: Alerts ────────────────────────────────────────────────
          const AlertsScreen(),
          // ── Tab 3: My Listings ───────────────────────────────────────────
          const MyListingsScreen(),
          // ── Tab 4: Profile ───────────────────────────────────────────────
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _C.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _C.secondaryContainer),
      ),
      title: const Text(
        'DormDeal',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: _C.primary,
          letterSpacing: -0.3,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: _C.primary),
          onPressed: () {},
          tooltip: 'Notifications',
        ),
      ],
    );
  }

  // ── Search Bar ───────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: _C.surfaceLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _C.outlineVariant),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.search_rounded, color: _C.outline, size: 20),
          ),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(fontSize: 14, color: _C.onSurface),
              decoration: const InputDecoration(
                hintText: 'Search textbooks, electronics, furniture...',
                hintStyle: TextStyle(color: _C.outline, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchCtrl.clear();
                setState(() => _searchQuery = '');
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.close_rounded, color: _C.outline, size: 18),
              ),
            ),
          Container(
            margin: const EdgeInsets.only(right: 6),
            child: IconButton(
              icon: Icon(
                _hasPriceFilter ? Icons.tune : Icons.tune_rounded,
                color: _hasPriceFilter ? Colors.white : _C.primary,
                size: 20,
              ),
              style: _hasPriceFilter
                  ? IconButton.styleFrom(
                      backgroundColor: _C.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    )
                  : null,
              onPressed: _showPriceFilterModal,
              tooltip: 'Price & Sort Filter',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ),
        ],
      ),
    );
  }

  // ── Categories ───────────────────────────────────────────────────────────
  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _C.onSurface,
            height: 28 / 18,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final selected = i == _selectedCategory;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                  decoration: BoxDecoration(
                    color: selected ? _C.primary : _C.secondaryContainer,
                    borderRadius: BorderRadius.circular(9999),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: _C.primary.withOpacity(0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _categories[i].icon,
                        size: 16,
                        color: selected ? _C.onPrimary : _C.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _categories[i].label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.1,
                          color: selected
                              ? _C.onPrimary
                              : _C.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Section header ────────────────────────────────────────────────────────
  Widget _buildSectionHeader() {
    final label = _selectedCategory == 0
        ? (_searchQuery.isEmpty ? 'Recent Listings' : 'Search Results')
        : _categories[_selectedCategory].label;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w600, color: _C.onSurface),
        ),
        if (_selectedCategory != 0 || _searchQuery.isNotEmpty)
          GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = 0);
              _searchCtrl.clear();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _C.secondaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.close_rounded, size: 13, color: _C.primary),
                SizedBox(width: 4),
                Text('Clear', style: TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w600, color: _C.primary)),
              ]),
            ),
          )
        else
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_hasPriceFilter) ...[
                GestureDetector(
                  onTap: () => setState(() {
                    _minPrice = null;
                    _maxPrice = null;
                    _sortBy = 'default';
                  }),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6F0E0),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _maxPrice != null
                              ? '≤ Rs. ${_maxPrice!.toInt()}'
                              : (_minPrice != null ? '≥ Rs. ${_minPrice!.toInt()}' : 'Sorted'),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1B6B3A)),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.close_rounded, size: 12, color: Color(0xFF1B6B3A)),
                      ],
                    ),
                  ),
                ),
              ],
              TextButton.icon(
                onPressed: _showPriceFilterModal,
                icon: Icon(Icons.filter_list_rounded, size: 16, color: _hasPriceFilter ? const Color(0xFF1B6B3A) : _C.primary),
                label: Text(
                  _hasPriceFilter ? 'Price Filtered' : 'Price Filter',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _hasPriceFilter ? const Color(0xFF1B6B3A) : _C.primary,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: _hasPriceFilter ? const Color(0xFFE8F8EE) : Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  minimumSize: Size.zero,
                ),
              ),
            ],
          ),
      ],
    );
  }

  // ── Item grid ─────────────────────────────────────────────────────────────
  Widget _buildItemGrid() {
    return FutureBuilder<List<Item>>(
      future: _futureItems,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: _C.primary),
            ),
          );
        }
        if (snapshot.hasError) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off_rounded, size: 48, color: _C.outline),
                  const SizedBox(height: 12),
                  const Text('Could not load listings.',
                    style: TextStyle(color: _C.onSurfaceVariant, fontSize: 15)),
                  const SizedBox(height: 8),
                  TextButton(onPressed: _refreshItems, child: const Text('Retry')),
                ],
              ),
            ),
          );
        }

        // ── Apply filters ──────────────────────────────────────────────
        List<Item> items = snapshot.data ?? [];

        // 1. Category filter (index 0 = All Items)
        if (_selectedCategory != 0) {
          final categoryName = _categories[_selectedCategory].label;
          items = items.where((item) =>
            (item.category ?? '').toLowerCase() == categoryName.toLowerCase()
          ).toList();
        }

        // 2. Search query filter
        if (_searchQuery.isNotEmpty) {
          items = items.where((item) =>
            item.title.toLowerCase().contains(_searchQuery) ||
            (item.description ?? '').toLowerCase().contains(_searchQuery) ||
            (item.category ?? '').toLowerCase().contains(_searchQuery)
          ).toList();
        }

        // 3. Price filter
        if (_minPrice != null) {
          items = items.where((item) => item.currentPrice >= _minPrice!).toList();
        }
        if (_maxPrice != null) {
          items = items.where((item) => item.currentPrice <= _maxPrice!).toList();
        }

        // 4. Sort filter
        if (_sortBy == 'price_asc') {
          items.sort((a, b) => a.currentPrice.compareTo(b.currentPrice));
        } else if (_sortBy == 'price_desc') {
          items.sort((a, b) => b.currentPrice.compareTo(a.currentPrice));
        } else if (_sortBy == 'time_asc') {
          items.sort((a, b) => a.auctionEndsAt.compareTo(b.auctionEndsAt));
        }

        // ── Empty state ────────────────────────────────────────────────
        if (items.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off_rounded, size: 56,
                    color: _C.outline.withValues(alpha: 0.5)),
                  const SizedBox(height: 12),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'No results for "$_searchQuery"'
                        : (_hasPriceFilter
                            ? 'No items match your price/sort filters'
                            : 'No items in ${_categories[_selectedCategory].label}'),
                    style: const TextStyle(color: _C.onSurfaceVariant, fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = 0;
                        _minPrice = null;
                        _maxPrice = null;
                        _sortBy = 'default';
                      });
                      _searchCtrl.clear();
                    },
                    child: const Text('Clear all filters'),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => ItemCard(item: items[index]),
              childCount: items.length,
            ),
          ),
        );
      },
    );
  }

  // ── FAB ──────────────────────────────────────────────────────────────────
  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PostItemScreen()),
        ).then((_) => _refreshItems());
      },
      backgroundColor: _C.primary,
      foregroundColor: _C.onPrimary,
      elevation: 4,
      icon: const Icon(Icons.add_rounded),
      label: const Text(
        'Sell',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    const items = [
      {'icon': Icons.home_rounded,            'label': 'Home'},
      {'icon': Icons.gavel_rounded,           'label': 'My Bids'},
      {'icon': Icons.notifications_outlined,  'label': 'Alerts'},
      {'icon': Icons.storefront_outlined,     'label': 'Listings'},
      {'icon': Icons.person_outline_rounded,  'label': 'Profile'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: _C.surfaceLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = i == _selectedNav;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedNav = i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: selected
                            ? BoxDecoration(
                                color: _C.secondaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              )
                            : null,
                        child: Icon(
                          items[i]['icon'] as IconData,
                          size: 22,
                          color: selected ? _C.primary : _C.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                          color: selected ? _C.primary : _C.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

