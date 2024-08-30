import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wisma1/data/expenses_data.dart';
import 'package:wisma1/models/expense_model.dart';

final fromFirestoreAPIProvider =
    Provider<FromFirestore>((ref) => FromFirestore());

class FromFirestore {
  Future<QuerySnapshot<Object?>> getExpensesData({
    DocumentSnapshot? lastDocument,
  }) async {
    CollectionReference expensesDataCollection =
        FirebaseFirestore.instance.collection('expensesData');

    Query expensesQuery = expensesDataCollection.limit(5);

    if (lastDocument != null) {
      expensesQuery = expensesQuery.startAfterDocument(lastDocument);
    }

    final QuerySnapshot querySnapshot = await expensesQuery.get();
    return querySnapshot;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<DocumentReference> addExpense(Expense expense) {
    return _firestore.collection('expenses').add(expense.toFirestore());
  }
}
