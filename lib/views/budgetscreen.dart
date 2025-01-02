import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:wallet_budget_tracker/Model/Transaction.dart';
import 'package:wallet_budget_tracker/bloc/listaccount/listaccount_bloc.dart';
import 'package:wallet_budget_tracker/bloc/transaction/transaction_bloc.dart';
import '../Model/Budget.dart';
import '../bloc/budget/budget_bloc.dart';
import '../components/minicalculator.dart';
import '../helper/colors.dart';
import '../helper/fonts.dart';

import 'add_transaction.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late TransactionBloc blocTransaction;
  final List<String> categories = [
    'Food',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Bills',
    'Others'
  ];
  bool visible = true;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';

  void _showAddBudgetDialog() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    String selectedCategory = categories[0];
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Add New Budget',
                style: FontsHelper.boldTextStyle(fontSize: 20),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Budget Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: categories.map((String category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            selectedCategory = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Start Date'),
                      subtitle:
                          Text(DateFormat('yyyy-MM-dd').format(startDate)),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: startDate,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() {
                            startDate = picked;
                          });
                        }
                      },
                    ),
                    ListTile(
                      title: const Text('End Date'),
                      subtitle: Text(DateFormat('yyyy-MM-dd').format(endDate)),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: endDate,
                          firstDate: startDate,
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() {
                            endDate = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        amountController.text.isNotEmpty) {
                      final budget = Budget(
                        name: nameController.text,
                        amount: double.parse(amountController.text),
                        category: selectedCategory,
                        startDate: startDate,
                        endDate: endDate,
                      );
                      context.read<BudgetBloc>().add(AddBudget(budget));
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _startListening() async {
    setState(() {
      _isListening = true;
    });

    _recognizedText = '';
    bool available = await _speech.initialize();
    if (available) {
      print("myvoice: $available");

      _speech.listen(onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
          print("myvoice: $_recognizedText");
          print("test voice");
          _isListening = false;
          print("test voice 3 $result");
        });
        print("test voice 2 ${result.hasConfidenceRating}");

        if (result.hasConfidenceRating && result.confidence > 0.5) {
          _createTransaction(_recognizedText);
        }
      });
    } else {
      setState(() {
        _isListening = false;
      });
    }
  }

  void _createTransaction(String command) {
    if (command.contains('spend')) {
      print("spend logiccc");
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<BudgetBloc>().add(LoadBudgets());
    context.read<TransactionBloc>().add(LoaddataEvent());
    context.read<ListaccountBloc>().add(LoadedListaccount());
    _speech = stt.SpeechToText();
  }

  final TextEditingController dropmenutypeController =
      TextEditingController(text: 'Income');

  void showaddTranscationDialog() {
    final List<DropdownMenuItem<dynamic>> listaccountItems = [];
    final List<DropdownMenuItem<String>> typelist = [
      const DropdownMenuItem(
        value: "Income",
        child: Text("Income"),
      ),
      const DropdownMenuItem(
        value: "Expense",
        child: Text("Expense"),
      ),
      const DropdownMenuItem(
        value: "Transfer",
        child: Text("Transfer"),
      )
    ];
    final TextEditingController amountController = TextEditingController();

    void showCalculator() {
      showDialog(
        context: context,
        builder: (context) => MiniCalculator(
          onResult: (value) {
            amountController.text = value;
          },
        ),
      );
    }

    showDialog(
      context: context,
      builder: (context) {
        return BlocBuilder<ListaccountBloc, ListaccountState>(
          builder: (context, state) {
            if (state is ListaccountLoaded) {
              final listaccount = state.accounts;
              for (var account in listaccount) {
                listaccountItems.add(DropdownMenuItem(
                  value: account,
                  child: Text(account.name),
                ));
              }
              return AlertDialog(
                title: Text(
                  'Add Transaction',
                  style: FontsHelper.boldTextStyle(fontSize: 20),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(),
                      ),
                      value: dropmenutypeController.text,
                      onChanged: (value) {
                        if (value != null) {
                          dropmenutypeController.text = value;
                          setState(() {
                            print(value);
                            if (value == "Transfer") {
                              visible = false;
                            } else {
                              visible = true;
                            }
                            //  print(visible);
                          });
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: "Income",
                          child: Text("Income"),
                        ),
                        DropdownMenuItem(
                          value: "Expense",
                          child: Text("Expense"),
                        ),
                        DropdownMenuItem(
                          value: "Transfer",
                          child: Text("Transfer"),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (listaccountItems.isNotEmpty)
                      DropdownButtonFormField(
                        decoration: const InputDecoration(
                          labelText: 'Account',
                          border: OutlineInputBorder(),
                        ),
                        value: listaccountItems.first.value,
                        onChanged: (value) {
                          if (value != null) {
                            /* context
                                .read<TransactionBloc>()
                                .add(TransactionEventAdd(value));*/
                            // Navigator.pop(context);
                          }
                        },
                        items: listaccountItems,
                      ),
                    Offstage(
                      offstage: visible,
                      child: Column(
                        children: [
                          Text(
                            "to",
                            style: FontsHelper.smallTextStyle(fontSize: 15),
                          ),
                          DropdownButtonFormField(
                            decoration: const InputDecoration(
                              labelText: 'Account',
                              border: OutlineInputBorder(),
                            ),
                            value: listaccountItems.first.value,
                            onChanged: (value) {
                              if (value != null) {
                                /* context
                                        .read<TransactionBloc>()
                                        .add(TransactionEventAdd(value));*/
                                // Navigator.pop(context);
                              }
                            },
                            items: listaccountItems,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: amountController,
                            decoration: const InputDecoration(
                              labelText: 'Amount',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calculate),
                          onPressed: showCalculator,
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      /*     _addTransaction(
                          context,
                          dropmenutypeController.text,
                          listaccountItems.first.value.toString(),
                          amountController.text);*/
                      // TODO: Handle the submission
                      Navigator.pop(context);
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  }

  Widget _offsetPopup() => PopupMenuButton<int>(
      itemBuilder: (context) => [
            PopupMenuItem(
              onTap: _showAddBudgetDialog,
              value: 1,
              child: const Text(
                "Add Budget",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
              ),
            ),
            PopupMenuItem(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddTransactionScreen()),
                );
              },
              value: 2,
              child: const Text(
                "Add Transaction",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
              ),
            ),
          ],
      icon: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Budgets',
          style: FontsHelper.boldTextStyle(
              color: ColorsHelper.white, fontSize: 24),
        ),
        backgroundColor: ColorsHelper.green,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BlocBuilder<BudgetBloc, BudgetState>(
            builder: (context, state) {
              if (state is BudgetLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is BudgetLoaded) {
                return state.budgets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Icon(
                              LucideIcons.ban,
                              size: 100,
                              color: ColorsHelper.lightGray,
                            ),
                            Text("No budgets yet",
                                style: FontsHelper.boldTextStyle(
                                    color: ColorsHelper.lightGray,
                                    fontSize: 20)),
                          ],
                        ),
                      )
                    : SizedBox(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: state.budgets.length,
                          itemBuilder: (context, index) {
                            return Dismissible(
                              key: Key(state.budgets[index].name),
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
                                context
                                    .read<BudgetBloc>()
                                    .add(DeleteBudget(index));
                              },
                              child: BudgetCard(budget: state.budgets[index]),
                            );
                          },
                        ),
                      );
              } else if (state is BudgetError) {
                return Center(
                  child: Text(
                    state.message,
                    style: FontsHelper.mediumTextStyle(fontSize: 16),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _showAddBudgetDialog,
            backgroundColor: ColorsHelper.green,
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          /*  AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isListening ? 70 : 56,
            height: _isListening ? 70 : 56,
            child: FloatingActionButton(
              backgroundColor: _isListening ? Colors.red : ColorsHelper.green,
              onPressed: _isListening ? null : _startListening,
              child: const Icon(
                Icons.mic,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),*/
        ],
      ),
    );
  }
}

Widget TransactionCard(Transaction transaction, BuildContext context) {
  // final blocAccounts = context.read<ListaccountBloc>().add(LoadedListaccount());
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorsHelper.green,
            ColorsHelper.green.withOpacity(0.9),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      Flexible(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /*  Icon(
                              LucideIcons.calendar,
                              size: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),*/
                            const SizedBox(width: 4),
                            Text(
                              '${DateFormat('d MMM y').format(transaction.date!)} ${DateFormat('jm').format(transaction.date!)}',
                              style: FontsHelper.smallTextStyle(
                                fontSize: 12,
                                color: const Color.fromRGBO(255, 255, 255, 1)
                                    .withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${transaction.type} / ${transaction.category}",
                    style: FontsHelper.smallTextStyle(
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                transaction.type == "Transfer"
                    ? InfoTransfer(transaction)
                    : Row(
                        children: [
                          Icon(
                            getIcon(transaction.iconNameFromAccount!),
                            size: 20,
                            color: ColorsHelper.white,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(transaction.accountName!,
                              style: FontsHelper.boldTextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              )),
                        ],
                      ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Description : ",
                    style: FontsHelper.mediumTextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    )),
                const SizedBox(
                  width: 10,
                ),
                Text(transaction.description!,
                    style: FontsHelper.boldTextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    )),
              ],
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: ColorsHelper.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  transaction.type == "Transfer"
                      ? Text(
                          "${transaction.amount!} DT",
                          style: FontsHelper.boldTextStyle(
                              color: ColorsHelper.blue, fontSize: 16),
                        )
                      : transaction.type == "Expense"
                          ? Text(
                              "- ${transaction.amount!} DT",
                              style: FontsHelper.boldTextStyle(
                                  color: ColorsHelper.red, fontSize: 16),
                            )
                          : Text(
                              "+ ${transaction.amount!} DT",
                              style: FontsHelper.boldTextStyle(
                                  color: ColorsHelper.green, fontSize: 16),
                            ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class BudgetCard extends StatelessWidget {
  final Budget budget;

  const BudgetCard({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ColorsHelper.green,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  budget.name,
                  style: FontsHelper.boldTextStyle(
                      color: ColorsHelper.white, fontSize: 18),
                ),
                Text(
                  budget.category,
                  style: FontsHelper.mediumTextStyle(
                    fontSize: 14,
                    color: ColorsHelper.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: budget.progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                budget.progress < 0.8
                    ? ColorsHelper.blue
                    : budget.progress < 1.0
                        ? Colors.orange
                        : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spent: ${budget.spent.toStringAsFixed(2)} DT',
                  style: FontsHelper.smallTextStyle(
                      color: ColorsHelper.white, fontSize: 14),
                ),
                Text(
                  'Remaining: ${budget.remainingAmount.toStringAsFixed(2)} DT',
                  style: FontsHelper.smallTextStyle(
                      color: ColorsHelper.white, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${DateFormat('MMM dd').format(budget.startDate)} - ${DateFormat('MMM dd').format(budget.endDate)}',
              style: FontsHelper.smallTextStyle(
                fontSize: 12,
                color: ColorsHelper.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData getIcon(String type) {
  print(" get icon: $type");
  var icon;

  final List<Map<String, dynamic>> icons = [
    {'name': 'wallet', 'icon': LucideIcons.wallet},
    {'name': 'card', 'icon': LucideIcons.creditCard},
    {'name': 'cash', 'icon': LucideIcons.banknote},
    {'name': 'savings', 'icon': LucideIcons.piggyBank},
    {'name': 'bank', 'icon': LucideIcons.landmark},
  ];

  for (var iconData in icons) {
    if (iconData['name'] == type) {
      icon = iconData['icon'];
    }
  }

  return icon;
}

Widget InfoTransfer(Transaction transaction) {
  return Expanded(
    child: Row(
      children: [
        Icon(
          getIcon(transaction.iconNameFromAccount!),
          size: 20,
          color: ColorsHelper.white,
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Text(
            transaction.fromAccount!,
            style: FontsHelper.mediumTextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ),
        Icon(
          LucideIcons.arrowBigRightDash,
          size: 18,
          color: Colors.white.withOpacity(0.9),
        ),
        const SizedBox(
          width: 30,
        ),
        Icon(
          getIcon(transaction.iconNameToAccount!),
          size: 20,
          color: ColorsHelper.white,
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Text(
            transaction.toAccount!,
            style: FontsHelper.mediumTextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ),
      ],
    ),
  );
}
