import 'package:equatable/equatable.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object> get props => [];
}

class SplashLoading extends SplashState {}

class SplashLoaded extends SplashState {
  final bool isAuthenticated; // Determines next screen

  const SplashLoaded(this.isAuthenticated);

  @override
  List<Object> get props => [isAuthenticated];
}
