import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_orders_offline/pos_orders_offline.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos_tablet/core/controllers/ui_store_controller.dart';
import 'package:pos_tablet/core/di/service_locator.dart';
import 'sign_in_state.dart';

/// Cubit responsible for managing sign-in state and authentication logic.
/// Handles user credential validation, organization lookup from local storage,
/// and authentication with the organization's backend.
class SignInCubit extends Cubit<SignInState> {
  final SharedPreferences prefs;

  SignInCubit({required this.prefs}) : super(const SignInState());

  void identifierChanged(String value) {
    emit(state.copyWith(identifier: value, clearError: true));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(password: value, clearError: true));
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  /// Submits the sign-in credentials for authentication.
  ///
  /// Validates the identifier and password, retrieves the organization code
  /// from local storage, and attempts to authenticate the user with the
  /// organization's backend via the UI controller.
  ///
  /// Emits appropriate states for loading, success, and error conditions.
  Future<void> submit() async {
    if (state.isLoading) return;

    // Validate input fields
    if (!state.isValid) {
      emit(state.copyWith(errorMessage: 'Please fill in all fields'));
      return;
    }

    // Validate password constraints
    if (!state.isPasswordValid) {
      emit(
        state.copyWith(
          errorMessage: 'Password must be between 3 and 11 characters',
        ),
      );
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      // Retrieve the organization code from local storage
      // This was set during the welcome/organization setup flow
      final orgCode = prefs.getString('orgCode');

      if (orgCode == null || orgCode.isEmpty) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage:
                'No organization code found. Please complete the setup process first.',
          ),
        );
        return;
      }

      final controller = getIt<UiStoreController>();

      // Attempt to authenticate the user with the organization
      final loggedIn = await controller.loginToOrganisation(
        orgCode: orgCode,
        email: state.identifier,
        password: state.password,
      );

      if (!loggedIn) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage:
                'Invalid credentials. Please check your email and password.',
          ),
        );
        return;
      }

      // Persist login status and credentials for future reference
      await prefs.setString('userLoggedIn', 'Y');
      await prefs.setString('userEmail', state.identifier);
      await prefs.setString('userPassword', state.password);

      List<StoreAccessibleStore> stores = controller.accessibleStores();

      if (stores.isEmpty) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage:
                'No accessible stores found for this account. Please contact your administrator.',
          ),
        );
        return;
      } else if (stores.length == 1) {
        // If only one store is accessible, persist it as the selected store
        await prefs.setString('selectedStoreId', stores.first.store.storeId);
        // Emit success state to trigger navigation
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: true,
            clearError: true,
            navigateToHome: true,
          ),
        );
      } else {
        // Emit success state to trigger navigation
        emit(
          state.copyWith(isLoading: false, isSuccess: true, clearError: true),
        );
      }
    } catch (e, _) {
      // Include stack trace in logs for easier debugging
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Authentication failed. Error: ${e.toString()}',
        ),
      );
    }
  }
}
