import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wisma1/models/check_model.dart';

// Firestore interaction class
class ChecksRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Check>> fetchAllChecks() async {
    final snapshot = await _firestore
        .collection('checks')
        .orderBy('createdAt', descending: true) // Added orderBy clause
        .get();
    return snapshot.docs.map((doc) => Check.fromFireStore(doc)).toList();
  }

  Future<void> addCheck(Check newCheck) async {
    await _firestore.collection('checks').add(newCheck.toFirestore());
  }

  Future<void> updateCheck(String id, Map<String, dynamic> newData) async {
    await _firestore.collection('checks').doc(id).update(newData);
  }

  Future<void> deleteCheck(String id) async {
    await _firestore.collection('checks').doc(id).delete();
  }
}

// Main Provider for Checks
class ChecksNotifier extends StateNotifier<List<Check>> {
  final ChecksRepository repository;

  ChecksNotifier({required this.repository}) : super([]);

  Future<void> fetchChecks() async {
    state = await repository.fetchAllChecks();
  }

  Future<void> addCheck(Check newCheck) async {
    await repository.addCheck(newCheck);
    state = [newCheck, ...state];
  }

  void extendCheckLastDayPaid(String id, DateTime extendDate) {
    state = state.map((check) {
      if (check.id == id) {
        check.extendLastDayPaid(extendDate);
      }
      return check;
    }).toList();
  }

  Future<void> extendCheckCheckOutDate(String id, DateTime extendDate) async {
    final extendedData = {
      'checkOutDate': extendDate.toIso8601String(),
    };
    await repository.updateCheck(id, extendedData);
    state = state
        .map((check) => check.id == id
            ? Check(
                id: check.id,
                roomNumber: check.roomNumber,
                guestName: check.guestName,
                status: check.status,
                checkDate: check.checkDate,
                checkOutDate: extendDate,
                lastDayPaid: check.lastDayPaid,
                totalPayment: check.totalPayment,
                createdAt: check.createdAt,
              )
            : check)
        .toList();
    state = state.map((check) {
      if (check.id == id) {
        check.extendCheckOutDate(extendDate);
      }
      return check;
    }).toList();
  }

  Future<void> updateCheckStatus(String id, Status newStatus,
      DateTime lastDayPaid, int addedPaymentAmount, Check updatedCheck) async {
    final updatedData = {
      'status': newStatus.toString(),
      'lastDayPaid': lastDayPaid.toIso8601String(),
      'totalPayment': FieldValue.increment(addedPaymentAmount),
    };
    // print(id);
    await repository.updateCheck(id, updatedData);
    state = state
        .map((check) => check.id == id
            ? Check(
                id: check.id,
                roomNumber: check.roomNumber,
                guestName: check.guestName,
                status: newStatus,
                checkDate: check.checkDate,
                checkOutDate: check.checkOutDate,
                lastDayPaid: lastDayPaid,
                totalPayment: check.totalPayment + addedPaymentAmount,
                createdAt: check.createdAt
              )
            : check)
        .toList();
  }

  void updateCheckDirectly(int index, Check updatedCheck) {
    final updatedState = List<Check>.from(state);
    updatedState[index] = updatedCheck;
    state = updatedState;
  }

  Future<void> removeCheck(String id) async {
    await repository.deleteCheck(id);
    state = state.where((check) => check.id != id).toList();
  }

  Check findCheckById(String id) {
    return state.firstWhere(
      (check) => check.id == id,
      orElse: () => throw Exception('Check with id $id not found'),
    );
  }
}

final checksRepositoryProvider = Provider((ref) => ChecksRepository());

final checksProvider =
    StateNotifierProvider<ChecksNotifier, List<Check>>((ref) {
  return ChecksNotifier(repository: ref.watch(checksRepositoryProvider));
});

// New Check Form State Management
class NewCheckFormState {
  final TextEditingController idController;
  final TextEditingController guestNameController;
  final TextEditingController roomNumberController;
  DateTime? selectedDate;
  DateTime? selectedCheckOutDate;
  DateTime? selectedLastDayPaid;

  NewCheckFormState({
    required this.idController,
    required this.guestNameController,
    required this.roomNumberController,
    this.selectedDate,
    this.selectedCheckOutDate,
    this.selectedLastDayPaid,
  });

  NewCheckFormState copyWith({
    TextEditingController? guestNameController,
    TextEditingController? roomNumberController,
    DateTime? selectedDate,
    DateTime? selectedCheckOutDate,
    DateTime? selectedLastDayPaid,
  }) {
    return NewCheckFormState(
      idController: idController ?? this.idController,
      guestNameController: guestNameController ?? this.guestNameController,
      roomNumberController: roomNumberController ?? this.roomNumberController,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedCheckOutDate: selectedCheckOutDate ?? this.selectedCheckOutDate,
      selectedLastDayPaid: selectedLastDayPaid ?? this.selectedLastDayPaid,
    );
  }
}

final newCheckFormProvider =
    StateNotifierProvider<NewCheckFormNotifier, NewCheckFormState>((ref) {
  return NewCheckFormNotifier();
});

class NewCheckFormNotifier extends StateNotifier<NewCheckFormState> {
  NewCheckFormNotifier()
      : super(NewCheckFormState(
          idController: TextEditingController(),
          guestNameController: TextEditingController(),
          roomNumberController: TextEditingController(),
        ));

  void setSelectedDateRange(DateTime checkIn, DateTime checkOut) {
    state = state.copyWith(
      selectedDate: checkIn,
      selectedCheckOutDate: checkOut,
    );
  }

  void setSelectedLastDayPaid(DateTime? date) {
    state = state.copyWith(selectedLastDayPaid: date);
  }

  void clearFields() {
    state.guestNameController.clear();
    state.roomNumberController.clear();
    state = NewCheckFormState(
      idController: TextEditingController(),
      guestNameController: TextEditingController(),
      roomNumberController: TextEditingController(),
    );
  }

  void disposeControllers() {
    state.guestNameController.dispose();
    state.roomNumberController.dispose();
  }
}
