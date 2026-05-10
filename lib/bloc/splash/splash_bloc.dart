import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_orders_offline/store.dart';
import 'package:pos_orders_offline/store_config.dart';
import 'package:pos_orders_offline/store_models.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<SplashStarted>(_onSplashStarted);
  }

  StoreConfig? _config;
  StoreOrganisation? _organisation;
  StoreOrganisationLoginResult? _organisationLogin;
  StoreOrganisationBootstrapSyncResult? _bootstrap;
  StoreDeviceRegistrationRequest? _deviceRegistration;
  Store? _store;

  Future<void> _onSplashStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    emit(SplashLoading());
    boot(environment: StoreEnvironment.development);
    if(_config == null){
      print("Config Initialized as fail");
    }else{
      print("Config Initialized as success");
    }

    // Simulate initialization delay like fetching config, etc.
    await Future.delayed(const Duration(seconds: 3));
    emit(SplashCompleted());
  }

  Future<void> boot({
    StoreEnvironment environment = StoreEnvironment.development,
  }) async {
    _config = await StoreConfig.loadForEnvironment(environment);
  }

  Future<void> bootWithConfig(StoreConfig config) async {
    _config = config;
  }
}
