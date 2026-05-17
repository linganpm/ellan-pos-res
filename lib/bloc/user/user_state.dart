import 'package:equatable/equatable.dart';
import 'package:pos_orders_offline/store_config.dart';

/// Abstract base class for all user states.
/// Extends Equatable for value comparison and immutability.
abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the UserBloc is first created.
class UserInitial extends UserState {}

/// State indicating that user initialization is in progress.
class UserLoading extends UserState {}

/// State indicating successful user initialization with the loaded configuration.
class UserLoaded extends UserState {
  final String storeId;

  const UserLoaded(this.storeId);

  @override
  List<Object?> get props => [storeId];
}

/// State indicating an error occurred during user initialization.
class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}
