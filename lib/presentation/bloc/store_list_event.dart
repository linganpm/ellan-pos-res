import 'package:equatable/equatable.dart';
import '../../data/models/store_model.dart';

/// Events for StoreListBloc
abstract class StoreListEvent extends Equatable {
  const StoreListEvent();

  @override
  List<Object?> get props => [];
}

/// Trigger loading of stores
class LoadStoresEvent extends StoreListEvent {}

/// Triggered when user types in search box
class SearchStoresEvent extends StoreListEvent {
  final String query;
  const SearchStoresEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Triggered when a store is selected
class SelectStoreEvent extends StoreListEvent {
  final StoreModel store;
  const SelectStoreEvent(this.store);

  @override
  List<Object?> get props => [store];
}

/// Trigger verification (submit) of selected store
class VerifyStoreEvent extends StoreListEvent {
  final StoreModel store;
  const VerifyStoreEvent(this.store);

  @override
  List<Object?> get props => [store];
}
