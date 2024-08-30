import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wisma1/models/check_model.dart';
import 'package:wisma1/providers/checks_provider.dart';
import 'package:wisma1/screens/home/views/show/edit_options.dart';

void showRoomList(BuildContext context, WidgetRef ref, List<int> rooms) {
  final checks = ref.read(checksProvider);

  // Generate a map to keep track of room statuses
  final roomStatuses = {for (var room in rooms) room: Status.checkOut};
  for (var check in checks) {
    roomStatuses[check.roomNumber] = check.status;
  }

  // void _refreshRoomStatuses() {
  //   final checks = ref.read(checksProvider);
  //   setState(() {
  //     roomStatuses = {for (var room in rooms) room: Status.checkOut};
  //     for (var check in checks) {
  //       roomStatuses[check.roomNumber] = check.status;
  //     }
  //   });
  // }

  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return FractionallySizedBox(
            heightFactor: 52 / 81,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'Room List',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: rooms.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.45,
                      ),
                      itemBuilder: (context, index) {
                        final roomNumber = rooms[index];
                        final status = roomStatuses[roomNumber]!;
                        final colorStatus = status != Status.checkOut
                            ? statusColor[status]
                            : Colors.white;
                        return GestureDetector(
                          onTap: () {
                            if (status != Status.checkOut) {
                              // showEditOptions(
                                  // context: context,
                                  // ref: ref,
                                  // roomNumber: roomNumber,
                                  // rooms: rooms,
                                  // openExtendCheckOverlay: (int) {},
                                  // openExtendLastDayPaidOverlay: (int) {});
                                  // refreshRoomList: _refreshRoomStatuses;
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colorStatus!,
                                  colorStatus.withOpacity(0.7)
                                ],
                                transform: const GradientRotation(pi / 4),
                              ),
                              boxShadow: [
                                if (status != Status.checkOut)
                                  BoxShadow(
                                    blurRadius: 4,
                                    color: Colors.grey.shade300,
                                    offset: const Offset(5, 5),
                                  )
                              ],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  roomNumber.toString(),
                                  style: TextStyle(
                                    color: status != Status.checkOut
                                        ? Colors.white
                                        : const Color.fromARGB(
                                            255, 100, 100, 100),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                status != Status.checkOut
                                    ? Text(
                                        checks
                                            .firstWhere(
                                              (check) =>
                                                  check.roomNumber ==
                                                  roomNumber,
                                            )
                                            .guestName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      )
                                    : const Text(
                                        'Empty',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
