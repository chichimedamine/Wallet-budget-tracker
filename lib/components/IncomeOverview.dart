import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:wallet_budget_tracker/components/donutchart.dart';

import '../Model/Transaction.dart';
import '../bloc/transaction/transaction_bloc.dart';
import '../helper/colors.dart';
import '../helper/fonts.dart';

class IncomeOverview extends StatelessWidget {
  const IncomeOverview({
    super.key,
  });

  double calculateIncomePercentage(double totalIncome, double totalExpenses) {
    print("totalIncome: $totalIncome, totalExpenses: $totalExpenses");
    if (totalIncome + totalExpenses == 0) return 0;
    return (totalIncome / (totalIncome + totalExpenses)) * 100;
  }

  Future<double> getTotalIncome(List<Transaction> transactions) async {
    double totalIncome = transactions
        .where((t) => t.type == "Income")
        .map((t) => double.parse(t.amount ?? "0"))
        .fold(0, (sum, amount) => sum + amount);
    final boxhive = await Hive.openBox('dataInEX');
    boxhive.put("totalIncome", totalIncome);
    return Future.value(totalIncome);
  }

  Future<double> getTotalExpense(List<Transaction> transactions) async {
    double totalExpense = transactions
        .where((t) => t.type == "Expense")
        .map((t) => double.parse(t.amount ?? "0"))
        .fold(0, (sum, amount) => sum + amount);
    final boxhive = await Hive.openBox('dataInEX');
    boxhive.put("totalExpense", totalExpense);
    return Future.value(totalExpense);
  }

  double percentageForThisMonth(double totalIncome, double monthlyIncome) {
    if (totalIncome == 0) return 0;
    return (monthlyIncome / totalIncome) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TransactionLoaded) {
          if (state.listtransaction.isEmpty) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  LucideIcons.ban,
                  size: 80,
                  color: ColorsHelper.gray,
                ),
                Text(
                  "No transactions yet",
                  style: FontsHelper.boldTextStyle(
                      fontSize: 20, color: ColorsHelper.gray),
                )
              ],
            ));
          } else {
            return FutureBuilder<double>(
              future: getTotalIncome(state.listtransaction),
              builder: (context, incomeSnapshot) {
                if (incomeSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (incomeSnapshot.hasError) {
                  return Center(child: Text('Error: ${incomeSnapshot.error}'));
                }
                double totalIncome = incomeSnapshot.data ?? 0;
                return FutureBuilder<double>(
                  future: getTotalExpense(state.listtransaction),
                  builder: (context, expenseSnapshot) {
                    if (expenseSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (expenseSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${expenseSnapshot.error}'));
                    }
                    double totalExpense = expenseSnapshot.data ?? 0;
                    double percentage =
                        calculateIncomePercentage(totalIncome, totalExpense);
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 30.0, top: 10),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  "Income overview",
                                  style: FontsHelper.largeTextStyle(
                                    color: ColorsHelper.black,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color:
                                          ColorsHelper.green.withOpacity(0.5),
                                      border: Border.all(
                                          color: ColorsHelper.white)),
                                  child: const Icon(
                                    LucideIcons.trendingUp,
                                    size: 30,
                                    color: ColorsHelper.green,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 30.0, top: 10),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "$totalIncome DT",
                                      style: FontsHelper.boldTextStyle(
                                          fontSize: 30,
                                          color: ColorsHelper.black),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        "+  ${percentage.toStringAsFixed(1)} %",
                                        style: FontsHelper.boldTextStyle(
                                            fontSize: 15,
                                            color: ColorsHelper.green),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 30,
                                ),
                                SizedBox(
                                  height: 80,
                                  width: 80,
                                  child: Align(
                                      alignment: Alignment.centerRight,
                                      child: DonutChartExample(
                                        color: ColorsHelper.green,
                                        value: percentage,
                                        rest: 100 - percentage,
                                      )),
                                )
                              ],
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 30.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              children: [],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          }
        }
        return const SizedBox();
      },
    );
  }
}
