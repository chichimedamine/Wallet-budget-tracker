import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:wallet_budget_tracker/Model/Account.dart';
import 'package:wallet_budget_tracker/helper/colors.dart';
import 'package:wallet_budget_tracker/helper/fonts.dart';

import '../Model/Transaction.dart';
import '../bloc/listaccount/listaccount_bloc.dart';
import '../bloc/transaction/transaction_bloc.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedType = 'Income';
  String _selectedCategory = 'Food';
  String _selectedInCategory = 'Awards';
  String _selectedAccount = 'Card';
  String _selectedToAccount = 'Cash';
  bool _isTransfer = false;
  List<Account> listAccount = [];

  final List<String> _categories = [
    'Food',
    'Transportation',
    'Entertainment',
    'Shopping',
    'Bills',
    'Others'
  ];
  final List<String> _Inccategories = [
    'Awards',
    'Salary',
    'Coupons',
    'Lottery',
    'Refunds',
    'Rental',
    'Sale',
  ];

  List<String> _accounts = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm(List<Account> accounts, String typeTransaction) {
    String iconNameFromAccount = "";
    String iconNameToAccount = "";

    for (var i = 0; i < accounts.length; i++) {
      if (accounts[i].name == _selectedAccount) {
        print("test add icon: ${accounts[i].iconName}");
        iconNameFromAccount = accounts[i].iconName;
      }
      if (accounts[i].name == _selectedToAccount) {
        print("test add icon 2: ${accounts[i].iconName}");
        iconNameToAccount = accounts[i].iconName;
      }
    }
    print("set iconss  $iconNameFromAccount $iconNameToAccount");
    if (_formKey.currentState!.validate()) {
      final transaction = Transaction(
        amount: _amountController.text,
        accountName: _selectedAccount,
        type: _selectedType,
        date: _selectedDate,
        fromAccount: _selectedAccount,
        toAccount: _selectedToAccount,
        category: _selectedType == "Expense"
            ? _selectedCategory
            : _selectedType == "Income"
                ? _selectedInCategory
                : "",
        iconNameFromAccount: iconNameFromAccount,
        iconNameToAccount: iconNameToAccount,
        description: _descriptionController.text,
      );

      context.read<TransactionBloc>().add(TransactionEventAdd(
          transaction: transaction,
          fromAccount: _selectedAccount,
          toAccount: _selectedToAccount));
      Navigator.pop(context);
      print("fin form");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: ColorsHelper.white),
        elevation: 0,
        backgroundColor: ColorsHelper.green,
        title: Text(
          'Add Transaction',
          style: FontsHelper.boldTextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ColorsHelper.green,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Amount Field
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: FontsHelper.mediumTextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelStyle: FontsHelper.mediumTextStyle(
                            fontSize: 16, color: ColorsHelper.black),
                        floatingLabelStyle: FontsHelper.mediumTextStyle(
                            fontSize: 16, color: ColorsHelper.green),
                        labelText: 'Amount',
                        prefixIcon: const Icon(Icons.attach_money,
                            color: ColorsHelper.green),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: ColorsHelper.green, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Description Field
                    TextFormField(
                      controller: _descriptionController,
                      style: FontsHelper.mediumTextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelStyle: FontsHelper.mediumTextStyle(
                            fontSize: 16, color: ColorsHelper.black),
                        floatingLabelStyle: FontsHelper.mediumTextStyle(
                            fontSize: 16, color: ColorsHelper.green),
                        labelText: 'Description',
                        prefixIcon: const Icon(Icons.description,
                            color: ColorsHelper.green),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: ColorsHelper.green, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Transaction Type
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      style: FontsHelper.mediumTextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelStyle: FontsHelper.mediumTextStyle(
                            fontSize: 16, color: ColorsHelper.black),
                        floatingLabelStyle: FontsHelper.mediumTextStyle(
                            fontSize: 16, color: ColorsHelper.green),
                        labelText: 'Transaction Type',
                        prefixIcon: Icon(
                          _selectedType == 'Income'
                              ? Icons.arrow_downward
                              : _selectedType == 'Expense'
                                  ? Icons.arrow_upward
                                  : LucideIcons.arrowLeftRight,
                          color: _isTransfer ? ColorsHelper.green : Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: ColorsHelper.green, width: 2),
                        ),
                      ),
                      items:
                          ['Income', 'Expense', 'Transfer'].map((String type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          if (newValue == "Transfer") {
                            _isTransfer = true;
                          } else {
                            _isTransfer = false;
                          }
                          _selectedType = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Category Dropdown
                    _selectedType == 'Expense'
                        ? DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            style: FontsHelper.mediumTextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              labelStyle: FontsHelper.mediumTextStyle(
                                  fontSize: 16, color: ColorsHelper.black),
                              floatingLabelStyle: FontsHelper.mediumTextStyle(
                                  fontSize: 16, color: ColorsHelper.green),
                              labelText: 'Category',
                              prefixIcon: const Icon(Icons.category,
                                  color: ColorsHelper.green),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: ColorsHelper.green, width: 2),
                              ),
                            ),
                            items: _categories.map((String category) {
                              IconData icon = Icons.category;
                              switch (category) {
                                case 'Food':
                                  icon = Icons.restaurant;
                                  break;
                                case 'Transportation':
                                  icon = Icons.directions_car;
                                  break;
                                case 'Entertainment':
                                  icon = Icons.movie;
                                  break;
                                case 'Shopping':
                                  icon = Icons.shopping_bag;
                                  break;
                                case 'Bills':
                                  icon = Icons.receipt;
                                  break;
                                case 'Others':
                                  icon = Icons.more_horiz;
                                  break;
                              }
                              return DropdownMenuItem(
                                value: category,
                                child: Row(
                                  children: [
                                    Icon(icon,
                                        size: 20, color: ColorsHelper.green),
                                    const SizedBox(width: 8),
                                    Text(category),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCategory = newValue!;
                              });
                            },
                          )
                        : _selectedType == 'Income'
                            ? DropdownButtonFormField<String>(
                                value: _selectedInCategory,
                                style:
                                    FontsHelper.mediumTextStyle(fontSize: 16),
                                decoration: InputDecoration(
                                  labelStyle: FontsHelper.mediumTextStyle(
                                      fontSize: 16, color: ColorsHelper.black),
                                  floatingLabelStyle:
                                      FontsHelper.mediumTextStyle(
                                          fontSize: 16,
                                          color: ColorsHelper.green),
                                  labelText: 'Category',
                                  prefixIcon: const Icon(Icons.category,
                                      color: ColorsHelper.green),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: ColorsHelper.green, width: 2),
                                  ),
                                ),
                                items: _Inccategories.map((String category) {
                                  IconData icon = Icons.category;

                                  switch (category) {
                                    case 'Awards':
                                      icon = Icons.card_giftcard;
                                      break;
                                    case 'Salary':
                                      icon = Icons.business;
                                      break;
                                    case 'Coupons':
                                      icon = Icons.card_giftcard;
                                      break;
                                    case 'Lottery':
                                      icon = Icons.casino;
                                      break;
                                    case 'Refunds':
                                      icon = Icons.monetization_on;
                                      break;
                                    case 'Rental':
                                      icon = Icons.home;
                                      break;
                                    case 'Sale':
                                      icon = Icons.shopping_cart;
                                      break;
                                  }
                                  return DropdownMenuItem(
                                    value: category,
                                    child: Row(
                                      children: [
                                        Icon(icon,
                                            size: 20,
                                            color: ColorsHelper.green),
                                        const SizedBox(width: 8),
                                        Text(category),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedInCategory = newValue!;
                                  });
                                },
                              )
                            : const SizedBox(),
                    const SizedBox(height: 20),

                    // Account Dropdown
                    BlocBuilder<ListaccountBloc, ListaccountState>(
                      builder: (context, state) {
                        if (state is ListaccountLoaded) {
                          listAccount = state.accounts;
                          _accounts = state.accounts
                              .map((account) => account.name)
                              .toList();
                        } else {
                          _accounts = [];
                        }
                        return DropdownButtonFormField<String>(
                          value: _selectedAccount,
                          style: FontsHelper.mediumTextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            labelStyle: FontsHelper.mediumTextStyle(
                                fontSize: 16, color: ColorsHelper.black),
                            floatingLabelStyle: FontsHelper.mediumTextStyle(
                                fontSize: 16, color: ColorsHelper.green),
                            labelText: 'Account',
                            prefixIcon: const Icon(Icons.account_balance_wallet,
                                color: ColorsHelper.green),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: ColorsHelper.green, width: 2),
                            ),
                          ),
                          items: _accounts.map((String account) {
                            return DropdownMenuItem(
                              value: account,
                              child: Text(account),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedAccount = newValue!;
                            });
                          },
                        );
                      },
                    ),

                    if (_isTransfer) ...[
                      const SizedBox(height: 16),
                      Text(
                        "Transfer to",
                        style: FontsHelper.boldTextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedToAccount,
                        style: FontsHelper.mediumTextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          labelStyle: FontsHelper.mediumTextStyle(
                              fontSize: 16, color: ColorsHelper.black),
                          floatingLabelStyle: FontsHelper.mediumTextStyle(
                              fontSize: 16, color: ColorsHelper.green),
                          labelText: 'To Account',
                          prefixIcon: const Icon(Icons.account_balance_wallet,
                              color: ColorsHelper.green),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: ColorsHelper.green, width: 2),
                          ),
                        ),
                        items: _accounts.map((String account) {
                          return DropdownMenuItem(
                            value: account,
                            child: Text(account),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedToAccount = newValue!;
                          });
                        },
                      ),
                    ],
                    const SizedBox(height: 20),

                    // Date Picker
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              LucideIcons.calendar,
                              color: ColorsHelper.green,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat('MMMM dd, yyyy').format(_selectedDate),
                              style: FontsHelper.mediumTextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: () {
                        _submitForm(listAccount, _selectedType);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsHelper.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_circle_outline,
                              color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'Add Transaction',
                            style: FontsHelper.boldTextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
