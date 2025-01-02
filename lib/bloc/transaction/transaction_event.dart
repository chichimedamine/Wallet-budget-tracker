part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object> get props => [];
}

class TransactionEventAdd extends TransactionEvent {
  final Transaction transaction;
  final String fromAccount;
  final String toAccount;

  const TransactionEventAdd(
      {required this.transaction,
      required this.fromAccount,
      required this.toAccount});

  @override
  List<Object> get props => [transaction];
}

class LoaddataEvent extends TransactionEvent {}

class TransactionEventRefresh extends TransactionEvent {}

class TransactionEventDelete extends TransactionEvent {
  final int index;

  final Transaction transaction;
  const TransactionEventDelete({required this.transaction , required this.index});  
}

class TransactionEventClearAll extends TransactionEvent {}
