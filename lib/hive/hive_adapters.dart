import 'package:hive_ce/hive.dart';
import '../Model/Account.dart';
import '../Model/Budget.dart';
import '../Model/Transaction.dart';

part 'hive_adapters.g.dart';

@GenerateAdapters([AdapterSpec<Account>(), AdapterSpec<Budget>(), AdapterSpec<Transaction>()])
// Annotations must be on some element
// ignore: unused_element
void _() {}