import 'package:cloud_firestore/cloud_firestore.dart' hide FromFirestore;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wisma1/apis/get_expenses_data.api.dart';
import 'package:wisma1/models/expense_model.dart';

class GetExpensesData extends StateNotifier<List<Expense>> {
  GetExpensesData({required this.fromFirestore}) : super([]);

  final FromFirestore fromFirestore;
  DocumentSnapshot? lastDocument;

  Future<List<Expense>> getInitialExpenseData() async {
    try {
      final data = await fromFirestore.getExpensesData();
      lastDocument = data.docs.isNotEmpty ? data.docs.last : null;

      final List<Expense> expensesData = data.docs
          .map((doc) => Expense.fromFireStore(doc))
          .toList();

      state = expensesData;
    } catch (e) {
      print("Error fetching initial expenses data: $e");
      rethrow;
    }
    return state;
  }

  Future<void> getNextExpensesData() async {
    try {
      // Fetch data from Firestore, with pagination if lastDocument is available
      final data = await fromFirestore.getExpensesData(lastDocument: lastDocument);

      if (data.docs.isNotEmpty) {
        lastDocument = data.docs.last;
        final List<Expense> expensesData =
            data.docs.map((doc) => Expense.fromFireStore(doc)).toList();
        // Update the state with new expenses data
        state = [...state, ...expensesData];
      } else {
        // Handle the case where there are no more documents to fetch
        print("No more expenses data to fetch");
      }
    } catch (e) {
      // Handle exceptions gracefully
      print("Error fetching next expenses data: $e");
      rethrow;
    }
  }

  Future<void> addExpense(Expense newExpense) async {
    try {
      final docRef = await fromFirestore.addExpense(newExpense);
      final expenseWithId = Expense(
        title: newExpense.title,
        amount: newExpense.amount,
        date: newExpense.date,
        category: newExpense.category,
      );
      state = [...state, expenseWithId];
    } catch (e) {
      print("Error adding expense: $e");
      rethrow;
    }
  }
}

// Declare the provider at the top-level scope
final getExpensesDataProvider = StateNotifierProvider<GetExpensesData, List<Expense>>(
  (ref) => GetExpensesData(fromFirestore: ref.watch(fromFirestoreAPIProvider)),
);
