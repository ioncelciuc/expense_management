sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthCompleted extends AuthState {}

final class AuthFailed extends AuthState {}
