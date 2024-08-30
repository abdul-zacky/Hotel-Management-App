import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wisma1/apis/get_expenses_data.api.dart';
import 'package:wisma1/models/date_flow_model.dart';
import 'package:wisma1/models/expense_model.dart';
import 'package:wisma1/providers/date_flows_provider.dart';
import 'package:wisma1/providers/expenses_provider.dart';
import 'package:wisma1/providers/notifiers/get_expenses_data_notifier.dart';

final formatter = DateFormat.yMd();

class NewExpense extends ConsumerWidget {
  NewExpense({super.key});

  final getChecksDataProvider =
      StateNotifierProvider<GetExpensesData, List<Expense>>((ref) =>
          GetExpensesData(fromFirestore: ref.watch(fromFirestoreAPIProvider)));

  Future<void> _presentDatePicker(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: now,
    );

    ref.read(newExpenseFormProvider.notifier).setSelectedDate(pickedDate);
  }

  void _submitExpenseData(BuildContext context, WidgetRef ref) {
    final state = ref.watch(newExpenseFormProvider);
    final enteredAmount = int.tryParse(state.amountController.text);
    final amountIsInvalid = enteredAmount == null || enteredAmount <= 0;

    if (state.titleController.text.trim().isEmpty ||
        amountIsInvalid ||
        state.selectedDate == null) {
      if (Platform.isIOS) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Invalid input'),
            content: const Text(
              'Please make sure a valid title, amount, date, and category was entered',
            ),
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
            content: const Text(
              'Please make sure a valid title, amount, date, and category was entered',
            ),
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

    ref.read(expensesProvider.notifier).addExpense(
          Expense(
            title: state.titleController.text,
            amount: enteredAmount,
            date: state.selectedDate!,
            category: state.selectedCategory,
          ),
        );
    DateFlow.addBalance(enteredAmount.toInt() * -1);
    Navigator.pop(context);
    ref.read(dateFlowProvider.notifier).addOrUpdateDateFlow(DateFlow(
          date: DateTime.now(),
          amount: 0,
          negAmount: enteredAmount,
        ));
    ref.read(newExpenseFormProvider.notifier).clearFields();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(newExpenseFormProvider);
    return FutureBuilder(
      future:
          ref.read(getExpensesDataProvider.notifier).getInitialExpenseData(),
      builder: (context, snapshot) {
        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   return Center(child: CircularProgressIndicator());
        // }
        return Consumer(
          builder: (context, ref, _) {
            final expensesData = ref.watch(getExpensesDataProvider);
            return LayoutBuilder(
              builder: (ctx, constraints) {
                return SizedBox(
                  height: double.infinity,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: Column(
                        children: [
                          TextField(
                            controller: state.titleController,
                            maxLength: 50,
                            decoration: const InputDecoration(
                              label: Text('Title'),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: state.amountController,
                                  decoration: const InputDecoration(
                                    prefixText: '\$ ',
                                    label: Text('Amount'),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      state.selectedDate == null
                                          ? 'No Date Selected'
                                          : formatter
                                              .format(state.selectedDate!),
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          _presentDatePicker(context, ref),
                                      icon: const Icon(Icons.calendar_month),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              DropdownButton<Category>(
                                value: state.selectedCategory,
                                items: Category.values
                                    .map(
                                      (category) => DropdownMenuItem(
                                        value: category,
                                        child: Text(
                                          category.name.toUpperCase(),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    ref
                                        .read(newExpenseFormProvider.notifier)
                                        .setSelectedCategory(value);
                                  }
                                },
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  ref
                                      .read(getExpensesDataProvider.notifier)
                                      .getNextExpensesData();
                                  () => Navigator.pushNamed(
                                      context, '/new_expense');
                                  StateNotifierProvider<GetExpensesData,
                                          List<Expense>>(
                                      (ref) => GetExpensesData(
                                          fromFirestore: ref.watch(
                                              fromFirestoreAPIProvider)));
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel'),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _submitExpenseData(context, ref);
                                  // DateFlow.subtractBalance(xxx);
                                },
                                child: const Text('Save Expense'),
                              ),
                            ],
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
