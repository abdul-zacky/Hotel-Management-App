import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wisma1/apis/get_checks_data.api.dart';
import 'package:wisma1/models/check_model.dart';
import 'package:wisma1/providers/checks_provider.dart';
import 'package:wisma1/providers/notifiers/get_checks_data_notifier.dart';
import 'package:wisma1/screens/home/views/main_screen.dart';

final formatter = DateFormat.yMd();

class NewCheck extends ConsumerWidget {
  // final VoidCallback onCheckSaved;
  NewCheck({super.key});

  final getChecksDataProvider =
      StateNotifierProvider<GetChecksData, List<Check>>((ref) =>
          GetChecksData(fromFirestore: ref.watch(fromFirestoreAPIProvider)));

  Future<void> _presentDateRangePicker(
      BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final DateTimeRange? pickedDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1, now.month, now.day),
      lastDate: DateTime(now.year + 2, now.month, now.day),
      initialDateRange: DateTimeRange(
        start: now,
        end: now.add(const Duration(days: 1)),
      ),
    );

    if (pickedDateRange != null) {
      ref.read(newCheckFormProvider.notifier).setSelectedDateRange(
            pickedDateRange.start,
            pickedDateRange.end,
          );
    }
  }

  void _submitCheckData(BuildContext context, WidgetRef ref) {
    final state = ref.watch(newCheckFormProvider);
    final checks = ref.read(checksProvider);

    final enteredRoomNumber = int.tryParse(state.roomNumberController.text);
    final roomNumberIsInvalid =
        enteredRoomNumber == null || enteredRoomNumber <= 0;

    // List of valid room numbers
    final List<int> validRooms = [
      // 1st Floor
      105, 106, 107, 108,
      // 2nd Floor
      201, 202, 203, 204, 205, 206, 207, 208,
      // 3rd Floor
      301, 302, 303, 304, 305, 306, 307, 308,
      // 4th Floor
      403, 404, 405, 406, 407, 408
    ];

    final roomExists = validRooms.contains(enteredRoomNumber);
    final roomOccupied = checks.any((check) =>
        check.roomNumber == enteredRoomNumber &&
        check.status != Status.checkOut);

    if (state.guestNameController.text.trim().isEmpty ||
        roomNumberIsInvalid ||
        !roomExists ||
        roomOccupied ||
        state.selectedDate == null ||
        state.selectedCheckOutDate == null) {
      String errorMessage;
      if (roomNumberIsInvalid || !roomExists) {
        errorMessage = "Please make sure a valid room number is entered.";
      } else if (roomOccupied) {
        errorMessage = "Room $enteredRoomNumber is already occupied.";
      } else {
        errorMessage =
            "Please make sure a valid guest name, check-in date, and check-out date are entered.";
      }

      if (Platform.isIOS) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Invalid input'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: const Text('Okay'),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Invalid input'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: const Text('Okay'),
              ),
            ],
          ),
        );
      }
      return;
    }

    ref.read(checksProvider.notifier).addCheck(
          Check(
            id: state.idController.toString(),
            roomNumber: enteredRoomNumber,
            guestName: state.guestNameController.text.toUpperCase(),
            status: Status.checkIn,
            checkDate: state.selectedDate!,
            checkOutDate: state.selectedCheckOutDate!,
            lastDayPaid: state.selectedDate!,
            createdAt: DateTime.now(),
          ),
        );
    // onCheckSaved;
    Navigator.pop(context);
    ref.read(newCheckFormProvider.notifier).clearFields();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(newCheckFormProvider);

    return FutureBuilder(
      future: ref.read(getChecksDataProvider.notifier).getInitialCheckData(),
      builder: (context, snapshot) {
        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   return Center(child: SizedBox());
        // }
        return Consumer(
          builder: (context, ref, _) {
            final usersData = ref.watch(getChecksDataProvider);
            return LayoutBuilder(
              builder: (ctx, constraints) {
                return SizedBox(
                  height: double.infinity,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: state.guestNameController,
                            maxLength: 50,
                            decoration: const InputDecoration(
                              label: Text('Guest Name'),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: state.roomNumberController,
                                  decoration: const InputDecoration(
                                    label: Text('Room Number'),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      _presentDateRangePicker(context, ref),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 12,
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          state.selectedDate == null
                                              ? 'DATE'
                                              : formatter
                                                  .format(state.selectedDate!),
                                        ),
                                        if (state.selectedCheckOutDate != null)
                                          Text(formatter.format(
                                              state.selectedCheckOutDate!)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _submitCheckData(context, ref);
                              ref
                                  .read(getChecksDataProvider.notifier)
                                  .getNextChecksData();
                              () => Navigator.pushNamed(context, '/new_check');
                              StateNotifierProvider<GetChecksData, List<Check>>(
                                  (ref) => GetChecksData(
                                      fromFirestore:
                                          ref.watch(fromFirestoreAPIProvider)));
                              ref.read(getChecksDataProvider.notifier).getInitialCheckData();
                            },
                            child: const Text('Save Check'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
