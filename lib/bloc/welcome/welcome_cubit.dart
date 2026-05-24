import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_orders_offline/store.dart';
import 'package:pos_orders_offline/store_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos_tablet/core/controllers/ui_store_controller.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import '../../core/di/service_locator.dart';
import 'welcome_state.dart';
import 'package:pos_tablet/core/constants/discovery_constants.dart';

/// Cubit responsible for managing welcome screen state and organization setup.
/// Handles organization code validation, remote config fetching, and device info collection.
class WelcomeCubit extends Cubit<WelcomeState> {
  final SharedPreferences prefs;

  WelcomeCubit({
    required this.prefs,
  }) : super(const WelcomeState());

  void organizationNameChanged(String name) {
    emit(state.copyWith(organizationName: name, clearError: true));
  }

  /// Collects device information using device_info_plus and persists selected
  /// fields to SharedPreferences. Keys used:
  /// - 'deviceMake'
  /// - 'deviceModel'
  /// - 'deviceId'
  ///
  /// This method is defensive: it catches and logs errors to avoid failing
  /// the entire setup flow when device info cannot be retrieved.
  Future<void> _collectAndStoreDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      String make = '';
      String model = '';
      String deviceId = '';

      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        make = info.manufacturer ?? '';
        model = info.model ?? '';
        deviceId = info.id;
      } else if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        make = info.name ?? '';
        model = info.model ?? '';
        deviceId = info.identifierForVendor ?? '';
      } else {
        // Fallback for other platforms
        try {
          final info = await deviceInfo.deviceInfo;
          final infoMap = info.data;
          model = infoMap.toString();
        } catch (_) {
          model = 'unknown';
        }
        make = 'unknown';
        deviceId = '';
      }

      await prefs.setString('deviceMake', make);
      await prefs.setString('deviceModel', model);
      await prefs.setString('deviceId', deviceId);
    } catch (e) {
      print('Failed to collect device info: $e');
    }
  }

  /// Submits the organization code for validation and configuration setup.
  /// Fetches remote config, persists the org code, boots the UI controller,
  /// and collects device information before emitting success state.
  ///
  /// Emits error states if organization is not found or if any step fails.
  Future<void> submit() async {
    if (!state.isValid || state.isLoading) return;

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      // Use centralized discovery URL constant
      // Resolve organization by code from remote discovery service
      final organisation = await Store.resolveOrganisationByCodeFromUrl(
        state.organizationName.toLowerCase(),
        lookupUrl: kDiscoveryUrl,
      );

      if (organisation == null) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Organisation code "${state.organizationName}" was not found. Please check and try again.',
        ));
        return;
      }

      // Load remote configuration for the resolved organization
      final remoteConfig = await StoreConfig.loadRemoteForOrganisation(
        orgCode: organisation.orgCode,
        lookupUrl: kDiscoveryUrl,
      );



      // Persist the resolved orgCode for future cold starts
      await prefs.setString('orgCode', organisation.orgCode);

      final controller = getIt<UiStoreController>();


      // Boot the UI controller with the remote configuration
      await controller.bootWithConfig(remoteConfig);

      final bootstrap = await controller.syncOrganisationBootstrap(organisation.orgCode);

      // Collect and store device information for analytics/identification
      await _collectAndStoreDeviceInfo();

      final deviceStatus = await controller.registerDevice(
        deviceId: 'ui-example-device-001',
        make: 'Linux',
        model: 'UI Example',
        lat: 0,
        lan: 0,

      );

      // Emit success state to trigger navigation
      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
        clearError: true,
      ));
    } catch (e, st) {
      // Include stack trace in logs for easier debugging
      print('WelcomeCubit::submit error: $e\n$st');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to set up organization. Error: ${e.toString()}',
      ));
    }
  }
}
