part of 'budget_bloc.dart';

abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object> get props => [];
}

class LoadBudgets extends BudgetEvent {}

class AddBudget extends BudgetEvent {
  final Budget budget;

  const AddBudget(this.budget);

  @override
  List<Object> get props => [budget];
}

class UpdateBudget extends BudgetEvent {
  final Budget budget;
  final int index;

  const UpdateBudget(this.budget, this.index);

  @override
  List<Object> get props => [budget, index];
}

class DeleteBudget extends BudgetEvent {
  final int index;

  const DeleteBudget(this.index);

  @override
  List<Object> get props => [index];
}
