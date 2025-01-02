part of 'analysis_bloc.dart';

sealed class AnalysisEvent extends Equatable {
  const AnalysisEvent();

  @override
  List<Object> get props => [];
}

class FetchAnalysisEvent extends AnalysisEvent {
  final String value;
  const FetchAnalysisEvent(this.value);
}

class LaunchAnalysisEvent extends AnalysisEvent {
  final String value;
  const LaunchAnalysisEvent([this.value = "Expenses"]);
}

class ChangeAnalysisEvent extends AnalysisEvent {
  final String value;
  const ChangeAnalysisEvent(this.value);
}
