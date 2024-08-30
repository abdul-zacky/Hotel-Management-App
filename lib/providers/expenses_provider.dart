import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wisma1/models/expense_model.dart';

// Firestore interaction class
class ExpensesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Expense>> fetchAllExpenses() async {
    final snapshot = await _firestore.collection('expenses').orderBy('date', descending: true).get();
    return snapshot.docs.map((doc) => Expense.fromFireStore(doc)).toList();
  }

  Future<void> addExpense(Expense newExpense) async {
    await _firestore.collection('expenses').add(newExpense.toFirestore());
  }

  Future<void> deleteExpense(String id) async {
    await _firestore.collection('expenses').doc(id).delete();
  }
}

// Main Provider for Expenses
class ExpensesNotifier extends StateNotifier<List<Expense>> {
  final ExpensesRepository repository;

  ExpensesNotifier({required this.repository}) : super([]);

  Future<void> fetchExpenses() async {
    state = await repository.fetchAllExpenses();
  }

  Future<void> addExpense(Expense newExpense) async {
    await repository.addExpense(newExpense);
    state = [newExpense, ...state];
  }

  Future<void> removeExpense(String id) async {
    await repository.deleteExpense(id);
    state = state.where((expense) => expense.id != id).toList();
  }
}

final expensesRepositoryProvider = Provider((ref) => ExpensesRepository());

final expensesProvider =
    StateNotifierProvider<ExpensesNotifier, List<Expense>>((ref) {
  return ExpensesNotifier(repository: ref.watch(expensesRepositoryProvider));
});

// New Expense Form State Management
class NewExpenseFormState {
  final TextEditingController titleController;
  final TextEditingController amountController;
  DateTime? selectedDate;
  Category selectedCategory;

  NewExpenseFormState({
    required this.titleController,
    required this.amountController,
    this.selectedDate,
    this.selectedCategory = Category.other,
  });

  NewExpenseFormState copyWith({
    TextEditingController? titleController,
    TextEditingController? amountController,
    DateTime? selectedDate,
    Category? selectedCategory,
  }) {
    return NewExpenseFormState(
      titleController: titleController ?? this.titleController,
      amountController: amountController ?? this.amountController,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

final newExpenseFormProvider =
    StateNotifierProvider<NewExpenseFormNotifier, NewExpenseFormState>((ref) {
  return NewExpenseFormNotifier();
});

class NewExpenseFormNotifier extends StateNotifier<NewExpenseFormState> {
  NewExpenseFormNotifier()
      : super(NewExpenseFormState(
          titleController: TextEditingController(),
          amountController: TextEditingController(),
        ));

  void setSelectedDate(DateTime? date) {
    state = NewExpenseFormState(
      titleController: state.titleController,
      amountController: state.amountController,
      selectedDate: date,
      selectedCategory: state.selectedCategory,
    );
  }

  void setSelectedCategory(Category category) {
    state = NewExpenseFormState(
      titleController: state.titleController,
      amountController: state.amountController,
      selectedDate: state.selectedDate,
      selectedCategory: category,
    );
  }

  void clearFields() {
    state.titleController.clear();
    state.amountController.clear();
    state = NewExpenseFormState(
      titleController: TextEditingController(),
      amountController: TextEditingController(),
    );
  }

  void disposeControllers() {
    state.titleController.dispose();
    state.amountController.dispose();
  }
}
