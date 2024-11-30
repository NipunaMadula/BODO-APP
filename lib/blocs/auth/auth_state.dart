import 'package:bodo_app/models/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserModel user;
  AuthSuccess({required this.user});
}

class AuthError extends AuthState {
  final String error;
  AuthError(this.error);
}

class AuthenticatedState extends AuthState {
  final UserModel user;
  AuthenticatedState(this.user);
}

class UnauthenticatedState extends AuthState {}