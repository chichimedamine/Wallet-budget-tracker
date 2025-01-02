import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:wallet_budget_tracker/helper/colors.dart';
import 'package:wallet_budget_tracker/helper/fonts.dart';

import '../bloc/transaction/transaction_bloc.dart';
import '../views/budgetscreen.dart';

class Listrecords extends StatelessWidget {
  const Listrecords({super.key});

  @override
  Widget build(BuildContext context) {
    return Listrecord();
  }
}

Widget EmptyList() => Container(
      padding: const EdgeInsets.only(left: 20),
      width: double.infinity,
      child: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.ban, size: 90, color: ColorsHelper.gray),
              Text(
                "No records found",
                style: FontsHelper.mediumTextStyle(
                    fontSize: 20, color: ColorsHelper.gray),
              )
            ],
          )),
    );

Widget Listrecord() => Container(
      padding: const EdgeInsets.only(left: 20),
      width: double.infinity,
      child: Align(
          alignment: Alignment.centerLeft,
          child: BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
              //print(state);
              if (state is TransactionLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is TransactionLoaded) {
                if (state.listtransaction.isEmpty) {
                  return EmptyList();
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Recent Records",
                            style: FontsHelper.mediumTextStyle(
                                fontSize: 18, color: ColorsHelper.gray),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: TextButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Clear All Transactions'),
                                    content: const Text(
                                        'Are you sure you want to clear all transactions? This action cannot be undone.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          context
                                              .read<TransactionBloc>()
                                              .add(TransactionEventClearAll());
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Clear All'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(LucideIcons.trash,
                                  color: Colors.red),
                              label: const Text('Clear All',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 170,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: state.listtransaction.length,
                          itemBuilder: (context, index) {
                            final transacation = state.listtransaction[index];
                            return Dismissible(
                              key: Key(transacation.accountName!),
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(
                                  LucideIcons.trash,
                                  color: Colors.white,
                                ),
                              ),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) {
                                context.read<TransactionBloc>().add(
                                    TransactionEventDelete(
                                        transaction: transacation,
                                        index: index));
                              },
                              child: TransactionCard(transacation, context),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
              }

              return const SizedBox();
            },
          )),
    );
