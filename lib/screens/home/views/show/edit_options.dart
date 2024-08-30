// edit_options.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wisma1/models/check_model.dart';
import 'package:wisma1/models/date_flow_model.dart';
import 'package:wisma1/providers/checks_provider.dart';
import 'package:wisma1/providers/date_flows_provider.dart';

void showEditOptions({
  required BuildContext context,
  required WidgetRef ref,
  required int roomNumber,
  required List<int> rooms,
  required void Function(String) openExtendCheckOverlay,
  required void Function(String) openExtendLastDayPaidOverlay,
}) {
  final checks = ref.read(checksProvider);
  final check = checks.firstWhere(
    (check) => check.roomNumber == roomNumber,
    orElse: () => Check(
      id: '0',
      roomNumber: roomNumber,
      guestName: 'Empty',
      status: Status.checkOut,
      checkDate: DateTime.now(),
      checkOutDate: DateTime.now().add(const Duration(days: 1)),
      createdAt: DateTime.now(),
    ),
  );

  String theGuestName = check.guestName;
  if (theGuestName.length > 7) {
    theGuestName = theGuestName.substring(0, 7);
  };

  final statusColorForThis = check.status != Status.checkOut
      ? statusColor[check.status]
      : Colors.white;

  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (BuildContext context) {
      return FractionallySizedBox(
        heightFactor: 52 / 81,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 100,
                    height: MediaQuery.of(context).size.width / 5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          statusColorForThis!,
                          statusColorForThis.withOpacity(0.7),
                        ],
                        transform: const GradientRotation(pi / 4),
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4,
                          color: Colors.grey.shade300,
                          offset: const Offset(5, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          roomNumber.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              theGuestName,
                              style: const TextStyle(
                                fontSize: 25,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'in: ${check.formattedCheckDate}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              'out: ${check.formattedCheckOutDate}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              'paid: ${check.paymentStatus}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => openExtendCheckOverlay(check.id.toString()),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 191 / 430,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            statusColorForThis.withOpacity(0.2),
                            statusColorForThis.withOpacity(0.05),
                          ],
                          transform: const GradientRotation(pi / 4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 4,
                            color: statusColorForThis.withOpacity(0.1),
                            offset: const Offset(5, 5),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 13, vertical: 6),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Extend",
                              style: TextStyle(
                                fontSize: 15,
                                color: statusColorForThis,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  check.status != Status.paid
                      ? GestureDetector(
                          onTap: () {
                            openExtendLastDayPaidOverlay(check.id.toString());
                          },
                          child: Container(
                            width:
                                MediaQuery.of(context).size.width * 191 / 430,
                            height: 60,
                            decoration: BoxDecoration(
                              // boxShadow: [
                              //   BoxShadow(
                              //     blurRadius: 4,
                              //     color: Colors.grey.shade400,
                              //     offset: const Offset(5, 5),
                              //   ),
                              // ],
                              gradient: LinearGradient(
                                colors: [
                                  statusColorForThis,
                                  statusColorForThis.withOpacity(0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 13, vertical: 6),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Pay',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            ref.read(checksProvider.notifier).updateCheckStatus(
                                  check.id.toString(),
                                  Status.checkOut,
                                  check.lastDayPaid!,
                                  0,
                                  check,
                                );
                            Navigator.pop(context);
                          },
                          child: Container(
                            width:
                                MediaQuery.of(context).size.width * 191 / 430,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  statusColorForThis,
                                  statusColorForThis.withOpacity(0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 13, vertical: 6),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Check Out",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ],
              ),
              // const SizedBox(height: 10),

              //     : const SizedBox(width: 0),
            ],
          ),
        ),
      );
    },
  );
}
