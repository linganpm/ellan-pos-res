import 'package:flutter_bloc/flutter_bloc.dart';
import 'welcome_state.dart';

class WelcomeCubit extends Cubit<WelcomeState> {
  WelcomeCubit() : super(const WelcomeState());

  void organizationNameChanged(String name) {
    emit(state.copyWith(organizationName: name, clearError: true));
  }

  Future<void> submit() async {
    if (!state.isValid || state.isLoading) return;

    emit(state.copyWith(isLoading: true, clearError: true));

    // Simulate network request or initialization
    await Future.delayed(const Duration(seconds: 1));

    if (state.organizationName.toLowerCase() == 'magictaste') {
      emit(state.copyWith(isLoading: false, isSuccess: true));
    } else {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Invalid organization name',
      ));
    }
  }
}
