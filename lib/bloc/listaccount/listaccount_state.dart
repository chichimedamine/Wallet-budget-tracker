part of 'listaccount_bloc.dart';

sealed class ListaccountState extends Equatable {
  const ListaccountState();

  @override
  List<Object> get props => [];
}

final class ListaccountLoaded extends ListaccountState {
  final List<Account> accounts;
  final bool isloaded;
  const ListaccountLoaded(this.accounts, this.isloaded);
  @override
  List<Object> get props => [accounts, isloaded];
}

final class ListaccountLoading extends ListaccountState {}

final class ListaccountEdit extends ListaccountState {
  final List<Account> accounts;
  final int index;
  const ListaccountEdit({required this.index, required this.accounts});
}

final class ListaccountError extends ListaccountState {}

final class ListaccountRefresh extends ListaccountState {
  final bool isRefreshing;

  const ListaccountRefresh({this.isRefreshing = true});
}
