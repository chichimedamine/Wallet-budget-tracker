import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import the services package
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallet_budget_tracker/Model/Account.dart';
import 'package:wallet_budget_tracker/bloc/budget/budget_bloc.dart';
import 'package:wallet_budget_tracker/bloc/listaccount/listaccount_bloc.dart';
import 'package:wallet_budget_tracker/bloc/transaction/transaction_bloc.dart';
import 'package:wallet_budget_tracker/hive/hive_registrar.g.dart';
import 'package:wallet_budget_tracker/views/splashscreen.dart';

import 'helper/notification.dart';

void main() async {
  // Ensure that plugin services are initialized before calling runApp
  WidgetsFlutterBinding.ensureInitialized();
   
  
  // Initialize notifications
  final notificationController = LocalNotificationController();
  

 
  // Set the system UI overlay style to hide the status bar
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom]);
  final directory = await getApplicationDocumentsDirectory();

  Hive
    ..init(directory.path)
    ..registerAdapters();

  // Initialize boxes
  await Hive.openBox('transaction');
  await Hive.openBox('df');
  await Hive.openBox<Account>('account');

  firstopen();
  //add request permission microphone

  runApp(const MyApp());
}


void firstopen() async {
  List name = ['Card', 'Cash', "Saving"];
  List iconname = ['wallet', 'card', 'cash', 'savings', 'bank'];
  Account result;
  final df = await Hive.openBox('df');
  final db = await Hive.openBox('db');
  if (df.get("is_first") == true) {
  } else {
    df.put("is_first", true);
    for (var i = 0; i < 3; i++) {
      if (name[i] == "Card") {
        final account = Account(
            name: name[i],
            balance: 0.00,
            currency: "DT",
            iconName: iconname[1]);
        result = account;
      } else if (name[i] == "Cash") {
        final account = Account(
            name: name[i],
            balance: 0.00,
            currency: "DT",
            iconName: iconname[2]);
        result = account;
      } else {
        final account = Account(
            name: name[i],
            balance: 0.00,
            currency: "DT",
            iconName: iconname[3]);
        result = account;
      }

      await db.add(result);
    }
  }
  final List<Account> listaccount = db.values.map((e) => e as Account).toList();
  //print("data account: ${listaccount[0].name}");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => ListaccountBloc()..add(LoadedListaccount())),
        BlocProvider(create: (context) => BudgetBloc()),
        BlocProvider(
            create: (context) => TransactionBloc()..add(LoaddataEvent())),
      
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Wallet Budget Tracker',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
