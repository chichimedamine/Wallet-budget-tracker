import 'package:hive_ce/hive.dart';


class Account extends HiveObject {


  String name;

  double balance;


  String currency;

  String iconName;

  Account({
    required this.name, 
    required this.balance, 
    required this.currency,
    this.iconName = 'wallet', // default icon
  });

  @override
  String toString() {
    return 'Account(name: $name, balance: $balance, currency: $currency, iconName: $iconName)';
  }
}
