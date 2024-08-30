import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wisma1/data/date_flow_data.dart';
import 'package:wisma1/models/date_flow_model.dart';

class DateFlowNotifier extends StateNotifier<List<DateFlow>> {
  DateFlowNotifier() : super(dateFlows);

  /// Strips time from a DateTime object
  DateTime _stripTime(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void addOrUpdateDateFlow(DateFlow newFlow) {
    DateTime newFlowDateOnly = _stripTime(newFlow.date);
    newFlow.date = newFlowDateOnly;
    int lastIndex = state.length - 1;
    bool isPositive = newFlow.amount != 0;

    // Check if there're days that have 0 income
    DateTime lastDateOnList = state[lastIndex].date;
    DateTime lastDayOnList = _stripTime(state[lastIndex].date);
    final zeroIncomeDays = newFlowDateOnly.difference(lastDayOnList).inDays;
    if (zeroIncomeDays > 0) {
      for (int i = 1; i < zeroIncomeDays; i++) {
        DateFlow newZeroIncomeFlow = DateFlow(
            date: lastDateOnList.add(Duration(days: i)),
            amount: 0,
            negAmount: 0);
        state = [...state, newZeroIncomeFlow];
      }
    }
    // newFlow.date = newFlow.date.add(Duration(days: zeroIncomeDays));
    DateTime theNewFlowDateOnly = _stripTime(newFlow.date);

    // Check if an existing flow with the same date (ignoring time) exists
    bool doesExist = false;
    for (int i = 0; i < state.length; i++) {
      if (theNewFlowDateOnly == _stripTime(state[i].date)) {
        doesExist = true;
      }
    }

    if (doesExist) {
      final updatedFlow = isPositive
          ? state[lastIndex]
              .copyWith(amount: state[lastIndex].amount + newFlow.amount)
          : state[lastIndex]
              .copyWith(negAmount: state[lastIndex].negAmount + newFlow.negAmount);
      state[lastIndex] = updatedFlow;
    } else {
      state = [...state, newFlow];
    }

    // Update the wallet balance
    DateFlow.addBalance(newFlow.amount + newFlow.negAmount);

    // print(zeroIncomeDays);
    // for (int i = 0; i < state.length; i++) {
    //   print(state[i].date.toString() + " ---- " + state[i].amount.toString());
    // }
  }

  void removeDateFlow(String id) {
    final dateFlow = state.firstWhere((flow) => flow.id == id,
        orElse: () => throw Exception("DateFlow not found"));
    DateFlow.addBalance(-dateFlow.amount);
    state = state.where((flow) => flow.id != id).toList();
  }

  void clearAll() {
    state = [];
    DateFlow.walletAmount = 0;
  }
}

final dateFlowProvider =
    StateNotifierProvider<DateFlowNotifier, List<DateFlow>>((ref) {
  return DateFlowNotifier();
});
