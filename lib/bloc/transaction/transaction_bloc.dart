import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import 'package:wallet_budget_tracker/Model/Transaction.dart';

import '../../Model/Account.dart';
import '../../Model/Budget.dart';
import '../../helper/notification.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc() : super(TransactionInitial()) {
    on<TransactionEventAdd>((event, emit) async {
      try {
        print("test bloc");
        final transctionData = await Hive.openBox('transaction');
        final db = await Hive.openBox('db');

        // Retrieve all values from the box and convert them to a list
        final List<Account> listaccount =
            db.values.map((e) => e as Account).toList();

        print("test bloc 2 ${event.transaction.type}");
        if (event.transaction.type == "Expense") {
          for (var i = 0; i < listaccount.length; i++) {
            if (listaccount[i].name == event.transaction.accountName) {
              listaccount[i].balance = listaccount[i].balance -
                  double.parse(event.transaction.amount!);
              await db.put(listaccount[i].key, listaccount[i]);
            }
          }
          print("data account: ${listaccount[0].balance}");
        } else if (event.transaction.type == "Income") {
          print("test income");

          print("test for${listaccount.length}");

          if (listaccount.isNotEmpty) {
            print("test for 3");
            for (var i = 0; i < listaccount.length; i++) {
              print("test 2");
              if (listaccount[i].name == event.transaction.accountName) {
                listaccount[i].balance = listaccount[i].balance +
                    double.parse(event.transaction.amount!);
                await db.putAt(i, listaccount[i]);
                print("data account in boucle: ${listaccount[i].balance}");
              }

              print("data account: ${listaccount[0].balance}");
            }
          }
        } else {
          print(
              "test transfer ${event.fromAccount} , ${event.toAccount} ,${listaccount.length}");
          for (var i = 0; i < listaccount.length; i++) {
            if (listaccount[i].name == event.fromAccount) {
              listaccount[i].balance = listaccount[i].balance -
                  double.parse(event.transaction.amount!);
              print("data account in boucle: ${listaccount[i].balance}");
              await db.putAt(i, listaccount[i]);
            }
            if (listaccount[i].name == event.toAccount) {
              listaccount[i].balance = listaccount[i].balance +
                  double.parse(event.transaction.amount!);
              await db.putAt(i, listaccount[i]);
            }
          }
          print("data account test transfer");
        }
        await transctionData.add(event.transaction);
        final box = await Hive.openBox<Budget>('budgets');

        final budgets = box.values.toList();
        final transctions = transctionData.values.toList();
        double totalSpent = 0;
////////////////////////////////
        ///
        for (var i = 0; i < transctions.length; i++) {
          final transaction = transctions[i];
          if (transaction.type == "Expense") {
            for (var j = 0; j < budgets.length; j++) {
              if (budgets[j].category == transaction.category) {
                 totalSpent = 0;
                totalSpent += double.parse(transaction.amount ?? "0");
                if (budgets[j].spent != totalSpent) {
                  budgets[j].spent = totalSpent;
                }
               

                box.putAt(j, budgets[j]);
                print("spent: ${budgets[j].spent}");
                if (budgets[j].spent > budgets[j].amount) {
                  LocalNotificationController().showNotification(
                    id: 1,
                    title: 'Notification',
                    body:
                        'You have exceeded your budget for ${budgets[j].category}',
                    payload: budgets[j].category,
                  );
                }
                if (budgets[j].spent > (budgets[j].amount * 0.6) &&
                    budgets[j].spent < budgets[j].amount) {
                  LocalNotificationController().showNotification(
                    id: 1,
                    title: 'Notification',
                    body:
                        'You are close to exceeding your budget for ${budgets[j].category}',
                    payload: budgets[j].category,
                  );
                }
              }
            }
          }
        }

//////////////////////////////
        emit(TransactionSuccess());
        // Add refresh after successful add
        emit(TransactionRefresh());
        add(LoaddataEvent());
      } catch (e) {
        emit(TransactionError(message: e.toString()));
      }
    });

    on<TransactionEventDelete>((event, emit) async {
      try {
        final transctionData = await Hive.openBox('transaction');
        await transctionData.deleteAt(event.index);
        emit(TransactionSuccess());
        // Add refresh after successful delete
        emit(TransactionRefresh());
        add(LoaddataEvent());
      } catch (e) {
        emit(TransactionError(message: e.toString()));
      }
    });

    on<TransactionEventClearAll>((event, emit) async {
      try {
        final transactionData = await Hive.openBox('transaction');
        await transactionData.clear();

        emit(TransactionRefresh());
        add(LoaddataEvent());
      } catch (e) {
        emit(TransactionError(message: e.toString()));
      }
    });

    on<TransactionEventRefresh>((event, emit) async {
      try {
        emit(TransactionRefresh());
      } catch (e) {
        emit(TransactionError(message: e.toString()));
      }
    });

    on<LoaddataEvent>((event, emit) async {
      try {
        emit(TransactionLoading());
        // Open the Hive box
        final transctionData = await Hive.openBox('transaction');

        // Retrieve all values from the box and convert them to a list
        final List<Transaction> listtransaction =
            transctionData.values.map((e) => e as Transaction).toList();

        // Emit the loaded state with the list of accounts
        emit(TransactionLoaded(listtransaction: listtransaction));
      } catch (e) {
        emit(TransactionError(message: e.toString()));
      }
    });
  }
}
