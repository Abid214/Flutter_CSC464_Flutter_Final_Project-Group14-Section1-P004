import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../models/expense.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expense;
  final VoidCallback? onExpenseSaved;

  const AddExpenseScreen({super.key, this.expense, this.onExpenseSaved});

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  DateTime date = DateTime.now();
  String category = 'Food';
  String? _errorMessage;
  bool _isLoading = false;
  late String name;
  late double amount;
  late String description;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.expense?.name ?? '');
    _amountController = TextEditingController(
      text: widget.expense?.amount.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.expense?.description ?? '',
    );
    name = widget.expense?.name ?? '';
    amount = widget.expense?.amount ?? 0.0;
    description = widget.expense?.description ?? '';
    if (widget.expense != null) {
      date = widget.expense!.date;
      category = widget.expense!.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _nameController.clear();
    _amountController.clear();
    _descriptionController.clear();
    setState(() {
      date = DateTime.now();
      category = 'Food';
      _errorMessage = null;
      _isLoading = false;
    });
  }

  Future<void> _deleteExpense() async {
    if (widget.expense == null) return;
    final firestoreService = Provider.of<FirestoreService>(
      context,
      listen: false,
    );
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await firestoreService.deleteExpense(widget.expense!.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense deleted successfully')),
          );
          widget.onExpenseSaved?.call();
          Navigator.of(context).pop();
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to delete expense: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.expense == null ? 'Add Expense' : 'Edit Expense',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: widget.expense != null
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteExpense,
                ),
              ]
            : null,
      ),
      body: Container(
        color: Colors.grey[50],
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text(
                  'Expense Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Expense Name',
                    prefixIcon: const Icon(Icons.label_outline),
                    hintText: 'e.g., Lunch at cafe',
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter expense name' : null,
                  onSaved: (value) => name = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixIcon: const Icon(Icons.attach_money),
                    hintText: 'e.g., 25.50',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter amount';
                    final num = double.tryParse(value);
                    if (num == null) return 'Enter valid amount';
                    if (num <= 0) return 'Amount must be positive';
                    return null;
                  },
                  onSaved: (value) => amount = double.parse(value ?? '0'),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: date,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) setState(() => date = picked);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Color(0xFF2196F3),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Date',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  DateFormat('MMM d, yyyy').format(date),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
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
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    prefixIcon: const Icon(Icons.category),
                  ),
                  items: ['Food', 'Transport', 'Entertainment', 'Other'].map((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => category = value!),
                  validator: (value) =>
                      value == null ? 'Select a category' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description (optional)',
                    prefixIcon: const Icon(Icons.note_outlined),
                    hintText: 'Add notes about this expense',
                  ),
                  maxLines: 3,
                  onSaved: (value) => description = value ?? '',
                ),
                const SizedBox(height: 16),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          print('Button pressed! Starting save process...');
                          if (_formKey.currentState!.validate()) {
                            print('Form validation passed');
                            _formKey.currentState!.save();
                            setState(() => _isLoading = true);
                            print('Loading state set to true');

                            try {
                              Expense expense = Expense(
                                id: widget.expense?.id ?? '',
                                name: name,
                                amount: amount,
                                date: date,
                                category: category,
                                description: description.isEmpty
                                    ? null
                                    : description,
                                createdAt:
                                    widget.expense?.createdAt ?? DateTime.now(),
                              );

                              print(
                                'Saving expense: ${expense.name}, amount: ${expense.amount}',
                              );

                              if (widget.expense == null) {
                                print('Adding new expense...');
                                await firestoreService
                                    .addExpense(expense)
                                    .timeout(
                                      const Duration(seconds: 10),
                                      onTimeout: () {
                                        throw Exception(
                                          'Firestore operation timed out after 10 seconds',
                                        );
                                      },
                                    );
                                print('Expense added successfully');
                              } else {
                                print('Updating existing expense...');
                                await firestoreService
                                    .updateExpense(expense.id, expense)
                                    .timeout(
                                      const Duration(seconds: 10),
                                      onTimeout: () {
                                        throw Exception(
                                          'Firestore operation timed out after 10 seconds',
                                        );
                                      },
                                    );
                                print('Expense updated successfully');
                              }

                              print('Navigating back...');
                              if (mounted) {
                                if (Navigator.of(context).canPop()) {
                                  Navigator.of(context).pop();
                                } else {
                                  // This screen can live inside an IndexedStack tab.
                                  // Keep it usable for the next add operation.
                                  setState(() {
                                    _isLoading = false;
                                    _errorMessage = null;
                                  });
                                  if (widget.expense == null) {
                                    _resetForm();
                                  }
                                  _formKey.currentState?.reset();
                                  // Force rebuild to clear form fields
                                  Future.delayed(Duration.zero, () {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            '✓ Expense added successfully',
                                          ),
                                          backgroundColor: Colors.green,
                                          duration: const Duration(seconds: 3),
                                        ),
                                      );
                                      widget.onExpenseSaved?.call();
                                    }
                                  });
                                }
                              }
                            } catch (e, stackTrace) {
                              print('Error saving expense: $e');
                              print('Stack trace: $stackTrace');
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                  _errorMessage = e.toString();
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error saving expense: $e'),
                                    duration: const Duration(seconds: 5),
                                  ),
                                );
                              }
                            }
                          }
                        },
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Icon(widget.expense == null ? Icons.add : Icons.update),
                  label: Text(
                    _isLoading
                        ? 'Saving...'
                        : (widget.expense == null
                              ? 'Add Expense'
                              : 'Update Expense'),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
