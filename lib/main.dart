import 'package:flutter/material.dart';

void main() {
  runApp(const StockSenseApp());
}

// ============================================================
// STOCKSENSE APP
// ============================================================

class StockSenseApp extends StatelessWidget {
  const StockSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StockSense',
      theme: ThemeData(
        fontFamily: 'Arial',
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

// ============================================================
// DASHBOARD SCREEN
// ============================================================

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedMenu = 0;
  bool darkMode = false;

  // Filter States
  String selectedDocType = 'All Document Types';
  String selectedStatus = 'All Status';
  String selectedWarehouse = 'All Warehouses';
  String selectedCategory = 'All Categories';

  final List<String> menuItems = [
    'Dashboard',
    'Products',
    'Receipts',
    'Delivery Orders',
    'Internal Transfers',
    'Inventory Adjustments',
    'Move History',
    'Warehouse',
    'Settings',
    'My Profile',
    'Logout',
  ];

  final List<Map<String, String>> operations = [
    {
      'reference': 'REC-1024',
      'product': 'Steel Rods',
      'sku': 'SKU-STR-001',
      'operation': 'Receipt',
      'quantity': '+50',
      'location': 'Main Warehouse',
      'status': 'Done',
    },
    {
      'reference': 'DEL-2041',
      'product': 'Office Chairs',
      'sku': 'SKU-CHR-102',
      'operation': 'Delivery',
      'quantity': '-10',
      'location': 'Warehouse 1',
      'status': 'Waiting',
    },
    {
      'reference': 'TRF-3012',
      'product': 'Steel Sheets',
      'sku': 'SKU-STL-204',
      'operation': 'Internal Transfer',
      'quantity': '25',
      'location': 'Production Rack',
      'status': 'Ready',
    },
    {
      'reference': 'ADJ-4009',
      'product': 'Steel Rods',
      'sku': 'SKU-STR-001',
      'operation': 'Adjustment',
      'quantity': '-3',
      'location': 'Main Warehouse',
      'status': 'Done',
    },
  ];

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF0F172A),
      ),
    );
  }

  void openAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return const AddProductDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor:
          darkMode ? const Color(0xFF0F172A) : const Color(0xFFF5F7FB),
      appBar: !isDesktop
          ? AppBar(
              backgroundColor: const Color(0xFF0F172A),
              title: const Text('StockSense', style: TextStyle(color: Colors.white)),
              iconTheme: const IconThemeData(color: Colors.white),
            )
          : null,
      drawer: !isDesktop ? Drawer(child: buildSidebarContent()) : null,
      body: Row(
        children: [
          if (isDesktop)
            SizedBox(
              width: 250,
              child: buildSidebarContent(),
            ),
          Expanded(
            child: Column(
              children: [
                // TOP BAR
                Container(
                  height: 72,
                  color: darkMode ? const Color(0xFF1E293B) : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 42,
                          decoration: BoxDecoration(
                            color: darkMode
                                ? const Color(0xFF334155)
                                : const Color(0xFFF8FAFC),
                            border: Border.all(
                              color: darkMode
                                  ? const Color(0xFF475569)
                                  : const Color(0xFFE2E8F0),
                            ),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: TextField(
                            style: TextStyle(
                                color: darkMode ? Colors.white : Colors.black),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.search,
                                color: Color(0xFF64748B),
                              ),
                              hintText: 'Search products, SKU...',
                              hintStyle: TextStyle(color: Color(0xFF64748B)),
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            darkMode = !darkMode;
                          });
                          showMessage('Theme changed');
                        },
                        icon: Icon(
                          darkMode ? Icons.light_mode : Icons.dark_mode,
                          color: darkMode ? Colors.amber : Colors.black87,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: darkMode
                              ? const Color(0xFF334155)
                              : const Color(0xFFF1F5F9),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            onPressed: () =>
                                showMessage('You have 3 new notifications'),
                            icon: Icon(
                              Icons.notifications_none,
                              color: darkMode ? Colors.white : Colors.black87,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: darkMode
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFF1F5F9),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: Color(0xFFDC2626),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  '3',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: Color(0xFFDBEAFE),
                            child: Text(
                              'TS',
                              style: TextStyle(
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tushar',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: darkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              const Text(
                                'Inventory Manager',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(0xFF64748B),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // DASHBOARD BODY
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HEADER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Inventory Dashboard',
                                  style: TextStyle(
                                    fontSize: 27,
                                    fontWeight: FontWeight.bold,
                                    color: darkMode
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  'Monitor your inventory operations in real time.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: openAddProductDialog,
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text(
                                'Add Product',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        // KPI CARDS
                        LayoutBuilder(
                          builder: (context, constraints) {
                            double cardWidth = constraints.maxWidth > 900
                                ? (constraints.maxWidth - (18 * 3)) / 4
                                : (constraints.maxWidth - 18) / 2;
                            return Wrap(
                              spacing: 18,
                              runSpacing: 18,
                              children: [
                                SizedBox(
                                  width: cardWidth,
                                  child: statCard(
                                    title: 'Total Products',
                                    value: '1,284',
                                    icon: Icons.inventory_2,
                                    iconBackground: const Color(0xFFDBEAFE),
                                    iconColor: const Color(0xFF2563EB),
                                    trend: '↑ 8.2% from last month',
                                    trendColor: const Color(0xFF16A34A),
                                  ),
                                ),
                                SizedBox(
                                  width: cardWidth,
                                  child: statCard(
                                    title: 'Low Stock Items',
                                    value: '37',
                                    icon: Icons.warning_amber,
                                    iconBackground: const Color(0xFFFEF3C7),
                                    iconColor: const Color(0xFFD97706),
                                    trend: '↑ Needs attention',
                                    trendColor: const Color(0xFFDC2626),
                                  ),
                                ),
                                SizedBox(
                                  width: cardWidth,
                                  child: statCard(
                                    title: 'Out of Stock',
                                    value: '12',
                                    icon: Icons.cancel,
                                    iconBackground: const Color(0xFFFEE2E8),
                                    iconColor: const Color(0xFFDC2626),
                                    trend: '↑ 3 new today',
                                    trendColor: const Color(0xFFDC2626),
                                  ),
                                ),
                                SizedBox(
                                  width: cardWidth,
                                  child: statCard(
                                    title: 'Pending Receipts',
                                    value: '24',
                                    icon: Icons.local_shipping,
                                    iconBackground: const Color(0xFFDCFCE7),
                                    iconColor: const Color(0xFF16A34A),
                                    trend: '◷ 8 due today',
                                    trendColor: const Color(0xFF16A34A),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 22),

                        // FILTERS
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: darkMode
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            border: Border.all(
                              color: darkMode
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0),
                            ),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              bool isWide = constraints.maxWidth > 800;
                              return Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  SizedBox(
                                    width: isWide
                                        ? (constraints.maxWidth - 36) / 4
                                        : (constraints.maxWidth - 12) / 2,
                                    child: filterDropdown(
                                      selectedDocType,
                                      [
                                        'All Document Types',
                                        'Receipts',
                                        'Delivery',
                                        'Internal',
                                        'Adjustments',
                                      ],
                                      (val) => setState(
                                          () => selectedDocType = val!),
                                    ),
                                  ),
                                  SizedBox(
                                    width: isWide
                                        ? (constraints.maxWidth - 36) / 4
                                        : (constraints.maxWidth - 12) / 2,
                                    child: filterDropdown(
                                      selectedStatus,
                                      [
                                        'All Status',
                                        'Draft',
                                        'Waiting',
                                        'Ready',
                                        'Done',
                                        'Canceled',
                                      ],
                                      (val) =>
                                          setState(() => selectedStatus = val!),
                                    ),
                                  ),
                                  SizedBox(
                                    width: isWide
                                        ? (constraints.maxWidth - 36) / 4
                                        : (constraints.maxWidth - 12) / 2,
                                    child: filterDropdown(
                                      selectedWarehouse,
                                      [
                                        'All Warehouses',
                                        'Main Warehouse',
                                        'Warehouse 1',
                                        'Warehouse 2',
                                      ],
                                      (val) => setState(
                                          () => selectedWarehouse = val!),
                                    ),
                                  ),
                                  SizedBox(
                                    width: isWide
                                        ? (constraints.maxWidth - 36) / 4
                                        : (constraints.maxWidth - 12) / 2,
                                    child: filterDropdown(
                                      selectedCategory,
                                      [
                                        'All Categories',
                                        'Steel',
                                        'Furniture',
                                        'Electronics',
                                      ],
                                      (val) => setState(
                                          () => selectedCategory = val!),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 22),

                        // CHARTS
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth > 900) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 2, child: inventoryChart()),
                                  const SizedBox(width: 20),
                                  Expanded(child: categoryChart()),
                                ],
                              );
                            }
                            return Column(
                              children: [
                                inventoryChart(),
                                const SizedBox(height: 20),
                                categoryChart(),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 22),

                        // RECENT OPERATIONS
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: darkMode
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            border: Border.all(
                              color: darkMode
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0),
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recent Operations',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: darkMode
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 15),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: const [
                                    DataColumn(label: Text('REFERENCE')),
                                    DataColumn(label: Text('PRODUCT')),
                                    DataColumn(label: Text('SKU')),
                                    DataColumn(label: Text('TYPE')),
                                    DataColumn(label: Text('QTY')),
                                    DataColumn(label: Text('LOCATION')),
                                    DataColumn(label: Text('STATUS')),
                                  ],
                                  rows: operations.map((op) {
                                    return DataRow(cells: [
                                      DataCell(Text(op['reference']!,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold))),
                                      DataCell(Text(op['product']!)),
                                      DataCell(Text(op['sku']!)),
                                      DataCell(Text(op['operation']!)),
                                      DataCell(Text(op['quantity']!)),
                                      DataCell(Text(op['location']!)),
                                      DataCell(buildStatusBadge(op['status']!)),
                                    ]);
                                  }).toList(),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SIDEBAR & WIDGET BUILDERS
  // ============================================================

  Widget buildSidebarContent() {
    return Container(
      color: const Color(0xFF0F172A),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 20, 14, 25),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                          text: 'Stock', style: TextStyle(color: Colors.white)),
                      TextSpan(
                          text: 'Sense',
                          style: TextStyle(color: Color(0xFF60A5FA))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                sidebarTitle('MAIN'),
                sidebarItem(index: 0, icon: Icons.pie_chart, title: 'Dashboard'),
                sidebarItem(
                    index: 1, icon: Icons.inventory_2, title: 'Products'),
                sidebarTitle('OPERATIONS'),
                sidebarItem(
                    index: 2, icon: Icons.local_shipping, title: 'Receipts'),
                sidebarItem(
                    index: 3,
                    icon: Icons.local_shipping_outlined,
                    title: 'Delivery Orders'),
                sidebarItem(
                    index: 4,
                    icon: Icons.swap_horiz,
                    title: 'Internal Transfers'),
                sidebarItem(
                    index: 5,
                    icon: Icons.tune,
                    title: 'Inventory Adjustments'),
                sidebarItem(
                    index: 6, icon: Icons.history, title: 'Move History'),
                sidebarTitle('MANAGEMENT'),
                sidebarItem(
                    index: 7, icon: Icons.warehouse, title: 'Warehouse'),
                sidebarItem(index: 8, icon: Icons.settings, title: 'Settings'),
                const Divider(color: Color(0xFF1E293B)),
                sidebarItem(index: 9, icon: Icons.person, title: 'My Profile'),
                sidebarItem(index: 10, icon: Icons.logout, title: 'Logout'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget sidebarTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget sidebarItem({
    required int index,
    required IconData icon,
    required String title,
  }) {
    final isSelected = selectedMenu == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        selected: isSelected,
        selectedTileColor: const Color(0xFF1E293B),
        leading: Icon(icon,
            color: isSelected ? const Color(0xFF60A5FA) : const Color(0xFF94A3B8)),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF94A3B8),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          setState(() => selectedMenu = index);
        },
      ),
    );
  }

  Widget statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    required String trend,
    required Color trendColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: darkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: darkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              )
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: darkMode ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            trend,
            style: TextStyle(
              color: trendColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  Widget filterDropdown(
      String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: darkMode ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: darkMode ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: darkMode ? const Color(0xFF1E293B) : Colors.white,
          style: TextStyle(
              color: darkMode ? Colors.white : Colors.black, fontSize: 13),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget inventoryChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: darkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: darkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stock Trends',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: darkMode ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Chart Visualization Placeholder',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget categoryChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: darkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: darkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stock by Category',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: darkMode ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Category Distribution Placeholder',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildStatusBadge(String status) {
    Color bg;
    Color fg;

    switch (status.toLowerCase()) {
      case 'done':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        break;
      case 'ready':
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF1D4ED8);
        break;
      default:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ============================================================
// ADD PRODUCT DIALOG
// ============================================================

class AddProductDialog extends StatelessWidget {
  const AddProductDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Product'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            TextField(
              decoration: InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              decoration: InputDecoration(
                labelText: 'SKU',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              decoration: InputDecoration(
                labelText: 'Initial Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
          ),
          child: const Text('Save', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}