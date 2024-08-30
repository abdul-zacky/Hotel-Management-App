import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat('dd/MM/yyyy');

const uuid = Uuid();

enum Category {
  water,
  electricity,
  wage,
  equipment,
  other
} // enum is used to make another type of data that very specific by typing them inside of the curly bracket

extension CategoryExtension on Expense {
  String toFirestore() => toString().split('.').last;

  static Category fromFirestore(String value) {
    try {
        return Category.values
            .firstWhere((type) => type.toString().split('.').last == value);
    } catch (e) {
      // Log the error or handle it
      print("Unknown status: $value");
      return Category.other; // Return a fallback value
    }
  }
}

const categoryIcons = {
  Category.water: Icons.water_drop,
  Category.electricity: Icons.electric_bolt,
  Category.wage: Icons.money_off_outlined,
  Category.equipment: Icons.settings_accessibility_outlined,
  Category.other: Icons.menu_rounded,
};

class Expense {
  Expense({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  }) : id = uuid
            .v4(); // Make a unique string id // If you don't want your variables to be parameters, you can code them this way

  final String id;
  final String title;
  final int amount;
  final DateTime date;
  final Category category;

  String get formattedDate {
    return formatter.format(date);
  }

  factory Expense.fromFireStore(QueryDocumentSnapshot map) {
    // print(map.id);
    var data = map.data() as Map<String, dynamic>;
    return Expense(
      title: map['title'] as String,
      amount: map['amount'] as int,
      date: map['date'] is String
          ? DateTime.parse(map['date'])
          : (map['date'] as Timestamp).toDate(),
      category: CategoryExtension.fromFirestore(map['category']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category.toString().split('.').last,
      // 'guestName': guestName,
      // 'roomNumber': roomNumber,
      // 'checkDate': checkDate.toIso8601String(),
      // 'checkOutDate': checkOutDate.toIso8601String(),
      // 'status': status.toString().split('.').last,
      // 'totalPayment': totalPayment,
    };
  }
}
