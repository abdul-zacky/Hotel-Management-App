import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wisma1/data/date_flow_data.dart';
import 'package:wisma1/models/check_model.dart';
import 'package:wisma1/models/date_flow_model.dart';
import 'package:wisma1/providers/checks_provider.dart';
import 'package:wisma1/providers/date_flows_provider.dart';

class PayCheck extends StatefulWidget {
  final String checkId;
  final void Function(DateTime) onPayDays;
  final DateTime lastDayPaid;
  final DateTime checkOutDate;
  final WidgetRef ref;
  final BuildContext contextImport;
  const PayCheck(
      {required this.checkId,
      required this.onPayDays,
      required this.lastDayPaid,
      required this.checkOutDate,
      required this.ref,
      required this.contextImport,
      super.key});
  @override
  State<PayCheck> createState() => _PayCheckState();
}

class _PayCheckState extends State<PayCheck> {
  late DateTime _selectedDate;
  late int _willBePaidDays;
  final priceFormatter = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);
  final listOfPrices = {
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

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.lastDayPaid;
    _willBePaidDays = _selectedDate.difference(widget.lastDayPaid).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final checks = widget.ref
        .read(checksProvider)
        .where((check) =>
            check.status == Status.checkIn ||
            check.status == Status.partiallyPaid)
        .toList();
    final checksNotifier = widget.ref.read(checksProvider.notifier);
    final checkKu = checksNotifier.findCheckById(widget.checkId);
    return Column(
      children: [
        ListTile(
          title: const Text('Pay Date'),
          subtitle: Text(
            '${_selectedDate.toLocal()}'.split(' ')[0],
          ),
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: _selectedDate,
              lastDate: widget.checkOutDate,
            );
            if (pickedDate != null) {
              setState(() {
                _selectedDate = pickedDate;
                _willBePaidDays = pickedDate
                    .difference(
                        widget.lastDayPaid.subtract(const Duration(days: 1)))
                    .inDays;
              });
            }
          },
        ),
        _willBePaidDays != 0
            ? GestureDetector(
                onTap: () {
                  widget.onPayDays(_selectedDate);
                  widget.ref.read(checksProvider.notifier).updateCheckStatus(
                        widget.checkId,
                        checkKu.statusPaymentStatus,
                        checkKu.lastDayPaid!,
                        listOfPrices[checkKu.roomNumber]! * (_willBePaidDays - 1),
                        checkKu,
                      );
                  Navigator.of(context).pop();
                  Navigator.of(widget.contextImport).pop();
                  widget.ref
                      .read(dateFlowProvider.notifier)
                      .addOrUpdateDateFlow(DateFlow(
                        date: DateTime.now(),
                        amount:
                            listOfPrices[checkKu.roomNumber]! * (_willBePaidDays - 1),
                        negAmount: 0,
                      ));
                  // checkKu.totalPayment = listOfPrices[checkKu.roomNumber]! * _willBePaidDays;
                },
                child: Container(
                  width: 191,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        statusColor[checkKu.status]!,
                        statusColor[checkKu.status]!.withOpacity(0.7),
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
                        'Pay ${priceFormatter.format(listOfPrices[checkKu.roomNumber]! * (_willBePaidDays - 1))}',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}
