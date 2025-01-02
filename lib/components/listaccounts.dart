import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../Model/Account.dart';
import '../bloc/listaccount/listaccount_bloc.dart';
import '../helper/colors.dart';
import '../helper/fonts.dart';

class Listaccounts extends StatefulWidget {
  const Listaccounts({super.key});

  @override
  State<Listaccounts> createState() => _ListaccountsState();
}

class _ListaccountsState extends State<Listaccounts> {
  String selectedIcon = 'wallet';

  void _handleMenuClick(
      String value, Account account, BuildContext context, int index) {
    switch (value) {
      case 'edit':
        _showEditAccountDialog(
            context, account, index); // TODO: Implement edit functionality
        break;
      case 'delete':
        _showDeleteConfirmation(context, account, index);
        break;
    }
  }

  Widget _buildIconSelector(
    StateSetter setState,
  ) {
    final List<Map<String, dynamic>> icons = [
      {'name': 'wallet', 'icon': LucideIcons.wallet},
      {'name': 'card', 'icon': LucideIcons.creditCard},
      {'name': 'cash', 'icon': LucideIcons.banknote},
      {'name': 'savings', 'icon': LucideIcons.piggyBank},
      {'name': 'bank', 'icon': LucideIcons.landmark},
    ];
    //   print(selectedIcon);

    return Wrap(
      spacing: 10,
      children: icons.map((iconData) {
        final bool isSelected = selectedIcon == iconData['name'];
        return InkWell(
          onTap: () {
            setState(() {
              selectedIcon = iconData['name'];
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

  void _showEditAccountDialog(
      BuildContext context, Account account, int index) {
    final TextEditingController nameController =
        TextEditingController(text: account.name);
    final TextEditingController amountController =
        TextEditingController(text: account.balance.toString());
    selectedIcon = account.iconName; // Set initial icon
    final bloc =
        context.read<ListaccountBloc>(); // Get bloc reference before dialog

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
                  'Edit Existing Account',
                  style: FontsHelper.boldTextStyle(
                      color: ColorsHelper.white, fontSize: 20),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        labelText: 'Name',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: amountController,
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
                    _buildIconSelector(
                      setState,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                TextButton(
                  child:
                      const Text('Save', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    setState(() {
                      if (amountController.text.isEmpty) {
                        amountController.text = "0.0";
                      }
                    });
                    Account updatedAccount = Account(
                      name: nameController.text,
                      balance: double.parse(amountController.text ?? "0.0"),
                      currency: "DT",
                      iconName: selectedIcon,
                    );

                    bloc.add(EditAccount(updatedAccount, index));

                    Navigator.of(dialogContext).pop();
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Account updated successfully'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, Account account, int index) {
    final bloc = context.read<ListaccountBloc>();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Delete ${account.name}?'),
          content: const Text(
              'Are you sure you want to delete this account? This action cannot be undone.'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                bloc.add(DeleteAccount(account, index));
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${account.name} has been deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Icon _getAccountIcon(String iconName) {
    switch (iconName) {
      case 'card':
        return const Icon(LucideIcons.creditCard, color: ColorsHelper.white);
      case 'cash':
        return const Icon(LucideIcons.banknote, color: ColorsHelper.white);
      case 'savings':
        return const Icon(LucideIcons.piggyBank, color: ColorsHelper.white);
      case 'bank':
        return const Icon(LucideIcons.landmark, color: ColorsHelper.white);
      case 'wallet':
      default:
        return const Icon(LucideIcons.wallet, color: ColorsHelper.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ListaccountBloc>().state;
    if (state is! ListaccountLoaded) {
      return const SizedBox.shrink();
    }

    final accounts = state.accounts;

    return ListView.builder(
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.all(10),
      shrinkWrap: true,
      itemCount: accounts.length,
      itemBuilder: (BuildContext context, int index) {
        final account = accounts[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: ColorsHelper.green,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColorsHelper.white),
            ),
            child: ListTile(
              trailing: PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_horiz,
                  color: ColorsHelper.white,
                ),
                onSelected: (String value) =>
                    _handleMenuClick(value, account, context, index),
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: ColorsHelper.green),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
              title: Text(
                account.name,
                style: FontsHelper.boldTextStyle(
                    color: ColorsHelper.white, fontSize: 20),
              ),
              subtitle: Text(
                "Balance: ${account.balance} ${account.currency}",
                style: FontsHelper.smallTextStyle(
                    color: ColorsHelper.white, fontSize: 30),
              ),
              leading: _getAccountIcon(account.iconName),
            ),
          ),
        );
      },
    );
  }
}
