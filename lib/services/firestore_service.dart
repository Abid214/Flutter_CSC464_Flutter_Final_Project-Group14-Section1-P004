import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addExpense(Expense expense) async {
    try {
      print('FirestoreService: Adding expense to Firestore...');
      print('FirestoreService: Expense data: ${expense.toFirestore()}');

      // Check if Firebase is initialized
      final firestore = FirebaseFirestore.instance;
      print('FirestoreService: Firestore instance created');

      final docRef = await firestore
          .collection('expenses')
          .add(expense.toFirestore());
      print('FirestoreService: Expense added with ID: ${docRef.id}');

      // Verify the document was added
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        print('FirestoreService: Document verified in Firestore');
      } else {
        print('FirestoreService: ERROR - Document not found after adding!');
      }
    } catch (e, stackTrace) {
      print('FirestoreService: Error adding expense: $e');
      print('Stack trace: $stackTrace');

      // Check if it's a Firebase error
      if (e.toString().contains('permission-denied')) {
        print(
          'FirestoreService: This is a permission error - check Firestore security rules',
        );
      } else if (e.toString().contains('unavailable')) {
        print(
          'FirestoreService: Firestore is unavailable - check network connection',
        );
      } else if (e.toString().contains('invalid-argument')) {
        print('FirestoreService: Invalid data being sent to Firestore');
      }

      rethrow;
    }
  }

  Stream<List<Expense>> getExpenses() {
    try {
      return _db
          .collection('expenses')
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList(),
          )
          .handleError((error) {
            print('Firestore Stream Error: $error');
            throw error;
          });
    } catch (e) {
      print('Error creating Firestore stream: $e');
      rethrow;
    }
  }

  Future<void> updateExpense(String id, Expense expense) async {
    await _db.collection('expenses').doc(id).update(expense.toFirestore());
  }

  Future<void> deleteExpense(String id) async {
    await _db.collection('expenses').doc(id).delete();
  }
}
