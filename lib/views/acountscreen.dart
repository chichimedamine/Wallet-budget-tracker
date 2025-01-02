import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:wallet_budget_tracker/bloc/transaction/transaction_bloc.dart';
import 'package:wallet_budget_tracker/components/backgroundcard.dart';

import '../Model/Account.dart';
import '../Model/Transaction.dart';
import '../bloc/listaccount/listaccount_bloc.dart';
import '../components/listaccounts.dart';
import '../helper/colors.dart';
import '../helper/fonts.dart';

class Acountscreen extends StatefulWidget {
  const Acountscreen({super.key});

  @override
  State<Acountscreen> createState() => _AcountscreenState();
}

class Bodycard extends StatelessWidget {
  const Bodycard({
    super.key,
  });

  double _calculateTotal(List<Account> accounts) {
    return accounts.fold(0.0, (sum, account) => sum + account.balance);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListaccountBloc, ListaccountState>(
      builder: (context, state) {
        double totalBalance = 0.0;
        if (state is ListaccountLoaded) {
          totalBalance = _calculateTotal(state.accounts);
        }

        return Padding(
          padding: const EdgeInsets.only(left: 20.0, bottom: 90),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "All Accounts: ${totalBalance.toStringAsFixed(2)} DT",
                        style: FontsHelper.boldTextStyle(
                            fontSize: 23.0, color: ColorsHelper.white),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 20.0),
                        child: Icon(
                          LucideIcons.plus,
                          color: ColorsHelper.white,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class CardIN_EX extends StatelessWidget {
  const CardIN_EX({
    super.key,
  });
  double getTotalIncome(List<Transaction> transactions) {
    return transactions
        .where((t) => t.type == "Income")
        .map((t) => double.parse(t.amount ?? "0"))
        .fold(0, (sum, amount) => sum + amount);
  }

  double getTotalExpense(List<Transaction> transactions) {
    return transactions
        .where((t) => t.type == "Expense")
        .map((t) => double.parse(t.amount ?? "0"))
        .fold(0, (sum, amount) => sum + amount);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoaded) {
          return Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: 60,
              width: 320,
              decoration: BoxDecoration(
                  border: Border.all(color: ColorsHelper.green),
                  color: ColorsHelper.white,
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "Income : ${getTotalIncome(state.listtransaction)} DT",
                    style: FontsHelper.boldTextStyle(
                        fontSize: 14, color: ColorsHelper.green),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Expense : ${getTotalExpense(state.listtransaction)} DT",
                    style: FontsHelper.boldTextStyle(
                        fontSize: 14, color: ColorsHelper.red),
                  ),
                ],
              ),
            ),
          );
        } else if (state is TransactionLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is TransactionError) {
          return Center(
            child: Text(state.message),
          );
        }
        return const SizedBox();
      },
    );
  }
}

class _AcountscreenState extends State<Acountscreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _selectedIcon = 'wallet'; // default icon
  late ListaccountBloc _accountBloc;

  @override
  void initState() {
    super.initState();
    _accountBloc = ListaccountBloc()..add(LoadedListaccount());
  }

  @override
  void dispose() {
    _accountBloc.close();
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _addNewAccount(BuildContext context) async {
    final String name = _nameController.text.trim();
    final double amount = double.tryParse(_amountController.text) ?? 0.0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an account name')),
      );
      return;
    }

    final db = await Hive.openBox('db');

    final account = Account(
      name: name,
      balance: amount,
      currency: "DT",
      iconName: _selectedIcon,
    );
    await db.add(account);

    // Trigger list refresh
    if (mounted) {
      _accountBloc.add(RefreshListaccount());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account added successfully')),
      );
    }

    // Clear the controllers
    _nameController.clear();
    _amountController.clear();
    _selectedIcon = 'wallet'; // reset to default
  }

  Widget _buildIconSelector(StateSetter setState) {
     final List<Map<String, dynamic>> icons = [
      {'name': 'wallet', 'icon': LucideIcons.wallet},
      {'name': 'card', 'icon': LucideIcons.creditCard},
      {'name': 'cash', 'icon': LucideIcons.banknote},
      {'name': 'savings', 'icon': LucideIcons.piggyBank},
      {'name': 'bank', 'icon': LucideIcons.landmark},
    ];

    return Wrap(
      spacing: 10,
      children: icons.map((iconData) {
        final bool isSelected = _selectedIcon == iconData['name'];
        return InkWell(
          onTap: () {
            setState(() {
              _selectedIcon = iconData['name'];
            });
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2,
              ),
            ),
            child: Icon(
              iconData['icon'],
              color: isSelected ? ColorsHelper.green : Colors.white,
              size: 30,
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showAddAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              elevation: 10,
              backgroundColor: ColorsHelper.green,
              title: Center(
                child: Text(
                  'Add New Account',
                  style: FontsHelper.boldTextStyle(
                      color: ColorsHelper.white, fontSize: 20),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        labelText: 'Name',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        labelText: 'Initial amount',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Select Icon',
                      style: FontsHelper.mediumTextStyle(
                          color: ColorsHelper.white, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    _buildIconSelector(setState),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    _nameController.clear();
                    _amountController.clear();
                    _selectedIcon = 'wallet';
                    Navigator.of(dialogContext).pop();
                  },
                ),
                TextButton(
                  child:
                      const Text('Save', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    _addNewAccount(dialogContext);
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _accountBloc,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: ColorsHelper.green,
          child: const Icon(
            LucideIcons.plus,
            color: ColorsHelper.white,
          ),
          onPressed: () => _showAddAccountDialog(context),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              BackgroundCard(
                body: const Bodycard(),
              ),
              const SizedBox(
                height: 20,
              ),
              const CardIN_EX(),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 300,
                child: BlocBuilder<ListaccountBloc, ListaccountState>(
                  builder: (context, state) {
                    if (state is ListaccountLoaded) {
                      return const Listaccounts();
                    } else if (state is ListaccountRefresh) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: ColorsHelper.green,
                        ),
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator(
                        color: ColorsHelper.green,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
