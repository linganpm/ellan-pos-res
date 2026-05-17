import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/store_model.dart';
import '../../data/repository/store_repository.dart';
import 'package:pos_tablet/core/di/service_locator.dart';
import 'store_list_event.dart';
import 'store_list_state.dart';

/// BLoC for managing store list and selection state
/// 
/// Handles loading stores, selecting a store, searching stores,
/// and verifying store selection before proceeding.
class StoreListBloc extends Bloc<StoreListEvent, StoreListState> {
  late final IStoreRepository repository;

  // Holds the list of all available stores
  List<StoreModel> _allStores = [];

  // Holds the currently selected store ID
  String? _selectedStoreId;

  StoreListBloc() : super(const StoreListInitial()) {
    // Access repository from the global service locator
    repository = getIt<StoreRepository>();
    // Register event handlers
    on<LoadStoresEvent>(_onLoadStores);
    on<SelectStoreEvent>(_onSelectStore);
    on<VerifyStoreEvent>(_onVerifyStore);
    on<SearchStoresEvent>(_onSearchStores);
  }

  /// Handles LoadStoresEvent
  /// 
  /// Fetches the list of available stores from the repository
  Future<void> _onLoadStores(
    LoadStoresEvent event,
    Emitter<StoreListState> emit,
  ) async {
    emit(const StoreListLoading());

    try {

      // Fetch stores from repository
      _allStores = await repository.getAvailableStores();

      if (_allStores.isEmpty) {
        emit(const StoreListError(
          errorMessage: 'No stores available. Please contact support.',
        ));
        return;
      }

      // Emit loaded state with all stores
      emit(StoreListLoaded(
        stores: _allStores,
        selectedStoreId: _selectedStoreId,
      ));
    } catch (e) {
      emit(StoreListError(
        errorMessage: 'Failed to load stores: ${e.toString()}',
      ));
    }
  }

  /// Handles SelectStoreEvent
  /// 
  /// Updates the selected store and emits the new state
  Future<void> _onSelectStore(
    SelectStoreEvent event,
    Emitter<StoreListState> emit,
  ) async {
    _selectedStoreId = event.storeId;

    // Find the selected store from the list
    final selectedStore = _allStores.firstWhere(
      (store) => store.storeId == event.storeId,
      orElse: () => const StoreModel(
        storeId: '',
        storeName: '',
        storeRole: '',
      ),
    );

    if (selectedStore.storeId.isEmpty) {
      emit(const StoreListError(
        errorMessage: 'Selected store not found',
      ));
      return;
    }

    // Emit the selection changed state
    if (state is StoreListLoaded) {
      final currentState = state as StoreListLoaded;
      emit(StoreListLoaded(
        stores: currentState.stores,
        selectedStoreId: _selectedStoreId,
        filteredStores: currentState.filteredStores,
      ));
    } else {
      emit(StoreListLoaded(
        stores: _allStores,
        selectedStoreId: _selectedStoreId,
      ));
    }

    emit(StoreSelectionChanged(
      selectedStore: selectedStore,
      allStores: _allStores,
    ));
  }

  /// Handles VerifyStoreEvent
  /// 
  /// Verifies the selected store with the backend
  Future<void> _onVerifyStore(
    VerifyStoreEvent event,
    Emitter<StoreListState> emit,
  ) async {
    // Check if a store is selected
    if (_selectedStoreId == null || _selectedStoreId!.isEmpty) {
      emit(const StoreListError(
        errorMessage: 'Please select a store first',
      ));
      return;
    }

    // Find the selected store
    final selectedStore = _allStores.firstWhere(
      (store) => store.storeId == _selectedStoreId,
      orElse: () => const StoreModel(
        storeId: '',
        storeName: '',
        storeRole: '',
      ),
    );

    if (selectedStore.storeId.isEmpty) {
      emit(const StoreListError(
        errorMessage: 'Selected store not found',
      ));
      return;
    }

    // Emit loading state during verification
    emit(StoreVerificationLoading(store: selectedStore));

    try {
      // Call repository to verify the store
      final isVerified = await repository.verifyStore(_selectedStoreId!);

      if (isVerified) {
        // Emit success state
        emit(StoreVerificationSuccess(store: selectedStore));
      } else {
        emit(StoreVerificationFailure(
          errorMessage: 'Store verification failed. Please try again.',
          store: selectedStore,
        ));
      }
    } catch (e) {
      emit(StoreVerificationFailure(
        errorMessage: 'Failed to verify store: ${e.toString()}',
        store: selectedStore,
      ));
    }
  }

  /// Handles SearchStoresEvent
  /// 
  /// Filters the store list based on search query
  Future<void> _onSearchStores(
    SearchStoresEvent event,
    Emitter<StoreListState> emit,
  ) async {
    if (state is! StoreListLoaded) {
      return;
    }

    final currentState = state as StoreListLoaded;

    if (event.query.isEmpty) {
      // If query is empty, show all stores
      emit(StoreListLoaded(
        stores: currentState.stores,
        selectedStoreId: currentState.selectedStoreId,
      ));
    } else {
      // Filter stores by name or ID
      final filteredStores = _allStores
          .where((store) =>
              store.storeName.toLowerCase().contains(event.query.toLowerCase()) ||
              store.storeId.toLowerCase().contains(event.query.toLowerCase()))
          .toList();

      emit(StoreListLoaded(
        stores: currentState.stores,
        selectedStoreId: currentState.selectedStoreId,
        filteredStores: filteredStores,
      ));
    }
  }
}

