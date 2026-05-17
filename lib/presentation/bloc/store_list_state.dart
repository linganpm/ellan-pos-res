import 'package:equatable/equatable.dart';
import '../../data/models/store_model.dart';

/// States emitted by StoreListBloc
abstract class StoreListState extends Equatable {
  const StoreListState();

  @override
  List<Object?> get props => [];
}

class StoreListInitial extends StoreListState {}

class StoreListLoading extends StoreListState {}

class StoreListLoaded extends StoreListState {
  final List<StoreModel> stores;
  final List<StoreModel> filtered;
  final StoreModel? selected;

  const StoreListLoaded({required this.stores, required this.filtered, this.selected});

  @override
  List<Object?> get props => [stores, filtered, selected];
}

class StoreSelectionChanged extends StoreListState {
  final List<StoreModel> stores;
  final List<StoreModel> filtered;
  final StoreModel selected;

  const StoreSelectionChanged({required this.stores, required this.filtered, required this.selected});

  @override
  List<Object?> get props => [stores, filtered, selected];
}

class StoreVerificationLoading extends StoreListState {}

class StoreVerificationSuccess extends StoreListState {
  final StoreModel store;
  const StoreVerificationSuccess(this.store);

  @override
  List<Object?> get props => [store];
}

class StoreVerificationFailure extends StoreListState {
  final String message;
  final List<StoreModel> stores;
  final List<StoreModel> filtered;
  final StoreModel? selected;

  const StoreVerificationFailure({required this.message, required this.stores, required this.filtered, this.selected});

  @override
  List<Object?> get props => [message, stores, filtered, selected];
}
