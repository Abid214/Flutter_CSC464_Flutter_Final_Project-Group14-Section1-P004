import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../models/expense.dart';
import 'add_expense_screen.dart';
import 'analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = '';
  String selectedCategory = 'All';
  String sortBy = 'date';
  bool sortDescending = true;

  void _showDeleteConfirmation(
    BuildContext context,
    Expense expense,
    FirestoreService firestoreService,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Expense'),
          content: Text('Are you sure you want to delete "${expense.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                firestoreService.deleteExpense(expense.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Expense deleted')),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expense Calculator',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined, size: 28),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AnalyticsScreen()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search expenses...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: searchQuery.isNotEmpty
                          ? GestureDetector(
                              onTap: () => setState(() => searchQuery = ''),
                              child: const Icon(
                                Icons.clear,
                                color: Colors.grey,
                              ),
                            )
                          : null,
                    ),
                    onChanged: (value) => setState(() => searchQuery = value),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: DropdownButton<String>(
                            value: selectedCategory,
                            isExpanded: true,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.unfold_more),
                            items:
                                [
                                  'All',
                                  'Food',
                                  'Transport',
                                  'Entertainment',
                                  'Other',
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Text(value),
                                    ),
                                  );
                                }).toList(),
                            onChanged: (value) =>
                                setState(() => selectedCategory = value!),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: DropdownButton<String>(
                            value: sortBy,
                            isExpanded: true,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.unfold_more),
                            items: ['date', 'amount'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text('Sort by $value'),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) =>
                                setState(() => sortBy = value!),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: IconButton(
                          icon: Icon(
                            sortDescending
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: const Color(0xFF2196F3),
                          ),
                          onPressed: () =>
                              setState(() => sortDescending = !sortDescending),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Expense>>(
                stream: firestoreService.getExpenses(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print('StreamBuilder Error: ${snapshot.error}');
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading expenses',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.red[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              'Make sure you have internet connection and Firestore is configured',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  List<Expense> expenses = snapshot.data!;

                  if (selectedCategory != 'All') {
                    expenses = expenses
                        .where((e) => e.category == selectedCategory)
                        .toList();
                  }
                  if (searchQuery.isNotEmpty) {
                    expenses = expenses
                        .where(
                          (e) => e.name.toLowerCase().contains(
                            searchQuery.toLowerCase(),
                          ),
                        )
                        .toList();
                  }

                  expenses.sort((a, b) {
                    int result;
                    if (sortBy == 'date') {
                      result = a.date.compareTo(b.date);
                    } else {
                      result = a.amount.compareTo(b.amount);
                    }
                    return sortDescending ? -result : result;
                  });

                  if (expenses.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No expenses found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      Expense expense = expenses[index];
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

                      return Dismissible(
                        key: Key(expense.id),
                        onDismissed: (direction) {
                          firestoreService.deleteExpense(expense.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Expense deleted'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        background: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color:
                                    (categoryColors[expense.category] ??
                                            Colors.grey)
                                        .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                categoryIcons[expense.category] ??
                                    Icons.shopping_bag,
                                color:
                                    categoryColors[expense.category] ??
                                    Colors.grey,
                              ),
                            ),
                            title: Text(
                              expense.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  '${expense.category} • ${DateFormat('MMM d, yyyy').format(expense.date)}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '\$${expense.amount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF2196F3),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _showDeleteConfirmation(
                                    context,
                                    expense,
                                    firestoreService,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AddExpenseScreen(expense: expense),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddExpenseScreen()),
        ),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
