import 'package:wisma1/models/expense_model.dart';

final expensesData = [
  Expense(
    title: "Water",
    amount: 100,
    date: DateTime.now(),
    category: Category.water,
  ),
  Expense(
    title: 'Electricity',
    amount: 250,
    date: DateTime.now(),
    category: Category.electricity,
  ),
  Expense(
    title: 'Wage',
    amount: 800,
    date: DateTime.now(),
    category: Category.wage,
  ),
];
