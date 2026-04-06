import 'package:equatable/equatable.dart';

class WelcomeState extends Equatable {
  final String organizationName;
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const WelcomeState({
    this.organizationName = '',
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  bool get isValid => organizationName.trim().isNotEmpty;

  WelcomeState copyWith({
    String? organizationName,
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
    bool clearError = false,
  }) {
    return WelcomeState(
      organizationName: organizationName ?? this.organizationName,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [organizationName, isLoading, errorMessage, isSuccess];
}
