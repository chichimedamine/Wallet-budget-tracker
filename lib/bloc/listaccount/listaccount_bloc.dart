import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';

import '../../Model/Account.dart';

part 'listaccount_event.dart';
part 'listaccount_state.dart';

class ListaccountBloc extends Bloc<ListaccountEvent, ListaccountState> {
  ListaccountBloc() : super(ListaccountLoading()) {
    on<LoadedListaccount>((event, emit) async {
      try {
        // Open the Hive box
        final db = await Hive.openBox('db');

        // Retrieve all values from the box and convert them to a list
        final List<Account> listaccount =
            db.values.map((e) => e as Account).toList();
        bool isloaded = true;

        // Emit the loaded state with the list of accounts
        emit(ListaccountLoaded(listaccount, isloaded));
      } catch (e) {
        emit(ListaccountError());
      }
    });

    on<RefreshListaccount>((event, emit) async {
      try {
        emit(const ListaccountRefresh());

        // Open the Hive box
        final db = await Hive.openBox('db');

        // Retrieve all values from the box and convert them to a list
        final List<Account> listaccount =
            db.values.map((e) => e as Account).toList();
        bool isloaded = true;

        // Emit the loaded state with the list of accounts
        emit(ListaccountLoaded(listaccount, isloaded));
      } catch (e) {
        emit(ListaccountError());
      }
    });

    on<DeleteAccount>((event, emit) async {
      try {
        emit(const ListaccountRefresh());

        // Open the Hive box
        final db = await Hive.openBox('db');

        // Delete the account at the specified index
        await db.deleteAt(event.index);

        // Retrieve updated list
        final List<Account> listaccount =
            db.values.map((e) => e as Account).toList();
        bool isloaded = true;

        // Emit the loaded state with the updated list
        emit(ListaccountLoaded(listaccount, isloaded));
      } catch (e) {
        emit(ListaccountError());
      }
    });

    on<EditAccount>((event, emit) async {
      try {
        emit(const ListaccountRefresh());

        // Open the Hive box
        final db = await Hive.openBox('db');

        // Update the account at the specified index
        await db.putAt(event.index, event.account);

        // Retrieve updated list
        final List<Account> listaccount =
            db.values.map((e) => e as Account).toList();
        bool isloaded = true;

        // Emit the loaded state with the updated list
        emit(ListaccountEdit(
          index: event.index,
          accounts: listaccount,
        ));

        emit(ListaccountLoaded(listaccount, isloaded));
      } catch (e) {
        emit(ListaccountError());
      }
    });
  }
}
