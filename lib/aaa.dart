import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wisma1/models/expense_model.dart';

// Firestore interaction class
class ExpensesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Expense>> fetchAllExpenses() async {
    final snapshot = await _firestore.collection('expenses').get();
    return snapshot.docs.map((doc) => Expense.fromFireStore(doc)).toList();
  }

  Future<void> addExpense(Expense newExpense) async {
    await _firestore.collection('expenses').add(newExpense.toFirestore());
  }

  Future<void> updateExpense(String id, Map<String, dynamic> newData) async {
    await _firestore.collection('expenses').doc(id).update(newData);
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

  // void extendExpenseExpenseOutDate(String id, DateTime extendDate) {
  //   state = state.map((expense) {
  //     if (expense.id == id) {
  //       expense.extendExpenseOutDate(extendDate);
  //     }
  //     return expense;
  //   }).toList();
  // }

  // void extendExpenseLastDayPaid(String id, DateTime extendDate) {
  //   state = state.map((expense) {
  //     if (expense.id == id) {
  //       expense.extendLastDayPaid(extendDate);
  //     }
  //     return expense;
  //   }).toList();
  // }

  // Future<void> updateExpenseStatus(String id, Status newStatus,
  //     DateTime lastDayPaid, int addedPaymentAmount) async {
  //   final updatedData = {
  //     'status': newStatus.toString(),
  //     'lastDayPaid': lastDayPaid.toIso8601String(),
  //     'totalPayment': FieldValue.increment(addedPaymentAmount),
  //   };
  //   print(id);
  //   await repository.updateExpense(id, updatedData);
  //   state = state
  //       .map((expense) => expense.id == id
  //           ? Expense(
  //               id: expense.id,
  //               roomNumber: expense.roomNumber,
  //               guestName: expense.guestName,
  //               status: newStatus,
  //               expenseDate: expense.expenseDate,
  //               expenseOutDate: expense.expenseOutDate,
  //               lastDayPaid: lastDayPaid,
  //               totalPayment: expense.totalPayment + addedPaymentAmount,
  //             )
  //           : expense)
  //       .toList();
  // }

  void updateExpenseDirectly(int index, Expense updatedExpense) {
    final updatedState = List<Expense>.from(state);
    updatedState[index] = updatedExpense;
    state = updatedState;
  }

  Future<void> removeExpense(String id) async {
    await repository.deleteExpense(id);
    state = state.where((expense) => expense.id != id).toList();
  }

  Expense findExpenseById(String id) {
    return state.firstWhere(
      (expense) => expense.id == id,
      orElse: () => throw Exception('Expense with id $id not found'),
    );
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
  final TextEditingController enteredAmount;
  DateTime? selectedDate;
  Category? category;
  // final TextEditingController idController;
  // final TextEditingController guestNameController;
  // final TextEditingController roomNumberController;
  // DateTime? selectedDate;
  // DateTime? selectedExpenseOutDate;
  // DateTime? selectedLastDayPaid;

  NewExpenseFormState({
    required this.titleController,
    required this.enteredAmount,
    this.selectedDate,
    this.category = Category.other,
    // required this.idController,
    // required this.guestNameController,
    // required this.roomNumberController,
    // this.selectedDate,
    // this.selectedExpenseOutDate,
    // this.selectedLastDayPaid,
  });

  NewExpenseFormState copyWith({
    TextEditingController? titleController,
    int? enteredAmount,
    DateTime? selectedDate,
    Category? category,
    // TextEditingController? guestNameController,
    // TextEditingController? roomNumberController,
    // DateTime? selectedDate,
    // DateTime? selectedExpenseOutDate,
    // DateTime? selectedLastDayPaid,
  }) {
    return NewExpenseFormState(
      titleController: titleController ?? this.titleController,
      enteredAmount: this.enteredAmount,
      selectedDate: selectedDate ?? this.selectedDate,
      category: category ?? this.category,
      // idController: idController ?? this.idController,
      // guestNameController: guestNameController ?? this.guestNameController,
      // roomNumberController: roomNumberController ?? this.roomNumberController,
      // selectedDate: selectedDate ?? this.selectedDate,
      // selectedExpenseOutDate: selectedExpenseOutDate ?? this.selectedExpenseOutDate,
      // selectedLastDayPaid: selectedLastDayPaid ?? this.selectedLastDayPaid,
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
          enteredAmount: TextEditingController(),
          // idController: TextEditingController(),
          // guestNameController: TextEditingController(),
          // roomNumberController: TextEditingController(),
        ));

  // void setSelectedDateRange(DateTime expenseIn, DateTime expenseOut) {
  //   state = state.copyWith(
  //     selectedDate: expenseIn,
  //     selectedExpenseOutDate: expenseOut,
  //   );
  // }

  // void setSelectedLastDayPaid(DateTime? date) {
  //   state = state.copyWith(selectedLastDayPaid: date);
  // }

  void clearFields() {
    state.titleController.clear();
    state.enteredAmount.clear();
    state = NewExpenseFormState(
      titleController: TextEditingController(),
      enteredAmount: TextEditingController(),
    );
    // state.guestNameController.clear();
    // state.roomNumberController.clear();
    // state = NewExpenseFormState(
    //   idController: TextEditingController(),
    //   guestNameController: TextEditingController(),
    //   roomNumberController: TextEditingController(),
    // );
  }

  void disposeControllers() {
    state.titleController.dispose();
    state.enteredAmount.dispose();
    // state.guestNameController.dispose();
    // state.roomNumberController.dispose();
  }
}
