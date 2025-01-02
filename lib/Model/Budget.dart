import 'package:hive_ce/hive.dart';


class Budget extends HiveObject {

  String name;

 
  double amount;


  double spent;

  String category;

  DateTime startDate;


  DateTime endDate;

  Budget({
    required this.name,
    required this.amount,
    this.spent = 0.0,
    required this.category,
    required this.startDate,
    required this.endDate,
  });

  double get remainingAmount => amount - spent;
  double get progress => (spent / amount).clamp(0.0, 1.0);
}
