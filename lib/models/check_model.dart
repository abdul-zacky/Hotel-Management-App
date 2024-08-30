import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final formatter = DateFormat('d/M/yyyy');

final amountFormatter = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);

const uuid = Uuid();

enum Status { checkIn, partiallyPaid, paid, checkOut }

extension StatusExtension on Status {
  String toFirestore() => toString().split('.').last;

  static Status fromFirestore(String value) {
    try {
      if (value == "checkIn") {
        return Status.values
            .firstWhere((type) => type.toString().split('.').last == value);
      } else {
        return Status.values.firstWhere((type) => type.toString() == value);
      }
    } catch (e) {
      // Log the error or handle it
      print("Unknown status: $value");
      return Status.checkOut; // Return a fallback value
    }
  }
}

enum Payment { paid, daily, later }

const statusColor = {
  Status.checkIn: Color.fromARGB(255, 200, 19, 6),
  Status.partiallyPaid: Color.fromARGB(255, 200, 171, 6),
  Status.paid: Color.fromARGB(255, 0, 99, 157),
  Status.checkOut: Colors.grey,
};

const listOfPrices = {
  105: 200000,
  106: 200000,
  107: 200000,
  108: 200000,
  201: 200000,
  202: 200000,
  203: 180000,
  204: 180000,
  205: 180000,
  206: 180000,
  207: 180000,
  208: 180000,
  301: 200000,
  302: 200000,
  303: 180000,
  304: 180000,
  305: 180000,
  306: 180000,
  307: 180000,
  308: 180000,
  403: 180000,
  404: 200000,
  405: 200000,
  406: 200000,
  407: 200000,
  408: 180000,
};

class Check {
  Check({
    required this.id,
    required this.roomNumber,
    required this.guestName,
    required this.status,
    required this.checkDate,
    required this.checkOutDate,
    DateTime? lastDayPaid,
    int? totalPayment,
    required this.createdAt,
  })  : lastDayPaid = lastDayPaid ?? checkDate,
        // id = uuid.v4(),
        totalPayment = totalPayment ?? 0;

  final String id;
  final int roomNumber;
  final String guestName;
  Status status;
  final DateTime checkDate;
  DateTime checkOutDate;
  DateTime? lastDayPaid;
  int totalPayment;
  DateTime createdAt;

  String get formattedCheckDate {
    return formatter.format(checkDate);
  }

  String get formattedCheckOutDate {
    return formatter.format(checkOutDate);
  }

  String get formattedLastDayPaid {
    return formatter.format(lastDayPaid!);
  }

  String get formattedTotalPayment {
    return amountFormatter.format(totalPayment);
  }

  DateTime _stripTime(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String get paymentStatus {
    // Compare just the dates, ignoring the time part
    final lastPaidDate = _stripTime(lastDayPaid!);
    final checkDateOnly = _stripTime(checkDate);
    final checkOutDateOnly = _stripTime(checkOutDate);
    final paidDays = lastPaidDate.difference(checkDateOnly).inDays;
    final unPaidDays = checkOutDateOnly.difference(lastPaidDate).inDays;
    // return lastPaidDate != checkDateOnly;
    if (lastPaidDate == checkDateOnly) {
      return "Not Paid, $unPaidDays days";
    } else if (lastPaidDate != checkOutDateOnly) {
      return '$paidDays days';
    } else {
      return "Paid";
    }
  }

  int get totalBill {
    final lastPaidDate = _stripTime(lastDayPaid!);
    final checkOutDateOnly = _stripTime(checkOutDate);
    final roomPrice = listOfPrices[roomNumber];
    final unPaidDays = checkOutDateOnly.difference(lastPaidDate).inDays;
    return (roomPrice! * unPaidDays);
  }

  // String get formattedTotalBill {
  //   final formatter = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);
  //   return formatter.format(totalBill);
  // }

  Status get statusPaymentStatus {
    final lastPaidDate = _stripTime(lastDayPaid!);
    final checkDateOnly = _stripTime(checkDate);
    final checkOutDateOnly = _stripTime(checkOutDate);
    final paidDays = lastPaidDate.difference(checkDateOnly).inDays;
    final unPaidDays = checkOutDateOnly.difference(lastPaidDate).inDays;
    if (lastPaidDate == checkDateOnly) {
      return Status.checkIn;
    } else if (lastPaidDate != checkOutDateOnly) {
      return Status.partiallyPaid;
    } else {
      return Status.paid;
    }
  }

  void updateStatus(Status newStatus) {
    status = newStatus;
  }

  void extendCheckOutDate(DateTime extendDate) {
    checkOutDate = extendDate;
  }

  void extendLastDayPaid(DateTime extendDate) {
    lastDayPaid = extendDate;
  }

  factory Check.fromFireStore(QueryDocumentSnapshot map) {
    // print(map.id);
    var data = map.data() as Map<String, dynamic>;
    return Check(
      id: map.id,
      roomNumber: map['roomNumber'] as int,
      guestName: map['guestName'] as String,
      status: StatusExtension.fromFirestore(map['status']),
      checkDate: map['checkDate'] is String
          ? DateTime.parse(map['checkDate'])
          : (map['checkDate'] as Timestamp).toDate(),
      checkOutDate: map['checkOutDate'] is String
          ? DateTime.parse(map['checkOutDate'])
          : (map['checkOutDate'] as Timestamp).toDate(),
      totalPayment:
          data.containsKey('totalPayment') ? data['totalPayment'] as int : 0,
      lastDayPaid: map['lastDayPaid'] is String
          ? DateTime.parse(map['lastDayPaid'])
          : (map['lastDayPaid'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'guestName': guestName,
      'roomNumber': roomNumber,
      'checkDate': checkDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'status': status.toString().split('.').last,
      'totalPayment': totalPayment,
      'lastDayPaid': lastDayPaid!.toIso8601String(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
