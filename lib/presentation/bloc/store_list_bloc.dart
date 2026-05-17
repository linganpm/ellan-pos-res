import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../data/models/store_model.dart';
import '../../data/repository/store_repository.dart';
import 'store_list_event.dart';
import 'store_list_state.dart';

/// Bloc responsible for loading, searching, selecting and verifying stores
class StoreListBloc extends Bloc<StoreListEvent, StoreListState> {
  final IStoreRepository repository;
  late List<StoreModel> _allStores;

  StoreListBloc({required this.repository}) : super(StoreListInitial()) {
    _allStores = [];

    on<LoadStoresEvent>(_onLoad);
    on<SearchStoresEvent>(_onSearch);
    on<SelectStoreEvent>(_onSelect);
    on<VerifyStoreEvent>(_onVerify);
  }

  Future<void> _onLoad(LoadStoresEvent event, Emitter<StoreListState> emit) async {
    emit(StoreListLoading());
    try {
      _allStores = await repository.getAvailableStores();
      emit(StoreListLoaded(stores: _allStores, filtered: _allStores, selected: null));
    } catch (e, st) {
      // Return empty list on failure with failure message
      emit(StoreVerificationFailure(message: 'Failed to load stores', stores: const [], filtered: const [], selected: null));
    }
  }

  Future<void> _onSearch(SearchStoresEvent event, Emitter<StoreListState> emit) async {
    final query = event.query.trim().toLowerCase();
    final filtered = query.isEmpty
        ? List<StoreModel>.from(_allStores)
        : _allStores.where((s) => s.storeName.toLowerCase().contains(query) || s.storeId.contains(query) || s.storeRole.toLowerCase().contains(query)).toList();

    // If currently a loaded state with selection, preserve it
    final currentSelected = state is StoreListLoaded ? (state as StoreListLoaded).selected : (state is StoreSelectionChanged ? (state as StoreSelectionChanged).selected : null);

    emit(StoreListLoaded(stores: _allStores, filtered: filtered, selected: currentSelected));
  }

  Future<void> _onSelect(SelectStoreEvent event, Emitter<StoreListState> emit) async {
    final StoreModel selected = event.store;
    final filtered = state is StoreListLoaded ? (state as StoreListLoaded).filtered : _allStores;
    emit(StoreSelectionChanged(stores: _allStores, filtered: filtered, selected: selected));
  }

  Future<void> _onVerify(VerifyStoreEvent event, Emitter<StoreListState> emit) async {
    emit(StoreVerificationLoading());
    try {
      final ok = await repository.verifyStore(event.store.storeId);
      if (ok) {
        emit(StoreVerificationSuccess(event.store));
      } else {
        final filtered = state is StoreListLoaded ? (state as StoreListLoaded).filtered : _allStores;
        final selected = event.store;
        emit(StoreVerificationFailure(message: 'Store verification failed', stores: _allStores, filtered: filtered, selected: selected));
      }
    } catch (e) {
      final filtered = state is StoreListLoaded ? (state as StoreListLoaded).filtered : _allStores;
      final selected = event.store;
      emit(StoreVerificationFailure(message: e.toString(), stores: _allStores, filtered: filtered, selected: selected));
    }
  }
}
