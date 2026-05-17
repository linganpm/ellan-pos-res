import 'package:pos_orders_offline/store_config.dart';
import 'package:pos_orders_offline/store_models.dart';
import 'package:pos_tablet/core/constants/discovery_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos_tablet/core/controllers/ui_store_controller.dart';
import '../../domain/repositories/store_repository.dart';

/// Concrete repository implementation that delegates to the existing
/// UiStoreController. This adapts the controller to the repository interface
/// used by the domain and presentation layers.
class StoreRepositoryImpl implements StoreRepository {
  final UiStoreController controller;
  final SharedPreferences prefs;

  StoreRepositoryImpl(this.controller, this.prefs);

  @override
  Future<StoreOrganisation?> resolveOrganisation(String orgCode) {
    return controller.resolveOrganisation(orgCode);
  }

  @override
  Future<StoreConfig> loadRemoteConfig(String orgCode) {
    return StoreConfig.loadRemoteForOrganisation(orgCode: orgCode, lookupUrl: kDiscoveryUrl);
  }

  @override
  Future<void> bootWithConfig(StoreConfig config) {
    return controller.bootWithConfig(config);
  }

  @override
  Future<bool> login({required String orgCode, required String email, required String password}) {
    return controller.loginToOrganisation(orgCode: orgCode, email: email, password: password);
  }

  @override
  List<StoreAccessibleStore> accessibleStores() {
    return controller.accessibleStores();
  }
}
