import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import '../../Model/Budget.dart';
import '../../helper/notification.dart';

part 'budget_event.dart';
part 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  BudgetBloc() : super(BudgetInitial()) {
    on<LoadBudgets>((event, emit) async {
      try {
        emit(BudgetLoading());
        final box = await Hive.openBox<Budget>('budgets');
        final transction = await Hive.openBox('transaction');
        final db = await Hive.openBox('db');

        final budgets = box.values.toList();
        final transctionData = transction.values.toList();
        double totalspend = 0;
        for (var i = 0; i < transctionData.length; i++) {
          final transaction = transctionData[i];
          if (transaction.type == "Expense") {
            for (var j = 0; j < budgets.length; j++) {
              if (budgets[j].category == transaction.category) {
                print("www spent: ${budgets[j].spent}");
                totalspend = 0;
                totalspend += double.parse(transaction.amount ?? "0");
                print("totalspend: $totalspend");
                if (budgets[j].spent != totalspend) {
                  budgets[j].spent = totalspend;
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
                } else if (budgets[j].spent > (budgets[j].amount * 0.6) &&
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

            //   box.clear();
          }
        }
        emit(BudgetLoaded(budgets));
      } catch (e) {
        emit(const BudgetError('Failed to load budgets'));
      }
    });

    on<AddBudget>((event, emit) async {
      try {
        final box = await Hive.openBox<Budget>('budgets');
        await box.add(event.budget);
        final budgets = box.values.toList();
        emit(BudgetLoaded(budgets));
      } catch (e) {
        emit(const BudgetError('Failed to add budget'));
      }
    });

    on<UpdateBudget>((event, emit) async {
      try {
        final box = await Hive.openBox<Budget>('budgets');
        await box.putAt(event.index, event.budget);
        final budgets = box.values.toList();
        emit(BudgetLoaded(budgets));
      } catch (e) {
        emit(const BudgetError('Failed to update budget'));
      }
    });

    on<DeleteBudget>((event, emit) async {
      try {
        final box = await Hive.openBox<Budget>('budgets');
        await box.deleteAt(event.index);
        final budgets = box.values.toList();
        emit(BudgetLoaded(budgets));
      } catch (e) {
        emit(const BudgetError('Failed to delete budget'));
      }
    });
  }
}
