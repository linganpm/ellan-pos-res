import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:pos_orders_offline/sqflite_ffi_io.dart';
import 'package:pos_orders_offline/store.dart';
import 'package:pos_orders_offline/store_config.dart';
import 'package:pos_orders_offline/store_models.dart';

class UiStoreController {

  static const String developmentAssetPath =
      'config/store_config.dev.json';
  static const String testAssetPath = 'config/store_config.test.json';
  static const String productionAssetPath =
      'config/store_config.production.json';

  StoreConfig? _config;
  StoreOrganisation? _organisation;
  StoreOrganisationLoginResult? _organisationLogin;
  StoreOrganisationBootstrapSyncResult? _bootstrap;
  StoreDeviceRegistrationRequest? _deviceRegistration;
  Store? _store;



  Store? get store => _store;
  StoreOrganisation? get organisation => _organisation;
  StoreOrganisationLoginResult? get organisationLogin => _organisationLogin;
  StoreOrganisationBootstrapSyncResult? get bootstrap => _bootstrap;

  Future<void> boot({
    StoreEnvironment environment = StoreEnvironment.development,
  }) async {
    _config = await loadForEnvironment(environment);
  }

  Future<void> bootWithConfig(StoreConfig config) async {
    _config = config;
  }


  Future<StoreConfig> loadFromFile([
    String filePath = developmentAssetPath,
  ]) async {
    final content = await rootBundle.loadString(filePath);
    final json = jsonDecode(content) as Map<String, dynamic>;
    return StoreConfig.fromJson(json);
  }

  Future<StoreConfig> loadForEnvironment(StoreEnvironment environment) {
    return loadFromFile(assetPathForEnvironment(environment));
  }

  String assetPathForEnvironment(StoreEnvironment environment) {
    switch (environment) {
      case StoreEnvironment.development:
        return developmentAssetPath;
      case StoreEnvironment.test:
        return testAssetPath;
      case StoreEnvironment.production:
        return productionAssetPath;
    }
  }

  Future<StoreOrganisation?> resolveOrganisation(String orgCode) async {
    final config = _requireConfig();
    final organisation = await Store.resolveOrganisationByCode(
      orgCode,
      config: config,
    );
    _organisation = organisation;
    return organisation;
  }

  Future<StoreOrganisationBootstrapSyncResult?> syncOrganisationBootstrap(String orgCode) async {
    final config = _requireConfig();
    final bootstrap = await Store.syncOrganisationBootstrap(
      orgCode: orgCode,
      config: config,
    );
    _bootstrap = bootstrap;
    _organisation = bootstrap?.organisation;
    return bootstrap;
  }

  Future<bool> loginToOrganisation({
    required String orgCode,
    required String email,
    required String password,
  }) async {
    final config = _requireConfig();
    final login = await Store.loginToOrganisation(
      orgCode: orgCode,
      email: email,
      password: password,
      config: config,
    );
    _organisationLogin = login;
    _organisation = login?.organisation;
    return login != null;
  }

  List<StoreAccessibleStore> accessibleStores() {
    return _organisationLogin?.accessibleStores ?? const [];
  }

  Future<StoreDeviceRegistrationResult?> registerDevice({
    required String deviceId,
    required String make,
    required String model,
    double? lat,
    double? lan,
  }) async {
    final config = _requireConfig();
    final organisation = _requireOrganisation();
    final request = StoreDeviceRegistrationRequest(
      deviceId: deviceId,
      make: make,
      model: model,
      lat: lat,
      lan: lan,
    );
    _deviceRegistration = request;
    final result = await Store.registerDeviceForOrganisation(
      orgId: organisation.orgId,
      request: request,
      config: config,
    );
    return result;
  }


  Future<void> openStore(String storeId) async {
    final config = _requireConfig();
    final login = _requireOrganisationLogin();
    final deviceRegistration = _requireDeviceRegistration();
    final databasePath = await databaseFactory.getDatabasesPath();

    final existingStore = _store;
    if (existingStore == null) {
      _store = await Store.openAccessibleStore(
        login: login,
        storeId: storeId,
        deviceRegistration: deviceRegistration,
        config: config,
        databasePath: databasePath
      );
    } else {
      _store = await existingStore.switchAccessibleStore(
        login: login,
        storeId: storeId,
        deviceRegistration: deviceRegistration,
      );
    }
    if(_store == null) {
      throw StateError('Failed to open store with ID $storeId');
    }else{
      print('Opened store: ${_store!.storeName} (ID: ${_store!.scope.storeId})');
    }

    if (_store!.sync.autoSyncEnabled) {
      _store!.sync.startAutoSync(_store!.scope);
    }
  }


  Future<void> switchStore(String storeId) async {
    final store = _requireStore();
    final login = _requireOrganisationLogin();
    final deviceRegistration = _requireDeviceRegistration();

    _store = await store.switchAccessibleStore(
      login: login,
      storeId: storeId,
      deviceRegistration: deviceRegistration,
    );

    if (_store!.sync.autoSyncEnabled && !_store!.sync.isAutoSyncRunning) {
      _store!.sync.startAutoSync(_store!.scope);
    }
  }

  Future<StoreRoleAccess?> currentStoreAccess() {
    final store = _requireStore();
    return store.auth.currentStoreAccess(store.scope);
  }

  Future<bool> restoreSession() async {
    final store = _requireStore();
    return store.auth.isLoggedIn();
  }

  Future<StoreSession?> currentSession() {
    return _requireStore().auth.currentSession();
  }

  Future<StoreCustomer?> currentCustomer() {
    return _requireStore().auth.currentCustomer();
  }

  Future<List<StoreOrderSummary>> loadOrders() {
    final store = _requireStore();
    return store.orders.listSummaries(store.scope);
  }

  Future<StoreOrderDetails?> loadOrder(int orderId) {
    final store = _requireStore();
    return store.orders.getById(store.scope, orderId);
  }

  Future<int> createWalkInOrder() {
    final store = _requireStore();
    return store.orders.create(
      store.scope,
      StoreCreateOrderRequest(
        restaurantName: store.storeName,
        customerName: 'Walk-in Customer',
        mobile: '+1000000000',
        statusName: 'Pending',
        total: 42.5,
        serviceInstance: store.serviceInstanceId,
        createdBy: 'ui-example',
        createdOn: DateTime.now().toIso8601String(),
        paymentStatus: 'Unpaid',
        orderType: StoreOrderType.dineIn,
        payments: const [
          StoreCreateOrderPaymentRequest(
            paymentMode: StoreOrderPaymentMode.cash,
            amount: 20.0,
            referenceId: 'ui-cash-auto-order',
          ),
        ],
      ),
    );
  }

  Future<void> addOrderPayment(int orderId) {
    final store = _requireStore();
    return store.orders.addPayment(
      store.scope,
      orderId,
      const StoreCreateOrderPaymentRequest(
        paymentMode: StoreOrderPaymentMode.card,
        amount: 22.5,
        referenceId: 'ui-card-auto-order',
      ),
    );
  }

  Future<void> closeOrder(int orderId) {
    final store = _requireStore();
    return store.orders.updateStatus(store.scope, orderId, 'Closed');
  }

  Future<List<String>> loadProductNames() {
    final store = _requireStore();
    return store.products.listNames(store.scope);
  }

  Future<List<StoreProductVariantRecord>> loadProductVariants(int categoryId) {
    final store = _requireStore();
    return store.products.listVariantsByCategory(store.scope, categoryId);
  }

  Future<List<StoreCustomer>> searchCustomers(String query) {
    final store = _requireStore();
    return store.customers.searchDetails(scope: store.scope, nameQuery: query, limit: 20);
  }

  Future<StoreSyncBatchResult> runSyncNow() {
    final store = _requireStore();
    return store.sync.syncOrdersProductsCredits(store.scope);
  }

  Future<void> refreshAccessControl() {
    final store = _requireStore();
    final deviceRegistration = _requireDeviceRegistration();
    return store.sync.refreshAccessControl(
      store.scope,
      deviceRegistration: deviceRegistration,
    );
  }

  Future<StoreSyncBatchResult> runSyncNowWithCallbacks({
    void Function(StoreSyncProgressUpdate update)? onProgress,
    int exportBatchSize = StoreSyncService.defaultExportBatchSize,
  }) {
    final store = _requireStore();
    return store.sync.runConfigured(
      store.scope,
      onProgress: onProgress,
      exportBatchSize: exportBatchSize,
    );
  }

  Future<StoreSyncBatchResult> restoreFromRemote({
    void Function(StoreSyncProgressUpdate update)? onProgress,
  }) {
    final store = _requireStore();
    return store.sync.restoreFromRemote(
      store.scope,
      onProgress: onProgress,
    );
  }

  Future<List<StoreSyncAttemptRecord>> loadSyncHistory() {
    final store = _requireStore();
    return store.sync.history(store.scope, limit: 20);
  }

  Future<void> logout() async {
    final store = _requireStore();
    await store.auth.logout();
  }

  Future<void> dispose() async {
    await _store?.close();
    _store = null;
  }

  StoreConfig _requireConfig() {
    final config = _config;
    if (config == null) {
      throw StateError('Controller is not booted. Call boot() first.');
    }
    return config;
  }

  StoreOrganisationLoginResult _requireOrganisationLogin() {
    final login = _organisationLogin;
    if (login == null) {
      throw StateError('Organisation login is required before selecting a store.');
    }
    return login;
  }

  StoreOrganisation _requireOrganisation() {
    final organisation = _organisation;
    if (organisation == null) {
      throw StateError('Organisation must be resolved before registering the device.');
    }
    return organisation;
  }

  StoreDeviceRegistrationRequest _requireDeviceRegistration() {
    final deviceRegistration = _deviceRegistration;
    if (deviceRegistration == null) {
      throw StateError('Register the device before selecting a store.');
    }
    return deviceRegistration;
  }

  Store _requireStore() {
    final store = _store;
    if (store == null) {
      throw StateError('Store is not initialized. Call boot() first.');
    }
    return store;
  }
}
