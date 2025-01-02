import 'package:flutter_bloc/flutter_bloc.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashLoading()) {
    on<LoadSplash>((event, emit) async {
      // Simulate some initialization logic, e.g., checking authentication
      await Future.delayed(const Duration(seconds: 3));

      // Example logic: Check user authentication
      bool isAuthenticated = true;

      emit(SplashLoaded(isAuthenticated));
    });
  }

  // Mock authentication check (replace with real implementation)
  Future<bool> checkUserAuthentication() async {
    // Simulate authentication check (true = logged in, false = not logged in)
    return false; // Replace with actual logic
  }
}
