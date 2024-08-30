import 'dart:math';

// import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wisma1/models/date_flow_model.dart';
import 'package:wisma1/providers/date_flows_provider.dart';
import 'package:wisma1/screens/flow_screen/views/chart.dart';

class FlowScreen extends ConsumerStatefulWidget {
  const FlowScreen({super.key});

  @override
  ConsumerState<FlowScreen> createState() => _FlowScreenState();
}

class _FlowScreenState extends ConsumerState<FlowScreen> {
  final amountFormatter =
      NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final dateFlows = ref.watch(dateFlowProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const Row(
              children: [
                Text(
                  'Wallet',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width / 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Theme.of(context).colorScheme.primary,
                  Color.fromARGB(255, 105, 137, 177),
                ], transform: GradientRotation(pi / 4)),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4,
                    color: Colors.grey.shade300,
                    offset: Offset(6, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Total Balance",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    amountFormatter.format(DateFlow.walletAmount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 25,
                              height: 25,
                              decoration: const BoxDecoration(
                                color: Colors.white30,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  CupertinoIcons.arrow_down,
                                  size: 12,
                                  color: Colors.greenAccent,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Income",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  amountFormatter.format(DateFlow.totalIncome),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: 25,
                              height: 25,
                              decoration: const BoxDecoration(
                                color: Colors.white30,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  CupertinoIcons.arrow_down,
                                  size: 12,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Expenses",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  amountFormatter.format(DateFlow.totalExpense),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width / 2,
              // color: Colors.red,
              child: MyChart(),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: ListView.builder(
                itemCount: dateFlows.length,
                itemBuilder: (context, int i) {
                  final dateFlow = dateFlows[dateFlows.length - i - 1];
                  return Padding(
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
                          children: [
                            SizedBox(
                              width: 55,
                              child: Text(
                                dateFlow.date.day.toString(),
                                style: const TextStyle(
                                  fontSize: 25,
                                  color: Color.fromARGB(255, 105, 137, 177),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Text(
                              dateFlow.incomeOfTheDay.toString(),
                            ),
                            const SizedBox(width: 20),
                            Text(
                              dateFlow.expenseOfTheDay.toString(),
                            ),
                          ],
                        ),
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
  }
}
