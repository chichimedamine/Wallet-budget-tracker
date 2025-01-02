part of 'transaction_bloc.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionSuccess extends TransactionState {}

class TransactionRefresh extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<Transaction> listtransaction;

  const TransactionLoaded({required this.listtransaction});

  @override
  List<Object> get props => [listtransaction];
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError({required this.message});

  @override
  List<Object> get props => [message];
}
