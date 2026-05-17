import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_orders_offline/store.dart';
import 'package:pos_orders_offline/store_config.dart';
import 'package:pos_tablet/core/controllers/ui_store_controller.dart';
import 'package:pos_tablet/core/di/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import '../../core/constants/discovery_constants.dart';
import 'user_event.dart';
import 'user_state.dart';

/// BLoC responsible for managing user-related state and business logic.
/// Handles initialization of user and store configuration during app launch.
class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<UserInitializeEvent>(_onUserInitialize);
  }

  /// Handles the UserInitializeEvent by performing the initialization logic.
  /// Emits UserLoading, then UserLoaded on success or UserError on failure.
  Future<void> _onUserInitialize(
    UserInitializeEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      // Obtain shared preferences and the global controller from the service
      // locator which is initialized during app startup.
      final prefs = getIt<SharedPreferences>();

      // If an org code has been stored previously, prefer the local value and
      // try to restore the previously saved StoreConfig (if present). This
      // speeds up app start and avoids a network call.
      final storedOrgCode = prefs.getString('orgCode');
      final controller = getIt<UiStoreController>();

      if (storedOrgCode != null && storedOrgCode.isNotEmpty) {
        // Load remote configuration for the resolved organization
        final remoteConfig = await StoreConfig.loadRemoteForOrganisation(
          orgCode: storedOrgCode,
          lookupUrl: kDiscoveryUrl,
        );
        // Boot the UI controller with the remote configuration
        await controller.bootWithConfig(remoteConfig);
        // Try to restore stored config JSON first
        final selectedStoreId = prefs.getString('selectedStoreId');

        if (selectedStoreId != null && selectedStoreId.isNotEmpty && false) {
          final userEmail = prefs.getString('userEmail');
          final userPassword = prefs.getString('userPassword');
          if (userEmail == null || userPassword == null) {
            emit(
              UserError(
                "No stored user credentials found. Please perform initial setup to fetch the latest configuration.",
              ),
            );
            return;
          }
          final isLoggedIn = await controller.loginToOrganisation(
            orgCode: storedOrgCode,
            email: userEmail,
            password: userPassword,
          );
          if (isLoggedIn) {
            // Collect device info for registration
            final deviceInfo = DeviceInfoPlugin();
            String make = prefs.getString('deviceMake') ?? 'unknown';
            String model = prefs.getString('deviceModel') ?? 'unknown';
            String deviceId = prefs.getString('deviceId') ?? '';

            // final deviceStatus = await controller.registerDevice(
            //   deviceId: deviceId,
            //   make: make,
            //   model: model,
            // );
            final deviceStatus = await controller.registerDevice(
              deviceId: 'ui-example-device-001',
              make: 'Linux',
              model: 'UI Example',
              lat: 0,
              lan: 0,

            );
            print("SelectedStoreId: $selectedStoreId");

            await controller.openStore(selectedStoreId);
            // In a real app, call this when connectivity resumes or before starting sync.
            await controller.refreshAccessControl();

            final storeAccess = await controller.currentStoreAccess();
            if (storeAccess == null || !storeAccess.accessEnabled) {
              throw StateError('Customer does not have access to the selected store.');
            }

            final session = await controller.currentSession();
            print("Session info: ${session?.loginAt}, expires at ${session?.role}");
            emit(UserLoaded(selectedStoreId));
          } else {
            emit(
              UserError(
                "Failed to log in with stored credentials. Please verify your credentials or perform initial setup to fetch the latest configuration.",
              ),
            );
            return;
          }
        } else {
          emit(
            UserError(
              "No stored configuration found for organisation code '$storedOrgCode'. Please perform initial setup to fetch the latest configuration.",
            ),
          );
          return;
        }
      } else {
        emit(
          UserError(
            "No stored organisation code found. Please perform initial setup.",
          ),
        );
        return;
      }
    } catch (e, st) {
      // Include stack trace in logs for easier debugging in CI or local dev.
      // Do not leak stack trace into the UserError message returned to the UI.
      print('UserBloc::_onUserInitialize error: $e\n$st');
      emit(UserError(e.toString()));
    }
  }
}
