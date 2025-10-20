// EXAMPLE USAGE OF ProductFilterBottomSheet
// This file demonstrates how to integrate the filter bottom sheet into your Tőzsde page

import 'package:flutter/material.dart';
import 'product_filter_bottom_sheet.dart';

class TozsdePage extends StatefulWidget {
  const TozsdePage({super.key});

  @override
  State<TozsdePage> createState() => _TozsdePageState();
}

class _TozsdePageState extends State<TozsdePage> {
  Map<String, dynamic>? _activeFilters;

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => ProductFilterBottomSheet(
          initialFilters: _activeFilters,
          onApply: (filters) {
            setState(() {
              _activeFilters = filters;
            });
            // TODO: Apply filters to your product list
            // Example:
            // _applyFiltersToProductList(filters);
            print('Filters applied: $filters');
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tőzsde'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Product List Here'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showFilterBottomSheet,
              child: const Text('Open Filter'),
            ),
            if (_activeFilters != null) ...[
              const SizedBox(height: 20),
              Text('Active Filters: ${_activeFilters.toString()}'),
            ],
          ],
        ),
      ),
    );
  }
}

// EXAMPLE: How to process filters
void _applyFiltersToProductList(Map<String, dynamic> filters) {
  // Access filter values:
  final sortBy = filters['sortBy'] as String;
  final exchanges = filters['exchanges'] as List<String>;
  final priceChangeTimeframe = filters['priceChangeTimeframe'] as String;
  final priceMin = filters['priceMin'] as double?;
  final priceMax = filters['priceMax'] as double?;
  final dividendMin = filters['dividendMin'] as double?;
  final dividendMax = filters['dividendMax'] as double?;
  final marketCapMin = filters['marketCapMin'] as double?;
  final marketCapMax = filters['marketCapMax'] as double?;
  final rsiMin = filters['rsiMin'] as double?;
  final rsiMax = filters['rsiMax'] as double?;

  // Apply filters to your data
  // Example:
  // products = products.where((product) {
  //   if (exchanges.isNotEmpty && !exchanges.contains(product.exchange)) {
  //     return false;
  //   }
  //   if (dividendMin != null && product.dividend < dividendMin) {
  //     return false;
  //   }
  //   // ... more filter logic
  //   return true;
  // }).toList();

  // Sort products
  // Example:
  // switch (sortBy) {
  //   case 'Név szerint':
  //     products.sort((a, b) => a.name.compareTo(b.name));
  //     break;
  //   case 'Ár szerint (növekvő)':
  //     products.sort((a, b) => a.price.compareTo(b.price));
  //     break;
  //   // ... more sorting logic
  // }
}
