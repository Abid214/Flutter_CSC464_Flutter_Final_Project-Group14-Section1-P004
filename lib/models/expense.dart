import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String name;
  final double amount;
  final DateTime date;
  final String category;
  final String? description;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
    required this.category,
    this.description,
    required this.createdAt,
  });

  factory Expense.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      name: data['name'] ?? '',
      amount: data['amount'] ?? 0.0,
      date: (data['date'] as Timestamp).toDate(),
      category: data['category'] ?? '',
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'category': category,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
