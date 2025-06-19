import 'package:expense_management/models/response.dart';

sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthShowSignInScreen extends AuthState {}

final class AuthShowSignInScreenError extends AuthState {
  final Response response;

  AuthShowSignInScreenError(this.response);
}

final class AuthShowSignUpScreen extends AuthState {}

final class AuthShowSignUpScreenError extends AuthState {
  final Response response;

  AuthShowSignUpScreenError(this.response);
}

final class AuthShowVerifyAccountScreen extends AuthState {}

final class AuthShowHomeScreen extends AuthState {}
