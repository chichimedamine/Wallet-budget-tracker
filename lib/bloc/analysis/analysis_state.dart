part of 'analysis_bloc.dart';

sealed class AnalysisState extends Equatable {
  const AnalysisState();

  @override
  List<Object> get props => [];
}

final class AnalysisInitial extends AnalysisState {}

final class AnalysisLoading extends AnalysisState {}

final class AnalysisLoaded extends AnalysisState {
  final String selectedValue;
  final Map<String, double> dataMapExpense;
  final Map<String, double> dataMapIncome;
  final Map<String, List> expensesData;
  final Map<String, List> incomesData;
  const AnalysisLoaded({
    required this.selectedValue,

    required this.dataMapExpense,
    required this.dataMapIncome,
    required this.expensesData,
    required this.incomesData,
   
  });
}

final class AnalysisError extends AnalysisState {}

final class AnalysisEmpty extends AnalysisState {
  final String selectedValue;
  const AnalysisEmpty({required this.selectedValue});
}

final class AnalysisSuccess extends AnalysisState {}
