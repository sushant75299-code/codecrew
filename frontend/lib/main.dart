import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const StockSenseApp());
}

// ============================================================
// API CONFIGURATION
// ============================================================

const String apiBaseUrl = 'http://127.0.0.1:8000';

// ============================================================
// APP
// ============================================================

class StockSenseApp extends StatelessWidget {
  const StockSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StockSense',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const StockSenseHome(),
    );
  }
}

// ============================================================
// HOME
// ============================================================

class StockSenseHome extends StatefulWidget {
  const StockSenseHome({super.key});

  @override
  State<StockSenseHome> createState() => _StockSenseHomeState();
}

class _StockSenseHomeState extends State<StockSenseHome> {
  int selectedPage = 0;

  final List<Widget> pages = const [
    DashboardPage(),
    ProductsPage(),
    StockAdjustmentPage(),
    LedgerPage(),
    LowStockPage(),
  ];

  final List<String> titles = [
    'Dashboard',
    'Products',
    'Stock Adjustment',
    'Stock Ledger',
    'Low Stock',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'StockSense • ${titles[selectedPage]}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: pages[selectedPage],
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: const Column(
                  children: [
                    Icon(
                      Icons.inventory_2,
                      size: 55,
                      color: Colors.blue,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'StockSense',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Inventory Management',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Divider(),

              _drawerItem(
                icon: Icons.dashboard,
                title: 'Dashboard',
                index: 0,
              ),

              _drawerItem(
                icon: Icons.inventory,
                title: 'Products',
                index: 1,
              ),

              _drawerItem(
                icon: Icons.edit_note,
                title: 'Stock Adjustment',
                index: 2,
              ),

              _drawerItem(
                icon: Icons.history,
                title: 'Stock Ledger',
                index: 3,
              ),

              _drawerItem(
                icon: Icons.warning_amber,
                title: 'Low Stock',
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: selectedPage == index,
      onTap: () {
        setState(() {
          selectedPage = index;
        });

        Navigator.pop(context);
      },
    );
  }
}

// ============================================================
// DASHBOARD
// ============================================================

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Future<List<dynamic>> getProducts() async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/products/'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load products');
    }

    return jsonDecode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Could not connect to FastAPI.\n\n'
              'Make sure the backend is running on port 8000.\n\n'
              '${snapshot.error}',
              textAlign: TextAlign.center,
            ),
          );
        }

        final products = snapshot.data ?? [];

        final lowStock = products.where((product) {
          final stock = (product['stock'] ?? 0).toDouble();
          final reorder = (product['reorder_level'] ?? 0).toDouble();

          return stock > 0 && stock <= reorder;
        }).length;

        final outOfStock = products.where((product) {
          final stock = (product['stock'] ?? 0).toDouble();

          return stock <= 0;
        }).length;

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Inventory Overview',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Monitor your inventory and stock movements.',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: _dashboardCard(
                      title: 'Total Products',
                      value: products.length.toString(),
                      icon: Icons.inventory_2,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: _dashboardCard(
                      title: 'Low Stock',
                      value: lowStock.toString(),
                      icon: Icons.warning_amber,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: _dashboardCard(
                      title: 'Out of Stock',
                      value: outOfStock.toString(),
                      icon: Icons.remove_shopping_cart,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Inventory Status',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      ...products.take(5).map(
                        (product) {
                          final stock =
                              (product['stock'] ?? 0).toDouble();

                          final reorder =
                              (product['reorder_level'] ?? 0).toDouble();

                          return ListTile(
                            leading: Icon(
                              stock <= 0
                                  ? Icons.cancel
                                  : stock <= reorder
                                      ? Icons.warning
                                      : Icons.check_circle,
                              color: stock <= 0
                                  ? Colors.red
                                  : stock <= reorder
                                      ? Colors.orange
                                      : Colors.green,
                            ),
                            title: Text(
                              product['name'] ?? 'Unknown',
                            ),
                            subtitle: Text(
                              'SKU: ${product['sku'] ?? '-'}',
                            ),
                            trailing: Text(
                              '${stock.toStringAsFixed(0)} ${product['unit'] ?? ''}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dashboardCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.blue,
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PRODUCTS
// ============================================================

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  Future<List<dynamic>> getProducts() async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/products/'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load products');
    }

    return jsonDecode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return const Center(
            child: Text('No products found.'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              final stock =
                  (product['stock'] ?? 0).toDouble();

              final reorder =
                  (product['reorder_level'] ?? 0).toDouble();

              final isOut = stock <= 0;
              final isLow = stock > 0 && stock <= reorder;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      '${product['id']}',
                    ),
                  ),
                  title: Text(
                    product['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'SKU: ${product['sku'] ?? '-'}\n'
                    'Reorder Level: ${reorder.toStringAsFixed(0)}',
                  ),
                  isThreeLine: true,
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        stock.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isOut
                              ? Colors.red
                              : isLow
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                      ),
                      Text(
                        product['unit'] ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ============================================================
// STOCK ADJUSTMENT
// ============================================================

class StockAdjustmentPage extends StatefulWidget {
  const StockAdjustmentPage({super.key});

  @override
  State<StockAdjustmentPage> createState() =>
      _StockAdjustmentPageState();
}

class _StockAdjustmentPageState
    extends State<StockAdjustmentPage> {
  final TextEditingController productIdController =
      TextEditingController();

  final TextEditingController locationIdController =
      TextEditingController(text: '1');

  final TextEditingController physicalCountController =
      TextEditingController();

  final TextEditingController reasonController =
      TextEditingController(
    text: 'Physical stock count correction',
  );

  double systemStock = 0;
  bool loading = false;

  double get physicalCount =>
      double.tryParse(
        physicalCountController.text,
      ) ??
      0;

  double get difference =>
      physicalCount - systemStock;

  Future<void> loadProduct() async {
    final id = int.tryParse(
      productIdController.text,
    );

    if (id == null) {
      _showMessage('Enter a valid Product ID');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/products/$id'),
      );

      if (response.statusCode == 200) {
        final product = jsonDecode(response.body);

        setState(() {
          systemStock =
              (product['stock'] ?? 0).toDouble();
        });
      } else {
        _showMessage(
          'Product not found (${response.statusCode})',
        );
      }
    } catch (e) {
      _showMessage('Could not connect to backend');
    }
  }

  Future<void> submitAdjustment() async {
    final productId = int.tryParse(
      productIdController.text,
    );

    final locationId = int.tryParse(
      locationIdController.text,
    );

    if (productId == null || locationId == null) {
      _showMessage(
        'Enter valid Product ID and Location ID',
      );
      return;
    }

    if (physicalCountController.text.isEmpty) {
      _showMessage('Enter physical count');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/stock-adjustments/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'product_id': productId,
          'location_id': locationId,
          'system_stock': systemStock,
          'physical_count': physicalCount,
          'reason': reasonController.text,
        }),
      );

      if (response.statusCode == 201) {
        _showMessage(
          'Stock adjustment created successfully!',
        );

        physicalCountController.clear();

        await loadProduct();
      } else {
        _showMessage(
          'Adjustment failed: ${response.statusCode}\n'
          '${response.body}',
        );
      }
    } catch (e) {
      _showMessage(
        'Could not connect to FastAPI.\n$e',
      );
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 700,
          ),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Stock Adjustment',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Compare physical stock with system stock.',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 30),

                  TextField(
                    controller: productIdController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Product ID',
                      hintText: 'Example: 1',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: loadProduct,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: locationIdController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Location ID',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'System Stock',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            systemStock.toStringAsFixed(2),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: physicalCountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                    decoration: const InputDecoration(
                      labelText: 'Physical Count',
                      hintText: 'Example: 97',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Card(
                    color: difference < 0
                        ? Colors.red.shade50
                        : difference > 0
                            ? Colors.green.shade50
                            : Colors.grey.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Difference',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            difference.toStringAsFixed(2),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: difference < 0
                                  ? Colors.red
                                  : difference > 0
                                      ? Colors.green
                                      : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: reasonController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Reason',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed:
                          loading ? null : submitAdjustment,
                      icon: loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        loading
                            ? 'Saving...'
                            : 'ADJUST STOCK',
                      ),
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
}

// ============================================================
// STOCK LEDGER
// ============================================================

class LedgerPage extends StatefulWidget {
  const LedgerPage({super.key});

  @override
  State<LedgerPage> createState() => _LedgerPageState();
}

class _LedgerPageState extends State<LedgerPage> {
  Future<List<dynamic>> getLedger() async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/stock/ledger'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Ledger API returned ${response.statusCode}',
      );
    }

    return jsonDecode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: getLedger(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.history,
                    size: 60,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Ledger API is not available yet.',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final ledger = snapshot.data ?? [];

        if (ledger.isEmpty) {
          return const Center(
            child: Text('No stock movements recorded yet.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: ledger.length,
          itemBuilder: (context, index) {
            final item = ledger[index];

            final quantity =
                (item['quantity'] ?? 0).toDouble();

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(
                    quantity >= 0
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                  ),
                ),
                title: Text(
                  item['operation_type'] ?? 'Movement',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Product: ${item['product_id'] ?? '-'}\n'
                  'Location: ${item['location_id'] ?? '-'}',
                ),
                isThreeLine: true,
                trailing: Text(
                  '${quantity >= 0 ? '+' : ''}'
                  '${quantity.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: quantity >= 0
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ============================================================
// LOW STOCK
// ============================================================

class LowStockPage extends StatefulWidget {
  const LowStockPage({super.key});

  @override
  State<LowStockPage> createState() => _LowStockPageState();
}

class _LowStockPageState extends State<LowStockPage> {
  Future<List<dynamic>> getProducts() async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/products/'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load products');
    }

    return jsonDecode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
            ),
          );
        }

        final products = snapshot.data ?? [];

        final lowStock = products.where((product) {
          final stock =
              (product['stock'] ?? 0).toDouble();

          final reorder =
              (product['reorder_level'] ?? 0).toDouble();

          return stock > 0 && stock <= reorder;
        }).toList();

        final outOfStock = products.where((product) {
          final stock =
              (product['stock'] ?? 0).toDouble();

          return stock <= 0;
        }).toList();

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Stock Alerts',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _alertCard(
                      'Low Stock',
                      lowStock.length,
                      Icons.warning_amber,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _alertCard(
                      'Out of Stock',
                      outOfStock.length,
                      Icons.cancel,
                      Colors.red,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                'Low Stock Products',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              if (lowStock.isEmpty)
                const Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    title: Text(
                      'No low-stock products',
                    ),
                  ),
                ),

              ...lowStock.map(
                (product) => _stockAlertTile(
                  product,
                  Colors.orange,
                  Icons.warning_amber,
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Out of Stock Products',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              if (outOfStock.isEmpty)
                const Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    title: Text(
                      'No out-of-stock products',
                    ),
                  ),
                ),

              ...outOfStock.map(
                (product) => _stockAlertTile(
                  product,
                  Colors.red,
                  Icons.cancel,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _alertCard(
    String title,
    int count,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 40,
            ),
            const SizedBox(height: 10),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }

  Widget _stockAlertTile(
    dynamic product,
    Color color,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(
          icon,
          color: color,
        ),
        title: Text(
          product['name'] ?? 'Unknown',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'SKU: ${product['sku'] ?? '-'}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Stock: ${product['stock'] ?? 0}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Reorder: ${product['reorder_level'] ?? 0}',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}