part of 'listaccount_bloc.dart';

sealed class ListaccountEvent extends Equatable {
  const ListaccountEvent();

  @override
  List<Object> get props => [];
}

class LoadedListaccount extends ListaccountEvent {}

class LoadingListaccount extends ListaccountEvent {}

class RefreshListaccount extends ListaccountEvent {}

class DeleteAccount extends ListaccountEvent {
  final Account account;
  final int index;

  const DeleteAccount(this.account, this.index);
}

class EditAccount extends ListaccountEvent {
  final Account account;
  final int index;

  const EditAccount(this.account, this.index);
}
