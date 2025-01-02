import 'package:hive_ce/hive.dart';

class Transaction extends HiveObject {
  String? type;
  String? accountName;
  String? amount;
  DateTime? date;
  String? category;
  String? description;
  String? fromAccount;
  String? toAccount;
  String? iconNameFromAccount;
  String? iconNameToAccount;

  Transaction(
      {this.type,
      this.accountName,
      this.amount,
      this.date,
      this.category,
      this.description,
      this.fromAccount,
      this.toAccount,
      this.iconNameFromAccount,
      this.iconNameToAccount});
}
