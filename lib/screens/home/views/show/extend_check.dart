import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wisma1/models/check_model.dart';
import 'package:wisma1/providers/checks_provider.dart';

class ExtendCheck extends StatefulWidget {
  final String checkId;
  final void Function(DateTime) onExtend;
  final DateTime checkDate;
  final WidgetRef ref;
  final BuildContext contextImport;
  final DateTime checkOutDate;
  const ExtendCheck(
      {required this.checkId,
      required this.checkOutDate,
      required this.onExtend,
      required this.checkDate,
      required this.ref,
      required this.contextImport,
      super.key});

  @override
  _ExtendCheckState createState() => _ExtendCheckState();
}

class _ExtendCheckState extends State<ExtendCheck> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.checkOutDate;
  }

  @override
  Widget build(BuildContext context) {
    final checks = widget.ref
        .read(checksProvider)
        .where((check) => check.status == Status.checkIn)
        .toList();
    final checksNotifier = widget.ref.read(checksProvider.notifier);
    final checkKu = checksNotifier.findCheckById(widget.checkId);
    final statusChange = (checkKu.status == Status.paid) ||
            (checkKu.status == Status.partiallyPaid)
        ? Status.partiallyPaid
        : Status.checkIn;
    return Column(
      children: [
        ListTile(
          title: const Text('Select Extend Date'),
          subtitle: Text(
            '${_selectedDate.toLocal()}'.split(' ')[0],
          ),
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: _selectedDate,
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              setState(() {
                _selectedDate = pickedDate;
              });
            }
          },
        ),
        ElevatedButton(
          onPressed: () {
            widget.onExtend(_selectedDate);
            widget.ref.read(checksProvider.notifier).extendCheckCheckOutDate(
                widget.checkId, 
                _selectedDate,
                );
            widget.ref.read(checksProvider.notifier).updateCheckStatus(
                  widget.checkId,
                  statusChange,
                  checkKu.lastDayPaid!,
                  0,
                  checkKu,
                );
            Navigator.of(context).pop();
            Navigator.of(widget.contextImport).pop();
          },
          child: const Text('Save Extend'),
        ),
      ],
    );
  }
}
