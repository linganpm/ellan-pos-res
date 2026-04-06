import 'package:flutter_bloc/flutter_bloc.dart';
import 'sign_in_state.dart';

class SignInCubit extends Cubit<SignInState> {
  SignInCubit() : super(const SignInState());

  void identifierChanged(String value) {
    emit(state.copyWith(identifier: value, clearError: true));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(password: value, clearError: true));
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  Future<void> submit() async {
    if (state.isLoading) return;

    if (!state.isValid) {
      emit(state.copyWith(
        errorMessage: 'Please fill in all fields',
      ));
      return;
    }

    if (!state.isPasswordValid) {
      emit(state.copyWith(
        errorMessage: 'Password must be between 3 and 11 characters',
      ));
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));

    // Simulate network request
    await Future.delayed(const Duration(seconds: 1));

    // For now we just succeed immediately if validation passes
    emit(state.copyWith(isLoading: false, isSuccess: true));
  }
}
