// main_screen.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wisma1/apis/get_checks_data.api.dart';
import 'package:wisma1/models/check_model.dart';
import 'package:wisma1/providers/checks_provider.dart';
import 'package:wisma1/providers/notifiers/get_checks_data_notifier.dart';
import 'package:wisma1/screens/home/views/new_check.dart';
import 'package:wisma1/screens/home/views/show/edit_options.dart';
import 'package:wisma1/screens/home/views/show/extend_check.dart';
import 'package:wisma1/screens/home/views/show/pay_check.dart';
import 'package:wisma1/screens/home/views/show/room_list.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final List<int> rooms = [
    // 1st Floor
    105, 106, 107, 108,
    // 2nd Floor
    201, 202, 203, 204, 205, 206, 207, 208,
    // 3rd Floor
    301, 302, 303, 304, 305, 306, 307, 308,
    // 4th Floor
    403, 404, 405, 406, 407, 408
  ];

  final getChecksDataProvider =
      StateNotifierProvider<GetChecksData, List<Check>>((ref) =>
          GetChecksData(fromFirestore: ref.watch(fromFirestoreAPIProvider)));

  @override
  void initState() {
    super.initState();
    ref.read(checksProvider.notifier).fetchChecks();
  }

  void reloadData() {
    setState(() {
      ref.read(checksProvider.notifier).fetchChecks();
    });
  }
  
  void _openAddCheckOverlay() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 52 / 81,
          child: NewCheck(),
        );
      },
    );
  }

  void _showEditOptions(int roomNumber) {
    showEditOptions(
      context: context,
      ref: ref,
      roomNumber: roomNumber,
      rooms: rooms,
      openExtendCheckOverlay: _openExtendCheckOverlay,
      openExtendLastDayPaidOverlay: _openExtendLastDayPaidOverlay,
    );
  }

  void _openExtendCheckOverlay(String checkId) {
    final checksNotifier = ref.read(checksProvider.notifier);
    Check checkKu;
    checkKu = checksNotifier.findCheckById(checkId);
    final DateTime checkDate = checkKu.checkDate;
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 52 / 81,
          child: ExtendCheck(
            checkId: checkId,
            onExtend: (DateTime extendDate) {
              ref
                  .read(checksProvider.notifier)
                  .extendCheckCheckOutDate(checkId, extendDate);
            },
            checkDate: checkDate,
            checkOutDate: checkKu.checkOutDate,
            ref: ref,
            contextImport: context,
          ),
        );
      },
    );
  }

  void _openExtendLastDayPaidOverlay(String checkId) {
    final checksNotifier = ref.read(checksProvider.notifier);
    Check checkKu;
    checkKu = checksNotifier.findCheckById(checkId);
    final DateTime checkDate = checkKu.checkOutDate; //
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 52 / 81,
          child: PayCheck(
            checkId: checkId,
            onPayDays: (DateTime date) {
              ref
                  .read(checksProvider.notifier)
                  .extendCheckLastDayPaid(checkId, date);
            },
            lastDayPaid: checkKu.lastDayPaid!,
            checkOutDate: checkKu.checkOutDate,
            ref: ref,
            contextImport: context,
          ),
        );
      },
    );
  }

  void _showRoomList() {
    showRoomList(context, ref, rooms);
  }

  @override
  Widget build(BuildContext context) {
    final checks = ref.watch(checksProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Activities',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: _showRoomList,
                  child: const Text(
                    'View Room List',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 102, 102, 102),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: checks.isNotEmpty
                  ? ListView.builder(
                    
                      itemCount: checks.length,
                      itemBuilder: (context, int i) {
                        final check = checks[i];
                        final statusEditable = check.status != Status.checkOut;
                        String theGuestName = check.guestName;
                        final roomNumber = check.roomNumber;
                        if (theGuestName.length > 10) {
                          theGuestName = theGuestName.substring(0,7);
                        }; 
                        return GestureDetector(
                          onTap: statusEditable
                              ? () => _showEditOptions(roomNumber)
                              : () {},
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  statusEditable
                                      ? BoxShadow(
                                          blurRadius: 4,
                                          color: Colors.grey.shade300,
                                          offset: const Offset(5, 5),
                                        )
                                      : const BoxShadow(),
                                ],
                                color: statusEditable
                                    ? Colors.white
                                    : const Color.fromARGB(255, 248, 248, 248),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 55,
                                          child: Text(
                                            check.roomNumber.toString(),
                                            style: TextStyle(
                                              fontSize: 25,
                                              color: statusColor[check.status],
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 20),

                                        Text(
                                          theGuestName,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: (check.status !=
                                                    Status.checkOut)
                                                ? Colors.black
                                                : Colors.grey,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "${check.formattedCheckDate} - ",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Color.fromARGB(
                                                    255, 102, 102, 102),
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Text(
                                              check.formattedCheckOutDate,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Color.fromARGB(
                                                    255, 102, 102, 102),
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          check.formattedTotalPayment
                                              .toString(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color.fromARGB(
                                                255, 102, 102, 102),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No Activities\nTry adding some!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
            GestureDetector(
              onTap: _openAddCheckOverlay,
              child: Container(
                width: 153,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      const Color.fromARGB(255, 105, 137, 177),
                    ],
                    transform: const GradientRotation(pi / 4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 4,
                      color: Colors.grey.shade300,
                      offset: const Offset(5, 5),
                    ),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 22, vertical: 17),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'CHECK IN',
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
