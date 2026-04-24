import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/expense.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Analytics',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[50],
        child: StreamBuilder<List<Expense>>(
          stream: firestoreService.getExpenses(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            List<Expense> expenses = snapshot.data!;
            double total = expenses.fold(0, (sum, e) => sum + e.amount);
            Map<String, double> categoryTotals = {};
            final categoryColors = {
              'Food': Colors.orange,
              'Transport': Colors.blue,
              'Entertainment': Colors.purple,
              'Other': Colors.grey,
            };
            final categoryIcons = {
              'Food': Icons.restaurant,
              'Transport': Icons.directions_car,
              'Entertainment': Icons.movie,
              'Other': Icons.shopping_bag,
            };

            for (var e in expenses) {
              categoryTotals[e.category] =
                  (categoryTotals[e.category] ?? 0) + e.amount;
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Expenses',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${expenses.length} transactions',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Breakdown by Category',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...categoryTotals.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color:
                                      (categoryColors[entry.key] ?? Colors.grey)
                                          .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  categoryIcons[entry.key] ??
                                      Icons.shopping_bag,
                                  color:
                                      categoryColors[entry.key] ?? Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        minHeight: 6,
                                        value: entry.value / total,
                                        backgroundColor: Colors.grey[300],
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              categoryColors[entry.key] ??
                                                  Colors.grey,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${entry.value.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${((entry.value / total) * 100).toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
