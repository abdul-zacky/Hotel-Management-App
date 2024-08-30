import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wisma1/apis/get_expenses_data.api.dart';
import 'package:wisma1/models/expense_model.dart';
import 'package:wisma1/providers/expenses_provider.dart';
import 'package:wisma1/providers/notifiers/get_expenses_data_notifier.dart';
import 'package:wisma1/screens/expense_screen/views/new_expense.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  final getChecksDataProvider =
    StateNotifierProvider<GetExpensesData, List<Expense>>((ref) =>
        GetExpensesData(fromFirestore: ref.watch(fromFirestoreAPIProvider)));

  @override
  void initState() {
    super.initState();
    ref.read(expensesProvider.notifier).fetchExpenses();
  }

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 60/81,
          child: NewExpense(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(expensesProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const Row(
              children: [
                Text(
                  'Expenses',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, int i) {
                  return GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4,
                              color: Colors.grey.shade300,
                              offset: const Offset(5, 5),
                            ),
                          ],
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                              colors: [
                                                Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                const Color.fromARGB(
                                                    255, 105, 137, 177),
                                              ],
                                              transform:
                                                  const GradientRotation(pi / 4)),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Icon(
                                        categoryIcons[expenses[i].category],
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 20),
                                  Text(
                                    expenses[i].title,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "\$${expenses[i].amount}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    expenses[i].formattedDate,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 102, 102, 102),
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
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _openAddExpenseOverlay,
              child: Container(
                width: 153,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(colors: [
                    Theme.of(context).colorScheme.primary,
                    const Color.fromARGB(255, 105, 137, 177),
                  ], transform: const GradientRotation(pi / 4)),
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
                  child: Text(
                    'ADD EXPENSE',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
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
