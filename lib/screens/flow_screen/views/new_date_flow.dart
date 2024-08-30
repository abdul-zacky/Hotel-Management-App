// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:wisma1/models/check_model.dart';
// import 'package:wisma1/models/date_flow_model.dart';
// import 'package:wisma1/providers/checks_provider.dart';
// import 'package:wisma1/providers/date_flow_provider.dart';

// class NewDateFlow extends ConsumerWidget {
//   final WidgetRef ref;
//   final String checkId;
//   const NewDateFlow({super.key, required this.ref, required this.checkId});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final checks = ref
//         .read(checksProvider)
//         .where((check) =>
//             check.status == Status.checkIn ||
//             check.status == Status.partiallyPaid)
//         .toList();
//     final checksNotifier = ref.read(checksProvider.notifier);
//     final checkKu = checksNotifier.findCheckById(checkId);
//     void _submitDateFlowData(BuildContext context, WidgetRef ref) {
//       final state = ref.watch(newDateFlowProvider);
//       final dateFlows = ref.read(dateFlowProvider);
//     }

//     ref.read(dateFlowProvider.notifier).addDateFlow(
//         DateFlow(date: DateTime.now(), type: type, amount: amount));

//     return Container();
//   }
// }
