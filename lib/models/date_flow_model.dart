import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat('d/M/yyyy');

const uuid = Uuid();

// enum Type { income, expense }

// const typeColor = {
//   Type.income: Colors.blue,
//   Type.expense: Colors.red,
// };

class DateFlow {
  DateFlow({
    required this.date,
    required this.amount,
    required this.negAmount,
  }) : id = uuid.v4();

  static int walletAmount = 0;
  static int totalIncome = 0;
  static int totalExpense = 0;
  final String id;
  DateTime date;
  final int amount;
  final int negAmount;

  static void addBalance(int amount) {
    walletAmount += amount;
    if (amount > 0) {
      totalIncome += amount;
    } else {
      totalExpense -= amount;
    }
  }

  // static void subtractBalance(int negAmount) {
  //   walletAmount -= negAmount;
  //   totalExpense += negAmount;
  // }

  DateFlow copyWith({
    DateTime? date,
    int? amount,
    int? negAmount,
  }) {
    return DateFlow(
      date: date ?? this.date,
      amount: amount ?? this.amount,
      negAmount: negAmount ?? this.negAmount,
    );
  }

  int get incomeOfTheDay {
    return amount;
  }

  int get expenseOfTheDay {
    return negAmount;
  }

    factory DateFlow.fromFireStore(QueryDocumentSnapshot map) {
    // print(map.id);
    var data = map.data() as Map<String, dynamic>;
    return DateFlow(
      date: map['date'] is String
          ? DateTime.parse(map['date'])
          : (map['date'] as Timestamp).toDate(),
      amount: map['amount'] as int,
      negAmount: map['negAmount'] as int,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': date,
      'amount': amount,
      'negAmount': negAmount,
    };
  }
}
